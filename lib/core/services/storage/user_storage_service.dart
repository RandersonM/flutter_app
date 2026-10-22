import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/storage/user_data_names.dart';

import 'i_encryption_key_store.dart';
import 'i_user_storage_service.dart';

class UserStorageService implements IUserStorageService {
  UserStorageService({
    required this._auth,
    required this._keyStore,
    required this._documentsDirectory,
  });

  static const guestScope = 'guest';
  static const _sqliteSidecarSuffixes = ['', '-wal', '-shm', '-journal'];
  static const _legacyOwnerBox = 'legacy_data_owner';
  static const _legacyOwnerKey = 'scope';

  final FirebaseAuth _auth;
  final IEncryptionKeyStore _keyStore;
  final Future<Directory> Function() _documentsDirectory;

  Future<void>? _ready;
  late HiveAesCipher _cipher;
  String _scope = guestScope;
  StreamSubscription<User?>? _authSubscription;
  final _openUserBoxes = <String, BoxBase<dynamic>>{};

  @override
  Future<void> initialize() =>
      _ready ??= _initialize().catchError((Object e, StackTrace st) {
        _ready = null;
        Error.throwWithStackTrace(e, st);
      });

  Future<void> _initialize() async {
    _cipher = HiveAesCipher(await _keyStore.readOrCreateKey());
    _scope = _scopeFor(_auth.currentUser?.uid);
    await _migrateLegacyData();
    _authSubscription ??= _auth.authStateChanges().listen(
      (user) => _switchScope(_scopeFor(user?.uid)),
    );
  }

  static String _scopeFor(String? uid) =>
      uid == null ? guestScope : uid.toLowerCase();

  static String _userBoxName(String name, String scope) => '${name}_$scope';

  static String _deviceBoxName(String name) => '${name}_encrypted';

  static String _databaseFileName(String name, String scope) =>
      '${name}_$scope.db';

  /// Boxes of the previous user are closed so their data stops being
  /// reachable in memory; every service re-resolves its box per call.
  Future<void> _switchScope(String scope) async {
    if (scope == _scope) return;
    _scope = scope;
    final previous = _openUserBoxes.values.toList();
    _openUserBoxes.clear();
    for (final box in previous) {
      if (box.isOpen) await box.close();
    }
  }

  @override
  Future<Box<T>> openUserBox<T>(String name) async {
    await initialize();
    final boxName = _userBoxName(name, _scope);
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<T>(boxName)
        : await _openRecovering(
            boxName,
            () => Hive.openBox<T>(boxName, encryptionCipher: _cipher),
          );
    _openUserBoxes[boxName] = box;
    return box;
  }

  @override
  Future<LazyBox<T>> openUserLazyBox<T>(String name) async {
    await initialize();
    final boxName = _userBoxName(name, _scope);
    final box = Hive.isBoxOpen(boxName)
        ? Hive.lazyBox<T>(boxName)
        : await _openRecovering(
            boxName,
            () => Hive.openLazyBox<T>(boxName, encryptionCipher: _cipher),
          );
    _openUserBoxes[boxName] = box;
    return box;
  }

  @override
  Future<Box<T>> openDeviceBox<T>(String name) async {
    await initialize();
    final boxName = _deviceBoxName(name);
    if (Hive.isBoxOpen(boxName)) return Hive.box<T>(boxName);
    return _openRecovering(
      boxName,
      () => Hive.openBox<T>(boxName, encryptionCipher: _cipher),
    );
  }

  /// A box that can't be read (corrupted, or restored to a device whose
  /// keychain no longer has the key) is reset instead of breaking the feature.
  Future<B> _openRecovering<B>(
    String boxName,
    Future<B> Function() open,
  ) async {
    try {
      return await open();
    } catch (e) {
      debugPrint('UserStorageService: "$boxName" unreadable, resetting: $e');
      await Hive.deleteBoxFromDisk(boxName);
      return open();
    }
  }

  @override
  Future<String> userDatabaseFileName(String name) async {
    await initialize();
    return _databaseFileName(name, _scope);
  }

