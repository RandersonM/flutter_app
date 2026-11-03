import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/services/config/i_environment_service.dart';
import 'package:opfan/core/services/config/i_locale_service.dart';
import 'package:opfan/core/services/gemma/gemma_service.dart';

const _modelName = 'gemma-4-E2B-it.litertlm';

class _MockEnvironmentService extends Mock implements IEnvironmentService {}

class _FakeLocaleService implements ILocaleService {
  @override
  String get languageCode => 'en';

  @override
  Locale? get locale => const Locale('en');

  @override
  Future<void> loadLocale() async {}

  @override
  Future<void> persistLocale(Locale locale) async {}
}

/// A chat whose answer, stop and close the test drives.
class _FakeChat implements InferenceChat {
  final queries = <Message>[];
  final answer = StreamController<ModelResponse>();
  int stopCalls = 0;
  bool closed = false;

  /// While set, [stopGeneration] waits for it — a native stop still running.
  Completer<void>? stopGate;

  @override
  Future<void> addQueryChunk(
    Message message, [
    bool noTool = false,
    bool prefix = false,
  ]) async {
    queries.add(message);
  }

  @override
  Stream<ModelResponse> generateChatResponseAsync() => answer.stream;

  @override
  Future<void> stopGeneration() async {
    stopCalls++;
    await stopGate?.future;
  }

  @override
  Future<void> close() async => closed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Opens a [_FakeChat] per `openChat`, right away or when the test resolves
/// the pending open. `createChat` is the Vegapunk singleton.
class _FakeModel implements InferenceModel {
  final vegapunkChat = _FakeChat();
  final openedChats = <_FakeChat>[];
  final pendingOpens = <Completer<InferenceChat>>[];
  bool holdOpens = false;

  Future<InferenceChat> _openChat() {
    if (holdOpens) {
      final pending = Completer<InferenceChat>();
      pendingOpens.add(pending);
      return pending.future;
    }
    final chat = _FakeChat();
    openedChats.add(chat);
    return Future.value(chat);
  }

