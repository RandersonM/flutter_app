/// Build-time configuration. Secrets the server can keep (Gemini, Tavily,
/// Imgur) are not here: they live as Cloud Functions secrets.
abstract class IEnvironmentService {
  String get youtubeApiKey;
  String get youtubeBaseUrl;
  String get devilFruitApiUrl;
  String get huggingFaceApiKey;
  String get gemmaModelUrl;
  String get gemmaModelName;
  String get appName;
  int get networkTimeout;
}
