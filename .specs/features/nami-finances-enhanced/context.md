# Context & Decisions — Nami Finances Enhanced

## Origin
User request: improve the finance registration/editing flow on the Nami finances
screen — make good use of the reserves field, add a month selector for which month
is being edited, and make the data as complete as possible so the personal
assistant chat can use it.

## Clarification Outcomes (user-answered)

### D1 — Month editing scope
**Decision:** Allow editing/creating the **current month and any past month**
(historical backfill). **Block future months.**
- Current behavior: `canEditFinances` allowed only the current month; the form
  always saved to `DateTime.now()`.

### D2 — Reserves enrichment (all options chosen)
The `savings` double becomes a richer concept:
1. **Monthly reserve goal** — configurable target per month (replaces the
   hard-coded R$5000 goal in the dashboard) + progress vs. goal.
2. **Purpose / note per reserve** — each reserve can describe its purpose
   (emergency, travel, goal, investment, other) and a free-text note.
3. **Accumulated reserves surfaced** — total accumulated reserves across months
   shown richly (leverages existing `getTotalSavings` / `getAccumulatedSavingsInfo`).
4. **Multiple reserves per month** — reserves become a list of items (like
   incomes/expenses), each with amount + purpose + note.

### D3 — Assistant integration
**Decision:** Finances data reaches the assistant via a **function-calling tool**
(not RAG retrieval). The tool is a reusable `ToolHandler` so it *can* be
registered in Vegapunk later, but **initially it is wired only to the Nami chat**.
- The RAG infrastructure (`NamiRagService`, `syncMonth`, backfill, vector store)
  stays **mounted** (kept populated) for a future RAG-driven feature, but is no
  longer the finances answer path for the chat.

## Complexity Assessment
**Complex** — multi-component: Hive model migration (fragile area), new domain
model + adapters, service/bloc/UI changes, GemmaService session tool-calling
surface change (fragile area), new function-calling loop in NamiChatBloc, i18n.
→ Full workflow: Specify → Design → Tasks → Execute.

## Verified Ground Truth (from code, 2026-07-09)
- Hive typeIds in use: 0,1,2,10,11,12,13. **14 and 15 are free** → used for
  `ReserveModel` (14) and `ReservePurpose` (15).
- `NamiFinancesModel` adapter (typeId 10) currently writes 7 fields (0–6). New
  fields append at indices 7 (reserves) and 8 (reserveGoal); old records
  (numOfFields=7) read them as defaults `[]` / `null` → backward compatible.
- `flutter_gemma` 1.1.1 `InferenceModel.openChat(...)` **accepts** `tools`,
  `supportsFunctionCalls`, `toolChoice`, `modelType` — same as `createChat`. So
  the isolated Nami session can carry tools.
- Tool infra: `ToolHandler` (abstract) + `FunctionRegistry` in
  `lib/features/vegapunk_chat/tools/`. `ToolResult.success/error`, `ToolCall`.
- Persistence is **Hive only** (box `nami_finances`, key = `YYYY-MM`). No Firestore.
- `savings` is summed by `getTotalSavings` / `getAccumulatedSavingsInfo`. To keep
  those working unchanged, on save we set `savings = totalReserves`
  (denormalized), so accumulation logic is untouched.
