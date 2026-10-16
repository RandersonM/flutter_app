# Design — Gemma Performance Remediation

## Root Cause Narrative

The Vegapunk chat feature (introduced in commit `4817f07`, "implement Vegapunk chat feature") ships with `GEMMA_MODEL_URL`/`GEMMA_MODEL_NAME` pointed at `gemma-4-E2B-it.litertlm`. The `.env.example` still carries a commented-out, much lighter alternative (`Gemma3-1B-IT`, plain text-only ~1B model). `tool_intent_detector.dart` even documents this in a comment: *"the Gemma 4 E2B model (2B params) is not always reliable at deciding when to use tools"* — confirming the swap was deliberate (likely for function-calling/tool support and multilingual quality), not an accident. E2B ("effective 2B") models in the Gemma 3n/4 family use a MatFormer architecture: the on-disk/runtime footprint and compute cost are substantially larger than a raw dense 1B model, even though the "effective" parameter count is quoted as ~2B. On mid-range phones this alone can push per-token decode time up several-fold — a plausible full explanation for "it used to run smooth."

Two compounding issues make it worse in practice:

1. **GPU backend isn't guaranteed after a chat reset.** `loadModel()` (used on cold start / thinking-mode toggle) explicitly requests `PreferredBackend.gpu`. `resetChat()` (used every time `VegapunkChatCubit.reset()` is called — i.e. every "new conversation") does not pass `preferredBackend` at all, so the plugin receives `null` and applies whatever its internal default is. If that default is CPU (common for safety when GPU delegate support is capability-gated per-device), then **the exact moment a user resets the chat, the app silently downgrades from GPU to CPU inference for a model that's already 2-4x heavier than before** — a very good match for "it was fine, then got laggy."

2. **A single global on-device vector store is shared by two unrelated features.** `RAGService` (Vegapunk lore/session RAG) and `NamiRagService` (finances RAG) both call `FlutterGemmaPlugin.instance.initializeVectorStore(<different db path>)`. `flutter_gemma`'s model/embedder APIs are exposed as a single "active" instance (`getActiveModel`, `getActiveEmbedder`) elsewhere in the same plugin family — if `initializeVectorStore` follows the same "one active instance" pattern, then visiting Nami Finances after Vegapunk chat (or vice versa) re-points the global vector store to a different SQLite file, forcing a redundant re-open/re-init and making the *other* feature's RAG search silently return nothing (or stale results) until it's reinitialized again. This needs a quick confirmation read of the plugin's native vector-store implementation, but the Dart-level pattern is a real architectural smell regardless.

## Recommended Fixes (priority order)

### 1. PERF-01 — Right-size the model (biggest win, needs a product decision)
- Verify whether Gemma-4-E2B is a hard product requirement (native function calling + multilingual quality) or a leftover from experimentation.
- If not required, revert `GEMMA_MODEL_URL`/`GEMMA_MODEL_NAME` to a lighter model (e.g. the already-referenced Gemma3-1B-IT, or a Gemma 3n E2B **text-only** variant without image/audio support) and re-measure tokens/sec on a representative mid-range device.
- If E2B must stay for tool-calling quality, consider: lowering `maxTokens` context (currently fixed at 4096 for both thinking and non-thinking modes — `gemma_service.dart:127,262`) and/or trimming `maxOutputTokens` further for the non-thinking path.

### 2. PERF-02 + PERF-04 — Fix backend fallback via de-duplication
- Extract a single private `Future<InferenceChat> _buildChat({required bool isThinkingMode})` in `GemmaService` that both `loadModel()` and `resetChat()` call, always passing `preferredBackend: PreferredBackend.gpu`. This makes the bug structurally impossible to reintroduce instead of just patching the one call site.
- File: `lib/core/services/gemma/gemma_service.dart:118-153` (loadModel) and `:251-278` (resetChat).

### 3. PERF-06 — Stop hardcoding `ModelType.gemma4`
- Reuse `_determineModelType(env.gemmaModelName)` inside the new `_buildChat()` helper instead of the literal `ModelType.gemma4`, so a future model downgrade (fix #1) doesn't require remembering to update this too.

### 4. PERF-03 — Namespace or serialize the vector store lifecycle
- Read `flutter_gemma_rag_sqlite`'s `initializeVectorStore`/`SqliteVectorStore` implementation to confirm single-vs-multi-store support.
- If single-store: introduce one shared `VectorStoreCoordinator` in `core/services/rag/` that both `RAGService` and `NamiRagService` go through, tracking which logical namespace is "active" and only re-initializing when the feature being used actually changes (memoized), rather than two independent services silently fighting over one global handle.
- If multi-store is supported (e.g. via a `collection`/`namespace` param already present on the plugin but unused here): pass distinct namespaces instead of distinct file paths so both features can be initialized once and stay active simultaneously.

### 5. PERF-05 — Bound session RAG growth
- Cap the number of session documents retained (e.g. keep last N turns) or evict on a rolling basis in `RAGService.addDocument`/`clearSession`, so long single sessions don't degrade `searchSimilar` latency over time.
- Consider canceling the pending `Future.delayed(2s)` session-doc insert in `VegapunkChatCubit._commitStreamingMessage` if a new `sendMessage` starts before it fires, since a fast typist can already race it today.

### 6. PERF-07 — Repo hygiene (separate from runtime perf)
- `android/build/ios/XCBuildData/PIFCache/...` appears to be committed build cache (visible as pending deletions in `git status`). Add `android/build/` to `.gitignore` and remove it from tracking — improves IDE indexing/build performance, unrelated to on-device inference speed.

## Verification Plan

- Instrument `GemmaService.loadModel`/`resetChat` with a debug log of the resolved backend (if the plugin exposes it) before/after the fix.
- Manual timing: cold start → first response tokens/sec; then trigger `reset()` → second conversation tokens/sec. Today these are expected to diverge (GPU vs CPU); after the fix they should match.
- If the model is downgraded (fix #1), re-run the same before/after timing to quantify the win independently from the GPU-fallback fix.
