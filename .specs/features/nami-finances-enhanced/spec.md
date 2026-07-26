# Spec — Nami Finances Enhanced

## Intent
Make the Nami finances register/edit flow richer and month-aware, turn "reserves"
into a first-class multi-item concept with goals, and expose the full financial
picture to the personal assistant chat via a function-calling tool.

## Scope
IN: month selector in edit flow, editable past months, reserves-as-list with
purpose/note, monthly reserve goal + progress, richer accumulated view,
dashboard/detailed updates, backward-compatible Hive migration, finances
function-calling tool, Nami chat tool-calling loop, i18n, unit tests.

OUT: Firestore/remote sync, future-month planning, registering the tool in
Vegapunk (kept possible but not wired), a new RAG-driven feature (RAG only kept
mounted), redesign of income/expense sections beyond wiring.

## Requirements

| ID | Requirement |
|----|-------------|
| NF-01 | The edit/registration flow SHALL provide a month selector (prev/next) letting the user choose which month to create or edit. |
| NF-02 | The selector SHALL allow the current month and any past month, and SHALL block future months (both in UI and service guard). |
| NF-03 | The service `canEditFinances` SHALL return true for current and past months and false for future months. |
| NF-04 | A reserve SHALL be modeled as a list item (`ReserveModel`) with `id`, `amount`, `purpose` (`ReservePurpose`), and free-text `note`. |
| NF-05 | `ReservePurpose` SHALL enumerate: emergency, travel, goal, investment, other. |
| NF-06 | The month record SHALL carry an optional monthly `reserveGoal` (double?). |
| NF-07 | The form SHALL let the user add/remove multiple reserves (amount + purpose + optional note) and set the monthly reserve goal. |
| NF-08 | `NamiFinancesModel` SHALL expose `totalReserves`, `availableAmount` (= income − expenses − totalReserves), and `reserveGoalProgress` (totalReserves / reserveGoal, null when no goal). `reservesByPurpose` SHALL aggregate reserve amounts per purpose. |
| NF-09 | Hive migration SHALL be backward compatible: existing records (no reserves list, no goal) SHALL load with `reserves = []` and `reserveGoal = null`, and `totalReserves` SHALL fall back to the legacy `savings` value when the list is empty. |
| NF-10 | On save, `savings` SHALL be denormalized to `totalReserves` so existing accumulation (`getTotalSavings`, `getAccumulatedSavingsInfo`) keeps working. |
| NF-11 | Editing an existing month SHALL preserve the record's `id` and `createdAt`, update `updatedAt`, and update (not duplicate) its RAG document. |
| NF-12 | The dashboard SHALL show reserve progress against the real `reserveGoal` (no hard-coded 5000), a breakdown of reserves by purpose, and the accumulated reserves total. |
| NF-13 | The detailed (read-only) screen SHALL reflect the new reserves list, goal, and progress. |
| NF-14 | A reusable `GetFinancesHandler` (`ToolHandler`) SHALL expose the user's finances to the model: a requested month (`YYYY-MM`, `current`, or `last`) or the last N months, returning structured JSON (income, expenses, expenses-by-category, reserves w/ purpose+note, reserveGoal, progress, availableAmount) plus accumulated totals. |
| NF-15 | `GetFinancesHandler` SHALL return a clear "no data for that month" result rather than fabricating numbers, consistent with the Nami persona rule. |
| NF-16 | `GemmaService.sendSessionMessage` SHALL accept optional `tools` and attach them to the isolated session; a `sendSessionToolResult` SHALL feed a tool result back for the second pass. Both SHALL be on `IGemmaService`. |
| NF-17 | `NamiChatBloc` SHALL run a function-calling loop: attach the finances tool to the `nami` session, execute the handler when the model requests it (or proactively for finance questions), feed the result back, and stream the final answer. |
| NF-18 | The RAG infrastructure SHALL remain functional and populated (`syncMonth` still called on save; backfill preserved) but SHALL NOT be the chat's finances answer path. |
| NF-19 | All new user-facing strings SHALL exist in both `intl_en.arb` and `intl_pt.arb`. |
| NF-20 | The change SHALL NOT break existing saved finances data or the current dashboard for legacy records. |

## Acceptance Criteria
- AC1 (NF-01,02,03): From the finances screen the user can navigate to a past month and save/edit it; navigating to a future month is not possible; saving a future month is rejected by the service.
- AC2 (NF-04..10): Saving a month with 2 reserves (e.g. emergency R$200 + travel R$300) and a goal of R$600 persists; reopening shows both reserves, the goal, and 83% progress; `availableAmount` subtracts R$500; `getTotalSavings` includes R$500 for that month.
- AC3 (NF-09,20): An app build reading a pre-existing (legacy) month record shows the old savings value as a single reserve total, no crash, goal absent.
- AC4 (NF-11): Editing a month twice does not create duplicate RAG documents (same id).
- AC5 (NF-14..17): In the Nami chat, asking "quanto guardei em <mês>?" or "qual minha reserva de emergência?" returns the correct persisted numbers sourced from the tool.
- AC6 (NF-18): Vector store still receives synced documents on save (debug log present); chat answers do not depend on RAG hits.
- AC7 (NF-19): `flutter gen-l10n` succeeds; no missing-key warnings; app compiles.
- AC8: `flutter analyze` clean; new bloc/tool unit test passes.
