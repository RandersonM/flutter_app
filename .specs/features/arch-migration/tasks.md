# Architecture Migration Tasks

**Initiative:** BLoC-Only State + Modular Structure  
**Spec:** arch-migration/spec.md  
**Design:** arch-migration/design.md  

---

## Phase 1 — State Management Consolidation
*Remove ChangeNotifier. No folder moves yet.*

### T1 — Create ThemeCubit
**Goal:** Replace ThemeService (ChangeNotifier) with ThemeCubit  
**Files to create:**
- `lib/core/theme/cubit/theme_cubit.dart`
- `lib/core/theme/cubit/theme_state.dart`

**Files to modify:**
- `lib/core/services/service_locator.dart` — register ThemeCubit, deregister ThemeService ChangeNotifier
- `lib/main.dart` — add BlocProvider<ThemeCubit>, remove addListener/removeListener for theme
- All callers of `ThemeService.toggleTheme()` — replace with `context.read<ThemeCubit>().toggleTheme()`

**Depends on:** None  
**Requirement:** ARCH-01, ARCH-02  
**Done when:**
- ThemeCubit emits ThemeState(isDarkMode) on toggle
- Hive persistence still works (dark mode survives app restart)
- ThemeService.dart no longer extends ChangeNotifier
- No `notifyListeners()` calls remain in theme code
- `flutter analyze` passes

---

### T2 — Create LocaleCubit
**Goal:** Replace LocaleService (ChangeNotifier) with LocaleCubit  
**Files to create:**
- `lib/core/locale/cubit/locale_cubit.dart`
- `lib/core/locale/cubit/locale_state.dart`

**Files to modify:**
- `lib/core/services/service_locator.dart` — register LocaleCubit
- `lib/main.dart` — add BlocProvider<LocaleCubit>, remove addListener/removeListener for locale
- All callers of `LocaleService.setLocale()` — replace with `context.read<LocaleCubit>().setLocale()`

**Depends on:** None (parallel with T1)  
**Requirement:** ARCH-01, ARCH-03  
**Done when:**
- LocaleCubit emits LocaleState(locale) on change
- Locale persists across app restart
- No `notifyListeners()` in locale code
- `flutter analyze` passes

---

### T3 — Create CalculatorCubit
**Goal:** Replace CalculatorProvider (ChangeNotifier) with CalculatorCubit  
**Files to create:**
- `lib/features/calculator/cubit/calculator_cubit.dart`
- `lib/features/calculator/cubit/calculator_state.dart`

**Files to modify:**
- `lib/screens/calculator/calculator_screen.dart` — swap ChangeNotifierProvider → BlocProvider, Consumer → BlocBuilder
- `lib/core/services/service_locator.dart` — register CalculatorCubit, remove CalculatorProvider

**Files to delete:**
- `lib/core/calculator/calculator_provider.dart`

**Depends on:** None (parallel with T1, T2)  
**Requirement:** ARCH-01, ARCH-04  
**Done when:**
- Calculator screen functions identically (all operations work)
- No `ChangeNotifierProvider` import in calculator screen
- `provider` package no longer imported by calculator code
- `flutter analyze` passes

---

### T4 — Remove provider Package
**Goal:** Remove the `provider` package from pubspec.yaml  
**Files to modify:**
- `pubspec.yaml` — remove `provider: ^6.1.1`
- Verify no remaining imports of `package:provider/`

**Depends on:** T1, T2, T3 all complete  
**Requirement:** ARCH-11  
**Done when:**
- `grep -r "package:provider" lib/` returns nothing
- `flutter pub get` succeeds without provider
- `flutter analyze` passes

---

## Phase 2 — Folder Structure Migration
*Move files to feature-first layout. Fix imports per batch.*

### T5 — Create Target Directory Skeleton
**Goal:** Create empty directories for new structure  
**Action:** mkdir the full target tree under lib/ (no file moves yet)  
**Depends on:** T4  
**Done when:** Directory tree matches design.md target structure (empty dirs OK)

---

### T6 — Migrate core/auth
**Goal:** Move auth files to new layout  
**Files to move:**
- `lib/core/auth/blocs/` → `lib/core/auth/bloc/`
- `lib/core/auth/models/` → `lib/core/auth/data/models/`
- `lib/core/services/auth_service.dart` → `lib/core/auth/data/auth_service.dart`

**Depends on:** T5  
**Done when:** Auth BLoC still functions, login/logout/session all work

---

### T7 — Migrate core/theme and core/locale
**Goal:** Move ThemeCubit and LocaleCubit files to core/ subdirectories  
**Files to move:**
- ThemeCubit files from temp location → `lib/core/theme/cubit/`
- LocaleCubit files → `lib/core/locale/cubit/`
- Hive persistence helpers → `lib/core/theme/data/` and `lib/core/locale/data/`

