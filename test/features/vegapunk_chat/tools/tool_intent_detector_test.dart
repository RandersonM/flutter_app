import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/vegapunk_chat/tools/tool_intent_detector.dart';

void main() {
  const detector = ToolIntentDetector();

  void expectIntent(
    String message, {
    required String tool,
    required ToolIntentConfidence confidence,
    Map<String, dynamic> args = const {},
  }) {
    final result = detector.detect(message);
    expect(result, isNotNull, reason: message);
    expect(result!.toolName, tool, reason: message);
    expect(result.confidence, confidence, reason: message);
    expect(result.extractedArgs, args, reason: message);
  }

  group('ToolIntentDetector high-confidence behaviour', () {
    test('routes explicit english searches and strips the trigger', () {
      expectIntent(
        'Search the web for the latest One Piece chapter',
        tool: 'searchInternet',
        confidence: ToolIntentConfidence.high,
        args: {'query': 'the latest One Piece chapter'},
      );
      expectIntent(
        'search for Oda interviews',
        tool: 'searchInternet',
        confidence: ToolIntentConfidence.high,
        args: {'query': 'Oda interviews'},
      );
    });

    test('routes explicit portuguese searches and strips the trigger', () {
      expectIntent(
        'Pesquise sobre o capítulo 1100',
        tool: 'searchInternet',
        confidence: ToolIntentConfidence.high,
        args: {'query': 'o capítulo 1100'},
      );
      expectIntent(
        'busque na internet o elenco do live action',
        tool: 'searchInternet',
        confidence: ToolIntentConfidence.high,
        args: {'query': 'o elenco do live action'},
      );
    });

    test(
      'keeps the whole message as query when the trigger is all there is',
      () {
        expectIntent(
          'pesquise na internet',
          tool: 'searchInternet',
          confidence: ToolIntentConfidence.high,
          args: {'query': 'pesquise na internet'},
        );
      },
    );

    test('routes profile questions in english and portuguese', () {
      for (final message in [
        'What is my weight?',
        'Show me my profile',
        'qual meu peso?',
        'Quais são meus dados?',
      ]) {
        expectIntent(
          message,
          tool: 'getUserProfile',
          confidence: ToolIntentConfidence.high,
        );
      }
    });

    test('routes workout history questions in english and portuguese', () {
      for (final message in [
        'Show my workout history',
        'how many workouts did I do?',
        'Quantos dias treinei este mês?',
        'mostra meus treinos',
      ]) {
        expectIntent(
          message,
          tool: 'getWorkoutHistory',
          confidence: ToolIntentConfidence.high,
        );
      }
    });

    test('routes workout logging in english and portuguese', () {
      for (final message in [
        'I trained today!',
        'Please log my workout',
        'Treinei hoje, registra aí',
        'pode salvar treino',
      ]) {
        expectIntent(
          message,
          tool: 'saveWorkout',
          confidence: ToolIntentConfidence.high,
        );
      }
    });

    test('lets an explicit search win over other intents in the message', () {
      expectIntent(
        'search for my profile',
        tool: 'searchInternet',
        confidence: ToolIntentConfidence.high,
        args: {'query': 'my profile'},
      );
    });
  });

  group('ToolIntentDetector medium-confidence behaviour', () {
    test('hints the character tool with the extracted name', () {
      expectIntent(
        'Who is Shanks?',
        tool: 'getCharacterInfo',
        confidence: ToolIntentConfidence.medium,
        args: {'characterName': 'shanks'},
      );
      expectIntent(
        'Quem é o Barba Branca?',
        tool: 'getCharacterInfo',
        confidence: ToolIntentConfidence.medium,
        args: {'characterName': 'barba branca'},
      );
    });

    test('hints a web search for current-events topics', () {
      expectIntent(
        'Who won the world cup',
        tool: 'searchInternet',
        confidence: ToolIntentConfidence.medium,
        args: {'query': 'Who won the world cup'},
      );
      expectIntent(
        'qual a cotação do dólar',
        tool: 'searchInternet',
        confidence: ToolIntentConfidence.medium,
        args: {'query': 'qual a cotação do dólar'},
      );
    });
  });

  group('ToolIntentDetector no-intent behaviour', () {
    test('returns no intent for unrelated messages', () {
      for (final message in [
        'Hello Vegapunk!',
        'Olá, tudo bem?',
        'Explain how devil fruits work',
        'Me conte uma piada de pirata',
        'I like to research ancient weapons',
        '',
      ]) {
        expect(detector.detect(message), isNull, reason: message);
      }
    });

    test('returns no intent when a character question has no name', () {
      expect(detector.detect('who is ?'), isNull);
    });
  });
}
