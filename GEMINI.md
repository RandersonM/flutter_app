# OpFan — Gemini Development Guide

## Project Summary

**OpFan** is a Flutter-based One Piece fan application. It uses Firebase for authentication and data storage, Hive for offline caching, BLoC for state management, and GetIt for dependency injection. The app supports **English (en)** and **Portuguese/pt-BR (pt)** and all user-facing text must be internationalized.

---

## Tech Stack Quick Reference

| Concern | Solution |
|---|---|
| Language | Dart >=3.0.0 |
| Framework | Flutter >=3.10.0 |
| State Management | flutter_bloc (BLoC/Cubit pattern) |
| Dependency Injection | get_it |
| Auth | firebase_auth + Google Sign-In |
| Database | Cloud Firestore |
| Local Storage | Hive |
| HTTP | Dio |
| AI | google_generative_ai (Gemini API) |
| Localization | ARB files + flutter_localizations + intl |
| Charts | fl_chart |
| Routing | Navigator.pushNamed with route constants |

---

## Codebase Layout

```
lib/
├── app/di/                  # Dependency injection (GetIt modules)
├── core/                    # Auth, models, services, theme, locale
├── features/                # 18 feature modules (see list below)
├── shared/
│   ├── widgets/
│   │   ├── atoms/           # Primitive UI components
│   │   ├── molecules/       # Composite components
│   │   └── organisms/       # Feature-level components
│   └── utils/               # Route constants, theme helpers
└── l10n/
    ├── intl_en.arb          # English strings (master)
    └── intl_pt.arb          # Portuguese strings
```

### Feature Modules

| Feature | Description |
|---|---|
| `auth` | Firebase Auth + Google Sign-In flow |
| `home` | Dashboard with featured content |
| `one_piece` | Character browser |
| `devil_fruit` | Devil Fruit database |
| `crews` | Pirate crew management |
| `custom_character` | Create/edit custom characters |
| `duels` | Battle simulator |
| `nami_finances` | Personal finance tracker |
| `robin_knowledge` | Trivia and knowledge base |
| `sanji_cooking` | Recipe collection |
| `youtube` | In-app YouTube video player |
| `zoro_workout` | Workout planner |
| `calculator` | Math utility |
| `profile` | User profile management |
| `onboarding` | First-time user flow |
| `splash` | Launch screen |
| `fav_character_selection` | Character picker |
| `user_profile` | Core user data model |

---

## Architecture Patterns

### BLoC / Cubit

Every feature uses a BLoC or Cubit for state management. UI widgets listen to state via `BlocBuilder` or `BlocListener` — they must not contain business logic.

```
Screen (StatelessWidget)
  └── BlocBuilder<FeatureBloc, FeatureState>
        └── renders based on state
```

- **BLoC**: use when the feature has multiple event types (e.g., fetch, filter, submit)
- **Cubit**: use for simpler state with direct method calls (e.g., toggle, increment)
- States are immutable. Use `copyWith` for updates.
- Events are sealed classes.

### Repository Pattern

Each feature that touches remote or local data has an abstract repository interface and a concrete implementation:

```dart
abstract class RecipeRepository {
  Future<List<Recipe>> fetchRecipes();
}

class FirestoreRecipeRepository implements RecipeRepository { ... }
```

BLoCs depend on the abstract interface, never the concrete class.

### Dependency Injection (GetIt)

```dart
// Registering (in features_module.dart)
getIt.registerFactory<SanjiCookingBloc>(
  () => SanjiCookingBloc(repository: getIt()),
);

// Resolving (in widget)
BlocProvider(create: (_) => getIt<SanjiCookingBloc>())
```

- **Singletons**: Services, AuthBloc, global cubits
- **Factories**: Feature BLoCs (one instance per screen)

---

## Internationalization (i18n) — Required

**All user-facing strings must be localized. Never hardcode text in widgets.**

### Supported Locales

| Language | Code | ARB File |
|---|---|---|
| English | `en` | `lib/l10n/intl_en.arb` |
| Portuguese (Brazil) | `pt` | `lib/l10n/intl_pt.arb` |

### Adding a New String

**Step 1** — Add to `lib/l10n/intl_en.arb`:
```json
{
  "cookingTips": "Cooking Tips",
  "@cookingTips": {
    "description": "Title for the cooking tips screen"
  }
}
```

**Step 2** — Add the same key to `lib/l10n/intl_pt.arb`:
```json
{
  "cookingTips": "Dicas de Culinária"
}
```

**Step 3** — Regenerate localizations:
```bash
flutter gen-l10n
```

**Step 4** — Use in widget:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.cookingTips)
```

### Runtime Language Switching

The app uses `LocaleCubit` to switch languages at runtime. Locale is persisted across sessions via `LocaleService`.

```dart
// Switch to Portuguese
context.read<LocaleCubit>().setLocale(const Locale('pt'));

