import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'i_environment_service.dart';

class EnvironmentService implements IEnvironmentService {
  static EnvironmentService? _instance;
  static EnvironmentService get instance {
    _instance ??= EnvironmentService();
    return _instance!;
  }

  

  

  @override
  Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  @override
  String get youtubeApiKey => _getString('YOUTUBE_API_KEY');

  @override
  String get youtubeBaseUrl =>
      _getString('YOUTUBE_BASE_URL', 'https://www.googleapis.com/youtube/v3');

  @override
  String get onepieceApiUrl =>
      _getString('ONEPIECE_API_URL', 'https://api.api-onepiece.com/v2/');

  @override
  String get devilFruitApiUrl => _getString(
      'DEVIL_FRUIT_API_URL', 'https://api.api-onepiece.com/v2/fruits/en');

  @override
  String get geminiApiKey => _getString('GEMINI_API_KEY', 'dev_mode');

  @override
  String get huggingFaceApiKey => _getString('HUGGING_FACE_API_KEY', '');

  @override
  String get gemmaModelUrl => _getString('GEMMA_MODEL_URL', '');

  @override
  String get gemmaModelName =>
      _getString('GEMMA_MODEL_NAME', 'gemma3_1b_it.litertlm');

  @override
  String get tavilyApiKey => _getString('TAVILY_API_KEY', '');

  @override
  String get appName => _getString('APP_NAME', 'One Piece Simple App');

  @override
  String get appVersion => _getString('APP_VERSION', '1.0.1');

  @override
  bool get debugMode => _getBool('DEBUG_MODE', true);

  // === Configurações de Rede ===

  @override
  int get networkTimeout => _getInt('NETWORK_TIMEOUT', 30000);

  @override
  int get retryCount => _getInt('RETRY_COUNT', 3);

  @override
  int get cacheExpiryTime => _getInt('CACHE_EXPIRY_TIME', 3600000);

  String _getString(String key, [String defaultValue = '']) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      if (defaultValue.isEmpty) {
        throw Exception('Environment variable $key is required but not set');
      }
      return defaultValue;
    }
    return value;
  }

  bool _getBool(String key, [bool defaultValue = false]) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return defaultValue;
    }
    return value.toLowerCase() == 'true';
  }

  int _getInt(String key, [int defaultValue = 0]) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return defaultValue;
    }
    return int.tryParse(value) ?? defaultValue;
  }

  @override
  bool hasKey(String key) {
    return dotenv.env.containsKey(key);
  }

  @override
  String? getRawValue(String key) {
    return dotenv.env[key];
  }

  @override
  List<String> getAllKeys() {
    return dotenv.env.keys.toList();
  }

  @override
  bool validateRequiredVariables() {
    final requiredKeys = [
      'YOUTUBE_API_KEY',
      'ONEPIECE_API_URL',
    ];

    for (final key in requiredKeys) {
      if (!hasKey(key) || getRawValue(key)?.isEmpty == true) {
        return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> getConfigSummary() {
    return {
      'app_name': appName,
      'app_version': appVersion,
      'debug_mode': debugMode,
      'youtube_api_configured': youtubeApiKey.isNotEmpty,
      'gemini_api_configured':
          geminiApiKey.isNotEmpty && geminiApiKey != 'dev_mode',
      'onepiece_api_url': onepieceApiUrl,
      'network_timeout': networkTimeout,
      'retry_count': retryCount,
      'cache_expiry_time': cacheExpiryTime,
    };
  }
}
