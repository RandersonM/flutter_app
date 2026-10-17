# Technical Concerns & Risk Areas

Prioritized backlog with effort: `.specs/codebase/TECH_DEBT.md`. This page lists
the fragile areas to be careful in; items fixed by the refactor PRs (#25–#35 and the P3
structure branch) are kept at the bottom so nobody re-reports them.

## HIGH RISK — Fragile Areas

### 1. Auth state machine (`lib/core/auth/blocs/auth_bloc.dart`)
- Global lazy singleton, ~280 lines, stream subscriptions to auth status and
  `IAuthService.profileChanges`, Hive cache fallback (`auth_cache`), first-login detection
- `AuthStarted` is dispatched only from `AppWrapper` (the double dispatch was fixed in #26)
- **Risk:** refactors here break login/logout/session flows

### 2. Shared on-device model (`lib/core/services/gemma/gemma_service.dart`)
- One model, one Vegapunk chat, N named sessions (Nami). `_recreateChat` (full
  reload) closes the chat **and every session**; routine re-entry/reset only
  refreshes the Vegapunk chat (`_refreshVegapunkChat`)
- No generation lock — callers track `isGenerating`
- iOS: Gemma 4 E2B needs `increased-memory-limit` (`ios/Runner/Runner.entitlements`);
  an OOM kill leaves no Dart error
- **Risk:** a second feature calling `initialize()`/`loadModel()` at the wrong time kills Nami's session

### 3. Global RAG vector store (`lib/core/services/rag/rag_store_coordinator.dart`)
- flutter_gemma has one active store per process; Vegapunk (`opfan_rag_<uid>.db`) and
  Nami (`nami_finances_store_<uid>.db`) use it only inside `RagStoreCoordinator.withStore`, which
  runs one operation at a time, the store switch included
- Clearing wipes the whole store; single documents go through `RagStoreCoordinator.removeDocument` inside `withStore`
- A long operation (Nami indexing a month) makes the other feature's search wait
- **Risk:** calling `initializeVectorStore` directly silently re-points the other feature's searches

### 4. `core_module.dart` (~240 lines)
- Every service, repository, the Vegapunk `FunctionRegistry` and `IGemmaService` in one place
- Registration order matters (`IWebSearchService` → `FunctionRegistry` → `IGemmaService` → `IVegapunkChatRepository`)
- **Risk:** cycles and order bugs as the app grows

### 5. Hive type ids
- Ids live only in `lib/core/storage/hive_type_ids.dart`, guarded by
  `test/core/storage/hive_type_ids_test.dart`; adapters are hand-written
- **Risk:** reusing a shipped id corrupts local data silently on upgrade

## MEDIUM RISK

### 6. NavigationService
- Owns the app's only `navigatorKey`; resolve it through `getIt<INavigationService>()`
- **Risk:** a second key or ad-hoc instance navigates the wrong tree

### 7. Firestore queries vs rules
- Rules are owner-scoped (#25); any query over an owner-only collection must filter
  by `userId`, or the whole query is denied
- No `firestore.indexes.json`: repositories sort in memory

## LOW RISK

### 8. String-based routes
- Per-feature `FeatureRouteModule`s aggregated in `AppRoutes._modules`; no compile-time safety

## Fixed (no longer concerns)

- Local data shared between accounts and stored in plain text → per-user, AES-encrypted
  Hive boxes and per-user RAG databases (`IUserStorageService`)
- Account deletion left Firestore data behind → `IUserDataEraser` runs before the Auth delete
- Unused `palette_generator`, `image`, `stylish_bottom_bar` dependencies → removed
- `service_locator.dart` with 40+ getters → split into `lib/app/di/` modules
- `ThemeService`/`LocaleService` `ChangeNotifier` listeners in `MyApp` → `ThemeCubit`/`LocaleCubit`
- `CalculatorProvider` (Provider/`ChangeNotifier`) → `CalculatorCubit`
- Manual repository singletons (`static _instance`) → lazy singletons in DI
- Empty `lib/core/providers/` → removed
- Single 296-line route file → per-feature `<f>_routes.dart` modules
- No global error widget → `GlobalErrorBoundary`; BLoC failures are enums localized by widgets
- `getIt` in widgets, BLoC-to-BLoC dependencies, `cubit/` folders,
  `*_repository_interface.dart` names and Robin's `part` BLoC files → removed (#27–#33, P3 structure branch)
- Firestore blanket `allow read, write` and missing `user_tokens` rule → fixed (#25)
- Duels querying every user's characters (denied by the rules), Dio logging API keys,
  the error boundary's "Go home" without a Navigator, the unused
  `NotificationManagerService` / `cloud_functions`, concurrent RAG store switches,
  the stuck devil fruit type filter and Zoro's zero progress stubs → fixed
