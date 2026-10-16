import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/config/environment_service.dart';

void main() {
  group('EnvironmentService behaviour', () {
    test('returns empty API keys instead of throwing when undefined', () {
      final env = EnvironmentService(values: const {});

      expect(env.huggingFaceApiKey, isEmpty);
      expect(env.gemmaModelUrl, isEmpty);
      expect(env.youtubeApiKey, isEmpty);
    });

    test('falls back to the declared defaults', () {
      final env = EnvironmentService(values: const {'NETWORK_TIMEOUT': 'x'});

      expect(env.gemmaModelName, 'gemma3_1b_it.litertlm');
      expect(env.appName, 'One Piece Simple App');
      expect(env.networkTimeout, 30000);
    });

    test('returns the values defined at build time', () {
      final env = EnvironmentService(
        values: const {
          'GEMMA_MODEL_NAME': 'e2b.litertlm',
          'NETWORK_TIMEOUT': '5000',
        },
      );

      expect(env.gemmaModelName, 'e2b.litertlm');
      expect(env.networkTimeout, 5000);
    });
  });
}
