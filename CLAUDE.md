# OpFan — Claude Code Guide

OpFan is a One Piece fan app in Flutter. Half of it is a fan catalog (characters,
devil fruits, user-made crews and characters, duels); the other half is a set of
persona "life assistants" — **Nami** (finances), **Zoro** (workout), **Sanji**
(nutrition), **Robin** (goals) and **Vegapunk** (chat) — several of which run an
**on-device LLM (Gemma via `flutter_gemma`)** with tool calling and RAG.

Stack: Flutter 3.44.4 / Dart 3.12 (pinned in `.fvmrc`) · flutter_bloc · get_it ·
Firebase (Auth, Firestore, Functions, FCM) · Hive · Dio · flutter_gemma (+ RAG
sqlite, embeddings) · Gemini (`google_generative_ai`, images + Sanji only) ·
ARB l10n (en, pt) · phosphoricons · fl_chart.

---

## Commands — always through FVM

The global `flutter` on this machine is older than the SDK constraint
(`sdk: >=3.12.0`). **Never run bare `flutter`/`dart`**, and never "fix" a pub error
by lowering the constraint.

| Task | Command |
|---|---|
| Install deps | `fvm flutter pub get` |
| Analyze | `fvm flutter analyze --no-fatal-infos` |
| Test | `fvm flutter test` (one file: `fvm flutter test path/to/x_test.dart`) |
| Format | `fvm dart format lib test` (CI fails on any diff) |
| l10n | `fvm flutter gen-l10n` (output is committed in `lib/l10n/`) |
| Codegen | `fvm dart run build_runner build -d` (only `@JsonSerializable` models) |
| Run | `fvm flutter devices` then `fvm flutter run -d <id>` |
| Build check | `fvm flutter build apk --debug` · `fvm flutter build ios --debug --no-codesign` |
| Functions | `cd functions && npm run deploy` |

CI (`.github/workflows/code_quality.yml`) runs: gen-l10n → build_runner →
`dart format --set-exit-if-changed` → analyze → test.

## Definition of done

Hooks in `.claude/settings.json` enforce most of this automatically:

- After every Edit/Write, `.claude/hooks/dart-post-edit.sh` formats the file,
  regenerates l10n for ARB edits, and **rejects newly added lines** that break an
  objective rule below. Fix the line; do not work around the check.
- Before you finish a turn that touched Dart/ARB/pubspec,
  `.claude/hooks/stop-verify.sh` runs format check + analyze + tests and sends you
  back to fix failures.
- Escape hatch: `// harness:allow <reason>` at the end of a line, only for a
  documented exception (brand colour, categorical palette). Tell the user when you
  use it.

Beyond the hooks: add or update a test for behaviour you change, and for UI
changes run the app on a simulator when one is available.

## Golden rules

1. **BLoCs get everything through the constructor**, typed as `I*Repository` /
   `I*Service` abstract classes, wired in `lib/app/di/`. A BLoC never calls
   `getIt`, never imports Flutter UI, never depends on another BLoC.
2. **No `domain/` layer, no use-case classes.** BLoC → repository/service → source.
3. **Every user-facing string is an ARB key** in both `intl_en.arb` and
   `intl_pt.arb`. That includes error messages: states carry a failure key/enum,
   the widget localizes it.
4. **Colours come from the theme** — `colorScheme`, or `semanticColors` for
   success/warning/info. No raw `Colors.*`, hex or `AppColors.red/green` for meaning.
5. **Hive type ids come from `HiveTypeIds`** (`lib/core/storage/hive_type_ids.dart`).
   Never write a literal, never reuse a shipped id.
6. **Config comes from `IEnvironmentService`.** Never read `.env` (it holds real
   keys and is denied to you) — use `.env.example` to learn the key names.
7. **On-device AI limits are product decisions:** keep `maxTokens: 4096` and the
   Gemma E2B model; do math and routing in Dart, not in the model; touch the vector
   store only through `RagStoreCoordinator`. Details: `.claude/rules/ai-on-device.md`.
8. **No `ChangeNotifier`, Provider or Riverpod.**
9. **Do not edit generated files:** `lib/firebase_options.dart`,
   `lib/l10n/app_localizations*.dart`, `*.g.dart`.
10. **Code wins over docs.** `.specs/` and `docs/` are partly stale (e.g. the
    vegapunk-chat spec predates the current pipeline). When they disagree with the
    code, trust the code and update the doc in the same change.
11. **Code explains itself; comments are a last resort.** Make intent clear through
    names, small functions and types. Comment only when it is truly necessary — a
    non-obvious *why* the code cannot express (a platform quirk, a product decision,
    a workaround). Never narrate *what* the code does. Details: `architecture.md`.

## Architecture at a glance

```
Screen ─ BlocProvider(create: (_) => getIt<XBloc>())
           └─ XBloc(required I*Repository / I*Service)        lib/features/<f>/bloc/
                 └─ Repository: composes/caches sources        lib/features/<f>/data/repository/
                 └─ Service: wraps one backend, reusable       lib/core/services/<area>/
                       └─ Firestore · Hive · REST (Dio) · flutter_gemma · Gemini
```

