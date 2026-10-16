import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/config/environment_service.dart';

void main() {
  final service = EnvironmentService();

  group('EnvironmentService behaviour', () {
    test('reads the Imgur client id from the environment', () {
      dotenv.testLoad(fileInput: 'IMGUR_CLIENT_ID=abc123');

      expect(service.imgurClientId, 'abc123');
    });

    test('leaves the Imgur client id empty when the key is missing', () {
      dotenv.testLoad();

      expect(service.imgurClientId, isEmpty);
    });
  });
}
