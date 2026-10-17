---
paths:
  - "lib/core/ai/**"
  - "lib/core/services/gemma/**"
  - "lib/core/services/rag/**"
  - "lib/core/services/gemini/**"
  - "lib/core/services/web_search/**"
  - "lib/core/models/rag/**"
  - "lib/features/vegapunk_chat/**"
  - "lib/features/nami_finances/tools/**"
  - "lib/features/nami_finances/bloc/chat/**"
  - "lib/features/nami_finances/data/services/**"
  - "ios/Runner/*.entitlements"
  - "test/features/vegapunk_chat/**"
  - "test/features/nami_finances/**"
---

# On-device AI (Gemma) and cloud AI

Read the code before trusting `docs/flutter-gemma-*.md` or `.specs/features/vegapunk-*`:
both predate parts of the current pipeline (sentinel names, entitlements, Qwen).

## Fixed constraints — product decisions, not tuning knobs

- Model: **Gemma 4 E2B** (`GEMMA_MODEL_NAME` in `.env`). Do not switch to a smaller model.
- `maxTokens: 4096`. Do not lower it.
- Memory pressure is solved with other levers: the iOS `increased-memory-limit`
  entitlement (`ios/Runner/Runner.entitlements`; a personal team cannot have the
  debugging one), GPU→CPU fallback, fewer concurrent sessions, smaller output caps,
  trimming tool output (1500–1800 chars), lean payloads, release/profile builds.
- An OOM kill on device leaves **no Dart error** — suspect memory first when the
  app vanishes during generation.

## IGemmaService (`lib/core/services/gemma/`)

- Lazy singleton. Status is a sealed `GemmaServiceStatus` (`NotInstalled`,
  `Downloading(progress)`, `Loading`, `Ready`, `Error`) on `statusStream`.
- Lifecycle: `initialize()` → installed? `loadModel` : `NotInstalled`;
  `downloadModel()` installs from `GEMMA_MODEL_URL` with the HuggingFace token.
- **`_recreateChat` closes the singleton chat and every named session.** Any
  reload/reset kills Nami's session too. Never call `initialize()` while the model
  is `Ready` from a second feature (Nami only initializes on `NotInstalled`).
- Tools must be set (`setTools`) **before** `loadModel`.
- Two chat kinds: the singleton Vegapunk chat (`sendMessage` / `sendToolResult`)
  and named sessions (`sendSessionMessage(sessionId, ...)`, `closeSession`).
  Close your session in the BLoC's `close()`.
- No generation lock: one generation at a time is the caller's job (the cubits
  track `isGenerating`). Cancelling the stream calls `stopGeneration`.

## Tool calling

- Contract: `ToolHandler` (`lib/features/vegapunk_chat/tools/tool_handler.dart`):
  `name`, `description` + `descriptionPt`, `parameterDescriptions` + `...Pt`,
  `requiredParameters`, `Future<ToolResult> execute(ToolCall call)`. Every parameter
  is a string in the schema — parse and validate inside `execute`.
- Return `ToolResult.success(jsonString)` / `ToolResult.error(...)`. Never throw out
  of `execute`.
- **Do the work in Dart, let the model only phrase it.** Handlers return JSON with
  pre-formatted `*_formatted` values and an `instructions`/`note` field telling the
  model to quote them verbatim. The 2B model mangles arithmetic and numbers.
- Two registries:
  - Default `FunctionRegistry` (wired in `core_module.dart`) for Vegapunk:
    `searchInternet`, `getUserProfile`, `getWorkoutHistory`, `saveWorkout`,
    `getCharacterInfo`.
  - `kNamiToolsRegistry` (named instance in `features_module.dart`) for Nami:
    `getFinances`, `affordableInstallment`, `simulateGoalPlan`, `budgetBreakdown`,
    `findExpenses`.

### Add a tool

1. Implement `ToolHandler` in `lib/features/<f>/tools/` with EN + PT descriptions
   and `*_formatted` output; keep output under ~1500 chars.
