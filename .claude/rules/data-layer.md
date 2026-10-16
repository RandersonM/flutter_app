---
paths:
  - "lib/**/data/**/*.dart"
  - "lib/core/services/**/*.dart"
  - "lib/core/user_profile/**/*.dart"
  - "lib/core/storage/**/*.dart"
  - "lib/core/models/**/*.dart"
  - "lib/core/auth/models/**/*.dart"
---

# Data layer — repositories, services, models

## Return types

- `Future<T>`; `Future<T?>` when "not found" is a normal outcome; `Stream<List<T>>`
  for `stream*` methods. No Either/Result type in this codebase — don't introduce one.
- Errors propagate as exceptions (see `architecture.md` › Errors).

## Firestore

- Feature code goes through `IFirestoreService`
  (`lib/core/services/auth_db/i_firestore_service.dart`): map-based, returns data
  with `id` merged in.
- **User scoping is a `userId` field on a top-level collection**, not a
  `users/{uid}/...` subcollection. `createUserDocument` injects `userId`,
  `createdAt`, `updatedAt`; `getUserDocuments`/`streamUserDocuments` filter by it.
  Only the profile lives at `users/{uid}`.
- Collection names are `static const _collection = 'crews';` in the repository.
- Timestamps: write `FieldValue.serverTimestamp()`; read
  `(data['x'] as Timestamp?)?.toDate()`.
- New collections use **camelCase** fields. `workout_assessments` and `users` use
  snake_case — keep that only when touching those.
- Some repos sort in memory because no composite indexes are deployed (there is no
  `firestore.indexes.json` yet). An `orderBy` + `where` on different fields needs
  one: create that file, reference it under `firestore` in `firebase.json`, and tell
  the user it must be deployed — otherwise keep sorting in memory.
- Every new collection needs a rule in `firestore.rules` (see `firebase.md`).

## Models

- `final` fields, `const` constructor where possible, `copyWith` with `x ?? this.x`.
- Equality via `Equatable` for anything compared in state or tests.
- Serialization naming follows the backend:
  - Firestore: `factory X.fromFirestore(Map<String, dynamic> data, String id)` + `toFirestore()`.
  - Nested maps: `fromMap` / `toMap`.
  - REST / `@JsonSerializable`: `fromJson` / `toJson`, `@JsonKey(name: 'snake_case')`.
    Run `fvm dart run build_runner build -d` after changing one; commit the `.g.dart`.
- Defensive reads: `data['name'] as String? ?? ''`, `List<String>.from(data['tags'] ?? const [])`.
- Money is `double` in BRL and formatted only through the feature's formatter
  (`formatBrl` in `nami_finances/data/finance_math.dart`). Never parse or format
  currency ad hoc.
- Golden: `lib/features/robin_knowledge/data/models/goal_model.dart`,
  `lib/features/crews/data/models/crew_model.dart`.

## Hive

- Adapters are **hand-written** (no `@HiveType`, no hive_generator). Golden:
  `lib/features/vegapunk_chat/data/models/chat_message.dart`.
- `final int typeId = HiveTypeIds.x;` — add the id to
  `lib/core/storage/hive_type_ids.dart` (respect its numeric blocks), and register
  the adapter with an **explicit model type** in `HiveStorageService.adapters`
  (`lib/core/services/config/storage_service.dart`). The guard test fails otherwise.
- Never reuse a shipped id; move dropped ids to `HiveTypeIds.retired`.
- Adding a field to an adapter: read it defensively (`fields[n] as T? ?? default`)
  so old boxes still decode.
- **Data that belongs to a user** (finances, chat history, RAG metadata) goes
  through `IUserStorageService` (`lib/core/services/storage/`):
  `openUserBox` / `openUserLazyBox` give an encrypted box named `<name>_<uid>`
  (`guest` when signed out), and `userDatabaseFileName` the user's SQLite file.
  Add every new per-user box or database to `UserDataNames`
  (`lib/core/storage/user_data_names.dart`) — that list drives the legacy
  migration and account deletion. Resolve the box on every call; don't cache it,
  the scope changes on sign-in/out.
- Sensitive data shared by the device (the auth cache) uses `openDeviceBox`.
- Non-sensitive device data (theme, locale, featured-character cache) keeps
  `Hive.isBoxOpen(name) ? Hive.box(name) : await Hive.openBox(name)`.
  Box names are `snake_case` constants next to the code that owns them.
- The AES key lives in the keychain/keystore (`flutter_secure_storage`, via
  `IEncryptionKeyStore`). A box that can't be decrypted is reset, not crashed on.

## Configuration & secrets

- Read config only through `IEnvironmentService`
  (`lib/core/services/config/i_environment_service.dart`). Values are build-time
  `--dart-define-from-file=.env`, never a bundled file. Add a key: a
  `String.fromEnvironment` entry in `EnvironmentService._compiledValues`, a getter
  on the interface + impl, the key in `.env.example`, and a default when the app
  can run without it.
- Everything in `.env` ends up in the binary. A key that bills or can be abused
  (Gemini, Tavily, Imgur) belongs in a Cloud Functions secret behind a callable
  (`functions/src/ai_proxy.ts`); only app-restricted keys (YouTube) or read-only
  tokens (HuggingFace) stay client-side.
- Never read or print `.env`. Never hardcode API keys or client ids in code.

## External APIs

- HTTP through Dio inside a service. Base URLs come from `IEnvironmentService`.
- Services that hit quotas (YouTube, Gemini) must degrade gracefully — return a
  fallback the UI can show, never crash a screen.
