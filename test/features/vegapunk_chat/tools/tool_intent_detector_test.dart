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

    test('does not log a workout from a negated or hypothetical message', () {
      for (final message in [
        'Não treinei hoje',
        'nao fiz treino hoje',
        'Será que eu treinei hoje?',
        'Se eu treinei hoje, quantas calorias gastei',
        "I didn't train today",
        'I did not finish my workout',
        'If I trained today, should I rest tomorrow',
        'Did I log my workout?',
      ]) {
        expect(
          detector.detect(message)?.toolName,
          isNot('saveWorkout'),
          reason: message,
        );
      }
    });

    test('does not log a workout from other negations or "sem" before it', () {
      for (final message in [
        'nem treinei hoje',
        'Jamais completei meu treino',
        'quase terminei meu treino',
        'treinei hoje não',
        'fiquei sem registrar treino',
        'I never finished my workout',
        'I didn’t log my workout',
        "I couldn't log my workout",
        'I almost finished my workout',
      ]) {
        expect(
          detector.detect(message)?.toolName,
          isNot('saveWorkout'),
          reason: message,
        );
      }
    });

    test('does not log a workout from a question typed without "?"', () {
      for (final message in [
        'quanto tempo treinei hoje',
        'me diz quando treinei hoje',
        'o que eu treinei hoje',
        'how long i trained today',
        'did i log my workout',
      ]) {
        expect(
          detector.detect(message)?.toolName,
          isNot('saveWorkout'),
          reason: message,
        );
      }
    });

    test(
      'still logs a workout when "sem" or a question word sits elsewhere',
      () {
        for (final message in [
          'treinei hoje sem parar',
          'Estou sem tempo, mas treinei hoje',
          'Adivinha o que, treinei hoje',
          'Guess what, I trained today',
          'I went to the gym and I trained today',
        ]) {
          expectIntent(
            message,
            tool: 'saveWorkout',
            confidence: ToolIntentConfidence.high,
          );
        }
      },
    );

    test('logs a workout only when the trigger itself is affirmed', () {
      const table = {
        // Negation or "quase" after the trigger is about something else.
        'Treinei hoje quase 2 horas': true,
        'treinei hoje e nem cansei': true,
        "I trained today, can't feel my legs": true,
        'Treinei hoje, não aguento mais de dor': true,
        // A time clause, not a question.
        'Quando acordei treinei hoje': true,
        'When I woke up I trained today': true,
        // A negation or question in an earlier clause or sentence.
        'Não sei, mas treinei hoje': true,
        'Treinei hoje. Devo descansar amanhã?': true,
        // Abbreviated "não".
        'n treinei hoje': false,
        'ñ treinei hoje': false,
        'naum treinei hoje': false,
        'Nao fiz treino hoje': false,
        'treinei hoje n': false,
        // Questions typed without "?".
        'have i trained today': false,
        'has i trained today': false,
        'me diz quando treinei hoje': false,
        'Treinei hoje?': false,
        // Every mention must be affirmed.
        'Treinei hoje, ou melhor, não treinei hoje': false,
      };

      for (final MapEntry(key: message, value: logs) in table.entries) {
        expect(
          detector.detect(message)?.toolName == 'saveWorkout',
          logs,
          reason: message,
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