**Depends on:** T1, T2, T5  
**Done when:** Theme and locale still work after move + import updates

---

### T8 — Migrate features/home
**Goal:** Move home screen and BLoC to features/home/  
**Files to move:**
- `lib/screens/home/` → `lib/features/home/presentation/`
- `lib/screens/home/blocs/` → `lib/features/home/bloc/`
- `lib/core/repository/featured_character_repository.dart` → `lib/features/home/data/repository/`

**Update imports in:** HomeBloc, HomeScreen, service_locator  
**Depends on:** T5  
**Done when:** Home screen loads, featured character displays, AMV video plays

---

### T9 — Migrate features/one_piece
**Files to move:**
- `lib/screens/one_piece/` → `lib/features/one_piece/presentation/`
- `lib/screens/one_piece/blocs/` → `lib/features/one_piece/bloc/`
- `lib/core/models/one_piece/` → `lib/features/one_piece/data/models/`

**Depends on:** T5  
**Done when:** Character list, search, and filters work

---

### T10 — Migrate features/crews
**Files to move:**
- `lib/screens/crews/` → `lib/features/crews/presentation/`
- Crew BLoCs → `lib/features/crews/bloc/`
- `lib/core/repository/crew_repository.dart` → `lib/features/crews/data/repository/`

**Depends on:** T5  
**Done when:** Create/list/edit/delete crew all work

---

### T11 — Migrate remaining features (batch)
**Features:** custom_character, devil_fruit, duels, nami_finances, robin_knowledge, sanji_cooking, zoro_workout  
**Pattern for each:**
- `lib/screens/{feature}/` → `lib/features/{feature}/presentation/`
- `lib/screens/{feature}/blocs/` → `lib/features/{feature}/bloc/`
- Move associated repository if exists

**Depends on:** T5  
**Note:** Can be done in parallel per feature. Fix imports after each.  
**Done when:** All screens load, BLoCs emit correctly

---

### T12 — Migrate calculator screen
**Files to move:**
- `lib/screens/calculator/` → `lib/features/calculator/presentation/`

**Depends on:** T3, T5  
**Done when:** Calculator screen loads and all operations work

---

### T13 — Migrate shared/
**Goal:** Move shared widgets and utilities  
**Files to move:**
- `lib/widgets/` → `lib/shared/widgets/`
- `lib/utils/` → `lib/shared/utils/`

**Update imports in:** All screens and widgets  
**Depends on:** T5  
**Done when:** All screens compile with new import paths

---

## Phase 3 — DI Module Split

### T14 — Split service_locator.dart into modules
**Goal:** Replace 191-line monolith with feature-scoped modules  
**Files to create:**
- `lib/app/di/injection.dart` — setupDependencies() entrypoint
- `lib/app/di/core_module.dart` — Firestore, Auth, Notification, Navigation
- `lib/app/di/theme_module.dart` — ThemeCubit
- `lib/app/di/locale_module.dart` — LocaleCubit
- `lib/app/di/features_module.dart` — All feature BLoCs/Cubits/Repos

**Files to delete:** `lib/core/services/service_locator.dart`  
**Update:** `lib/main.dart` — call `setupDependencies()` instead of `setupServiceLocator()`

**Depends on:** T6–T13 complete (all imports stable)  
**Done when:**
- App bootstraps correctly
- All GetIt registrations work
- `flutter analyze` passes

---

## Phase 4 — Validation

### T15 — Full App Smoke Test
- [ ] App cold starts without crash
- [ ] Login with Google works
- [ ] Logout works, session cleared
- [ ] Theme toggle: dark ↔ light persists after restart
- [ ] Locale switch: en ↔ pt-BR persists
- [ ] Calculator: all operations produce correct results
- [ ] Home screen: featured character loads, AMV video plays
- [ ] One Piece: character list loads, search works, filters work
- [ ] Crews: create / view / edit / delete all work
- [ ] Custom characters: CRUD works
- [ ] Finances: monthly data loads, edit current month works
- [ ] Workout: assessment loads, history shows
- [ ] Cooking: recipes and AI tips load
- [ ] Knowledge: tasks list loads, create/complete work
- [ ] Duels: battle screen loads
- [ ] `flutter analyze` — zero new warnings

---

## Execution Order Summary

```
Phase 1 (parallel): T1 + T2 + T3
      ↓
     T4 (remove provider)
      ↓
     T5 (skeleton dirs)
      ↓
Phase 2 (parallel per feature): T6 + T7 + T8 + T9 + T10 + T11 + T12 + T13
      ↓
     T14 (DI split)
      ↓
     T15 (validation)
```

**Estimated scope:** ~40-60 file moves/creates, ~100-150 import updates  
**Recommended approach:** One task per commit. Branch: `refactor/arch-bloc-modular`
