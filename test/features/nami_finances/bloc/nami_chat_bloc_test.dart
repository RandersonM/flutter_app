import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter_gemma/core/model_response.dart';
import 'package:flutter_gemma/core/tool.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/ai/prompts/index.dart';
import 'package:opfan/core/services/config/i_locale_service.dart';
import 'package:opfan/core/services/finances/i_nami_finances_service.dart';
import 'package:opfan/core/services/gemma/gemma_service_status.dart';
import 'package:opfan/core/services/gemma/i_gemma_service.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_chat_bloc.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_chat_state.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/features/vegapunk_chat/tools/function_registry.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_call.dart';
import 'package:opfan/features/vegapunk_chat/tools/models/tool_result.dart';
import 'package:opfan/features/vegapunk_chat/tools/tool_handler.dart';

class _MockNamiRagService extends Mock implements INamiRagService {}

class _MockNamiFinancesService extends Mock implements INamiFinancesService {}

class _SessionRequest {
  _SessionRequest({
    required this.sessionId,
    required this.systemInstruction,
    required this.text,
    required this.ragContext,
    required this.tools,
    required this.maxOutputTokens,
  });

  final String sessionId;
  final String systemInstruction;
  final String text;
  final List<String>? ragContext;
  final List<Tool>? tools;
  final int maxOutputTokens;
}

/// Controllable model status plus a scripted session stream. Members the
/// cubit never touches fall through to [noSuchMethod].
class _FakeGemmaService implements IGemmaService {
  _FakeGemmaService(this.currentStatus);

  final _statusController = StreamController<GemmaServiceStatus>.broadcast();

  @override
  GemmaServiceStatus currentStatus;

  /// What [initialize] reports on the status stream.
  List<GemmaServiceStatus> statusesOnInitialize = const [];
  int initializeCalls = 0;

  final sessionRequests = <_SessionRequest>[];
  final closedSessions = <String>[];

  /// Each [sendSessionMessage] answers with the next stream in this list.
  final sessionAnswers = <Stream<ModelResponse>>[];

  @override
  Stream<GemmaServiceStatus> get statusStream => _statusController.stream;

  void pushStatus(GemmaServiceStatus status) {
    currentStatus = status;
    _statusController.add(status);
  }

  @override
  Future<void> initialize({bool isThinkingMode = false}) async {
    initializeCalls++;
    statusesOnInitialize.forEach(pushStatus);
  }

  @override
  Stream<ModelResponse> sendSessionMessage(
    String sessionId, {
    required String systemInstruction,
    required String text,
    List<String>? ragContext,
    List<Tool>? tools,
    int maxOutputTokens = 512,
  }) {
    sessionRequests.add(
      _SessionRequest(
        sessionId: sessionId,
        systemInstruction: systemInstruction,
        text: text,
        ragContext: ragContext,
        tools: tools,
        maxOutputTokens: maxOutputTokens,
      ),
    );
    return sessionAnswers.removeAt(0);
  }

