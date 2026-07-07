import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

/// Coordinates flutter_gemma's single global embedder + vector store across
/// every RAG-backed feature (Vegapunk chat, Nami finances RAG, …).
///
/// flutter_gemma exposes exactly ONE active vector store at a time
/// (`ServiceRegistry.instance.vectorStoreRepository` is a process-global
/// singleton inside the plugin). Before this coordinator existed, each
/// feature's RAG service called `initializeVectorStore()` independently with
/// its own db path — whichever feature initialized *last* silently
/// re-pointed the shared store at its own file, breaking the other feature's
/// RAG search until the app restarted.
///
/// Every RAG service must call [ensureActive] with its own `owner` id and db
/// file name before touching the vector store. The switch is memoized: it's
/// a no-op as long as the same feature keeps using the store back to back,
/// and only pays the SQLite re-open cost when the active feature changes.
class RagStoreCoordinator {
  RagStoreCoordinator._();

  static const _embedderModelUrl =
      'https://huggingface.co/litert-community/Gecko-110m-en/resolve/main/Gecko_64_quant.tflite';
  static const _embedderTokenizerUrl =
      'https://huggingface.co/litert-community/Gecko-110m-en/resolve/main/sentencepiece.model';

  static Future<EmbeddingModel>? _embedderReady;
  static String? _activeOwner;

  /// Installs AND activates the shared Gecko embedding model, returning the
  /// ready-to-use instance. Safe to call from every RAG service — runs at
  /// most once for the process lifetime; retried on the next call if it
  /// previously failed.
  static Future<EmbeddingModel> ensureEmbedderInstalled() {
    return _embedderReady ??= _installAndActivateEmbedder().catchError((e, st) {
      _embedderReady = null;
      Error.throwWithStackTrace(e, st);
    });
  }

  static Future<EmbeddingModel> _installAndActivateEmbedder() async {
    debugPrint('RagStoreCoordinator: installing embedding model…');
    await FlutterGemma.installEmbedder()
        .modelFromNetwork(_embedderModelUrl)
        .tokenizerFromNetwork(_embedderTokenizerUrl)
        .install();

    // Installing only registers the model spec. flutter_gemma's auto-embed
    // convenience APIs (`addDocument(content:)`, `searchSimilar(query:)` —
    // used by NamiRagService) read a separate plugin-internal
    // `initializedEmbeddingModel` field that is only populated by
    // getActiveEmbedder()/createEmbeddingModel(). Without this call, any RAG
    // service that never explicitly fetches an EmbeddingModel instance
    // itself hits "No embedding model is active", gets caught and
    // swallowed, and silently returns no context.
    return FlutterGemma.getActiveEmbedder();
  }

  /// Points the shared vector store at [owner]'s database file. No-op when
  /// [owner] is already the active store.
  static Future<void> ensureActive(String owner, String dbFileName) async {
    if (_activeOwner == owner) return;
    final appDir = await getApplicationDocumentsDirectory();
    await FlutterGemmaPlugin.instance.initializeVectorStore(
      '${appDir.path}/$dbFileName',
    );
    _activeOwner = owner;
    debugPrint('RagStoreCoordinator: active store switched to "$owner"');
  }
}
