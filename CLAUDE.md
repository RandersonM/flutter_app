# OpFan — Claude Code Guide

## Project Overview

**OpFan** is a One Piece fan app built with Flutter. It integrates Firebase for auth/database, Gemini AI for generative features, and supports English and Portuguese localization. The app is structured with a feature-first, BLoC-driven architecture using GetIt for dependency injection.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter >=3.10.0 / Dart >=3.0.0 |
| State Management | flutter_bloc ^9.1.1 + bloc ^9.0.0 |
| DI / Service Locator | get_it ^7.6.4 |
| Backend | Firebase (Auth, Firestore, Cloud Functions, FCM) |
| Local Storage | Hive ^2.2.3 |
| HTTP Client | Dio ^5.4.0 |
| AI / Generative | google_generative_ai ^0.3.0 (Gemini) |
| Code Generation | json_serializable + hive_generator + build_runner |
| Routing | Navigator.pushNamed + AuthRouteMiddleware |
| Localization | ARB files + flutter_localizations + intl ^0.20.2 |
| Charts | fl_chart ^1.0.0 |
| Font Manager | FVM (Flutter Version Manager) |

---

## Project Structure

```
lib/
├── app/
│   └── di/
│       ├── injection.dart          # GetIt bootstrap
│       ├── core_module.dart        # Services & repositories
│       ├── features_module.dart    # Feature BLoCs/Cubits
│       ├── theme_module.dart
│       └── locale_module.dart
├── core/
│   ├── auth/                       # AuthBloc + UserModel (global singleton)
│   ├── models/                     # Domain models
│   ├── services/                   # 12+ service classes
│   ├── middleware/                 # AuthRouteMiddleware
│   ├── theme/                      # ThemeCubit
│   ├── locale/                     # LocaleCubit
│   └── user_profile/
├── features/                       # 18 feature modules
│   ├── auth/
│   ├── home/
│   ├── calculator/
│   ├── one_piece/
│   ├── devil_fruit/
│   ├── crews/
│   ├── custom_character/
│   ├── duels/
│   ├── nami_finances/
│   ├── robin_knowledge/
│   ├── sanji_cooking/
│   ├── youtube/
│   ├── zoro_workout/
│   ├── profile/
│   ├── onboarding/
│   ├── splash/
│   └── fav_character_selection/
├── shared/
│   ├── widgets/
│   │   ├── atoms/                  # Smallest reusable components
│   │   ├── molecules/              # Medium composite components
│   │   └── organisms/             # Large/page-level components
│   └── utils/                      # Routes, theme helpers, transitions
└── l10n/
    ├── intl_en.arb                 # English (master template)
    └── intl_pt.arb                 # Portuguese
```

---

## Architecture

### Data Flow

```
Screen → BlocProvider (GetIt) → BLoC/Cubit
                                    ↓
                            Repository (abstract interface)
                                    ↓
                         Service (Auth/Firestore/API/Hive)
                                    ↓
                        Firebase / External API / Local DB
```

### Dependency Injection (GetIt)

- **Singletons**: AuthBloc, RobinKnowledgeBloc, all core services
- **Factories**: Feature-specific BLoCs (one per screen lifecycle)
- Registration split across `core_module.dart` and `features_module.dart`

### BLoC Conventions

- Each feature has its own `bloc/` or `cubit/` subdirectory
- Events are sealed classes; States are immutable (use `copyWith`)
- BLoCs must not reference UI or BuildContext
- Cubits are preferred for simple state without event branching

---

## Internationalization (i18n)

**This app must be fully internationalized. All user-facing strings must use localization keys — never hardcode text in widgets.**

### Supported Languages

| Language | ARB File | Code |
|---|---|---|
| English | `lib/l10n/intl_en.arb` | `en` |
| Portuguese (Brazil) | `lib/l10n/intl_pt.arb` | `pt` |

