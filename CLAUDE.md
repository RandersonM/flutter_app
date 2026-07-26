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
| Code Generation | json_serializable + build_runner (Hive adapters are hand-written) |
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
│   ├── vegapunk_chat/
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
                     abstract interface (I*Repository or I*Service)
                                    ↓
                       concrete impl (Firestore / API / Hive)
                                    ↓
                        Firebase / External API / Local DB
```

**The one hard rule: a BLoC/Cubit never reaches for `getIt` itself.** Every
dependency arrives through the constructor, typed as an abstract interface, and
is wired in `features_module.dart`. That is what makes a BLoC testable without
booting the whole container.

There is no `domain/` layer and no use-case classes — the app does not have
business logic complex enough to earn them. Do not add them.

**Repository vs. Service** — both are valid direct dependencies of a BLoC:

| Use a `I*Repository` | Use a `I*Service` |
|---|---|
| Composes or caches more than one source (e.g. Firestore + Hive) | Wraps a single backend or is pure computation |
| Owns a feature's collection shape | Reusable across features |
| Lives in `features/<name>/data/repository/` | Lives in `core/services/<area>/` |

A repository that only forwards calls to one service is ceremony — depend on
the service directly instead.

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
- Do not introduce Riverpod or Provider for new features; there is no
  `ChangeNotifier` left in the codebase and none should be added
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

## Colors & Theming

**Never write a raw `Colors.*` for anything that carries meaning.** The theme is
the source of truth, so light and dark are decided in one place instead of by
each widget.

| Need | Use |
|---|---|
| Brand, surfaces, text | `Theme.of(context).colorScheme.*` |
| Error / destructive | `Theme.of(context).colorScheme.error` |
| Success, warning, info | `Theme.of(context).semanticColors.*` |

`semanticColors` comes from `AppSemanticColors`, a `ThemeExtension` registered in
both `getLightTheme()` and `getDarkTheme()` — see
`lib/shared/utils/app_semantic_colors.dart`. It exists because `ColorScheme` has
no slot for success/warning/info, which is why those were previously hardcoded.
Import it to get the `semanticColors` getter:

```dart
import 'package:opfan/shared/utils/app_semantic_colors.dart';

final semantic = Theme.of(context).semanticColors;
Icon(PhosphorIconsRegular.checkCircle, color: semantic.success);
```

A raw `Colors.*` is only acceptable when the colour is **not** semantic:
- a third-party brand colour (YouTube red in `youtube_player_screen.dart`)
- a **categorical** palette where hues only need to differ from each other, not
  to mean anything — `RoleIconMapper` assigns 20 crew roles 20 distinguishable
  colours; folding those into success/warning/info would erase the distinction
- purely decorative art (`futuristic_background.dart`)
- `Colors.transparent`

If a colour states "this is good / careful / broken", it belongs in the theme.

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
| `app_routes.dart` | High | ~220-line monolith; prone to merge conflicts |
| `core_module.dart` | High | Service/repo wiring in one place; circular dependency risk |
| `AuthBloc` | High | Complex subscription logic |
| Hive type ids | High | Collisions corrupt local data silently on upgrade — ids are owned by `lib/core/storage/hive_type_ids.dart` and guarded by `test/core/storage/hive_type_ids_test.dart`. Never write a literal `typeId` in an adapter, and never reuse a shipped id |
| `NavigationService` | Medium | Owns the app's single `navigatorKey` — always resolve via `getIt<INavigationService>()`; a second instance detaches programmatic navigation |
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
- [ ] Follow structure: `presentation/`, `bloc/` (or `cubit/`), `data/` — no `domain/`
- [ ] Take every dependency via the constructor as an abstract interface; never
      call `getIt` from inside a BLoC/Cubit
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
