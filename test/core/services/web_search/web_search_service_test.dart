import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/config/environment_service.dart';
import 'package:opfan/core/services/web_search/web_search_service.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('WebSearchService behaviour', () {
    test('maps results and attaches the answer to the first one', () {
      final results = WebSearchService.resultsFromResponse({
        'answer': 'Chapter 1100 is out.',
        'results': [
          {'title': 'A', 'url': 'https://a', 'content': 'first', 'score': 0.9},
          {'title': 'B', 'url': 'https://b', 'content': '', 'score': 0.5},
          {'title': 'C', 'url': 'https://c', 'content': 'third', 'score': 0.4},
        ],
      });

      expect(results.map((r) => r.title), ['A', 'C']);
      expect(results.first.answer, 'Chapter 1100 is out.');
      expect(results.last.answer, isNull);
    });

    test('does not call Tavily without a key', () async {
      final dio = _MockDio();
      final service = WebSearchService(
        env: EnvironmentService(values: const {}),
        dio: dio,
      );

      expect(service.isConfigured, isFalse);
      expect(await service.search('One Piece'), isEmpty);
      verifyZeroInteractions(dio);
    });
  });
}
