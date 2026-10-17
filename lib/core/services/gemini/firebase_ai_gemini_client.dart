import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:opfan/core/errors/app_exceptions.dart';

import 'i_gemini_client.dart';

/// Gemini through Firebase AI Logic (Gemini Developer API), which works on the
/// no-cost Spark plan: the API key stays in the Firebase project, never in the
/// app, and calls carry an App Check token.
class FirebaseAiGeminiClient implements IGeminiClient {
  FirebaseAiGeminiClient({required this._ai});

  final FirebaseAI _ai;

  @override
  Future<String?> generateText({
    required String model,
    required String prompt,
    String? systemInstruction,
    double? temperature,
    int? topK,
    double? topP,
    int? maxOutputTokens,
  }) async {
    final response = await _generate(
      _ai.generativeModel(
        model: model,
        systemInstruction: systemInstruction == null
            ? null
            : Content.system(systemInstruction),
        generationConfig: GenerationConfig(
          temperature: temperature,
          topK: topK,
          topP: topP,
          maxOutputTokens: maxOutputTokens,
        ),
      ),
      prompt,
    );
    return response.text;
  }

  @override
  Future<Uint8List?> generateImage({
    required String model,
    required String prompt,
  }) async {
    final response = await _generate(
      _ai.generativeModel(
        model: model,
        generationConfig: GenerationConfig(
          responseModalities: [ResponseModalities.image],
        ),
      ),
      prompt,
    );
    for (final part in response.inlineDataParts) {
      if (part.mimeType.startsWith('image/')) return part.bytes;
    }
    return null;
  }

  Future<GenerateContentResponse> _generate(
    GenerativeModel model,
    String prompt,
  ) async {
    try {
      return await model.generateContent([Content.text(prompt)]);
    } on FirebaseAIException catch (e) {
      // The plugin's own QuotaExceeded type is not exported; it is the error
      // whose message mentions the quota.
      if (e.message.toLowerCase().contains('quota')) {
        throw const QuotaExceededException();
      }
      rethrow;
    }
  }
}
