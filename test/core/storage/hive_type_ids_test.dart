import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/core/services/config/storage_service.dart';
import 'package:opfan/core/storage/hive_type_ids.dart';

/// A Hive type-id collision corrupts local data silently and only after an
/// upgrade, on a real device — there is no runtime error to catch. These tests
/// are the only place it can be caught, so they guard the registry itself
/// rather than any single model.
void main() {
  group('HiveTypeIds', () {
    test('declares no duplicate ids', () {
      final duplicates = <int>[];
      final seen = <int>{};
      for (final id in HiveTypeIds.all) {
        if (!seen.add(id)) duplicates.add(id);
      }

      expect(
        duplicates,
        isEmpty,
        reason:
            'Duplicate Hive type ids $duplicates — two adapters would decode '
            'each other\'s bytes. Give one of them a fresh id.',
      );
    });

    test('does not reuse a retired id', () {
      final reused = HiveTypeIds.all
          .where(HiveTypeIds.retired.contains)
          .toList();

      expect(
        reused,
        isEmpty,
        reason:
            'Ids $reused are marked retired but claimed by a live adapter. '
            'Retired ids still exist in old boxes on disk — take a new one.',
      );
    });
  });

  group('HiveStorageService.adapters', () {
    test('every registered adapter reports an id from the registry', () {
      final registered = HiveStorageService.adapters
          .map((adapter) => adapter.typeId)
          .toList();
      final unregistered = registered
          .where((id) => !HiveTypeIds.all.contains(id))
          .toList();

      expect(
        unregistered,
        isEmpty,
        reason:
            'Adapters report ids $unregistered that HiveTypeIds.all does not '
            'list. Add them to the registry so collisions stay detectable.',
      );
    });

    test('registry lists no id without a registered adapter', () {
      final registered = HiveStorageService.adapters
          .map((adapter) => adapter.typeId)
          .toSet();
      final orphans = HiveTypeIds.all
          .where((id) => !registered.contains(id))
          .toList();

      expect(
        orphans,
        isEmpty,
        reason:
            'HiveTypeIds.all lists $orphans but no adapter in '
            'HiveStorageService.adapters claims them. Either register the '
            'adapter or move the id to HiveTypeIds.retired.',
      );
    });

    test('binds every adapter to a concrete model type, never dynamic', () {
      // Regression guard. Hive resolves an adapter by `value is T`, so a
      // registration with `T == dynamic` matches EVERY value and Hive routes
      // all writes to whichever adapter was registered first. That surfaced as
      // "type 'UserModel' is not a subtype of type 'TodayCharacter'" at
      // runtime, with no analyzer or test failure to warn about it.
      final untyped = HiveStorageService.adapters
          .where((r) => r.modelType == dynamic || r.modelType == Object)
          .map((r) => 'typeId ${r.typeId}')
          .toList();

      expect(
        untyped,
        isEmpty,
        reason:
            'Adapters $untyped are registered under a dynamic/Object type. '
            'Hive would send every write to the first-registered adapter. '
            'Give each _Registration an explicit model type argument.',
      );
    });

    test('binds each model type exactly once', () {
      final types = HiveStorageService.adapters
          .map((r) => r.modelType)
          .toList();

      expect(
        types.length,
        types.toSet().length,
        reason:
            'Two registrations claim the same model type — one of them will '
            'never receive a write.',
      );
    });

    test('registers exactly one adapter per id', () {
      final registered = HiveStorageService.adapters
          .map((adapter) => adapter.typeId)
          .toList();

      expect(
        registered.length,
        registered.toSet().length,
        reason:
            'Two adapters in HiveStorageService.adapters share a type id. '
            'Hive.registerAdapter would silently keep only the first.',
      );
    });
  });
}
