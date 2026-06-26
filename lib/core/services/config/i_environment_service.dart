abstract class IEnvironmentService {
  Future<void> initialize();
  
  String get youtubeApiKey;
  String get youtubeBaseUrl;
  String get onepieceApiUrl;
  String get devilFruitApiUrl;
  String get geminiApiKey;
  String get huggingFaceApiKey;
  String get gemmaModelUrl;
  String get gemmaModelName;
  String get tavilyApiKey;
  String get appName;
  String get appVersion;
  bool get debugMode;
  int get networkTimeout;
  int get retryCount;
  int get cacheExpiryTime;
  
  bool hasKey(String key);
  String? getRawValue(String key);
  List<String> getAllKeys();
  bool validateRequiredVariables();
  Map<String, dynamic> getConfigSummary();
}
