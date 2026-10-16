import 'package:flutter/cupertino.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:opfan/core/services/gemma/gemma_service_status.dart';
import 'package:opfan/core/services/gemma/i_gemma_service.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_executor.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/features/vegapunk_chat/tools/tool_intent_detector.dart';

import 'i_vegapunk_chat_repository.dart';

/// Orchestrates the function calling loop between Gemma and external tools.
///
/// **Architecture (Gemma 4 Native Function Calling):**
///
///   1. [ToolIntentDetector] checks if the user message has obvious tool intent.
///   2. If high-confidence intent → tool is executed directly, result injected
///      as context, and Gemma generates the final response.
///   3. If no pre-detected intent → Gemma generates normally.
///   4. The SDK's native function calling may yield [FunctionCallResponse]
///      in the stream → tool is executed → result sent back via
///      [Message.toolResponse] → Gemma generates the final answer.
///   5. [FunctionExecutor] is kept as fallback for text-based tool call
///      detection in case the SDK path misses it.
class VegapunkChatRepository implements IVegapunkChatRepository {
  VegapunkChatRepository({
    required IGemmaService gemmaService,
    required IRAGService ragService,
    required FunctionRegistry functionRegistry,
    required FunctionExecutor functionExecutor,
    this._intentDetector = const ToolIntentDetector(),
  }) : _gemma = gemmaService,
       _rag = ragService,
       _registry = functionRegistry,
       _executor = functionExecutor;

  final IGemmaService _gemma;
  final IRAGService _rag;
  final FunctionRegistry _registry;
  final FunctionExecutor _executor;
  final ToolIntentDetector _intentDetector;

  @override
  Stream<GemmaServiceStatus> get modelStatusStream => _gemma.statusStream;

  @override
  GemmaServiceStatus get currentModelStatus => _gemma.currentStatus;

  @override
  Future<void> initializeModel({bool isThinkingMode = false}) =>
      _gemma.initialize(isThinkingMode: isThinkingMode);

  @override
  Future<void> downloadModel() => _gemma.downloadModel();

  /// Combines lore and session-memory hits into one context list for the
  /// prompt. Each search has its own scope and topK — see
  /// `IRAGService.searchLore`/`searchSession` — so a strong lore match can
  /// no longer crowd out a relevant piece of conversation history, or vice
  /// versa. An empty result from either (or both) is valid: absence of
  /// context is not an error.
  Future<List<String>?> _combinedRagContext(String text) async {
    final lore = await _rag.searchLore(text);
    final session = await _rag.searchSession(text);
    final combined = [...lore, ...session];
    return combined.isEmpty ? null : combined;
  }

  @override
  Stream<String> sendMessage(String text, {String? styleInstruction}) =>
      _sendWithFunctionCalling(text, styleInstruction: styleInstruction);

