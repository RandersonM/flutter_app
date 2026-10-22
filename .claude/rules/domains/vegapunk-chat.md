---
paths:
  - "lib/features/vegapunk_chat/**"
  - "lib/core/ai/prompts/personas/vegapunk*.dart"
  - "test/features/vegapunk_chat/**"
---

# Domain — Vegapunk chat

On-device assistant persona (Dr. Vegapunk and his satellites). Private route
`/vegapunkChat`. Works offline except `searchInternet`. Pipeline, tools and RAG
rules: `ai-on-device.md`.

## Behaviour

- `VegapunkChatCubit` (golden cubit) states: `ModelNotInstalled`, `Downloading`,
  `Loading`, `Ready{messages, streamingToken, isGenerating, selectedSatellite,
  isThinkingMode, activeToolName}`, `Error`.
- Tokens are emitted in **80 ms batches**; a **90 s watchdog** ends a stuck generation.
- **Satellites:** 7 personas sharing one thread; each turn adds a per-satellite style
  block (`vegapunk_satellite_prompt.dart`). Thinking mode lowers temperature
  (0.15) and output cap (512 vs 768).
- `activeToolName` is a raw tool key; the widget localizes it (golden pattern for
  "state carries a key, UI localizes").

## Tools

- `saveWorkout` runs only from `ToolIntentDetector`, and only when every trigger
  in the message is affirmed. It looks at the trigger's own clause (up to the
  previous `.,;:!?`) and skips it when that clause has, before the trigger, a
  negation (`não`/`nao`/`naum`/`n`/`ñ`, `nem`, `jamais`, `quase`, `never`,
  `*n't` with `'` or `’`, ...), a hypothetical (`se`, `if`, `será que`), an
  interrogative (`quanto`, `how`, `did i`, `have i`, ...), `quando`/`when` right
  before it, or `sem` right before it; when `não` follows it ("treinei hoje
  não"); or when its sentence ends in `?`. Words after the trigger or in another
  clause don't count: "treinei hoje e nem cansei", "Quando acordei treinei
  hoje" and "treinei hoje sem parar" log. A `saveWorkout` the model proposes is
  still refused (`writesUserData`), so a sentence the detector skips is never
  saved.

## Memory

- History: encrypted per-user Hive **LazyBox** `vegapunk_chat_history_<uid>`
  (`IUserStorageService`), `ChatMessage` typeIds 50/51.
  The last 20 messages are loaded **for display only — not replayed into the model**.
- Long-term memory is session RAG docs (`sess:` prefix, `"User asked…\nAnswer:…"`,
  ≤ 512 chars, max 20 per process). When the store is cleared,
  `setOnStoreCleared` rebuilds them from history. Answers built from web search
  (`ChatMessage.usedWebContent`) never become session memory, live or on rebuild,
  so injected web text can't come back in a later turn where tools are active.
- Static lore: `lib/features/vegapunk_chat/data/knowledge/one_piece_knowledge_base.dart`
  (categories `vegapunk`, `character`, `devil_fruit`). Changing a document's text
  needs a new id to trigger re-indexing.

## Model lifecycle

`initialize()` runs every time the screen opens. When the model is already open it
only refreshes the Vegapunk chat (`_refreshVegapunkChat`), which keeps the model and
Nami's session alive; only `_recreateChat` closes every session.
