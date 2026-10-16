# Tasks — Gemma Performance Remediation

Decision: **PERF-01 (model downgrade) is explicitly out of scope** — the team wants to keep `gemma-4-E2B-it.litertlm`. All other findings were implemented.

| ID | Task | Status |
|----|------|--------|
| PERF-02 | Fix `GemmaService.resetChat` silently dropping GPU backend preference | ✅ Done |
| PERF-04 | De-duplicate `loadModel`/`resetChat` into one `_recreateChat` helper | ✅ Done (same change as PERF-02) |
| PERF-06 | Stop hardcoding `ModelType.gemma4`; reuse `_determineModelType(env.gemmaModelName)` | ✅ Done (same change) |
| PERF-03 | Fix the shared/global vector store being silently re-pointed by two independent RAG features | ✅ Done — new `RagStoreCoordinator` |
| PERF-05 | Bound session RAG growth + stop silently dropping session docs when a fast reply races the 2s delay | ✅ Done |
| PERF-07 | Ignore `android/build/` (committed Xcode/Gradle build cache) | ✅ Done (`.gitignore` only — deletions were already pending in git status, not staged/committed by this change) |
| PERF-01 | Right-size the model | ⏸️ Deferred — product decision to keep Gemma-4-E2B |

## What changed

### `lib/core/services/gemma/gemma_service.dart`
- Extracted `_recreateChat({required isThinkingMode})`, used by both `loadModel` and `resetChat`.
- Both paths now always request `preferredBackend: PreferredBackend.gpu` — previously only `loadModel` did, so every "new chat" (`resetChat`) risked silently falling back to CPU inference on the 2-4x heavier E2B model.
- `modelType` is now derived via `_determineModelType(env.gemmaModelName)` instead of a hardcoded `ModelType.gemma4`, so a future model change doesn't silently desync this.

### `lib/core/services/rag/rag_store_coordinator.dart` (new)
- Single owner of the shared Gecko embedder install and the flutter_gemma vector store's "active" pointer.
- `ensureEmbedderInstalled()` — installs once for the process, shared by both RAG services (previously duplicated identical install code in two files).
- `ensureActive(owner, dbFileName)` — re-points the plugin's single global vector store at `owner`'s db file; no-op when already active. Confirmed via `flutter_gemma` source (`ServiceRegistry.instance.vectorStoreRepository` is a process-global singleton) that this was a real, not just theoretical, risk.

### `lib/core/services/rag/rag_service.dart`
- `initialize()` no longer calls `initializeVectorStore` directly; delegates to `RagStoreCoordinator`.
- Every store-touching method (`addDocument`, `addDocumentBatch`, `search`, `clearSession`, `setKnowledgeBase`) now calls `_ensureActiveStore()` first, which re-asserts ownership via the coordinator — so if Nami Finances was used in between, Vegapunk's RAG search correctly re-points the store back instead of silently querying the wrong database.
- Session documents (`isSession: true`) are now capped at 20 per session (`_maxSessionDocs`) to prevent unbounded vector-store growth (and the search-latency creep that comes with it) during a single long conversation. The counter resets on `clearSession()`/`setKnowledgeBase()`.

### `lib/features/nami_finances/data/services/nami_rag_service.dart`
- Same pattern: delegates embedder install and vector-store activation to `RagStoreCoordinator` instead of duplicating the install/init logic with a different db path.
- Removed an unused `flutter_dotenv` import.

### `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart`
- The post-response session-document insert (delayed 2s to avoid competing with in-flight inference) now uses a cancelable `Timer` (`_sessionDocTimer`) instead of a bare `Future.delayed`.
- If the model starts generating again before the delay elapses (fast follow-up message), the insert now **reschedules itself** instead of being silently dropped — no more losing a turn's session memory because the user typed quickly.
- `_sessionDocTimer` is canceled on `reset()` and `close()` to avoid inserting a stale document after a session reset or screen disposal.

### `.gitignore`
- Added `android/build/` — the repo had ~48 committed Xcode/Gradle build-cache files under `android/build/ios/XCBuildData/PIFCache/...` (unrelated to runtime chat performance, but bloats the repo/IDE indexing). These deletions were already pending in `git status` from a prior session; this change only prevents them from being re-tracked. Nothing was staged or committed.

## Verification

- `fvm flutter analyze` — no issues found (ran across the whole project after all edits).
- Not yet done: manual on-device timing before/after (cold start vs. post-`reset()` tokens/sec) to confirm the GPU-fallback fix actually closes the gap described by the user. Recommend the user do a quick before/after comparison: send a message, note responsiveness, tap "new chat", send another message, compare.
