# Architecture (Current State)

Rules live in `.claude/rules/architecture.md` (and `bloc.md`, `data-layer.md`,
`routing.md`); this page is the map. Code wins over both.

## Pattern: feature-first BLoC + repository/service, DI via get_it

```
Screen ─ BlocProvider(create: (_) => getIt<XBloc>())
           └─ XBloc(required I*Repository / I*Service)        lib/features/<f>/bloc/
                 └─ Repository: composes/caches sources        lib/features/<f>/data/repository/
                 └─ Service: wraps one backend, reusable       lib/core/services/<area>/
                       └─ Firestore · Hive · REST (Dio) · flutter_gemma · Gemini
```

No `domain/` layer and no use cases: BLoC → repository/service → source.

```
lib/
├── main.dart          setupDependencies → Hive → locale → Firebase/env/theme → FlutterGemma.initialize → runApp
├── app/               app_bloc_observer.dart, di/ (injection, core/theme/locale/features modules)
├── core/
│   ├── ai/prompts/    personas, RAG framing, image prompts, PromptLocale
│   ├── auth/          AuthBloc (blocs/), UserModel, AppWrapper
│   ├── connectivity/  ConnectivityCubit
│   ├── errors/        app_exceptions.dart
│   ├── locale/bloc/ theme/bloc/   LocaleCubit, ThemeCubit
│   ├── models/        rag/, form/, theme/
│   ├── services/      one folder per area: i_<name>.dart + impl + index.dart barrel
│   ├── storage/       HiveTypeIds
│   └── user_profile/  users/{uid} repository
├── features/<f>/      bloc/ · data/{models,repository,services} · presentation/{*_screen.dart,widgets/} · tools/ · <f>_routes.dart
├── shared/
│   ├── utils/         app_routes.dart, feature_route_module.dart, theme.dart, app_semantic_colors.dart
│   └── widgets/       atoms/ · molecules/ (no BLoC) · organisms/ (may read BLoCs), global_error_boundary.dart
└── l10n/              intl_en.arb, intl_pt.arb, generated app_localizations*.dart
```

## State management

| Layer | Pattern |
|---|---|
| Business logic (24 classes) | BLoC / Cubit |
| Global (theme, locale, auth, connectivity) | `ThemeCubit`, `LocaleCubit`, `AuthBloc` (lazy singletons), `ConnectivityCubit` (eager singleton) |
| Widget-local UI | `setState` |

No `ChangeNotifier`, Provider or Riverpod. BLoCs take every dependency through the
constructor as `I*Repository`/`I*Service`, never call `getIt`, never import Flutter
UI and never depend on another BLoC.

## Dependency injection

`lib/app/di/injection.dart`: `registerCoreModule` (SDK handles, services,
repositories, `FunctionRegistry`, `IGemmaService`, `AuthBloc`) →
`registerThemeModule` → `registerLocaleModule` → `registerFeaturesModule`
(feature BLoCs as `registerFactory`/`registerFactoryParam`; `RobinKnowledgeBloc` is a
lazy singleton on purpose). `getIt` appears only in `lib/app/di/`, `main.dart` and
widgets' `BlocProvider(create:)` / `BlocProvider.value` of a singleton.

## Navigation

Named routes. Each feature exposes a `FeatureRouteModule` (`<f>_routes.dart`: routes,
`privateRoutes`, `getRoute`); `AppRoutes._modules` aggregates them and
`AuthRouteMiddleware.onGenerateRoute()` guards private routes
(`lib/shared/utils/app_routes.dart`). `NavigationService` owns the only
`navigatorKey`.

## Naming

Interfaces `abstract class IName` in `i_name.dart` next to the impl (no
`*_repository_interface.dart`, no `*Impl`). BLoCs live in `bloc/` (no `cubit/`
folders), split into `x_bloc.dart` / `x_event.dart` / `x_state.dart` with imports
and a barrel — `part` is used only by json_serializable models. Screens sit in
`presentation/` with the `_screen` suffix.

## Known pain points

1. String-based routes (no compile-time safety).
2. `core_module.dart` wires every service in one file; registration order matters.
3. Single global RAG vector store and Gemma model shared by Vegapunk and Nami — see
   `CONCERNS.md`.
4. Backlog: `.specs/codebase/TECH_DEBT.md`.
