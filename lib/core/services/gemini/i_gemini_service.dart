abstract class IGeminiService {
  Future<String?> generateText({
    required String prompt,
    String? systemInstruction,
    String? context,
    Map<String, dynamic>? parameters,
  });

  Future<String?> generateImage({
    required String prompt,
    bool forceRefresh = false,
  });

  void clearCache();

  Map<String, dynamic> getServiceStatus();
}
