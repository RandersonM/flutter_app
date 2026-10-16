---
paths:
  - "test/**"
---

# Testing

Stack: `flutter_test` + **mocktail** + **bloc_test**. No mockito, no codegen mocks
(hook-enforced). Coverage is thin (about 15 test files) — prioritize BLoC logic,
repositories, AI tool handlers/routers, and guard tests.

## Layout

```
test/
├── core/<area>/...            services, storage guards
├── features/<f>/bloc/         bloc_test for the feature's BLoCs
├── features/<f>/...           handlers, routers, repositories
├── l10n/arb_parity_test.dart  en/pt key parity
├── ui/<f>/                    widget tests
├── fixtures/                  JSON fixtures
└── testable_widget.dart       getTestableWidget(child): MaterialApp + l10n + theme
```

File names end in `_test.dart` and mirror the lib path.

## BLoC tests

```dart
class _MockCrewRepository extends Mock implements ICrewRepository {}

void main() {
  late _MockCrewRepository repo;
  setUp(() => repo = _MockCrewRepository());

  blocTest<ListCrewsBloc, ListCrewsState>(
    'emits [loading, loaded] when crews load',
    setUp: () => when(() => repo.getUserCrews()).thenAnswer((_) async => [crew]),
    build: () => ListCrewsBloc(repository: repo),
    act: (bloc) => bloc.add(const LoadUserCrews()),
    expect: () => [const ListCrewsLoading(), ListCrewsLoaded(crews: [crew])],
  );

  blocTest<ListCrewsBloc, ListCrewsState>(
    'emits a failure, not a message, when the repository throws',
    setUp: () => when(() => repo.getUserCrews()).thenThrow(Exception('boom')),
    build: () => ListCrewsBloc(repository: repo),
    act: (bloc) => bloc.add(const LoadUserCrews()),
    expect: () => [const ListCrewsLoading(), const ListCrewsError(CrewsFailure.unknown)],
  );
}
```

- Mock the **interface**, never the concrete class. Register fallbacks with
  `registerFallbackValue` for custom argument types used with `any()`.
- Hand-written `_FakeX implements IX` classes are still fine when a fake with real
  behaviour (in-memory store, controllable stream) reads better than stubs — golden:
  `test/features/vegapunk_chat/cubit/vegapunk_chat_cubit_history_test.dart`.
- Close BLoCs you build manually (`await cubit.close()`).

## Widget tests

- Wrap with `getTestableWidget(child)` (`test/testable_widget.dart`).
- Register what the widget resolves from `getIt` in `setUp`, `getIt.reset()` in
  `tearDown`.
- Golden: `test/ui/calculator/calculator_test.dart`.

## Hive and files

`Hive.init(tempDir.path)` with a `Directory.systemTemp.createTempSync()` per test;
delete it in `tearDown`. Never touch the real app boxes.

## Naming

`group('ClassName behaviour')`, test names are lowercase behaviour sentences:
`'reports hasData:false for a month with no record'`. Not `'Should ...'`.

## Guard tests — keep them green, extend them

- `test/core/storage/hive_type_ids_test.dart` — Hive id registry and literal ids.
- `test/l10n/arb_parity_test.dart` — en/pt key parity.
