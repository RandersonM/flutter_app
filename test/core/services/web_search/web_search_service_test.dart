import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/web_search/web_search_service.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

void main() {
  setUpAll(() => registerFallbackValue(HttpsCallableOptions()));

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

    test('returns no results when the function refuses the call', () async {
      final functions = _MockFunctions();
      final callable = _MockCallable();
      when(
        () => functions.httpsCallable(
          'webSearch',
          options: any(named: 'options'),
        ),
      ).thenReturn(callable);
      when(() => callable.call<Object?>(any())).thenThrow(
        FirebaseFunctionsException(code: 'unauthenticated', message: 'no'),
      );

      final results = await WebSearchService(
        functions: functions,
      ).search('One Piece');

      expect(results, isEmpty);
    });
  });
}
