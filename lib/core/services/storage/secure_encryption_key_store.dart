import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import 'i_encryption_key_store.dart';

class SecureEncryptionKeyStore implements IEncryptionKeyStore {
  SecureEncryptionKeyStore({required this._secureStorage});

  static const _keyName = 'hive_encryption_key';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<List<int>> readOrCreateKey() async {
    final stored = await _secureStorage.read(key: _keyName);
    if (stored != null) return base64Url.decode(stored);

    final key = Hive.generateSecureKey();
    await _secureStorage.write(key: _keyName, value: base64Url.encode(key));
    return key;
  }
}
