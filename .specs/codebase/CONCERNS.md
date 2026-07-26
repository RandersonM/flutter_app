# Technical Concerns & Risk Areas

## HIGH RISK — Fragile Areas

### 1. Auth State Machine (auth_bloc.dart)
- 224 lines, 8 events, 9 states
- Stream subscription to Firebase auth status
- Hive caching of UserModel
- First-login detection logic
- **Risk:** Any refactoring here can break login/logout/session flows

### 2. app_routes.dart (296 lines)
- All routes defined in one file
- Private/public route sets maintained manually
- AuthRouteMiddleware inline in same file
- **Risk:** Adding routes requires editing this single file; merge conflicts likely

### 3. service_locator.dart (191 lines)
- All services, repos, BLoCs registered in one place
- Extension getters (40+) on GetIt
- Init order matters (environment loaded first)
- **Risk:** Circular dependency risk as project grows

### 4. Hive Adapter Registration (main.dart)
- Adapters registered before openBox calls
- TypeId collision if new adapters added without coordination
- **Risk:** Type ID conflicts cause silent data corruption on upgrade

### 5. ThemeService / LocaleService Listeners
- MyApp.initState() calls addListener() on both
- dispose() must call removeListener()
- **Risk:** Memory leak if widget tree reconstructed

## MEDIUM RISK

### 6. CalculatorProvider (ChangeNotifier)
- Only screen using Provider package pattern
- Inconsistent with rest of app
- **Risk:** Low — isolated to one screen

### 7. NavigationService Singleton
- GlobalKey<NavigatorState> shared across app
- Used for navigation from non-widget context
- **Risk:** Can cause navigation to wrong context if widget tree rebuilt

### 8. Repository Singleton Pattern
- Manual singleton (`static _instance`)
- Not using GetIt for lifetime management
- **Risk:** Cannot be replaced with mocks in tests

### 9. Missing Error Boundaries
- BLoCs emit error states but no global error widget
- No retry logic standardized across features
- **Risk:** Unhandled errors silently fail

## LOW RISK

### 10. Unused Providers Directory
- lib/core/providers/ exists but is empty
- Suggests previous Riverpod consideration
- **Risk:** Confusion for new developers

### 11. Dio Declared but Underused
- Dio installed but most HTTP done via Firebase SDKs
- YouTube/Gemini may use their own HTTP
- **Risk:** Inconsistent HTTP layer