  /// Completes the oldest pending open with a new chat and returns it.
  _FakeChat resolveOpen() {
    final chat = _FakeChat();
    openedChats.add(chat);
    pendingOpens.removeAt(0).complete(chat);
    return chat;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #openChat) return _openChat();
    if (invocation.memberName == #createChat) {
      return Future<InferenceChat>.value(vegapunkChat);
    }
    return super.noSuchMethod(invocation);
  }
}

class _FakeModelManager implements ModelFileManager {
  @override
  ModelSpec? get activeInferenceModel => InferenceModelSpec.fromLegacyUrl(
    name: _modelName,
    modelUrl: 'https://example.com/$_modelName',
    modelType: ModelType.gemma4,
    fileType: ModelFileType.litertlm,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Every `getActiveModel` builds a new [_FakeModel], like a real reload.
class _FakeGemmaPlugin extends FlutterGemmaPlugin {
  final models = <_FakeModel>[];

  /// While set, `createModel` waits for it — a reload still in progress.
  Completer<void>? createGate;

  @override
  ModelFileManager get modelManager => _FakeModelManager();

  @override
  Future<InferenceModel> createModel({
    required ModelType modelType,
    ModelFileType fileType = ModelFileType.task,
    int maxTokens = 1024,
    PreferredBackend? preferredBackend,
    List<int>? loraRanks,
    int? maxNumImages,
    bool supportImage = false,
    bool supportAudio = false,
    bool? enableSpeculativeDecoding,
    int? maxConcurrentSessions,
  }) async {
    await createGate?.future;
    final model = _FakeModel();
    models.add(model);
    return model;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Listens to a session answer and records how it ended.
class _Answer {
  _Answer(Stream<ModelResponse> stream) {
    subscription = stream.listen(
      (_) {},
      onError: (Object e) => error = e,
      onDone: () => done = true,
    );
  }

  late final StreamSubscription<ModelResponse> subscription;
  Object? error;
  bool done = false;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeGemmaPlugin plugin;
  late GemmaService service;

  setUp(() async {
    plugin = _FakeGemmaPlugin();
    FlutterGemmaPlugin.instance = plugin;
    final env = _MockEnvironmentService();
    when(() => env.gemmaModelName).thenReturn(_modelName);
    service = GemmaService(env: env, localeService: _FakeLocaleService());
    await service.loadModel();
  });

  _Answer send(String text) => _Answer(
    service.sendSessionMessage(
      'nami',
      systemInstruction: 'You are Nami.',
      text: text,
    ),
  );

  group('GemmaService session behaviour', () {
    test('reuses the open session for the next message', () async {
      final model = plugin.models.single;
      final first = send('first');
      await _settle();
      await model.openedChats.single.answer.close();
      await _settle();
      expect(first.done, isTrue);

      send('second');
      await _settle();

      expect(model.openedChats, hasLength(1));
      expect(model.openedChats.single.queries, hasLength(2));
    });

    test('discards a session that was closed while it was opening', () async {
      final model = plugin.models.single..holdOpens = true;
      final answer = send('quanto sobrou?');
      await _settle();

      await service.closeSession('nami');
      final lateChat = model.resolveOpen();
      await _settle();

      expect(lateChat.closed, isTrue);
      expect(lateChat.queries, isEmpty);
      expect(answer.error, isA<StateError>());

      model.holdOpens = false;
      send('de novo');
      await _settle();
      expect(model.openedChats, hasLength(2));
      expect(model.openedChats.last.queries, hasLength(1));
    });

    test('reopens on the reloaded model a session whose open the reload '
        'interrupted', () async {
      final oldModel = plugin.models.single..holdOpens = true;
      final answer = send('quanto sobrou?');
      await _settle();

      await service.loadModel();
      final lateChat = oldModel.resolveOpen();
      await _settle();

      expect(lateChat.closed, isTrue);
      expect(lateChat.queries, isEmpty);
      expect(answer.error, isNull);
      final reopened = plugin.models.last.openedChats.single;
      expect(reopened.queries.single.text, contains('quanto sobrou?'));
    });

    test('waits for a reload in progress before reopening', () async {
      final oldModel = plugin.models.single..holdOpens = true;
      final answer = send('quanto sobrou?');
      await _settle();
      plugin.createGate = Completer<void>();

      final reloading = service.loadModel();
      oldModel.resolveOpen();
      await _settle();

      expect(plugin.models, hasLength(1));
      expect(answer.error, isNull);

      plugin.createGate!.complete();
      await reloading;
      await _settle();

      expect(answer.error, isNull);
      expect(plugin.models.last.openedChats.single.queries, hasLength(1));
    });

    test(
      'opens one session for a message sent while it is still opening',
      () async {
        final model = plugin.models.single..holdOpens = true;
        final timedOut = send('first');
        await _settle();
        await timedOut.subscription.cancel();

        final retry = send('second');
        await _settle();
        expect(model.pendingOpens, hasLength(1));

        final chat = model.resolveOpen();
        await _settle();

        expect(retry.error, isNull);
        expect(model.openedChats, hasLength(1));
        expect(chat.queries.single.text, contains('second'));

        await service.closeSession('nami');
        expect(model.openedChats.every((opened) => opened.closed), isTrue);
      },
    );

    test('a session reopened while the previous one is still stopping is '
        'neither stopped nor closed by that close', () async {
      final model = plugin.models.single;
      final oldAnswer = send('first');
      await _settle();
      final oldChat = model.openedChats.single..stopGate = Completer<void>();

      final closing = service.closeSession('nami');
      send('second');
      await _settle();
      final newChat = model.openedChats.last;
      unawaited(oldAnswer.subscription.cancel());
      await _settle();
      oldChat.stopGate!.complete();
      await closing;

      expect(newChat, isNot(same(oldChat)));
      expect(newChat.queries.single.text, contains('second'));
      expect(oldChat.closed, isTrue);
      expect(newChat.closed, isFalse);
      expect(newChat.stopCalls, 0);
    });

    test('stops a generating session before closing it', () async {
      send('first');
      await _settle();
      final chat = plugin.models.single.openedChats.single;

      await service.closeSession('nami');

      expect(chat.stopCalls, 1);
      expect(chat.closed, isTrue);
    });

    test('closing a session leaves the vegapunk chat alone', () async {
      send('first');
      await _settle();

      await service.closeSession('nami');

      final vegapunk = plugin.models.single.vegapunkChat;
      expect(vegapunk.stopCalls, 0);
      expect(vegapunk.closed, isFalse);
    });
  });
}
