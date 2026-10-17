import 'package:hive/hive.dart';

/// Local storage that belongs to the signed-in user (or to the guest when
/// nobody is signed in), encrypted at rest. Names come from `UserDataNames`.
abstract class IUserStorageService {
  /// Reads the encryption key, picks the current user's scope and moves data
  /// written before per-user storage existed into it. Runs once; every other
  /// member awaits it.
  Future<void> initialize();

  /// An encrypted box private to the current user.
  Future<Box<T>> openUserBox<T>(String name);

  /// An encrypted lazy box private to the current user.
  Future<LazyBox<T>> openUserLazyBox<T>(String name);

  /// An encrypted box shared by everyone who uses the device.
  Future<Box<T>> openDeviceBox<T>(String name);

  /// File name of the current user's copy of a SQLite database.
  Future<String> userDatabaseFileName(String name);

  /// Deletes every box and database file of [uid] from the device.
  Future<void> deleteUserData(String uid);
}
