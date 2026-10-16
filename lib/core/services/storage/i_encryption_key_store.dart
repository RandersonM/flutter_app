/// Keeps the key that encrypts the local Hive boxes outside of them.
abstract class IEncryptionKeyStore {
  /// The 32-byte AES key, created on first use.
  Future<List<int>> readOrCreateKey();
}
