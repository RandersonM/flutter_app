# Architecture (Current State)

## Pattern: Mixed MVC/BLoC + Service Locator

```
lib/
├── main.dart               # Bootstrap: Hive init, GetIt setup, BlocProviders
├── core/
│   ├── auth/               # AuthBloc + UserModel
│   ├── calculator/         # CalculatorProvider (ChangeNotifier) ← to migrate
│   ├── models/             # Domain models (mixed location)
│   ├── repository/         # 5 repositories with interfaces
│   ├── services/           # 12+ services + service_locator.dart
│   ├── middleware/
│   └── widgets/
├── screens/                # 18 feature screens (screen + widgets/ + blocs/)
├── widgets/                # atoms / molecules / organisms
├── utils/                  # routes, theme, constants
└── l10n/                   # arb localization files
```

## State Management Layers

| Layer          | Pattern        | Count |
|----------------|----------------|-------|
| Business logic | BLoC/Cubit     | 14    |
| Theme + Locale | ChangeNotifier | 2     |
| Calculator     | ChangeNotifier | 1     |
| Widget UI      | setState       | ~157  |

## Dependency Injection
GetIt service locator — `lib/core/services/service_locator.dart`
- Singletons: AuthService, FirestoreService, AuthBloc, RobinKnowledgeBloc, repositories
- Factories: HomeBloc, CharactersCubit, CalculatorProvider (per-screen)
- Extension getters on GetIt for convenience

## Navigation
Manual Navigator.pushNamed with string routes.
Auth guard via AuthRouteMiddleware.onGenerateRoute().
NavigationService holds a GlobalKey<NavigatorState>.
Route catalogue in `lib/utils/app_routes.dart` (296 lines).

## Data Flow
```
Screen → BlocProvider (GetIt) → BLoC/Cubit
                                     ↓
                              Repository (interface)
                                     ↓
                         Service (Auth/Firestore/API)
                                     ↓
                        Firebase / External API / Hive
```

## BLoC Lifecycle
- Screen-scoped BLoCs created inside BlocProvider(create: ...) — disposed with screen
- Global singleton BLoCs (AuthBloc, RobinKnowledgeBloc) registered in GetIt as lazy singletons

## Known Pain Points
1. ThemeService/LocaleService use ChangeNotifier + manual addListener in MyApp.initState()
2. CalculatorProvider uses ChangeNotifierProvider<> — inconsistent with BLoC pattern
3. String-based routing is error-prone (no compile-time safety)
4. service_locator.dart is 191 lines — not split by feature
5. models/ in lib/core/ mix domain and Hive-specific concerns
6. No domain layer (use cases) — repositories called directly from BLoCs
