---
paths:
  - "lib/**/*.dart"
---

# Architecture

## Layers

```
presentation (widgets)  →  bloc (BLoC/Cubit)  →  I*Repository | I*Service  →  Firestore · Hive · REST · flutter_gemma · Gemini
```

- Dependencies point one way. Widgets talk to BLoCs; BLoCs talk to abstract
  repositories/services; only implementations know the backend.
- **There is no `domain/` layer and no use-case classes.** The app has no business
  logic complex enough to earn them. Pure business math lives next to its data as a
  plain Dart file (golden: `lib/features/nami_finances/data/finance_math.dart`).
- Global state (`AuthBloc`, `ConnectivityCubit`, `ThemeCubit`, `LocaleCubit`) is
  read by widgets through context. BLoCs never reach for it — they depend on the
  service underneath (see `bloc.md`).

## Repository vs service

Both are valid direct dependencies of a BLoC.

| Use an `I*Repository` | Use an `I*Service` |
|---|---|
| Composes or caches more than one source (Firestore + Hive) | Wraps one backend, or is pure computation |
| Owns one feature's collection shape | Reusable across features |
| `lib/features/<f>/data/repository/` | `lib/core/services/<area>/` — or `lib/features/<f>/data/services/` when only that feature uses it (e.g. `nami_rag_service.dart`) |

A repository that only forwards calls to one service is ceremony — depend on the
service directly.

## Feature folder

```
lib/features/<feature>/
├── bloc/                 BLoCs and Cubits (also for Cubits; `cubit/` is legacy)
│   ├── x_bloc.dart  x_event.dart  x_state.dart
├── data/
│   ├── models/
│   ├── repository/       singular; interface + impl side by side
│   └── services/         feature-local services only
├── presentation/
│   ├── x_screen.dart     screens sit directly here, suffix `_screen`
│   └── widgets/
├── tools/                on-device AI tool handlers (Vegapunk, Nami)
└── <feature>_routes.dart
```

## Naming

- Interfaces: `abstract class IName` in `i_name.dart`, in the same folder as the
  impl. The impl drops the prefix: `CrewRepository implements ICrewRepository`.
  No `*Impl`, no backend prefix (`FirestoreCrewRepository`). Legacy
  `*_repository_interface.dart` files and `PlannerRepositoryInterface` are debt.
- Files `snake_case.dart`, one public class per file (event/state/model files may
  hold a family of related classes). Private helper widgets `_Name` may share the file.
- Barrel `index.dart` files exist for services, blocs and widget folders; add new
  public files to the barrel of their folder.

## Dependency injection

- `lib/app/di/injection.dart` runs `registerCoreModule` → `registerThemeModule` →
  `registerLocaleModule` → `registerFeaturesModule`. Order matters: a module may
  only resolve what earlier modules registered.
- Services and repositories: `getIt.registerLazySingleton<IFoo>(() => Foo(bar: getIt<IBar>()))`
  in `core_module.dart`.
- Feature BLoCs: `registerFactory` in `features_module.dart` (one instance per
  screen); `registerFactoryParam` when a runtime argument is needed.
- `getIt` is called only in `lib/app/di/`, in `main.dart`, and in a widget's
  `BlocProvider(create: (_) => getIt<XBloc>())`. Nowhere else.

## Constructors

Inject with named private params — the dominant modern form:

```dart
class CrewRepository implements ICrewRepository {
  CrewRepository({required this._firestore, required this._auth});
  final IFirestoreService _firestore;
  final IAuthService _auth;
}
```

Do not default to a global (`_auth = auth ?? FirebaseAuth.instance`); let DI pass
it. SDK handles (`FirebaseAuth`, `FirebaseFirestore`, `FirebaseMessaging`,
`GoogleSignIn`) are lazy singletons at the top of `core_module.dart`.

## Errors

- Repositories/services let failures propagate (or `rethrow` after logging). Catch
  only to translate into a typed exception the BLoC can map, or to fall back
  (cache, default) deliberately.
- Do not build user-facing messages in data code. Semantic failures use the typed
  exceptions in `lib/core/errors/app_exceptions.dart` (`NotSignedInException`,
  `NotFoundException`); malformed input throws Dart's `FormatException`.
- BLoCs map exceptions to a failure enum; widgets localize it (`bloc.md`, `i18n.md`).

## Logging

`debugPrint('ClassName: message')` — no logger package, no emojis, no `print`.
Never log secrets, tokens or full user payloads.

## Imports

`package:opfan/...` for cross-folder imports; relative only for siblings (a BLoC
importing its own event/state files, barrels). No `../../` chains.

## Comments — only when truly necessary

The code must explain itself. Before writing a comment, try to make it unnecessary:
rename the variable, extract a well-named function, introduce a type or enum,
replace a magic number with a named constant.

Write a comment only for what the code cannot say:
- a non-obvious **why** — a product decision, a platform/plugin quirk, a workaround
  for a bug (link it), a constraint that would look like a mistake otherwise;
- a reference to the spec behind a decision (`// see .specs/features/<name>/design.md`);
- `///` docs on a public interface member whose contract isn't evident from its
  signature.

Never:
- narrate what the next line does (`// load the crews`, `// increment counter`);
- leave commented-out code, TODOs without an owner/issue, or section banners in
  short files;
- add the old `// Developed by ...` / copyright header to new files.

Keep comments in English, one or two lines. When you change code, update or delete
the comments around it — a stale comment is worse than none.