  @override
  Future<void> deleteUserData(String uid) async {
    await initialize();
    final scope = _scopeFor(uid);
    for (final name in UserDataNames.userBoxes) {
      final boxName = _userBoxName(name, scope);
      _openUserBoxes.remove(boxName);
      await Hive.deleteBoxFromDisk(boxName);
    }
    final directory = await _documentsDirectory();
    for (final name in UserDataNames.userDatabases) {
      for (final suffix in _sqliteSidecarSuffixes) {
        final file = File(
          '${directory.path}/${_databaseFileName(name, scope)}$suffix',
        );
        if (await file.exists()) await file.delete();
      }
    }
  }

  /// Before per-user storage, every box and database had one shared,
  /// unencrypted name. They move once to whoever is signed in at the first
  /// launch of this version (or to the guest).
  Future<void> _migrateLegacyData() async {
    for (final name in UserDataNames.deviceBoxes) {
      await _moveLegacyBox(name, _deviceBoxName(name));
    }
    if (!await _hasLegacyUserData()) return;
    final owner = await _legacyDataOwner();
    for (final name in UserDataNames.userBoxes) {
      await _moveLegacyBox(name, _userBoxName(name, owner));
    }
    final directory = await _documentsDirectory();
    for (final name in UserDataNames.userDatabases) {
      for (final suffix in _sqliteSidecarSuffixes) {
        final legacy = File('${directory.path}/$name.db$suffix');
        final target = File(
          '${directory.path}/${_databaseFileName(name, owner)}$suffix',
        );
        if (await legacy.exists() && !await target.exists()) {
          await legacy.rename(target.path);
        }
      }
    }
    if (!await _hasLegacyUserData()) {
      await Hive.deleteBoxFromDisk(_deviceBoxName(_legacyOwnerBox));
    }
  }

  Future<bool> _hasLegacyUserData() async {
    for (final name in UserDataNames.userBoxes) {
      if (await Hive.boxExists(name)) return true;
    }
    final directory = await _documentsDirectory();
    for (final name in UserDataNames.userDatabases) {
      if (await File('${directory.path}/$name.db').exists()) return true;
    }
    return false;
  }

  /// The legacy data belongs to whoever was signed in when it was first
  /// found. A move that fails is retried on a later launch, possibly with
  /// another account signed in, so that owner is stored rather than re-read.
  Future<String> _legacyDataOwner() async {
    final box = await _openRecovering(
      _deviceBoxName(_legacyOwnerBox),
      () => Hive.openBox<String>(
        _deviceBoxName(_legacyOwnerBox),
        encryptionCipher: _cipher,
      ),
    );
    final owner = box.get(_legacyOwnerKey);
    if (owner == null) await box.put(_legacyOwnerKey, _scope);
    await box.close();
    return owner ?? _scope;
  }

  /// A failed move leaves the legacy box untouched (it is retried on the next
  /// launch) and closes both boxes, so the typed open that follows still works.
  /// The user may have saved into the new box between a failed move and the
  /// retry, so only legacy keys it lacks are copied: its own entries win.
  /// A box filled with `add` (the chat history) is a list ordered by its int
  /// keys; the legacy entries are older, so they go before the new ones.
  Future<void> _moveLegacyBox(String legacyName, String targetName) async {
    if (!await Hive.boxExists(legacyName)) return;
    Box<dynamic>? legacy;
    Box<dynamic>? target;
    try {
      legacy = await Hive.openBox<dynamic>(legacyName);
      target = await Hive.openBox<dynamic>(
        targetName,
        encryptionCipher: _cipher,
      );
      if (_isList(legacy) && _isList(target)) {
        final newer = target.values.toList();
        await target.clear();
        await target.addAll([...legacy.values, ...newer]);
      } else {
        await target.putAll({
          for (final MapEntry(:key, :value) in legacy.toMap().entries)
            if (!target.containsKey(key)) key: value,
        });
      }
      await target.close();
      await legacy.deleteFromDisk();
      debugPrint('UserStorageService: moved "$legacyName" to "$targetName"');
    } catch (e) {
      debugPrint('UserStorageService: could not move "$legacyName": $e');
      if (target != null && target.isOpen) await target.close();
      if (legacy != null && legacy.isOpen) await legacy.close();
    }
  }

  static bool _isList(Box<dynamic> box) => box.keys.every((key) => key is int);
}