  /// Main orchestration stream.
  ///
  /// Yields sentinel tokens so the cubit can show UI indicators without
  /// coupling the repository to UI state.
  Stream<String> _sendWithFunctionCalling(
    String text, {
    String? styleInstruction,
  }) async* {
    // ── Step 0: Pre-model intent detection ────────────────────────────────
    final intent = _intentDetector.detect(text);

    if (intent != null &&
        intent.confidence == ToolIntentConfidence.high &&
        _registry.has(intent.toolName)) {
      debugPrint(
        'VegapunkChatRepository: high-confidence intent detected — '
        '${intent.toolName}',
      );

      // Execute the tool directly without asking the model
      yield toolStartSentinel(intent.toolName);

      final toolCall = ToolCall(
        name: intent.toolName,
        arguments: intent.extractedArgs,
      );
      final result = await _registry.execute(toolCall);
      debugPrint(
        'VegapunkChatRepository: pre-model tool result (isError=${result.isError})',
      );

      yield toolDoneSentinel;

      // Inject the result as context and let the model generate a response
      String safeContent = result.content;
      if (safeContent.length > 1500) {
        safeContent = '${safeContent.substring(0, 1500)}\n...[TRUNCATED]';
      }

      final toolContext =
          '[SEARCH RESULTS for "${intent.toolName}"]\n'
          '$safeContent\n'
          '[END SEARCH RESULTS]\n\n'
          'Answer the following question using the search results above:\n'
          '$text';

      final ragContext = await _combinedRagContext(text);

      await for (final response in _gemma.sendMessage(
        toolContext,
        styleInstruction: styleInstruction,
        ragContext: ragContext,
      )) {
        if (response is TextResponse) {
          yield response.token;
        }
        // Ignore any further function calls in this pass
      }
      return;
    }

    // ── Step 1: RAG context ──────────────────────────────────────────────
    final ragContext = await _combinedRagContext(text);

    // ── Step 2: Gemma pass (with native function calling) ────────────────
    final buffer = StringBuffer();
    FunctionCallResponse? nativeFunctionCall;
    ToolCall? textParsedCall;

    await for (final response in _gemma.sendMessage(
      text,
      styleInstruction: styleInstruction,
      ragContext: ragContext,
    )) {
      switch (response) {
        case TextResponse(:final token):
          buffer.write(token);
          yield token;

        case FunctionCallResponse(:final name):
          // Native SDK-detected function call
          nativeFunctionCall = response;
          debugPrint('VegapunkChatRepository: native function call — $name');

        case ParallelFunctionCallResponse(:final calls):
          // Take the first call for now
          if (calls.isNotEmpty) {
            nativeFunctionCall = calls.first;
            debugPrint(
              'VegapunkChatRepository: parallel function call — '
              '${nativeFunctionCall.name}',
            );
          }

        case ThinkingResponse():
          // Ignore thinking tokens
          break;
      }
    }

    // ── Step 3: Handle native function call ───────────────────────────────
    if (nativeFunctionCall != null) {
      yield toolStartSentinel(nativeFunctionCall.name);

      final toolCall = ToolCall(
        name: nativeFunctionCall.name,
        arguments: nativeFunctionCall.args,
      );
      final result = await _registry.execute(toolCall);
      debugPrint(
        'VegapunkChatRepository: native tool result (isError=${result.isError})',
      );

      yield toolDoneSentinel;

      // Send tool result back to the model for the second pass
      // using the native Message.toolResponse API.
      String safeContent = result.content;
      if (safeContent.length > 1500) {
        safeContent = '${safeContent.substring(0, 1500)}\n...[TRUNCATED]';
      }

      await for (final response in _gemma.sendToolResult(
        toolName: nativeFunctionCall.name,
        result: {'result': safeContent},
      )) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
      return;
    }

    // ── Step 4: Text-based fallback detection ────────────────────────────
    // If the SDK didn't detect a function call, try parsing the accumulated
    // text. This catches cases where the model emits JSON but the SDK
    // doesn't parse it (e.g., non-standard format).
    textParsedCall = _executor.tryParse(buffer.toString());

    if (textParsedCall != null && _registry.has(textParsedCall.name)) {
      debugPrint(
        'VegapunkChatRepository: text-fallback function call — '
        '${textParsedCall.name}',
      );

      yield toolStartSentinel(textParsedCall.name);

      final result = await _registry.execute(textParsedCall);
      debugPrint(
        'VegapunkChatRepository: fallback tool result (isError=${result.isError})',
      );

      String safeContent = result.content;
      if (safeContent.length > 1500) {
        safeContent = '${safeContent.substring(0, 1500)}\n...[TRUNCATED]';
      }

      final toolContext =
          '[SEARCH RESULTS for "${textParsedCall.name}"]\n'
          '$safeContent\n'
          '[END SEARCH RESULTS]\n\n'
          'Answer the original question using the results above:\n'
          '$text';

      yield toolDoneSentinel;

      await for (final response in _gemma.sendMessage(
        toolContext,
        styleInstruction: styleInstruction,
        ragContext: ragContext,
      )) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
      return;
    }

    // Step 5: Normal text response — already streamed above!
  }

  // ── Sentinel tokens (not displayed to user) ──────────────────────────────

  /// Emitted into the stream when a tool starts executing. The [toolName] is
  /// embedded so the cubit can extract it and display a specific label.
  static String toolStartSentinel(String toolName) =>
      '\x00TOOL_START:$toolName\x00';

  /// Emitted when a tool finishes (success or error).
  static const toolDoneSentinel = '\x00TOOL_DONE\x00';

  /// Legacy aliases kept for any external code that still references them.
  static String get searchingWebSentinel => toolStartSentinel('searchInternet');
  static String get searchingDoneSentinel => toolDoneSentinel;

  /// Parses a [toolStartSentinel] and returns the embedded tool name,
  /// or null if [token] is not a tool-start sentinel.
  static String? parseToolName(String token) {
    if (token.startsWith('\x00TOOL_START:') && token.endsWith('\x00')) {
      return token.substring('\x00TOOL_START:'.length, token.length - 1);
    }
    return null;
  }

  @override
  Future<void> stopGeneration() => _gemma.stopGeneration();

  @override
  Future<void> resetChat({bool isThinkingMode = false}) =>
      _gemma.resetChat(isThinkingMode: isThinkingMode);

  @override
  void dispose() {
    // GemmaService is a shared singleton; disposing it here would permanently
    // close its StreamController and break subsequent screen visits.
  }
}
