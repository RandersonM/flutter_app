abstract class IGeminiService {
  Future<String?> generateText({
    required String prompt,
    String? systemInstruction,
    String? context,
    double? temperature,
    int? topK,
    double? topP,
    int? maxOutputTokens,
  });

  Future<String?> generateImage({
    required String prompt,
    bool forceRefresh = false,
  });
}
