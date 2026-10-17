/// Build-time configuration (`--dart-define-from-file=.env`). The Gemini key is
/// not here: Gemini goes through Firebase AI Logic, which keeps it server-side.
abstract class IEnvironmentService {
  String get youtubeApiKey;
  String get youtubeBaseUrl;
  String get devilFruitApiUrl;
  String get huggingFaceApiKey;
  String get tavilyApiKey;
  String get imgurClientId;
  String get gemmaModelUrl;
  String get gemmaModelName;
  String get appName;
  int get networkTimeout;
}
