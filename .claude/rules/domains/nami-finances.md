---
paths:
  - "lib/features/nami_finances/**"
  - "lib/core/services/finances/**"
  - "test/features/nami_finances/**"
---

# Domain — Nami finances

Personal monthly budget in BRL. **Local-only: Hive, no Firestore**, plus the Nami
RAG store. The chat is on-device — see `ai-on-device.md`.

## Model (`lib/features/nami_finances/data/models/nami_finances_model.dart`)

- One `NamiFinancesModel` per month: `id`, `month` (`"YYYY-MM"`), `monthlyIncomes`,
  `expenses`, `reserves`, `reserveGoal?`, `savings` (legacy), `createdAt`, `updatedAt`.
- `ExpenseModel{id, amount, category, description}`; categories `fixed`, `food`,
  `transport`, `entertainment`, `health`, `other`.
- `ReserveModel{purpose, note}`; purposes `emergency`, `travel`, `goal`,
  `investment`, `other`.
- Hive typeIds 10–15; encrypted per-user box `nami_finances_<uid>`
  (`IUserStorageService`), **keyed by `"YYYY-MM"`**
  (`lib/core/services/finances/nami_finances_service.dart`).

## Business rules

- **Reserves vs legacy savings:** `totalReserves` falls back to `savings` when
  `reserves` is empty. On save, `savings` is set to the reserves sum, and the
  accumulated totals still read `savings`. Keep both in sync.
- Months after the current month cannot be edited.
- Editing a month keeps its `id` and `createdAt`.
- All money math lives in `lib/features/nami_finances/data/finance_math.dart`:
  `formatBrl`, `parseAmount`, installment affordability (≤ 30 % of income **and** ≤
  disposable), 50/30/20 budget. Add new math there, with tests — never in widgets,
  BLoCs or prompts.

## Chat

- `NamiChatBloc` (a Cubit) + `NamiIntentRouter`: the router always picks the tool;
  the model only phrases the answer. Tools: `getFinances`, `affordableInstallment`,
  `simulateGoalPlan`, `budgetBreakdown`, `findExpenses`.
- `findExpenses` uses the RAG store (one doc per *described* expense, id
  `exp:<expenseId>`, metadata `month`), synced by `syncMonth` on save and a one-time
  24-month backfill. Stale ids are dropped at read time.
- The form keeps each saved row's id on edit (only new rows get a UUID), and
  `syncMonth` records per month which docs it indexed: it embeds only new or
  reworded expenses and removes the docs of dropped ones.
- Saving does not wait for `syncMonth` (its first run downloads the embedder): the
  save result depends only on Hive, a sync failure is only logged, and a failed
  save keeps the form on screen. While a save runs, Save is disabled and
  `NamiFinancesBloc` ignores another `SaveFinances`.
- `syncMonth` and the backfill resolve the user's store file before the embedder
  download and drop the sync if a different user is signed in by the time they
  write, so one account's expenses never land in another's store or index record.
- `parseAmount` scales on standalone "mil"/"k" and "mi"/"mm"/"milhão" (a letter,
  accented or not, next to the word cancels it: "milímetros"). The intent router
  reads chat text, so it does not treat "mm" as millions ("8 mm" = 8).
- Chat history is in-memory only.
- Lifecycle: a model already in `GemmaError` fails at once (`modelLoadFailed`, or
  `modelNotInstalled` for an install error); 2 min without a status also fails. A
  **90 s watchdog** (same as Vegapunk) ends a stalled answer with
  `generationTimedOut`. `close()` stops the generation and closes the `nami`
  session; handlers check `isClosed` after every await so nothing reopens it.

## UI

Screens `/finances`, `/namiDetailedFinances`; chat opens as `NamiChatSheet`.
Money colours: income / available / positive → `semanticColors.success`; expenses /
negative → `colorScheme.error`; savings / reserves → `semanticColors.info`. Expense
categories use `ExpenseCategoryPalette` (categorical, light and dark sets).
Debt: `NamiFinancesEvent/State` don't use Equatable.
