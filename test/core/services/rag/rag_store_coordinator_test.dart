import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/rag/rag_store_coordinator.dart';

/// Records which database the shared vector store was pointed at. Every other
/// plugin member is unused by the coordinator and falls through to
/// [noSuchMethod].
class _FakeGemmaPlugin extends FlutterGemmaPlugin {
  final opened = <String>[];
  int failuresLeft = 0;

  @override
  Future<void> initializeVectorStore(String databasePath) async {
    if (failuresLeft > 0) {
      failuresLeft--;
      throw Exception('sqlite busy');
    }
    opened.add(databasePath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _documentsPath = '/docs';

Future<void> _switchTo(String owner, String dbFileName) =>
    RagStoreCoordinator.withStore(owner, dbFileName, () async {});
const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeGemmaPlugin plugin;

  setUp(() {
    plugin = _FakeGemmaPlugin();
    FlutterGemmaPlugin.instance = plugin;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          return call.method == 'getApplicationDocumentsDirectory'
              ? _documentsPath
              : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
  });

  // The coordinator memoizes the active owner in process-wide static state, so
  // every test activates owners no other test uses.
  group('RagStoreCoordinator behaviour', () {
    test('opens the owner database inside the documents directory', () async {
      await _switchTo('owner-a', 'a.db');

      expect(plugin.opened, ['$_documentsPath/a.db']);
    });

    test('does nothing when the active owner asks again', () async {
      await _switchTo('owner-b', 'b.db');
      await _switchTo('owner-b', 'b.db');
      await _switchTo('owner-b', 'b.db');

      expect(plugin.opened, ['$_documentsPath/b.db']);
    });

    test('reopens the store once per owner switch', () async {
      await _switchTo('owner-c', 'c.db');
      await _switchTo('owner-d', 'd.db');
      await _switchTo('owner-d', 'd.db');
      await _switchTo('owner-c', 'c.db');

      expect(plugin.opened, [
        '$_documentsPath/c.db',
        '$_documentsPath/d.db',
        '$_documentsPath/c.db',
      ]);
    });

    test('remembers the active owner, not the database file', () async {
      await _switchTo('owner-e', 'e.db');
      await _switchTo('owner-e', 'other.db');

      expect(plugin.opened, ['$_documentsPath/e.db']);
    });

    test('retries the switch after a failed activation', () async {
      plugin.failuresLeft = 1;

      await expectLater(_switchTo('owner-f', 'f.db'), throwsException);
      await _switchTo('owner-f', 'f.db');
      await _switchTo('owner-f', 'f.db');

      expect(plugin.opened, ['$_documentsPath/f.db']);
    });

    test(
      'still treats the previous owner as active when a switch fails',
      () async {
        await _switchTo('owner-g', 'g.db');
        plugin.failuresLeft = 1;
        await expectLater(_switchTo('owner-h', 'h.db'), throwsException);

        await _switchTo('owner-g', 'g.db');

        expect(plugin.opened, ['$_documentsPath/g.db']);
      },
    );

    test('opens once when the same owner asks concurrently', () async {
      await Future.wait([
        _switchTo('owner-i', 'i.db'),
        _switchTo('owner-i', 'i.db'),
        _switchTo('owner-i', 'i.db'),
      ]);

      expect(plugin.opened, ['$_documentsPath/i.db']);
    });

    test('ends on the owner requested last when switches overlap', () async {
      await Future.wait([
        _switchTo('owner-j', 'j.db'),
        _switchTo('owner-k', 'k.db'),
      ]);
      await _switchTo('owner-k', 'k.db');

      expect(plugin.opened, ['$_documentsPath/j.db', '$_documentsPath/k.db']);
    });

    test('keeps serving queued calls after one fails', () async {
      plugin.failuresLeft = 1;
      final failing = _switchTo('owner-l', 'l.db');
      final queued = _switchTo('owner-l', 'l.db');

      await expectLater(failing, throwsException);
      await queued;

      expect(plugin.opened, ['$_documentsPath/l.db']);
    });

    test('returns what the operation returns', () async {
      final result = await RagStoreCoordinator.withStore(
        'owner-m',
        'm.db',
        () async => 42,
      );

      expect(result, 42);
    });

    test('keeps another owner out until the operation finishes', () async {
      final release = Completer<void>();
      final first = RagStoreCoordinator.withStore(
        'owner-n',
        'n.db',
        () => release.future,
      );
      final second = _switchTo('owner-o', 'o.db');
      await pumpEventQueue();

      expect(plugin.opened, ['$_documentsPath/n.db']);

      release.complete();
      await Future.wait([first, second]);
      expect(plugin.opened, ['$_documentsPath/n.db', '$_documentsPath/o.db']);
    });

    test('runs a nested call for the same owner inline', () async {
      final result = await RagStoreCoordinator.withStore(
        'owner-p',
        'p.db',
        () => RagStoreCoordinator.withStore('owner-p', 'p.db', () async => 1),
      );

      expect(result, 1);
      expect(plugin.opened, ['$_documentsPath/p.db']);
    });

    test('rejects a different owner nested inside an operation', () async {
      await expectLater(
        RagStoreCoordinator.withStore(
          'owner-q',
          'q.db',
          () => _switchTo('owner-r', 'r.db'),
        ),
        throwsStateError,
      );
      await _switchTo('owner-r', 'r.db');

      expect(plugin.opened, ['$_documentsPath/q.db', '$_documentsPath/r.db']);
    });

    test('releases the store when the operation throws', () async {
      await expectLater(
        RagStoreCoordinator.withStore(
          'owner-s',
          's.db',
          () async => throw Exception('search failed'),
        ),
        throwsException,
      );
      await _switchTo('owner-t', 't.db');

      expect(plugin.opened, ['$_documentsPath/s.db', '$_documentsPath/t.db']);
    });
  });
}