### Configuration

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: intl_en.arb
output-localization-file: app_localizations.dart
```

### How to Add a New String

1. Add the key + English value to `lib/l10n/intl_en.arb`
2. Add the same key + Portuguese value to `lib/l10n/intl_pt.arb`
3. Run `flutter gen-l10n` (or `flutter pub get` triggers it via l10n.yaml)
4. Use the generated class in widgets: `AppLocalizations.of(context)!.yourKey`

### Runtime Language Switching

`LocaleCubit` manages the active locale and persists it via `LocaleService`. Do not read locale from device directly; always go through `LocaleCubit`.

```dart
// Switch to Portuguese
context.read<LocaleCubit>().setLocale(const Locale('pt'));
```

---

## State Management Rules

- Primary pattern: **BLoC/Cubit** via flutter_bloc
- `CalculatorProvider` (ChangeNotifier) is a known legacy — migrate to Cubit on touch
- Do not introduce Riverpod or Provider for new features
- Never put business logic in widgets; delegate to BLoC/Cubit

---

## Routing

- Routes defined in `lib/shared/utils/app_routes.dart` and per-feature `*_routes.dart` files
- Auth guard via `AuthRouteMiddleware.onGenerateRoute()`
- `NavigationService` holds a `GlobalKey<NavigatorState>` for programmatic navigation
- New screens must register a route constant in the relevant `*_routes.dart` and add it to the middleware chain if it requires auth

---

## Firebase Integration

- **Auth**: Google Sign-in via firebase_auth
- **Database**: Cloud Firestore (collection-per-feature pattern)
- **Functions**: TypeScript in `/functions/src/`
- **Config**: `lib/firebase_options.dart` (auto-generated — do not edit manually)
- **Rules**: `firestore.rules` — all writes require authenticated users; data is user-scoped

---

## Environment Variables

All sensitive keys live in `.env` (never commit this file). Use `flutter_dotenv`:

```dart
final apiKey = dotenv.env['GEMINI_API_KEY']!;
```

See `.env.example` for required keys.

---

## Code Generation

After modifying any model annotated with `@JsonSerializable` or `@HiveType`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Shared Widget System (Atomic Design)

| Level | Location | Rule |
|---|---|---|
| Atom | `shared/widgets/atoms/` | No BLoC dependency, pure UI |
| Molecule | `shared/widgets/molecules/` | May compose atoms, no BLoC |
| Organism | `shared/widgets/organisms/` | May depend on BLoC via context |

---

## Known Fragile Areas (Handle with Care)

| Area | Risk | Notes |
|---|---|---|
| `app_routes.dart` | High | 296-line monolith; prone to merge conflicts |
| `injection.dart` | High | All DI in one place; circular dependency risk |
| `AuthBloc` | High | Complex subscription logic; 224 lines |
| Hive TypeId assignments | High | Collisions break local data on upgrades |
| `ThemeService` / `LocaleService` | Medium | Manual listener management — memory leak risk |

---

## Testing

- Framework: `flutter_test` + `mockito`
- Test entry: `test/testable_widget.dart` wraps widgets with required providers
- Run tests: `flutter test`
- Fixtures in `test/fixtures/`
- Coverage is minimal — prioritize tests for BLoC logic and repositories

---

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Deploy Firebase functions
cd functions && npm run deploy
```

---

## Feature Development Checklist

When adding a new feature:

- [ ] Create feature directory under `lib/features/<feature_name>/`
- [ ] Follow structure: `presentation/`, `bloc/` (or `cubit/`), `data/`, `domain/`
- [ ] Register BLoC/Cubit in `lib/app/di/features_module.dart`
- [ ] Add routes to a new `<feature>_routes.dart` and register in `app_routes.dart`
- [ ] Add all user-facing strings to both `intl_en.arb` and `intl_pt.arb`
- [ ] Add auth guard in `AuthRouteMiddleware` if the route is private
- [ ] Write at least one BLoC unit test

---

## Architecture Docs

Detailed specs live in `.specs/`:
- `.specs/codebase/ARCHITECTURE.md` — full architecture reference
- `.specs/codebase/STACK.md` — tech stack details
- `.specs/codebase/CONCERNS.md` — risk registry
- `.specs/features/` — per-feature specs and task breakdowns
