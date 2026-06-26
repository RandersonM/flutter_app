import 'package:flutter/cupertino.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/services/gemma/gemma_service_status.dart';
import 'package:opfan/core/services/gemma/i_gemma_service.dart';
import 'package:opfan/core/services/rag/i_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_executor.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';

import 'i_vegapunk_chat_repository.dart';

/// Orchestrates the function calling loop between Gemma and external tools.
///
/// Flow:
///   1. RAG context is fetched in parallel.
///   2. Gemma generates a response.
///   3. [FunctionExecutor] scans the accumulated output for a tool call JSON.
///   4. If found → tool is executed via [FunctionRegistry] → result injected
///      back as [SEARCH RESULTS] context → Gemma generates the final response.
///   5. All tokens (both RAG pass and final pass) are yielded to the UI.
class VegapunkChatRepository implements IVegapunkChatRepository {
  VegapunkChatRepository({
    IGemmaService? gemmaService,
    IRAGService? ragService,
    FunctionRegistry? functionRegistry,
    FunctionExecutor? functionExecutor,
  })  : _gemma = gemmaService ?? getIt<IGemmaService>(),
        _rag = ragService ?? getIt<IRAGService>(),
        _registry = functionRegistry ?? getIt<FunctionRegistry>(),
        _executor = functionExecutor ?? getIt<FunctionExecutor>();

  final IGemmaService _gemma;
  final IRAGService _rag;
  final FunctionRegistry _registry;
  final FunctionExecutor _executor;

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
  /// Yields [SearchingWebEvent] as a sentinel token so the cubit can show
  /// a "Searching…" indicator without coupling the repository to UI state.
  Stream<String> _sendWithFunctionCalling(
    String text, {
    String? styleInstruction,
  }) async* {
    // ── Step 1: RAG context ──────────────────────────────────────────────────
    final ragDocs = await _rag.search(text, topK: 2);
    final ragContext = ragDocs.isEmpty ? null : ragDocs;

    // ── Step 2: First Gemma pass ─────────────────────────────────────────────
    final buffer = StringBuffer();
    bool functionCallDetected = false;

    await for (final token in _gemma.sendMessage(
      text,
      styleInstruction: styleInstruction,
      ragContext: ragContext,
    )) {
      buffer.write(token);

      // Try parsing a function call as soon as we have enough text.
      if (!functionCallDetected && buffer.length > 10) {
        final call = _executor.tryParse(buffer.toString());
        if (call != null && _registry.has(call.name)) {
          functionCallDetected = true;
          debugPrint(
              'VegapunkChatRepository: function call detected — ${call.name}');

          // Yield a sentinel so the cubit can flip isSearchingWeb = true.
          yield _searchingWebSentinel;

          // ── Step 3: Execute the tool ───────────────────────────────────────
          final result = await _registry.execute(call);

          debugPrint(
              'VegapunkChatRepository: tool result (isError=${result.isError})');

          // ── Step 4: Second Gemma pass with tool result ─────────────────────
          final argsStr = call.arguments.entries.map((e) => '${e.key}="${e.value}"').join(', ');
          final toolContext = '[SEARCH RESULTS for "${call.name}($argsStr)"]\n'
              '${result.content}\n'
              '[END SEARCH RESULTS]';

          // Yield end-of-search sentinel before streaming final response.
          yield _searchingDoneSentinel;

          await for (final finalToken in _gemma.sendMessage(
            text,
            styleInstruction: styleInstruction,
            ragContext: [
              if (ragContext != null) ...ragContext,
              toolContext,
            ],
          )) {
            yield finalToken;
          }

          return; // Function call flow complete.
        }
      }
    }

    // ── Step 5: Normal response (no function call) ────────────────────────────
    if (!functionCallDetected) {
      // Stream the buffered tokens to the UI.
      final fullText = buffer.toString();
      if (fullText.isNotEmpty) {
        yield fullText;
      }
    }
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