  @override
  Future<void> closeSession(String sessionId) async {
    closedSessions.add(sessionId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingToolHandler extends ToolHandler {
  _RecordingToolHandler(this.name, {String? content})
    : content = content ?? '{"tool":"$name"}';

  @override
  final String name;
  final String content;
  final calls = <ToolCall>[];

  @override
  String get description => name;

  @override
  Map<String, String> get parameterDescriptions => const {};

  @override
  Future<ToolResult> execute(ToolCall call) async {
    calls.add(call);
    return ToolResult.success(toolName: name, content: content);
  }
}

class _FakeLocaleService implements ILocaleService {
  _FakeLocaleService(this.languageCode);

  @override
  final String languageCode;

  @override
  Locale? get locale => Locale(languageCode);

  @override
  Future<void> loadLocale() async {}

  @override
  Future<void> persistLocale(Locale locale) async {}
}

Stream<ModelResponse> _answer(List<String> tokens) =>
    Stream.fromIterable(tokens.map(TextResponse.new));

Future<NamiChatReady> _ready(NamiChatBloc bloc) async {
  final current = bloc.state;
  if (current is NamiChatReady) return current;
  return await bloc.stream.firstWhere((s) => s is NamiChatReady)
      as NamiChatReady;
}

Future<NamiChatReady> _settled(NamiChatBloc bloc) async {
  final current = bloc.state;
  if (current is NamiChatReady && !current.isGenerating) return current;
  return await bloc.stream.firstWhere(
        (s) => s is NamiChatReady && !s.isGenerating,
      )
      as NamiChatReady;
}

void main() {
  late _MockNamiRagService rag;
  late _MockNamiFinancesService finances;
  late FunctionRegistry registry;
  late _RecordingToolHandler installmentTool;
  late _RecordingToolHandler financesTool;

  setUp(() {
    rag = _MockNamiRagService();
    finances = _MockNamiFinancesService();
    when(() => finances.getLastMonthsFinances(24)).thenAnswer((_) async => []);
    when(() => rag.backfillIfNeeded(any())).thenAnswer((_) async {});

    installmentTool = _RecordingToolHandler('affordableInstallment');
    financesTool = _RecordingToolHandler('getFinances');
    registry = FunctionRegistry()
      ..register(installmentTool)
      ..register(financesTool);
  });

  NamiChatBloc build(_FakeGemmaService gemma, {String language = 'pt'}) =>
      NamiChatBloc(
        rag,
        gemma,
        finances,
        registry,
        localeService: _FakeLocaleService(language),
      );

  group('NamiChatBloc loading behaviour', () {
    test('starts loading and becomes ready without failure when the model '
        'is already loaded', () async {
      final gemma = _FakeGemmaService(const GemmaReady());
      final bloc = build(gemma);

      expect(bloc.state, isA<NamiChatLoading>());
      final ready = await _ready(bloc);

      expect(ready.failure, isNull);
      expect(ready.messages, isEmpty);
      expect(gemma.initializeCalls, 0);
      await bloc.close();
    });

    test('backfills the rag store with the last 24 months', () async {
      final bloc = build(_FakeGemmaService(const GemmaReady()));
      await _ready(bloc);

      verify(() => finances.getLastMonthsFinances(24)).called(1);
      verify(() => rag.backfillIfNeeded([])).called(1);
      await bloc.close();
    });

    test('still becomes ready when the backfill fails', () async {
      when(
        () => finances.getLastMonthsFinances(24),
      ).thenThrow(Exception('hive'));
      final bloc = build(_FakeGemmaService(const GemmaReady()));

      expect((await _ready(bloc)).failure, isNull);
      await bloc.close();
    });

    test('loads the model itself when nobody has started it', () async {
      final gemma = _FakeGemmaService(const GemmaNotInstalled())
        ..statusesOnInitialize = const [GemmaLoading(), GemmaReady()];
      final bloc = build(gemma);

      expect((await _ready(bloc)).failure, isNull);
      expect(gemma.initializeCalls, 1);
      await bloc.close();
    });

    test('reports modelNotInstalled when initialize finds no model', () async {
      final gemma = _FakeGemmaService(const GemmaNotInstalled())
        ..statusesOnInitialize = const [GemmaNotInstalled()];
      final bloc = build(gemma);

      expect((await _ready(bloc)).failure, NamiChatFailure.modelNotInstalled);
      await bloc.close();
    });

    test('waits for a load already in flight without reinitializing and '
        'reports modelLoadFailed when it errors', () async {
      final gemma = _FakeGemmaService(const GemmaLoading());
      final bloc = build(gemma);
      await Future<void>.delayed(Duration.zero);

      gemma.pushStatus(GemmaError(Exception('oom')));

      expect((await _ready(bloc)).failure, NamiChatFailure.modelLoadFailed);
      expect(gemma.initializeCalls, 0);
      await bloc.close();
    });
  });

  group('NamiChatBloc message behaviour', () {
    test('routes the question to the tool and narrates its result on '
        'the nami session', () async {
      final gemma = _FakeGemmaService(const GemmaReady())
        ..sessionAnswers.add(_answer(['Você ', 'pode ', 'sim.']));
      final bloc = build(gemma);
      await _ready(bloc);

      const question = 'Posso comprar um carro de 60 mil?';
      await bloc.sendMessage(question);
      final state = await _settled(bloc);

      expect(installmentTool.calls.single.arguments, {'price': '60000'});
      expect(financesTool.calls, isEmpty);

      final request = gemma.sessionRequests.single;
      expect(request.sessionId, 'nami');
      expect(request.text, question);
      expect(request.ragContext, ['{"tool":"affordableInstallment"}']);
      expect(request.tools, isNull);
      expect(request.maxOutputTokens, 1536);
      expect(request.systemInstruction, NamiPrompt.system(isPortuguese: true));

      expect(state.failure, isNull);
      expect(state.streamingToken, isEmpty);
      expect(state.messages.map((m) => (m.role, m.text)), [
        (MessageRole.user, question),
        (MessageRole.assistant, 'Você pode sim.'),
      ]);
      await bloc.close();
    });

    test('uses the english persona for an english locale', () async {
      final gemma = _FakeGemmaService(const GemmaReady())
        ..sessionAnswers.add(_answer(['Fine.']));
      final bloc = build(gemma, language: 'en');
      await _ready(bloc);

      await bloc.sendMessage('how am I doing?');

      expect(
        gemma.sessionRequests.single.systemInstruction,
        NamiPrompt.system(isPortuguese: false),
      );
      expect(financesTool.calls.single.arguments, {'monthsBack': '6'});
      await bloc.close();
    });

    test('streams tokens into streamingToken while generating', () async {
      final answer = StreamController<ModelResponse>();
      final gemma = _FakeGemmaService(const GemmaReady())
        ..sessionAnswers.add(answer.stream);
      final bloc = build(gemma);
      await _ready(bloc);

      final sending = bloc.sendMessage('como estão minhas finanças?');
      await Future<void>.delayed(Duration.zero);
      expect((bloc.state as NamiChatReady).isGenerating, isTrue);

      answer.add(const TextResponse('Tudo '));
      final streaming = await bloc.stream.firstWhere(
        (s) => s is NamiChatReady && s.streamingToken.isNotEmpty,
      );
      expect((streaming as NamiChatReady).streamingToken, 'Tudo ');

      answer.add(const TextResponse('certo.'));
      await answer.close();
      await sending;

      final done = bloc.state as NamiChatReady;
      expect(done.isGenerating, isFalse);
      expect(done.messages.last.text, 'Tudo certo.');
      await bloc.close();
    });

    test('strips tool-call json the model leaks into the answer', () async {
      final gemma = _FakeGemmaService(const GemmaReady())
        ..sessionAnswers.add(
          _answer(['Aqui está. ', '{"name":"getFinances","arguments":{}}']),
        );
      final bloc = build(gemma);
      await _ready(bloc);

      await bloc.sendMessage('quanto sobrou?');

      expect((bloc.state as NamiChatReady).messages.last.text, 'Aqui está.');
      await bloc.close();
    });

    test(
      'truncates oversized tool output before handing it to the model',
      () async {
        registry.register(
          _RecordingToolHandler('getFinances', content: 'x' * 2000),
        );
        final gemma = _FakeGemmaService(const GemmaReady())
          ..sessionAnswers.add(_answer(['ok']));
        final bloc = build(gemma);
        await _ready(bloc);

        await bloc.sendMessage('quanto sobrou?');

        expect(
          gemma.sessionRequests.single.ragContext!.single,
          '${'x' * 1800}\n...[TRUNCATED]',
        );
        await bloc.close();
      },
    );

    test('flags connectionFailed and keeps the question when generation '
        'errors', () async {
      final gemma = _FakeGemmaService(const GemmaReady())
        ..sessionAnswers.add(Stream.error(Exception('session closed')));
      final bloc = build(gemma);
      await _ready(bloc);

      await bloc.sendMessage('quanto sobrou?');
      final state = bloc.state as NamiChatReady;

      expect(state.failure, NamiChatFailure.connectionFailed);
      expect(state.isGenerating, isFalse);
      expect(state.messages.single.role, MessageRole.user);
      await bloc.close();
    });

    test('ignores blank messages', () async {
      final gemma = _FakeGemmaService(const GemmaReady());
      final bloc = build(gemma);
      final ready = await _ready(bloc);

      await bloc.sendMessage('   ');

      expect(bloc.state, ready);
      expect(gemma.sessionRequests, isEmpty);
      await bloc.close();
    });

    test('ignores a second message while an answer is generating', () async {
      final answer = StreamController<ModelResponse>();
      final gemma = _FakeGemmaService(const GemmaReady())
        ..sessionAnswers.add(answer.stream);
      final bloc = build(gemma);
      await _ready(bloc);

      final first = bloc.sendMessage('quanto sobrou?');
      await Future<void>.delayed(Duration.zero);
      await bloc.sendMessage('e no mês passado?');

      expect(gemma.sessionRequests, hasLength(1));
      await answer.close();
      await first;
      await bloc.close();
    });
  });

  group('NamiChatBloc close behaviour', () {
    test('closes the nami session', () async {
      final gemma = _FakeGemmaService(const GemmaReady());
      final bloc = build(gemma);
      await _ready(bloc);

      await bloc.close();

      expect(gemma.closedSessions, ['nami']);
    });
  });
}
