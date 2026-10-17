import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opfan/core/models/theme/theme_model.dart';
import 'package:opfan/core/services/config/storage_service.dart';
import 'package:opfan/core/services/storage/i_encryption_key_store.dart';
import 'package:opfan/core/services/storage/user_storage_service.dart';
import 'package:opfan/core/storage/user_data_names.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _FixedKeyStore implements IEncryptionKeyStore {
  _FixedKeyStore(int seed) : key = List<int>.generate(32, (i) => i + seed);
  final List<int> key;

  @override
  Future<List<int>> readOrCreateKey() async => key;
}

User _user(String uid) {
  final user = _MockUser();
  when(() => user.uid).thenReturn(uid);
  return user;
}

void main() {
  late Directory hiveDir;
  late Directory documentsDir;
  late _MockFirebaseAuth auth;
  late StreamController<User?> authChanges;

  setUpAll(() {
    for (final registration in HiveStorageService.adapters) {
      if (!Hive.isAdapterRegistered(registration.typeId)) {
        registration.register();
      }
    }
  });

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('user_storage_hive');
    documentsDir = await Directory.systemTemp.createTemp('user_storage_docs');
    Hive.init(hiveDir.path);
    auth = _MockFirebaseAuth();
    authChanges = StreamController<User?>.broadcast();
    when(() => auth.authStateChanges()).thenAnswer((_) => authChanges.stream);
    when(() => auth.currentUser).thenReturn(null);
  });

  tearDown(() async {
    await authChanges.close();
    await Hive.close();
    await hiveDir.delete(recursive: true);
    await documentsDir.delete(recursive: true);
  });

  UserStorageService build({int keySeed = 0}) => UserStorageService(
    auth: auth,
    keyStore: _FixedKeyStore(keySeed),
    documentsDirectory: () async => documentsDir,
  );

  void startSignedIn(String uid) {
    final user = _user(uid);
    when(() => auth.currentUser).thenReturn(user);
  }

  Future<void> signIn(String? uid) async {
    final user = uid == null ? null : _user(uid);
    authChanges.add(user);
    await pumpEventQueue();
  }

  group('UserStorageService behaviour', () {
    test('keeps each signed-in user in their own box', () async {
      startSignedIn('UserA');
      final storage = build();

      final boxA = await storage.openUserBox<String>('nami_finances');
      await boxA.put('2026-10', 'A spent 100');

      await signIn('UserB');
      final boxB = await storage.openUserBox<String>('nami_finances');
      expect(boxB.get('2026-10'), isNull);
      expect(boxA.isOpen, isFalse);

      await signIn('UserA');
      final boxAAgain = await storage.openUserBox<String>('nami_finances');
      expect(boxAAgain.get('2026-10'), 'A spent 100');
    });

    test('uses the guest scope when nobody is signed in', () async {
      final storage = build();

      expect(
        await storage.userDatabaseFileName('opfan_rag'),
        'opfan_rag_guest.db',
      );
    });

    test('encrypts what it stores', () async {
      startSignedIn('u1');
      final storage = build();

      final box = await storage.openUserBox<String>('nami_finances');
      await box.put('note', 'PLAINTEXT-MARKER');
      await box.close();

      final file = File('${hiveDir.path}/nami_finances_u1.hive');
      final bytes = await file.readAsBytes();
      expect(String.fromCharCodes(bytes).contains('PLAINTEXT-MARKER'), isFalse);
    });

    test('moves legacy shared data to the signed-in user once', () async {
      final legacy = await Hive.openBox<String>('nami_finances');
      await legacy.put('2026-09', 'old data');
      await legacy.close();
      final legacyHistory = await Hive.openBox<String>('vegapunk_chat_history');
      await legacyHistory.addAll(['first', 'second']);
      await legacyHistory.close();
      await File('${documentsDir.path}/opfan_rag.db').writeAsString('db');
      await File('${documentsDir.path}/opfan_rag.db-wal').writeAsString('wal');
      startSignedIn('u1');

      final storage = build();
      final box = await storage.openUserBox<String>('nami_finances');
      final history = await storage.openUserLazyBox<String>(
        'vegapunk_chat_history',
      );

      expect(box.get('2026-09'), 'old data');
      expect(
        [await history.getAt(0), await history.getAt(1)],
        ['first', 'second'],
      );
      expect(await Hive.boxExists('nami_finances'), isFalse);
      expect(File('${documentsDir.path}/opfan_rag.db').existsSync(), isFalse);
      expect(File('${documentsDir.path}/opfan_rag_u1.db').existsSync(), isTrue);
      expect(
        File('${documentsDir.path}/opfan_rag_u1.db-wal').existsSync(),
        isTrue,
      );
    });

    test('moves legacy finance records into the typed user box', () async {
      final legacy = await Hive.openBox<NamiFinancesModel>('nami_finances');
      await legacy.put(
        '2026-09',
        NamiFinancesModel(
          id: 'f1',
          month: DateTime(2026, 9),
          monthlyIncomes: const [],
          expenses: const [],
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 2),
        ),
      );
      await legacy.close();
      startSignedIn('u1');

      final box = await build().openUserBox<NamiFinancesModel>('nami_finances');

      expect(box.get('2026-09')?.id, 'f1');
      expect(await Hive.boxExists('nami_finances'), isFalse);
    });

    test(
      'keeps the legacy box and leaves nothing open when a move fails',
      () async {
        // A HiveObject stays bound to the box it was read from, so copying it
        // into another box throws — the failure path the migration must survive.
        final legacy = await Hive.openBox<ThemeSettings>('nami_finances');
        await legacy.put('settings', ThemeSettings(isDarkMode: true));
        await legacy.close();
        startSignedIn('u1');

        final box = await build().openUserBox<ThemeSettings>('nami_finances');

        expect(box.isOpen, isTrue);
        expect(await Hive.boxExists('nami_finances'), isTrue);
      },
    );

    test(
      'keeps legacy months when the user saved one after a failed move',
      () async {
        final saved = await Hive.openBox<String>(
          'nami_finances_u1',
          encryptionCipher: HiveAesCipher(_FixedKeyStore(0).key),
        );
        await saved.putAll({'2026-09': 'new Sept', '2026-10': 'new Oct'});
        await saved.close();
        final legacy = await Hive.openBox<String>('nami_finances');
        await legacy.putAll({'2026-08': 'old August', '2026-09': 'old Sept'});
        await legacy.close();
        startSignedIn('u1');

        final box = await build().openUserBox<String>('nami_finances');

        expect(box.toMap(), {
          '2026-08': 'old August',
          '2026-09': 'new Sept',
          '2026-10': 'new Oct',
        });
        expect(await Hive.boxExists('nami_finances'), isFalse);
      },
    );

    test('moves the legacy auth cache into an encrypted device box', () async {
      final legacy = await Hive.openBox<String>('auth_cache');
      await legacy.put('current_user', 'cached');
      await legacy.close();

      final storage = build();
      final box = await storage.openDeviceBox<String>('auth_cache');

      expect(box.get('current_user'), 'cached');
      expect(await Hive.boxExists('auth_cache'), isFalse);
    });

    test('deletes only the given user\'s boxes and databases', () async {
      startSignedIn('u1');
      final storage = build();
      for (final name in UserDataNames.userBoxes) {
        await (await storage.openUserBox<String>(name)).put('k', 'u1');
      }
      await File('${documentsDir.path}/opfan_rag_u1.db').writeAsString('db');
      await signIn('u2');
      await (await storage.openUserBox<String>('nami_finances')).put('k', 'u2');
      await File('${documentsDir.path}/opfan_rag_u2.db').writeAsString('db');

      await storage.deleteUserData('u1');

      for (final name in UserDataNames.userBoxes) {
        expect(await Hive.boxExists('${name}_u1'), isFalse, reason: name);
      }
      expect(
        File('${documentsDir.path}/opfan_rag_u1.db').existsSync(),
        isFalse,
      );
      expect(File('${documentsDir.path}/opfan_rag_u2.db').existsSync(), isTrue);
      expect(
        (await storage.openUserBox<String>('nami_finances')).get('k'),
        'u2',
      );
    });

    test('resets a box it cannot decrypt instead of failing', () async {
      startSignedIn('u1');
      final writer = build(keySeed: 1);
      await (await writer.openUserBox<String>('nami_finances')).put('k', 'v');
      await Hive.close();

      final reader = build(keySeed: 99);
      final box = await reader.openUserBox<String>('nami_finances');

      expect(box.get('k'), isNot('v'));
    });
  });
}