2. Register it in the right registry.
3. Make it reachable deterministically:
   - Vegapunk → a `_matchesXIntent` in `ToolIntentDetector` (high-confidence intents
     execute directly, before the model).
   - Nami → a branch in `NamiIntentRouter` (`lib/features/nami_finances/bloc/chat/nami_intent_router.dart`),
     respecting its priority order.
4. Test the handler (pure Dart, golden: `test/features/nami_finances/get_finances_handler_test.dart`)
   and the routing (golden: `nami_intent_router_test.dart`).

### Why the routers exist

The small model often *describes* a tool call instead of emitting it. So:
- **Nami** never lets the model choose: `NamiIntentRouter` (pure regex) always
  returns a `ToolCall`; `NamiChatBloc` executes it in Dart and passes the result as
  `ragContext` to a session **with no tools attached**, then strips leaked tool JSON.
- **Vegapunk** tries, in order: high-confidence intent → native function call
  (`FunctionCallResponse`) → text fallback parsed by `FunctionExecutor`. UI sentinels
  `\x00TOOL_START:<name>\x00` / `\x00TOOL_DONE\x00` drive the tool indicator.

## RAG

- Touch the vector store only inside `RagStoreCoordinator.withStore(owner, dbFile, op)`.
  There is one global store and one embedder (Gecko 110m, ~110 MB); never call
  `initializeVectorStore` directly. Operations run one at a time in call order, the
  store switch included, so no other feature re-points the store mid-operation
  (`rag_store_coordinator_test.dart`). Keep embedding generation outside `op` when it
  doesn't need the store, await everything inside it, and never nest another owner.
- Stores are per user (`IUserStorageService.userDatabaseFileName`): Vegapunk
  `opfan_rag_<uid>.db`, Nami `nami_finances_store_<uid>.db` (`guest` when signed
  out). The file name is the coordinator owner, so signing in as someone else
  reopens the store.
- Clearing wipes the whole store; there is no per-document delete. Readers must
  tolerate stale ids (golden: `FindExpensesHandler` drops ids that no longer resolve).
- Vegapunk re-indexes the static knowledge base only when its fingerprint (sorted
  ids) changes — **changing a document's content requires changing its id**.
- Defer embedding work so it doesn't compete with inference (session docs are added
  ~2 s after a turn).
- The Nami RAG store is deliberately kept populated for future features; don't
  remove it.

## Prompts (`lib/core/ai/prompts/`)

- `personas/` (Nami, Vegapunk, Vegapunk satellites, Sanji), `framing/`
  (`[INTERNAL REFERENCE]` lore vs `[AVAILABLE DATA]` facts), `image_generation/`.
- Every prompt has `_en` and `_pt` variants; pick with
  `PromptLocale.isPortuguese(localeService)` (inject `ILocaleService`).
  The Vegapunk system prompt's locale is fixed when the chat is created.
- Keep prompts short and rule-based; temperature ~0.2 for tool emission.
- Prompts are code: changing one changes behaviour — mention it in the PR.

## Cloud AI and other APIs

- Gemini (`lib/core/services/gemini/`) goes through **Firebase AI Logic**
  (`firebase_ai`, Gemini Developer API, free on Spark) behind `IGeminiClient`:
  `gemini-3.5-flash-lite` for Sanji text (`gemini-2.5-flash-lite` is closed to new
  projects), `gemini-2.5-flash-image` for character / crew images — which has **no
  free-tier quota** (429), so images are not generated without billing, uploaded by `IImageHostService` (Imgur, data URI fallback). No
  Gemini key in the app. Any failure returns `null`; a used-up free quota
  (`QuotaExceededException`) pauses calls for 2 min. Not used for chat.
- Tavily web search (`TAVILY_API_KEY`, free plan) behind `searchInternet`; must
  return an error result offline or unconfigured, not throw.
- App Check is activated in `main.dart` (debug provider in debug builds) and its
  token goes with every AI Logic call; enforce it for AI Logic in the Firebase
  console once both apps (and the debug tokens) are registered.
- Env keys without defaults throw at startup — see `data-layer.md` › Configuration.
