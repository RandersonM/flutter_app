import 'package:opfan/core/services/gemma/gemma_service_status.dart';

abstract class IVegapunkChatRepository {
  Stream<GemmaServiceStatus> get modelStatusStream;
  GemmaServiceStatus get currentModelStatus;

  Future<void> initializeModel({bool isThinkingMode = false});
  Future<void> downloadModel();

  /// Send a user message; returns a stream of incremental tokens.
  Stream<String> sendMessage(String text, {String? styleInstruction});
  Future<void> stopGeneration();
  Future<void> resetChat({bool isThinkingMode = false});
  void dispose();
}
