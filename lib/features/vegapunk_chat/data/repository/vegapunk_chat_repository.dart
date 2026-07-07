import 'package:flutter/cupertino.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/services/gemma/gemma_service.dart';
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
    IGemmaService? gemmaService,
    IRAGService? ragService,
    FunctionRegistry? functionRegistry,
    FunctionExecutor? functionExecutor,
    ToolIntentDetector? intentDetector,
  }) : _gemma = gemmaService ?? getIt<IGemmaService>(),
       _rag = ragService ?? getIt<IRAGService>(),
       _registry = functionRegistry ?? getIt<FunctionRegistry>(),
       _executor = functionExecutor ?? getIt<FunctionExecutor>(),
       _intentDetector = intentDetector ?? const ToolIntentDetector();

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
        '${intent.toolName}(${intent.extractedArgs})',
      );

      // Execute the tool directly without asking the model
      yield _searchingWebSentinel;

      final toolCall = ToolCall(
        name: intent.toolName,
        arguments: intent.extractedArgs,
      );
      final result = await _registry.execute(toolCall);
      debugPrint(
        'VegapunkChatRepository: pre-model tool result (isError=${result.isError})',
      );

      yield _searchingDoneSentinel;

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

      final ragDocs = await _rag.search(text, topK: 2);
      final ragContext = ragDocs.isEmpty ? null : ragDocs;

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
    final ragDocs = await _rag.search(text, topK: 2);
    final ragContext = ragDocs.isEmpty ? null : ragDocs;

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

        case FunctionCallResponse(:final name, :final args):
          // Native SDK-detected function call
          nativeFunctionCall = response;
          debugPrint(
            'VegapunkChatRepository: native function call — $name($args)',
          );

        case ParallelFunctionCallResponse(:final calls):
          // Take the first call for now
          if (calls.isNotEmpty) {
            nativeFunctionCall = calls.first;
            debugPrint(
              'VegapunkChatRepository: parallel function call — '
              '${nativeFunctionCall.name}(${nativeFunctionCall.args})',
            );
          }

        case ThinkingResponse():
          // Ignore thinking tokens
          break;
      }
    }

    // ── Step 3: Handle native function call ───────────────────────────────
    if (nativeFunctionCall != null) {
      yield _searchingWebSentinel;

      final toolCall = ToolCall(
        name: nativeFunctionCall.name,
        arguments: nativeFunctionCall.args,
      );
      final result = await _registry.execute(toolCall);
      debugPrint(
        'VegapunkChatRepository: native tool result (isError=${result.isError})',
      );

      yield _searchingDoneSentinel;

      // Send tool result back to the model for the second pass
      // using the native Message.toolResponse API.
      String safeContent = result.content;
      if (safeContent.length > 1500) {
        safeContent = '${safeContent.substring(0, 1500)}\n...[TRUNCATED]';
      }

      if (_gemma is GemmaService) {
        await for (final response in (_gemma).sendToolResult(
          toolName: nativeFunctionCall.name,
          result: {'result': safeContent},
        )) {
          if (response is TextResponse) {
            yield response.token;
          }
        }
      } else {
        // Fallback: re-send as context injection
        final toolContext =
            '[SEARCH RESULTS for "${nativeFunctionCall.name}"]\n'
            '$safeContent\n'
            '[END SEARCH RESULTS]\n\n'
            'Answer the original question using the results above:\n'
            '$text';

        await for (final response in _gemma.sendMessage(
          toolContext,
          styleInstruction: styleInstruction,
          ragContext: ragContext,
        )) {
          if (response is TextResponse) {
            yield response.token;
          }
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

      yield _searchingWebSentinel;

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

      yield _searchingDoneSentinel;

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
  static const searchingWebSentinel = '\x00SEARCHING_WEB\x00';
  static const searchingDoneSentinel = '\x00SEARCHING_DONE\x00';

  static const _searchingWebSentinel = searchingWebSentinel;
  static const _searchingDoneSentinel = searchingDoneSentinel;

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
