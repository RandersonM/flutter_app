# Tasks — Nami Finances Enhanced

Execution order respects dependencies. Each task lists Goal / Files / Requirements
/ Done-when.

---

## T1 — Domain model: ReserveModel, ReservePurpose, model fields + getters
- Goal: Add `ReservePurpose` (typeId 15) + adapter, `ReserveModel` (typeId 14) +
  adapter, and extend `NamiFinancesModel` with `reserves` + `reserveGoal`,
  updated getters, and backward-compatible adapter.
- Files: `lib/features/nami_finances/data/models/nami_finances_model.dart`
- Requirements: NF-04,05,06,08,09,10
- Done when: compiles; adapter writes 9 fields, reads legacy 7-field records with
  defaults; `totalReserves`/`availableAmount`/`reserveGoalProgress`/`reservesByPurpose` present.

## T2 — Register new Hive adapters
- Goal: Register `ReserveModelAdapter` (14) + `ReservePurposeAdapter` (15).
- Files: `lib/core/services/config/storage_service.dart`
- Requirements: NF-04,05,09 · Depends: T1
- Done when: adapters registered following existing guarded pattern.

## T3 — Service edit-scope guard
- Goal: `canEditFinances` allows current + past, blocks future.
- Files: `lib/core/services/finances/nami_finances_service.dart`
- Requirements: NF-02,03
- Done when: future month → false; current/past → true.

## T4 — Event + Bloc save path
- Goal: `SaveFinances` carries `reserves` + `reserveGoal`; `_onSaveFinances`
  reuses existing id/createdAt on edit, denormalizes `savings = totalReserves`,
  keeps `syncMonth`.
- Files: `lib/features/nami_finances/bloc/nami_finances_event.dart`,
  `lib/features/nami_finances/bloc/nami_finances_bloc.dart`
- Requirements: NF-10,11,18 · Depends: T1,T3
- Done when: compiles; edit preserves identity; save denormalizes savings.

## T5 — Form: reserves list + goal + month-aware onSave
- Goal: Replace single savings field with reserves section (amount + purpose +
  note, add/remove) and a reserve-goal field; new `onSave` signature; seed legacy
  savings as one reserve on edit.
- Files: `lib/features/nami_finances/presentation/widgets/finances_setup_form.dart`
  (+ new reserve item widget if needed under `presentation/widgets/`)
- Requirements: NF-04,07,09 · Depends: T1
- Done when: can add/remove reserves, set goal; edit pre-populates; validity rules per spec.

## T6 — Screen: month selector + wire save to selected month
- Goal: Add prev/next month navigator (block future), track `_selectedMonth`,
  load via `LoadFinances`, pass selected month + reserves + goal to `SaveFinances`.
- Files: `lib/features/nami_finances/presentation/nami_finances_screen.dart`
- Requirements: NF-01,02 · Depends: T4,T5
- Done when: navigating months reloads data; right arrow disabled at current month; save targets selected month.

## T7 — Dashboard + detailed screen: new reserves model
- Goal: Use `totalReserves`, real `reserveGoal`/progress (drop hard-coded 5000),
  reserves-by-purpose breakdown, accumulated total.
- Files: `lib/features/nami_finances/presentation/widgets/finances_dashboard_view.dart`,
  `lib/features/nami_finances/presentation/nami_detailed_finances_screen.dart`
- Requirements: NF-12,13 · Depends: T1
- Done when: dashboard/detailed render with new fields; no hard-coded goal; legacy record renders.

## T8 — GetFinancesHandler tool
- Goal: Implement reusable `ToolHandler` returning structured finances JSON
  (month/range + accumulated) with `hasData:false` for empty months.
- Files: `lib/features/nami_finances/tools/get_finances_handler.dart`
- Requirements: NF-14,15 · Depends: T1
- Done when: unit-testable; returns correct JSON via mocked service.

## T9 — GemmaService session tool-calling surface
- Goal: `sendSessionMessage` accepts `tools`; add `sendSessionToolResult`; add
  both to `IGemmaService`. Additive/default-safe for other sessions.
- Files: `lib/core/services/gemma/i_gemma_service.dart`,
  `lib/core/services/gemma/gemma_service.dart`
- Requirements: NF-16
- Done when: compiles; sessions without tools behave as before.

## T10 — NamiChatBloc function-calling loop
- Goal: Attach finances tool to `nami` session; run tool loop with proactive
  fallback; drop RAG answer path (keep backfill/sync mounted).
- Files: `lib/features/nami_finances/bloc/chat/nami_chat_bloc.dart`
- Requirements: NF-17,18 · Depends: T8,T9
- Done when: chat answers finance questions from tool data; store still synced.

## T11 — DI wiring
- Goal: Provide `GetFinancesHandler` and inject into `NamiChatBloc` (Nami only —
  NOT added to the shared Vegapunk `FunctionRegistry`).
- Files: `lib/app/di/core_module.dart` and/or `lib/app/di/features_module.dart`
- Requirements: NF-14,17 · Depends: T8,T10
- Done when: `getIt<NamiChatBloc>()` resolves with the handler; Vegapunk tools unchanged.

## T12 — i18n
- Goal: Add all new keys to `intl_en.arb` + `intl_pt.arb`; run gen-l10n.
- Files: `lib/l10n/intl_en.arb`, `lib/l10n/intl_pt.arb`
- Requirements: NF-19 · Depends: T5,T6,T7,T8
- Done when: `flutter gen-l10n` clean; strings used in widgets resolve.

## T13 — Tests + verification
- Goal: Unit tests for handler + bloc save path; `flutter analyze`; build check.
- Files: `test/features/nami_finances/...`
- Requirements: NF-14,15,10,11,03 · Depends: T4,T8
- Done when: tests pass; analyze clean.

---

## Progress
- [x] T1  - [x] T2  - [x] T3  - [x] T4  - [x] T5  - [x] T6  - [x] T7
- [x] T8  - [x] T9  - [x] T10 - [x] T11 - [x] T12 - [x] T13

All tasks complete. `flutter analyze` clean; full test suite (14 tests) passes.

### Notes / follow-ups
- RAG (`NamiRagService`) is kept mounted and its summaries are now enriched
  (reserves by purpose + goal), but it is no longer the chat's finances answer
  path — that goes through `GetFinancesHandler`. A future feature should be
  designed to leverage the populated vector store (per user request).
- `GetFinancesHandler` is a reusable `ToolHandler`; to expose finances in the
  Vegapunk chat later, register it in the shared `FunctionRegistry`
  (`core_module.dart`) — no other changes needed.
- `finances_results_view.dart` is dead code (unused) and was left untouched.
- Runtime UI walkthrough on device was not performed here; logic is covered by
  unit tests + static analysis. Recommend a quick manual pass of the chat's
  tool loop on a device with the Gemma model installed.
