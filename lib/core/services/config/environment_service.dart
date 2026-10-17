import 'i_environment_service.dart';

class EnvironmentService implements IEnvironmentService {
  EnvironmentService({this._values = _compiledValues});

  /// Filled at build time by `--dart-define-from-file=.env`, so no config file
  /// ships inside the app. A key that was not defined is an empty string.
  static const _compiledValues = <String, String>{
    'YOUTUBE_API_KEY': String.fromEnvironment('YOUTUBE_API_KEY'),
    'YOUTUBE_BASE_URL': String.fromEnvironment('YOUTUBE_BASE_URL'),
    'DEVIL_FRUIT_API_URL': String.fromEnvironment('DEVIL_FRUIT_API_URL'),
    'HUGGING_FACE_API_KEY': String.fromEnvironment('HUGGING_FACE_API_KEY'),
    'TAVILY_API_KEY': String.fromEnvironment('TAVILY_API_KEY'),
    'IMGUR_CLIENT_ID': String.fromEnvironment('IMGUR_CLIENT_ID'),
    'GEMMA_MODEL_URL': String.fromEnvironment('GEMMA_MODEL_URL'),
    'GEMMA_MODEL_NAME': String.fromEnvironment('GEMMA_MODEL_NAME'),
    'APP_NAME': String.fromEnvironment('APP_NAME'),
    'NETWORK_TIMEOUT': String.fromEnvironment('NETWORK_TIMEOUT'),
  };

  final Map<String, String> _values;

  @override
  String get youtubeApiKey => _string('YOUTUBE_API_KEY');

  @override
  String get youtubeBaseUrl =>
      _string('YOUTUBE_BASE_URL', 'https://www.googleapis.com/youtube/v3');

  @override
  String get devilFruitApiUrl => _string(
    'DEVIL_FRUIT_API_URL',
    'https://api.api-onepiece.com/v2/fruits/en',
  );

  @override
  String get huggingFaceApiKey => _string('HUGGING_FACE_API_KEY');

  @override
  String get tavilyApiKey => _string('TAVILY_API_KEY');

  @override
  String get imgurClientId => _string('IMGUR_CLIENT_ID');

  @override
  String get gemmaModelUrl => _string('GEMMA_MODEL_URL');

  @override
  String get gemmaModelName =>
      _string('GEMMA_MODEL_NAME', 'gemma3_1b_it.litertlm');

  @override
  String get appName => _string('APP_NAME', 'One Piece Simple App');

  @override
  int get networkTimeout => int.tryParse(_string('NETWORK_TIMEOUT')) ?? 30000;

  /// Never throws: a missing key yields [defaultValue] (empty for API keys),
  /// and each service treats an empty key as "not configured" and degrades.
  String _string(String key, [String defaultValue = '']) {
    final value = _values[key];
    return value == null || value.isEmpty ? defaultValue : value;
  }
}
