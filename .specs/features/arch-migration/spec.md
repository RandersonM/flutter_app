# Architecture Migration Spec

## Initiative: BLoC-Only State + Modular Structure

**Status:** Planning  
**Complexity:** Large Initiative → Full Workflow: Specify → Design → Tasks → Execute  

---

## Goals

| ID | Requirement |
|----|-------------|
| ARCH-01 | All state management SHALL use BLoC/Cubit — no ChangeNotifier, no Provider package for state |
| ARCH-02 | ThemeService SHALL be migrated to ThemeCubit registered as singleton in GetIt |
| ARCH-03 | LocaleService SHALL be migrated to LocaleCubit registered as singleton in GetIt |
| ARCH-04 | CalculatorProvider SHALL be migrated to CalculatorCubit |
| ARCH-05 | Folder structure SHALL be feature-first (features/ directory) |
| ARCH-06 | Each feature SHALL be self-contained: bloc/, data/, presentation/ |
| ARCH-07 | Shared code SHALL live in shared/ or core/ with clear ownership |
| ARCH-08 | service_locator.dart SHALL be split into feature-scoped modules |
| ARCH-09 | app_routes.dart SHALL be modular (routes defined per feature, aggregated centrally) |
| ARCH-10 | All existing behavior SHALL be preserved — no functional regressions |
| ARCH-11 | provider package SHALL be removed from pubspec.yaml after migration |

## Out of Scope (this initiative)

- GoRouter/auto_route migration (navigation remains manual Navigator)
- Riverpod migration
- Adding domain use-case layer
- Adding tests
- Dio standardization
- Firebase architecture changes

## Constraints

- Must remain on flutter_bloc ^9.1.1
- All Hive adapters must remain compatible (no TypeId changes)
- Firebase configuration must not change
- Localization must continue working (en/pt-BR)
- GetIt remains the DI mechanism

## Acceptance Criteria

- [ ] `provider` package no longer imported anywhere except pubspec.yaml (then removed)
- [ ] ThemeService ChangeNotifier replaced by ThemeCubit
- [ ] LocaleService ChangeNotifier replaced by LocaleCubit
- [ ] CalculatorProvider replaced by CalculatorCubit
- [ ] lib/ folder structure follows feature-first layout
- [ ] `flutter analyze` passes with no new warnings
- [ ] App builds and runs without errors
- [ ] Theme switching works
- [ ] Locale switching works
- [ ] Calculator works
- [ ] All 18 screens load correctly
