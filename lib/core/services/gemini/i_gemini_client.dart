import 'dart:typed_data';

/// The calls `GeminiService` makes to Gemini, so it can be tested without the
/// Firebase AI Logic plugin. Throws `QuotaExceededException` when the free
/// tier is used up.
abstract class IGeminiClient {
  Future<String?> generateText({
    required String model,
    required String prompt,
    String? systemInstruction,
    double? temperature,
    int? topK,
    double? topP,
    int? maxOutputTokens,
  });

  /// PNG bytes of the first image in the answer, or null.
  Future<Uint8List?> generateImage({
    required String model,
    required String prompt,
  });
}