// Switch to English
context.read<LocaleCubit>().setLocale(const Locale('en'));
```

### ARB File Format — Best Practices

```json
{
  "@@locale": "en",

  "simpleString": "Hello, World!",
  "@simpleString": { "description": "A simple greeting" },

  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Personalized greeting",
    "placeholders": {
      "name": { "type": "String" }
    }
  },

  "itemCount": "{count, plural, one{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Item count with pluralization",
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

---

## Routing

Routes are string constants defined in per-feature `*_routes.dart` files and aggregated in `lib/shared/utils/app_routes.dart`.

```dart
// Navigating to a screen
Navigator.pushNamed(context, AppRoutes.sanjiCooking);

// Programmatic navigation (outside widget tree)
getIt<NavigationService>().navigateTo(AppRoutes.home);
```

Routes that require authentication must be registered in `AuthRouteMiddleware`. Public routes (login, onboarding) do not.

---

## Firebase Firestore — Data Patterns

- **Collection per feature**: each feature owns its Firestore collection
- **User-scoped documents**: user data is stored under `users/{userId}/...`
- **Auth required**: all writes require an authenticated user (enforced by `firestore.rules`)
- **No direct Firestore calls in BLoC**: always go through a Repository and Service

```dart
// Service layer example
class RecipeService {
  final FirebaseFirestore _db;

  Future<List<Recipe>> getUserRecipes(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('recipes')
        .get();
    return snap.docs.map((d) => Recipe.fromJson(d.data())).toList();
  }
}
```

---

## Local Storage (Hive)

- Hive is used for offline-first caching of Firestore data and user preferences
- Each model that needs caching has a `@HiveType` annotation and a generated adapter
- TypeId values are globally unique integers — **never reuse or reorder them**
- Run `build_runner` after modifying Hive models

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Gemini AI Integration

The app uses `google_generative_ai` for generative features (e.g., AI character images, cooking suggestions).

```dart
// lib/core/services/gemini_service.dart
final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: dotenv.env['GEMINI_API_KEY']!,
);
final response = await model.generateContent([Content.text(prompt)]);
```

API keys are stored in `.env` — never hardcode them.

---

## Environment Variables

Use `flutter_dotenv` to access keys. Never commit `.env`.

```
GEMINI_API_KEY=...
YOUTUBE_API_KEY=...
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
final key = dotenv.env['GEMINI_API_KEY']!;
```

---

## Shared Widget Guidelines (Atomic Design)

| Level | Folder | Rule |
|---|---|---|
| Atom | `shared/widgets/atoms/` | Pure UI, no BLoC, no business logic |
| Molecule | `shared/widgets/molecules/` | Composes atoms, no BLoC |
| Organism | `shared/widgets/organisms/` | May read from BLoC via `context` |

---

## Code Generation

After modifying JSON-serializable or Hive models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Development Commands

```bash
flutter pub get                                               # install dependencies
flutter gen-l10n                                              # regenerate localizations
flutter pub run build_runner build --delete-conflicting-outputs  # code generation
flutter run                                                   # run on connected device
flutter analyze                                               # static analysis
flutter test                                                  # run all tests
```

---

## Feature Development Checklist

When creating or extending a feature:

- [ ] Directory: `lib/features/<feature_name>/presentation/`, `bloc/` or `cubit/`, `data/`, `domain/`
- [ ] Register BLoC/Cubit in `lib/app/di/features_module.dart`
- [ ] Add route constant to `<feature>_routes.dart` and register in `app_routes.dart`
- [ ] Add auth guard in `AuthRouteMiddleware` if route is private
- [ ] Add all user-facing strings to **both** `intl_en.arb` and `intl_pt.arb`
- [ ] Run `flutter gen-l10n` after adding strings
- [ ] Write at least one unit test for the BLoC/Cubit

---

## Known Architecture Constraints

| Area | Notes |
|---|---|
| `app_routes.dart` | Large monolithic file — edit carefully to avoid merge conflicts |
| `AuthBloc` | Global singleton; 224-line state machine — do not refactor without full test coverage |
| Hive TypeIds | Never reuse or renumber — causes local data corruption on upgrades |
| `CalculatorProvider` | Legacy ChangeNotifier — migrate to Cubit if touching this feature |
| Navigator routing | String-based — no compile-time safety; prefer named constants from route files |

---

## Documentation

- `.specs/codebase/ARCHITECTURE.md` — full architecture reference
- `.specs/codebase/STACK.md` — tech stack breakdown
- `.specs/codebase/CONCERNS.md` — risk registry and fragile areas
- `.specs/features/` — per-feature specs, designs, and task breakdowns
