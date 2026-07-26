# Gemma Chat Performance & Architecture Audit

## Initiative: Diagnose and fix perceived slowdown of the on-device Vegapunk/Gemma chat

**Status:** PERF-01 through PERF-07 implemented (see `tasks.md`). The original model-downgrade finding was dropped from this list per product decision — the team is keeping `gemma-4-E2B-it.litertlm`.
**Complexity:** Medium (brownfield analysis; fixes are mostly localized to 2-3 files)
**Trigger:** User report — "it used to run smoothly, now it's noticeably janky/frozen" (flutter_gemma-based chat)

---

## Symptom

The Vegapunk chat (on-device LLM via `flutter_gemma`) used to run smoothly and now feels heavily throttled/laggy, without any explicit performance work being done recently.

## Scope

- `lib/core/services/gemma/gemma_service.dart`
- `lib/core/services/rag/rag_service.dart`
- `lib/features/vegapunk_chat/**`
- `lib/features/nami_finances/data/services/nami_rag_service.dart`
- `lib/main.dart` (FlutterGemma bootstrap)
- `.env` / `environment_service.dart` (model configuration)

## Requirements (traceable findings)

| ID | Finding | Severity | Confidence |
|----|---------|----------|------------|
| PERF-01 | `GemmaService.resetChat()` omits `preferredBackend: PreferredBackend.gpu` that `loadModel()` sets, risking silent CPU fallback after every "new chat" | High | Confirmed (code diff) |
| PERF-03 | Two independent RAG features (`RAGService`, `NamiRagService`) each call `FlutterGemmaPlugin.instance.initializeVectorStore(dbPath)` with different paths against a single active/global vector store handle | High | Confirmed (read `flutter_gemma` source — `ServiceRegistry.instance.vectorStoreRepository` is a process-global singleton) |
| PERF-04 | `GemmaService.loadModel` / `resetChat` are near-duplicated code paths — the divergence in PERF-02 is a direct symptom of this duplication | Medium | Confirmed |
| PERF-05 | Session RAG documents accumulate unbounded for the lifetime of a chat session (only cleared on explicit `reset()`), each insert costing an embedding generation ~2s after every assistant turn | Medium | Confirmed |
| PERF-06 | `loadModel`/`resetChat` hardcode `modelType: ModelType.gemma4` instead of reusing `_determineModelType(env.gemmaModelName)`, so changing the configured model back to a lighter one (fix for PERF-01) will silently mismatch model type unless this is fixed too | Low-Medium | Confirmed |
| PERF-07 | Committed Xcode/Android build cache artifacts (`android/build/ios/XCBuildData/PIFCache/...`) bloat the repo and IDE indexing — unrelated to runtime chat lag but affects "project feels slow" (editor/build side) | Low | Confirmed (git status) |

## Out of Scope

- Rewriting the RAG/vector-store plugin integration from scratch
- Migrating away from `flutter_gemma` to a different on-device inference stack
- General non-Gemma related codebase performance (already tracked in `.specs/codebase/CONCERNS.md`)
