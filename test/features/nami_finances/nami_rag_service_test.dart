import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/services/storage/i_user_storage_service.dart';
import 'package:opfan/core/storage/user_data_names.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'package:opfan/features/nami_finances/data/services/nami_rag_service.dart';

ExpenseModel _expense(String id, String description) => ExpenseModel(
  id: id,
  amount: 100,
  category: ExpenseCategory.food,
  description: description,
);

NamiFinancesModel _month(List<ExpenseModel> expenses, {int month = 7}) =>
    NamiFinancesModel(
      id: 'month-id',
      month: DateTime(2026, month),
      monthlyIncomes: const [],
      expenses: expenses,
      createdAt: DateTime(2026, month),
      updatedAt: DateTime(2026, month),
    );

/// Scopes boxes and database files by [scope], like the real service does
/// by uid, so a test can sign someone else in mid-sync.
class _SwitchableUserStorage implements IUserStorageService {
  _SwitchableUserStorage(this.scope);

  String scope;

  @override
  Future<void> initialize() async {}

  @override
  Future<Box<T>> openUserBox<T>(String name) =>
      Hive.openBox<T>('${name}_$scope');

  @override
  Future<LazyBox<T>> openUserLazyBox<T>(String name) =>
      Hive.openLazyBox<T>('${name}_$scope');

  @override
  Future<Box<T>> openDeviceBox<T>(String name) => Hive.openBox<T>(name);

  @override
  Future<String> userDatabaseFileName(String name) async => '${name}_$scope.db';

  @override
  Future<void> deleteUserData(String uid) async {}
}

/// Records every write with the database the shared store pointed at.
/// Every other plugin member is unused and falls through to [noSuchMethod].
class _FakeGemmaPlugin extends FlutterGemmaPlugin {
  final writes = <String>[];
  void Function()? onDocumentAdded;
  bool failWrites = false;
  String? _openDatabase;

  @override
  Future<void> initializeVectorStore(String databasePath) async =>
      _openDatabase = databasePath;

  @override
  Future<void> clearVectorStore() async => writes.add('$_openDatabase clear');

  @override
  Future<void> addDocument({
    required String id,
    required String content,
    String? metadata,
  }) async {
    if (failWrites) throw Exception('embedding failed');
    writes.add('$_openDatabase $id');
    onDocumentAdded?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _documentsPath = '/docs';
const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

String _storePath(String scope) =>
    '$_documentsPath/${UserDataNames.namiRagDatabase}_$scope.db';

Future<Map<dynamic, dynamic>> _indexRecord(String scope) async =>
    (await Hive.openBox<dynamic>(
      '${UserDataNames.namiRagIndexMetaBox}_$scope',
    )).toMap();

void main() {
  group('NamiRagService.documentsFor', () {
    test('keys each described expense by its own id', () {
      final docs = NamiRagService.documentsFor(
        _month([_expense('a', 'praia'), _expense('b', '  ')]),
      );

      expect(docs, {'exp:a': 'praia (food, 2026-07)'});
    });

    test('gives the same documents when an unchanged month is saved again', () {
      final expenses = [_expense('a', 'praia'), _expense('b', 'mercado')];

      expect(
        NamiRagService.documentsFor(_month(expenses)),
        NamiRagService.documentsFor(_month(List.of(expenses))),
      );
    });
  });

  group('NamiRagService.planSync', () {
    const indexed = {
      'exp:a': 'praia (food, 2026-07)',
      'exp:b': 'mercado (food, 2026-07)',
    };

    test('does nothing when the month did not change', () {
      final plan = NamiRagService.planSync(indexed: indexed, wanted: indexed);

      expect(plan.toIndex, isEmpty);
      expect(plan.toRemove, isEmpty);
    });

    test('indexes only new or reworded expenses', () {
      final plan = NamiRagService.planSync(
        indexed: indexed,
        wanted: {
          'exp:a': 'praia (food, 2026-07)',
          'exp:b': 'feira (food, 2026-07)',
          'exp:c': 'cinema (food, 2026-07)',
        },
      );

      expect(plan.toIndex, ['exp:b', 'exp:c']);
      expect(plan.toRemove, isEmpty);
    });

    test('removes the documents of expenses the edit dropped', () {
      final plan = NamiRagService.planSync(
        indexed: indexed,
        wanted: {'exp:a': 'praia (food, 2026-07)'},
      );

      expect(plan.toIndex, isEmpty);
      expect(plan.toRemove, ['exp:b']);
    });
  });

  // The store coordinator memoizes the active database in process-wide static
  // state, so every test uses scopes no other test uses.
  group('NamiRagService.syncMonth user scope', () {
    late Directory hiveDir;
    late _FakeGemmaPlugin plugin;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      hiveDir = Directory.systemTemp.createTempSync('nami_rag_test');
      Hive.init(hiveDir.path);
      plugin = _FakeGemmaPlugin();
      FlutterGemmaPlugin.instance = plugin;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_pathProviderChannel, (call) async {
            return call.method == 'getApplicationDocumentsDirectory'
                ? _documentsPath
                : null;
          });
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_pathProviderChannel, null);
      await Hive.close();
      hiveDir.deleteSync(recursive: true);
    });

