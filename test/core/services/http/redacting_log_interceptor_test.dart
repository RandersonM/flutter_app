import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/http/redacting_log_interceptor.dart';

void main() {
  group('redactSecrets behaviour', () {
    test('masks API keys in query parameters', () {
      expect(
        redactSecrets(
          'uri: https://www.googleapis.com/youtube/v3/search?part=snippet&key=AIzaSyC08uAl&q=Luffy',
        ),
        'uri: https://www.googleapis.com/youtube/v3/search?part=snippet&key=***&q=Luffy',
      );
    });

    test('masks secret headers, including two-word values', () {
      expect(
        redactSecrets(' x-goog-api-key: AIzaSy123'),
        ' x-goog-api-key: ***',
      );
      expect(
        redactSecrets(' Authorization: Client-ID 546c25a59c58ad7'),
        ' Authorization: ***',
      );
    });

    test('masks secret fields in a JSON body', () {
      expect(
        redactSecrets('{"api_key": "tvly-abc", "query": "One Piece"}'),
        '{"api_key": "***", "query": "One Piece"}',
      );
    });

    test('leaves ordinary log lines untouched', () {
      const line = 'statusCode: 200 query: Monkey D. Luffy keyword=haki';
      expect(redactSecrets(line), line);
    });
  });
}
