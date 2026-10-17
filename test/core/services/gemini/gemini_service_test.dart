import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/core/services/gemini/gemini_service.dart';
import 'package:opfan/core/services/gemini/i_gemini_client.dart';
import 'package:opfan/core/services/image_host/i_image_host_service.dart';

class _MockClient extends Mock implements IGeminiClient {}

class _MockImageHost extends Mock implements IImageHostService {}

void main() {
  late _MockClient client;
  late _MockImageHost imageHost;
  final png = Uint8List.fromList([1, 2, 3]);

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    client = _MockClient();
    imageHost = _MockImageHost();
  });

  GeminiService build() => GeminiService(client: client, imageHost: imageHost);

  void textReturns(Future<String?> Function() answer) => when(
    () => client.generateText(
      model: any(named: 'model'),
      prompt: any(named: 'prompt'),
      systemInstruction: any(named: 'systemInstruction'),
      temperature: any(named: 'temperature'),
      topK: any(named: 'topK'),
      topP: any(named: 'topP'),
      maxOutputTokens: any(named: 'maxOutputTokens'),
    ),
  ).thenAnswer((_) => answer());

  group('GeminiService behaviour', () {
    test('prepends the context and fills the default config', () async {
      textReturns(() async => 'Use a hot pan.');

      final text = await build().generateText(
        prompt: 'Cook rice',
        context: 'Sanji',
        systemInstruction: '',
      );

      expect(text, 'Use a hot pan.');
      verify(
        () => client.generateText(
          model: 'gemini-3.5-flash-lite',
          prompt: 'Context: Sanji\n\nCook rice',
          systemInstruction: null,
          temperature: 0.4,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        ),
      ).called(1);
    });

    test('returns null and pauses after the free quota is used up', () async {
      textReturns(() async => throw const QuotaExceededException());
      final service = build();

      expect(await service.generateText(prompt: 'a'), isNull);
      expect(await service.generateText(prompt: 'b'), isNull);

      verify(
        () => client.generateText(
          model: any(named: 'model'),
          prompt: any(named: 'prompt'),
          systemInstruction: any(named: 'systemInstruction'),
          temperature: any(named: 'temperature'),
          topK: any(named: 'topK'),
          topP: any(named: 'topP'),
          maxOutputTokens: any(named: 'maxOutputTokens'),
        ),
      ).called(1);
    });

    test('returns null without retrying when the call fails', () async {
      textReturns(() async => throw Exception('offline'));

      expect(await build().generateText(prompt: 'a'), isNull);
      verify(
        () => client.generateText(
          model: any(named: 'model'),
          prompt: any(named: 'prompt'),
          systemInstruction: any(named: 'systemInstruction'),
          temperature: any(named: 'temperature'),
          topK: any(named: 'topK'),
          topP: any(named: 'topP'),
          maxOutputTokens: any(named: 'maxOutputTokens'),
        ),
      ).called(1);
    });

    test('returns null without retrying when an image fails', () async {
      when(
        () => client.generateImage(
          model: any(named: 'model'),
          prompt: any(named: 'prompt'),
        ),
      ).thenThrow(Exception('offline'));

      expect(await build().generateImage(prompt: 'Luffy'), isNull);
      verify(
        () => client.generateImage(
          model: any(named: 'model'),
          prompt: any(named: 'prompt'),
        ),
      ).called(1);
      verifyNever(() => imageHost.upload(any()));
    });

    test('hosts a generated image and reuses it for the same prompt', () async {
      when(
        () => client.generateImage(
          model: any(named: 'model'),
          prompt: any(named: 'prompt'),
        ),
      ).thenAnswer((_) async => png);
      when(
        () => imageHost.upload(any()),
      ).thenAnswer((_) async => 'https://i.imgur.com/x.png');
      final service = build();

      expect(
        await service.generateImage(prompt: 'Luffy'),
        'https://i.imgur.com/x.png',
      );
      expect(
        await service.generateImage(prompt: 'Luffy'),
        'https://i.imgur.com/x.png',
      );

      verify(() => imageHost.upload(png)).called(1);
    });

    test('returns null when no image comes back', () async {
      when(
        () => client.generateImage(
          model: any(named: 'model'),
          prompt: any(named: 'prompt'),
        ),
      ).thenAnswer((_) async => null);

      expect(await build().generateImage(prompt: 'Luffy'), isNull);
      verifyNever(() => imageHost.upload(any()));
    });
  });
}
