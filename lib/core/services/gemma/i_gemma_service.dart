import 'gemma_service_status.dart';

abstract class IGemmaService {
  Stream<GemmaServiceStatus> get statusStream;
  GemmaServiceStatus get currentStatus;

  /// Check if model is on-device and load it; call once at startup.
  Future<void> initialize({bool isThinkingMode = false});

  /// Download the model file, broadcasting progress via [statusStream].
  Future<void> downloadModel();

  /// Load an already-installed model into memory and create a chat session.
  Future<void> loadModel({bool isThinkingMode = false});

  /// Send a user message and return a streaming token response.
  /// [ragContext] is an optional list of relevant facts injected before the query.
  Stream<String> sendMessage(
    String text, {
    String? styleInstruction,
    List<String>? ragContext,
  });

  /// Stop an in-progress generation.
  Future<void> stopGeneration();

  /// Reset the chat history while keeping the model loaded.
  Future<void> resetChat({bool isThinkingMode = false});

  void dispose();
}