    test('indexes the month into the store and record of its user', () async {
      final service = NamiRagService(
        storage: _SwitchableUserStorage('alice-1'),
        installEmbedder: () async {},
      );

      await service.syncMonth(_month([_expense('a', 'praia')]));

      expect(plugin.writes, [
        '${_storePath('alice-1')} clear',
        '${_storePath('alice-1')} exp:a',
      ]);
      expect(await _indexRecord('alice-1'), containsPair('2026-07', isMap));
    });

    test('drops the sync when another user signs in while the embedder '
        'downloads', () async {
      final storage = _SwitchableUserStorage('alice-2');
      final embedder = Completer<void>();
      final service = NamiRagService(
        storage: storage,
        installEmbedder: () => embedder.future,
      );

      final sync = service.syncMonth(_month([_expense('a', 'praia')]));
      await pumpEventQueue();
      storage.scope = 'bob-2';
      embedder.complete();
      await sync;

      expect(plugin.writes, isEmpty);
      expect(await _indexRecord('bob-2'), isEmpty);
      expect(await _indexRecord('alice-2'), isEmpty);
    });

    test(
      'stops a backfill when another user signs in between months',
      () async {
        final storage = _SwitchableUserStorage('alice-3');
        final service = NamiRagService(
          storage: storage,
          installEmbedder: () async {},
        );
        plugin.onDocumentAdded = () => storage.scope = 'bob-3';

        await service.backfillIfNeeded([
          _month([_expense('a', 'praia')], month: 6),
          _month([_expense('b', 'mercado')], month: 7),
        ]);

        expect(plugin.writes, [
          '${_storePath('alice-3')} clear',
          '${_storePath('alice-3')} exp:a',
        ]);
        expect(await _indexRecord('bob-3'), isEmpty);
      },
    );

    test('retries a backfill whose embedder could not load', () async {
      var attempts = 0;
      final service = NamiRagService(
        storage: _SwitchableUserStorage('alice-4'),
        installEmbedder: () async {
          if (attempts++ == 0) throw Exception('offline');
        },
      );
      final months = [
        _month([_expense('a', 'praia')]),
      ];

      await service.backfillIfNeeded(months);
      expect(plugin.writes, isEmpty);
      expect(await service.isIndexComplete(), isFalse);

      await service.backfillIfNeeded(months);
      expect(plugin.writes, [
        '${_storePath('alice-4')} clear',
        '${_storePath('alice-4')} exp:a',
      ]);
      expect(await service.isIndexComplete(), isTrue);
    });

    test('keeps the index incomplete until every expense is in', () async {
      final service = NamiRagService(
        storage: _SwitchableUserStorage('alice-5'),
        installEmbedder: () async {},
      );
      final months = [
        _month([_expense('a', 'praia')]),
      ];
      plugin.failWrites = true;

      await service.backfillIfNeeded(months);
      expect(await service.isIndexComplete(), isFalse);

      plugin.failWrites = false;
      await service.backfillIfNeeded(months);
      expect(plugin.writes, contains('${_storePath('alice-5')} exp:a'));
      expect(await service.isIndexComplete(), isTrue);
    });

    test('counts a user with no months as fully indexed', () async {
      final service = NamiRagService(
        storage: _SwitchableUserStorage('alice-6'),
        installEmbedder: () => Completer<void>().future,
      );

      await service.backfillIfNeeded(const []);

      expect(await service.isIndexComplete(), isTrue);
    });

    test('reports the search as not ready while the embedder downloads', () {
      fakeAsync((async) {
        final service = NamiRagService(
          storage: _SwitchableUserStorage('alice-7'),
          installEmbedder: () => Completer<void>().future,
        );
        Object? error;
        service
            .findExpenses('praia')
            .then<void>((_) {}, onError: (Object e) => error = e);

        async.elapse(
          NamiRagService.embedderWaitLimit + const Duration(seconds: 1),
        );

        expect(error, isA<ExpenseSearchNotReady>());
      });
    });

    test('reports the search as not ready when the embedder fails', () async {
      final service = NamiRagService(
        storage: _SwitchableUserStorage('alice-8'),
        installEmbedder: () async => throw Exception('offline'),
      );

      expect(await service.isSearchReady(), isFalse);
      await expectLater(
        service.findExpenses('praia'),
        throwsA(isA<ExpenseSearchNotReady>()),
      );
    });
  });
}
