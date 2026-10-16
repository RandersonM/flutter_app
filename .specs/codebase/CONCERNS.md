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
- flutter_gemma has one active store per process; Vegapunk (`opfan_rag.db`) and Nami
  (`nami_finances_store.db`) switch it through `RagStoreCoordinator.ensureActive`
- Clearing wipes the whole store; no per-document delete; no unit test for the coordinator
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
- Rules are owner-scoped (#25); `getAllCustomCharacters()` (Duels) is unfiltered, which
  the `custom_characters` rule denies for other users' docs
- No `firestore.indexes.json`: repositories sort in memory

### 8. Dio `LogInterceptor` logs full URLs incl. API keys (debug builds)
- `youtube_service.dart`, `devil_fruit_service.dart`, `gemini_service.dart`

## LOW RISK

### 9. String-based routes
- Per-feature `FeatureRouteModule`s aggregated in `AppRoutes._modules`; no compile-time safety

### 10. Dead code
- `NotificationManagerService` (only client use of `cloud_functions`) is never registered;
  `palette_generator`, `image`, `stylish_bottom_bar` are declared but unused

### 11. `GlobalErrorBoundary` "Go home" calls the Navigator on a context without one

## Fixed (no longer concerns)

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
