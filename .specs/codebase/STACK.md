# Stack

Source of truth: `pubspec.yaml`, `.fvmrc`, `lib/main.dart`, `lib/app/di/`.

## Runtime
- Flutter 3.44.4 pinned in `.fvmrc` — always run through `fvm`
- Dart SDK `>=3.12.0 <4.0.0` (`pubspec.yaml`)

## State Management
- flutter_bloc ^9.1.1 + bloc ^9.0.0 — the only pattern (24 BLoCs/Cubits, incl. the
  global `AuthBloc`, `ConnectivityCubit`, `ThemeCubit`, `LocaleCubit`)
- equatable ^2.0.7
- No Provider, Riverpod or `ChangeNotifier`

## Dependency Injection
- get_it ^7.6.4 — `lib/app/di/injection.dart` runs core → theme → locale → features
  modules; `getIt` is used only in `lib/app/di/`, `main.dart` and `BlocProvider(create:)`

## On-device AI (Vegapunk chat, Nami finances assistant)
- flutter_gemma ^1.1.1 — model **Gemma 4 E2B** (`.litertlm`, downloaded on demand from
  `GEMMA_MODEL_URL` with the HuggingFace token), `maxTokens: 4096`, GPU→CPU fallback
- flutter_gemma_litertlm ^1.0.2 — LiteRT-LM inference engine (the only engine; no mediapipe)
- flutter_gemma_embeddings ^1.0.1 — Gecko 110m embedder for RAG
- flutter_gemma_rag_sqlite ^1.1.0 — SQLite vector store, one file per user
  (`opfan_rag_<uid>.db`, `nami_finances_store_<uid>.db`)
- Registered once in `main.dart` (`FlutterGemma.initialize(inferenceEngines:
  [LiteRtLmEngine()], embeddingBackends: [LiteRtEmbeddingBackend()], vectorStore:
  SqliteVectorStore())`); wrapped by `lib/core/services/gemma/` and `lib/core/services/rag/`

## Cloud AI (not used for chat)
- google_generative_ai ^0.3.0 — Gemini `gemini-2.5-flash-lite` for Sanji text
- Gemini REST via Dio — `gemini-2.5-flash-image` for custom character and crew images
  (`lib/core/services/gemini/gemini_service.dart`)
- Tavily web search via Dio (`lib/core/services/web_search/`) behind Vegapunk's `searchInternet`

## Backend / Firebase
- firebase_core ^3.6.0
- firebase_auth ^5.3.1 + google_sign_in ^6.2.1 — Google Sign-In
- cloud_firestore ^5.4.0 — `users`, `crews`, `custom_characters`, `planner`,
  `workout_assessments`, `featuredCharacters`, `user_tokens` (rules: `firestore.rules`)
- firebase_messaging ^15.1.3 + flutter_local_notifications ^22.0.0 — FCM push
- Cloud Functions (`functions/`, TypeScript, v2, Node 22) — scheduled push notifications;
  the app has no client-side `cloud_functions` calls

## Local Storage
- hive ^2.2.3 + hive_flutter ^1.1.0 — hand-written adapters, type ids in
  `lib/core/storage/hive_type_ids.dart` (no hive_generator)
- path_provider ^2.1.1

## Networking
- dio ^5.4.0 — One Piece API, YouTube Data API, Gemini image REST, Tavily
- connectivity_plus ^6.1.0 — `ConnectivityCubit`, offline banner/blocker

## Code Generation
- json_serializable ^6.7.1 + json_annotation ^4.8.1 + build_runner ^2.5.4 — only
  `@JsonSerializable` models (`*.g.dart` committed)

## Localization
- flutter_localizations + intl ^0.20.2; ARB files `lib/l10n/intl_en.arb` (template)
  and `intl_pt.arb`; generated `app_localizations*.dart` committed (`l10n.yaml`)

## UI / Other
- phosphoricons_flutter ^1.0.0 (icons), fl_chart ^1.0.0, markdown_widget ^2.3.2+8
- youtube_player_flutter ^10.0.1, video_player ^2.8.2, cached_network_image ^3.3.1,
  flutter_svg ^2.0.10, url_launcher ^6.2.5, uuid ^4.5.1
- math_expressions ^2.4.0 (calculator)
- flutter_dotenv ^5.1.0 — read only inside `EnvironmentService`
- flutter_secure_storage ^11.2.0 — keychain/keystore holder of the Hive AES key

## Testing
- flutter_test, test ^1.24.6, mocktail ^1.0.5, bloc_test ^10.0.0, flutter_lints ^5.0.0
