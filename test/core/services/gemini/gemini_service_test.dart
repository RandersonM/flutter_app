import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/gemini/gemini_service.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockResult extends Mock implements HttpsCallableResult<Object?> {}

void main() {
  late _MockFunctions functions;
  late _MockCallable textCallable;
  late _MockCallable imageCallable;

  setUpAll(() => registerFallbackValue(HttpsCallableOptions()));

  setUp(() {
    functions = _MockFunctions();
    textCallable = _MockCallable();
    imageCallable = _MockCallable();
    when(
      () => functions.httpsCallable(
        'geminiGenerateText',
        options: any(named: 'options'),
      ),
    ).thenReturn(textCallable);
    when(
      () => functions.httpsCallable(
        'geminiGenerateImage',
        options: any(named: 'options'),
      ),
    ).thenReturn(imageCallable);
  });

  void returns(_MockCallable callable, Map<String, Object?> data) {
    final result = _MockResult();
    when(() => result.data).thenReturn(data);
    when(() => callable.call<Object?>(any())).thenAnswer((_) async => result);
  }

  group('GeminiService behaviour', () {
    test('sends the prompt with its context and returns the text', () async {
      returns(textCallable, {'text': 'Use a hot pan.'});

      final text = await GeminiService(
        functions: functions,
      ).generateText(prompt: 'Cook rice', context: 'Sanji', temperature: 0.2);

      expect(text, 'Use a hot pan.');
      final payload =
          verify(() => textCallable.call<Object?>(captureAny())).captured.single
              as Map;
      expect(payload['prompt'], 'Context: Sanji\n\nCook rice');
      expect(payload['temperature'], 0.2);
      expect(payload.containsKey('topK'), isFalse);
    });

    test('returns null and pauses after the daily quota is hit', () async {
      when(() => textCallable.call<Object?>(any())).thenThrow(
        FirebaseFunctionsException(
          code: 'resource-exhausted',
          message: 'Daily text limit reached',
        ),
      );
      final service = GeminiService(functions: functions);

      expect(await service.generateText(prompt: 'a'), isNull);
      expect(await service.generateText(prompt: 'b'), isNull);

      verify(() => textCallable.call<Object?>(any())).called(1);
    });

    test('returns null when the caller is not signed in', () async {
      when(() => textCallable.call<Object?>(any())).thenThrow(
        FirebaseFunctionsException(code: 'unauthenticated', message: 'no'),
      );

      expect(
        await GeminiService(functions: functions).generateText(prompt: 'a'),
        isNull,
      );
    });

    test('reuses a generated image url for the same prompt', () async {
      returns(imageCallable, {'url': 'https://i.imgur.com/x.png'});
      final service = GeminiService(functions: functions);

      expect(
        await service.generateImage(prompt: 'Luffy'),
        'https://i.imgur.com/x.png',
      );
      expect(
        await service.generateImage(prompt: 'Luffy'),
        'https://i.imgur.com/x.png',
      );

      verify(() => imageCallable.call<Object?>(any())).called(1);
    });
  });
}
