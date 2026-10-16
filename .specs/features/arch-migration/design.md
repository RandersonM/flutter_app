# Architecture Migration Design

## Target Folder Structure

```
lib/
├── app/
│   ├── app.dart                    # MyApp widget (moved from main.dart inline)
│   └── di/
│       ├── injection.dart          # setupServiceLocator() entrypoint
│       ├── core_module.dart        # Auth, Firestore, Notification, Navigation
│       ├── theme_module.dart       # ThemeCubit
│       ├── locale_module.dart      # LocaleCubit
│       └── features_module.dart    # All feature BLoCs/Cubits
│
├── core/
│   ├── auth/
│   │   ├── bloc/                   # AuthBloc (rename from blocs/)
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   ├── auth_state.dart
│   │   │   └── index.dart
│   │   ├── data/
│   │   │   ├── auth_service.dart
│   │   │   └── models/
│   │   │       └── user_model.dart
│   │   └── app_wrapper.dart
│   │
│   ├── theme/
│   │   ├── cubit/
│   │   │   ├── theme_cubit.dart    # NEW — replaces ThemeService ChangeNotifier
│   │   │   └── theme_state.dart
│   │   └── data/
│   │       └── theme_persistence.dart  # Hive only, no ChangeNotifier
│   │
│   ├── locale/
│   │   ├── cubit/
│   │   │   ├── locale_cubit.dart   # NEW — replaces LocaleService ChangeNotifier
│   │   │   └── locale_state.dart
│   │   └── data/
│   │       └── locale_persistence.dart
│   │
│   └── network/
│       └── firestore_service.dart  # Moved from core/services/
│
├── features/
│   ├── home/
│   │   ├── bloc/
│   │   ├── data/repository/
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   │
│   ├── one_piece/
│   │   ├── bloc/
│   │   ├── data/
│   │   │   └── models/
│   │   └── presentation/
│   │
│   ├── crews/
│   │   ├── bloc/
│   │   ├── data/repository/
│   │   └── presentation/
│   │
│   ├── custom_character/
│   │   ├── bloc/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── devil_fruit/
│   │   ├── bloc/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── duels/
│   │   ├── bloc/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── nami_finances/
│   │   ├── bloc/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── robin_knowledge/
│   │   ├── bloc/
│   │   ├── data/repository/
│   │   └── presentation/
│   │
│   ├── sanji_cooking/
│   │   ├── bloc/
│   │   ├── data/repository/
│   │   └── presentation/
│   │
│   ├── zoro_workout/
│   │   ├── bloc/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── calculator/
│       ├── cubit/
│       │   ├── calculator_cubit.dart   # NEW — replaces CalculatorProvider
│       │   └── calculator_state.dart
│       └── presentation/
│           ├── calculator_screen.dart
│           └── widgets/
│
├── shared/
│   ├── widgets/                    # atoms / molecules / organisms
│   ├── models/                     # Shared Hive models
│   └── utils/                      # app_routes, theme defs, constants
│
└── l10n/                           # Unchanged
```

---

## Key Migration Decisions

### Decision 1: ThemeService → ThemeCubit

**Before:**
```dart
class ThemeService extends ChangeNotifier {
  static Future<void> toggleTheme() async { ... notifyListeners(); }
}
// MyApp.initState():
ThemeService().addListener(_onThemeChanged);
```

**After:**
```dart
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial());
  Future<void> toggleTheme() async {
    final next = !state.isDarkMode;
    await _persistence.save(isDarkMode: next);
    emit(ThemeState(isDarkMode: next));
  }
}
// MyApp build():
BlocBuilder<ThemeCubit, ThemeState>(
  builder: (context, themeState) => MaterialApp(
    themeMode: themeState.themeMode,
    ...
  ),
)
```

GetIt: `registerLazySingleton<ThemeCubit>(() => ThemeCubit()..initialize())`

---

### Decision 2: LocaleService → LocaleCubit

**Before:**
```dart
class LocaleService extends ChangeNotifier {
  void setLocale(Locale locale) { _locale = locale; notifyListeners(); }
}
```

**After:**
```dart
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(locale: Locale('en')));
  void setLocale(Locale locale) => emit(LocaleState(locale: locale));
}
```

GetIt: `registerLazySingleton<LocaleCubit>(() => LocaleCubit())`

---

### Decision 3: CalculatorProvider → CalculatorCubit

**Before:**
```dart
// CalculatorScreen uses ChangeNotifierProvider<CalculatorProvider>
class CalculatorProvider extends ChangeNotifier {
  String _result = '0';
  void equalPressed() { ... notifyListeners(); }
}
```

**After:**
```dart
class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorState.initial());
  void equalPressed() { ... emit(state.copyWith(result: eval.toString())); }
}
// CalculatorScreen:
BlocProvider(
  create: (_) => getIt<CalculatorCubit>(),
  child: BlocBuilder<CalculatorCubit, CalculatorState>(...),
)
```

---

### Decision 4: DI Module Split

**Before:** `service_locator.dart` — 191 lines, all dependencies in one file.

**After:**
```dart
// lib/app/di/injection.dart
Future<void> setupDependencies() async {
  await registerCoreModule();
  registerThemeModule();
  registerLocaleModule();
  registerFeaturesModule();
}
```

Each module only registers its own slice. `injection.dart` is the entry point called from `main.dart`.

---

## Global BlocProvider Tree (Target — app.dart)

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()..add(const AuthStarted())),
    BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
    BlocProvider<LocaleCubit>(create: (_) => getIt<LocaleCubit>()),
    BlocProvider<RobinKnowledgeBloc>(create: (_) => getIt<RobinKnowledgeBloc>()),
  ],
  child: BlocBuilder<ThemeCubit, ThemeState>(
    builder: (context, themeState) =>
      BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) => MaterialApp(
          themeMode: themeState.themeMode,
          locale: localeState.locale,
          ...
        ),
      ),
  ),
)
```

---

## Risk Matrix

| Change                   | Risk   | Mitigation                                |
|--------------------------|--------|-------------------------------------------|
| ThemeCubit migration     | Medium | Test toggle before/after in both themes   |
| LocaleCubit migration    | Medium | Test en/pt-BR switch                      |
| CalculatorCubit          | Low    | Isolated to one screen                    |
| Folder restructure       | High   | One feature at a time, compile after each |
| DI module split          | Medium | Same GetIt registrations, just split files|
| Remove provider package  | Low    | Last step, after all ChangeNotifier gone  |
