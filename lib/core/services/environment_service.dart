// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentService {
  static EnvironmentService? _instance;

  EnvironmentService._internal();

  static EnvironmentService get instance {
    _instance ??= EnvironmentService._internal();
    return _instance!;
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  String get youtubeApiKey => _getString('YOUTUBE_API_KEY');

  String get youtubeBaseUrl =>
      _getString('YOUTUBE_BASE_URL', 'https://www.googleapis.com/youtube/v3');

  String get charactersApiUrl => _getString(
      'CHARACTERS_API_URL', 'https://api.api-onepiece.com/v2/characters/en');

  String get appName => _getString('APP_NAME', 'One Piece Simple App');

  String get appVersion => _getString('APP_VERSION', '1.0.1');

  bool get debugMode => _getBool('DEBUG_MODE', true);

  // === Configurações de Rede ===

  int get networkTimeout => _getInt('NETWORK_TIMEOUT', 30000);

  int get retryCount => _getInt('RETRY_COUNT', 3);

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

  bool hasKey(String key) {
    return dotenv.env.containsKey(key);
  }

  String? getRawValue(String key) {
    return dotenv.env[key];
  }

  List<String> getAllKeys() {
    return dotenv.env.keys.toList();
  }

  bool validateRequiredVariables() {
    final requiredKeys = [
      'YOUTUBE_API_KEY',
      'CHARACTERS_API_URL',
    ];

    for (final key in requiredKeys) {
      if (!hasKey(key) || getRawValue(key)?.isEmpty == true) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> getConfigSummary() {
    return {
      'app_name': appName,
      'app_version': appVersion,
      'debug_mode': debugMode,
      'youtube_api_configured': youtubeApiKey.isNotEmpty,
      'characters_api_url': charactersApiUrl,
      'network_timeout': networkTimeout,
      'retry_count': retryCount,
      'cache_expiry_time': cacheExpiryTime,
    };
  }
}