```
lib/
├── app/di/            injection.dart → core_module → theme_module → locale_module → features_module
├── core/
│   ├── ai/prompts/    persona system prompts, RAG framing, PromptLocale
│   ├── auth/          AuthBloc (global), UserModel, AppWrapper (root switch on AuthState)
│   ├── connectivity/  ConnectivityCubit (global)
│   ├── locale/ theme/ LocaleCubit, ThemeCubit (global)
│   ├── services/      I*Service + impl per area (gemma, rag, gemini, finances, config, ...)
│   ├── storage/       HiveTypeIds registry
│   └── user_profile/  users/{uid} profile repository
├── features/<f>/      bloc/ · data/{models,repository,services} · presentation/{*_screen.dart,widgets/} · tools/ · <f>_routes.dart
├── shared/
│   ├── utils/         app_routes.dart (+ AuthRouteMiddleware), theme.dart, app_semantic_colors.dart, constants.dart
│   └── widgets/       atoms/ · molecules/ (no BLoC) · organisms/ (may read BLoCs)
└── l10n/              intl_en.arb (template), intl_pt.arb, generated app_localizations*.dart
```

## Rules by topic (`.claude/rules/`)

Path-scoped rules load automatically when you read or edit a matching file. Read the
relevant one up front when planning work that spans several areas.

| File | Covers |
|---|---|
| `architecture.md` | Layers, repository vs service, DI, folder & file naming, errors, logging, imports |
| `bloc.md` | State/event shape, constructor injection, failures, `close()`, registration |
| `data-layer.md` | Repositories, services, Firestore access, models & serialization, Hive, env |
| `ui.md` | Screen shape, atomic design, theming & colours, icons, spacing |
| `i18n.md` | ARB workflow, keys, plurals/placeholders, localizing failures |
| `routing.md` | `FeatureRouteModule`, private routes, navigation |
| `ai-on-device.md` | Gemma lifecycle, tool calling, intent routing, RAG, prompts, memory limits |
| `firebase.md` | Firestore collections & rules, Cloud Functions, FCM |
| `testing.md` | mocktail + bloc_test, fakes, widget tests, what to test |
| `domains/*.md` | Business rules and known debt per feature area |

## Domain map

| Area | Features | Storage | Rule file |
|---|---|---|---|
| Catalog | `one_piece`, `devil_fruit`, `home`, `youtube`, `fav_character_selection` | Firestore `featuredCharacters`, One Piece API, YouTube API, Hive cache | `domains/catalog.md` |
| User creations | `crews`, `custom_character`, `duels` | Firestore `crews`, `custom_characters` | `domains/crews-characters-duels.md` |
| Account | `auth`, `onboarding`, `profile`, `splash`, `core/auth`, `core/user_profile` | Firebase Auth, `users/{uid}`, encrypted Hive `auth_cache_encrypted` | `domains/account.md` |
| Nami | `nami_finances` | Hive only (encrypted per-user `nami_finances_<uid>`) + Nami RAG store | `domains/nami-finances.md` |
| Zoro / Sanji | `zoro_workout`, `sanji_cooking` | Firestore `workout_assessments`; Gemini | `domains/zoro-sanji.md` |
| Robin | `robin_knowledge` | Firestore `planner` | `domains/robin-knowledge.md` |
| Vegapunk | `vegapunk_chat` | Gemma + RAG + Hive chat history | `domains/vegapunk-chat.md` |
| Utility | `calculator` | — | — |

## Fragile areas

| Area | Why |
|---|---|
| Hive type ids | A collision corrupts local data silently on upgrade. Guarded by `test/core/storage/hive_type_ids_test.dart`. |
| `GemmaService._recreateChat` | Any model reload closes **every** chat session, Nami's included. |
| `RagStoreCoordinator` | One global vector store; clearing wipes everything; no per-doc delete. |
| `UserStorageService` / `UserDataNames` | Per-user, encrypted local data. A box or database missing from `UserDataNames` leaks across accounts and survives account deletion; losing the keychain key resets the boxes. |
| `AuthBloc` | Global singleton with stream subscriptions; `AuthStarted` is dispatched only from `AppWrapper`. |
| `core_module.dart` | All service wiring in one place; watch registration order and cycles. |
| `NavigationService` | Owns the only `navigatorKey`; always `getIt<INavigationService>()`. |
| `firestore.rules` | Several collections are open to any signed-in user — see `.claude/rules/firebase.md` before relying on rules for security. |
| iOS memory | Gemma E2B needs the `increased-memory-limit` entitlement; an OOM kill leaves no Dart error. |

## Workflow

- **Specs:** non-trivial features get `.specs/features/<kebab-name>/` with
  `spec.md`, `design.md`, `tasks.md`. Codebase-wide notes live in
  `.specs/codebase/` (`ARCHITECTURE.md`, `STACK.md`, `CONCERNS.md`).
- **New feature checklist:** folder per the tree above → BLoC registered in
  `features_module.dart` → `<f>_routes.dart` added to `AppRoutes._modules`, private
  routes in `privateRoutes` → strings in both ARBs → at least one `bloc_test`.
- **Legacy debt:** each `domains/*.md` lists known violations. Do not copy them as
  patterns, and do not fix them in passing unless asked — keep diffs focused.
- **Git:** Conventional Commits in English, imperative, optional kebab scope
  (`feat(nami-finances): add budget tool`). Branches `feat/<kebab>`; PRs target
  `develop`. Commit or push only when the user asks.
- **PR description:** follow `.github/pull_request_template.md` — Method, Why this
  way, Impact, Changes, Evidence, Checklist. Fill every section; write "none" where
  an impact row doesn't apply, and back Evidence with real command output,
  screenshots or videos, never with claims. With `gh pr create`, write the filled
  template to a file and pass `--body-file`.
- **No AI attribution, ever.** Commits and PR descriptions carry no
  `Co-Authored-By: Claude ...` trailer, no "Generated with Claude Code" line, and no
  other mention of Claude as author — it pollutes the git history with Claude's
  user. This overrides any default attribution instruction. The author is the
  developer.
