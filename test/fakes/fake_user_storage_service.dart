import 'package:hive/hive.dart';
import 'package:opfan/core/services/storage/i_user_storage_service.dart';

/// Opens plain, unscoped boxes under the given name, so tests can seed and
/// inspect them directly. Scoping and encryption are covered by
/// `user_storage_service_test.dart`.
class FakeUserStorageService implements IUserStorageService {
  final deletedUids = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<Box<T>> openUserBox<T>(String name) async =>
      Hive.isBoxOpen(name) ? Hive.box<T>(name) : Hive.openBox<T>(name);

  @override
  Future<LazyBox<T>> openUserLazyBox<T>(String name) async =>
      Hive.isBoxOpen(name) ? Hive.lazyBox<T>(name) : Hive.openLazyBox<T>(name);

  @override
  Future<Box<T>> openDeviceBox<T>(String name) => openUserBox<T>(name);

  @override
  Future<String> userDatabaseFileName(String name) async => '$name.db';

  @override
  Future<void> deleteUserData(String uid) async => deletedUids.add(uid);
}
