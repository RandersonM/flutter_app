import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/config/environment_service.dart';

void main() {
  final env = EnvironmentService();

  group('EnvironmentService with missing optional keys', () {
    setUp(() => dotenv.testLoad(fileInput: ''));

    test('returns empty API keys instead of throwing at startup', () {
      expect(env.huggingFaceApiKey, isEmpty);
      expect(env.gemmaModelUrl, isEmpty);
      expect(env.youtubeApiKey, isEmpty);
      expect(env.tavilyApiKey, isEmpty);
    });

    test('falls back to the declared defaults', () {
      expect(env.geminiApiKey, 'dev_mode');
      expect(env.gemmaModelName, 'gemma3_1b_it.litertlm');
      expect(env.networkTimeout, 30000);
    });
  });

  test('returns configured values when present', () {
    dotenv.testLoad(
      fileInput: 'TAVILY_API_KEY=abc\nGEMMA_MODEL_NAME=e2b.litertlm',
    );

    expect(env.tavilyApiKey, 'abc');
    expect(env.gemmaModelName, 'e2b.litertlm');
  });
}
