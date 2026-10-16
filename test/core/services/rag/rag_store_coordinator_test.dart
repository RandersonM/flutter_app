import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/rag/rag_store_coordinator.dart';

/// Records which database the shared vector store was pointed at. Every other
/// plugin member is unused by `ensureActive` and falls through to
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
      await RagStoreCoordinator.ensureActive('owner-a', 'a.db');

      expect(plugin.opened, ['$_documentsPath/a.db']);
    });

    test('does nothing when the active owner asks again', () async {
      await RagStoreCoordinator.ensureActive('owner-b', 'b.db');
      await RagStoreCoordinator.ensureActive('owner-b', 'b.db');
      await RagStoreCoordinator.ensureActive('owner-b', 'b.db');

      expect(plugin.opened, ['$_documentsPath/b.db']);
    });

    test('reopens the store once per owner switch', () async {
      await RagStoreCoordinator.ensureActive('owner-c', 'c.db');
      await RagStoreCoordinator.ensureActive('owner-d', 'd.db');
      await RagStoreCoordinator.ensureActive('owner-d', 'd.db');
      await RagStoreCoordinator.ensureActive('owner-c', 'c.db');

      expect(plugin.opened, [
        '$_documentsPath/c.db',
        '$_documentsPath/d.db',
        '$_documentsPath/c.db',
      ]);
    });

    test('remembers the active owner, not the database file', () async {
      await RagStoreCoordinator.ensureActive('owner-e', 'e.db');
      await RagStoreCoordinator.ensureActive('owner-e', 'other.db');

      expect(plugin.opened, ['$_documentsPath/e.db']);
    });

    test('retries the switch after a failed activation', () async {
      plugin.failuresLeft = 1;

      await expectLater(
        RagStoreCoordinator.ensureActive('owner-f', 'f.db'),
        throwsException,
      );
      await RagStoreCoordinator.ensureActive('owner-f', 'f.db');
      await RagStoreCoordinator.ensureActive('owner-f', 'f.db');

      expect(plugin.opened, ['$_documentsPath/f.db']);
    });

    test(
      'still treats the previous owner as active when a switch fails',
      () async {
        await RagStoreCoordinator.ensureActive('owner-g', 'g.db');
        plugin.failuresLeft = 1;
        await expectLater(
          RagStoreCoordinator.ensureActive('owner-h', 'h.db'),
          throwsException,
        );

        await RagStoreCoordinator.ensureActive('owner-g', 'g.db');

        expect(plugin.opened, ['$_documentsPath/g.db']);
      },
    );
  });
}
