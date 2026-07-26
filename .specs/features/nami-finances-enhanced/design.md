# Design — Nami Finances Enhanced

## 1. Data Model (`data/models/nami_finances_model.dart`)

### New: `ReservePurpose` — Hive typeId **15**
```dart
enum ReservePurpose { emergency, travel, goal, investment, other }
```
Adapter maps ordinals 0–4; default → `other`.

### New: `ReserveModel` — Hive typeId **14**
```dart
class ReserveModel {
  final String id;
  final double amount;
  final ReservePurpose purpose;
  final String note; // free text, may be ''
}
```
Adapter writes 4 fields (0=id,1=amount,2=purpose,3=note).

### Changed: `NamiFinancesModel` (typeId 10)
Add fields:
- `final List<ReserveModel> reserves;`  (default `const []`)
- `final double? reserveGoal;`          (nullable)

Keep `savings` (field 4) for backward compat + accumulation denormalization.

Adapter: `writeByte(9)`; write existing 0–6, then `..writeByte(7)..write(reserves)`
`..writeByte(8)..write(reserveGoal)`. Read with defaults:
`reserves: (fields[7] as List?)?.cast<ReserveModel>() ?? const []`,
`reserveGoal: fields[8] as double?`. Legacy records (numOfFields=7) → both defaults.

New/changed getters:
```dart
double get totalReserves =>
    reserves.isEmpty ? savings : reserves.fold(0.0, (s, r) => s + r.amount);
double get availableAmount => totalIncome - totalExpenses - totalReserves; // CHANGED
double? get reserveGoalProgress =>
    (reserveGoal != null && reserveGoal! > 0) ? totalReserves / reserveGoal! : null;
Map<ReservePurpose, double> get reservesByPurpose => ...; // aggregate
```
`savingsPercentage`, `yearlySavings` switch to `totalReserves`.

Register `ReserveModelAdapter` (14) and `ReservePurposeAdapter` (15) in
`lib/core/services/config/storage_service.dart` (guard with `isAdapterRegistered`
following the existing pattern).

## 2. Service (`core/services/finances/`)
- `canEditFinances(month)`:
```dart
final now = DateTime.now();
final firstOfNext = DateTime(now.year, now.month + 1, 1);
return month.isBefore(firstOfNext); // current + past, block future
```
- No interface signature changes needed (existing read methods suffice for the tool).

## 3. Bloc / Event
`SaveFinances` event: replace `double savings` with
`List<ReserveModel> reserves` + `double? reserveGoal` (keep `month`).

`_onSaveFinances`:
1. `canEditFinances(event.month)` guard (now allows past).
2. Fetch existing record for `event.month`; if present reuse `id` + `createdAt`
   (NF-11), else new UUID + `createdAt = now`.
3. Build model: `savings = reserves.fold(sum)` (NF-10), `updatedAt = now`.
4. `saveFinances` + `ragService.syncMonth` (RAG stays mounted).
5. Emit loaded.

## 4. UI

### Screen (`nami_finances_screen.dart`)
- Track `DateTime _selectedMonth` (default current). Load via `LoadFinances(_selectedMonth)`.
- Header month navigator (reuse the prev/next pattern from
  `nami_detailed_finances_screen.dart`): left always enabled (down to a floor,
  e.g. Dec 2019 like the detailed screen); right disabled when `_selectedMonth`
  is the current month (no future — NF-02).
- On month change: reset edit flags, dispatch `LoadFinances`.
- Save passes `_selectedMonth` (not `DateTime.now()`).

### Form (`finances_setup_form.dart`)
- `onSave` signature →
  `Function(List<MonthlyIncomeModel> incomes, List<ExpenseModel> expenses, List<ReserveModel> reserves, double? reserveGoal)`.
- Replace single savings field with a **Reserves section**: add/remove reserve
  items, each = `FinanceCurrencyTextField` (amount) + purpose dropdown
  (`CustomDropdown<ReservePurpose>`) + optional note (`CustomTextField`).
- New **Reserve goal** field (optional `FinanceCurrencyTextField`).
- Pre-populate from `existingFinances.reserves` / `.reserveGoal` on edit;
  legacy record with empty reserves but non-zero `savings` → seed one reserve
  (`other`, amount = savings) so the value isn't lost on first re-edit.
- `_isFormValid`: ≥1 income>0, ≥1 expense>0, reserves optional (≥0).

### Dashboard (`finances_dashboard_view.dart`) & Detailed screen
- Use `totalReserves` instead of `savings`.
- `_SavingsGoalCard`: use real `finances.reserveGoal` (hide/adapt when null);
  progress = `reserveGoalProgress`.
- Add reserves-by-purpose breakdown; show accumulated total via existing
  `getAccumulatedSavingsInfoLocalized` (already surfaced — keep).

## 5. Assistant Tool

### `GetFinancesHandler` — `lib/features/nami_finances/tools/get_finances_handler.dart`
Implements `ToolHandler` (imports shared `tool_handler.dart`). Injects
`INamiFinancesService`.
- `name = 'getFinances'`
- Params (all optional, JSON-schema strings):
  - `month`: `"YYYY-MM"`, `"current"`, or `"last"`.
  - `monthsBack`: string int — summarize the last N months.
- `execute`:
  - Resolve target month(s); fetch via `getFinancesForMonth` /
    `getLastMonthsFinances`.
  - For each month emit structured map: `month`, `totalIncome`, `totalExpenses`,
    `expensesByCategory`, `reserves` (list of {amount, purpose, note}),
    `totalReserves`, `reserveGoal`, `reserveGoalProgress`, `availableAmount`.
  - Append accumulated block from `getAccumulatedSavingsInfo` + `getTotalSavings`.
  - No data for requested month → `ToolResult.success` with
    `{"month": "...", "hasData": false}` (NF-15; model instructed not to invent).
  - `jsonEncode` the payload → `ToolResult.success(toolName: name, content: ...)`.

### GemmaService / IGemmaService (fragile — surgical)
- `sendSessionMessage(..., {List<Tool>? tools})`: when creating the lazy session,
  pass `tools: tools ?? const []`, `supportsFunctionCalls: tools?.isNotEmpty ?? false`,
  `toolChoice: (tools?.isNotEmpty ?? false) ? ToolChoice.auto : ToolChoice.none`,
  `modelType: _determineModelType(env.gemmaModelName)`. Session is cached per
  `sessionId`; tools fixed at first creation (fine for static finances tool).
- Add `sendSessionToolResult(sessionId, {toolName, result})` mirroring
  `sendToolResult` but against `_sessions[sessionId]`.
- Add both to `IGemmaService` (session tools param + `sendSessionToolResult`).

### NamiChatBloc — function-calling loop
- Inject `GetFinancesHandler` (via DI). Build `tools = [handler.toFlutterGemmaTool(isPortuguese: ...)]`.
- Replace the current single-pass `sendSessionMessage(...).listen(...)` with a
  loop mirroring `VegapunkChatRepository._sendWithFunctionCalling`, but on the
  session and simplified:
  1. Send message with `tools`.
  2. Collect stream: on `FunctionCallResponse` → execute via handler →
     `sendSessionToolResult` → stream final tokens.
  3. **Reliability fallback** (small on-device model): if no function call was
     emitted, proactively `handler.execute` with args parsed from the message
     (month if mentioned else `current` + accumulated), then
     `sendSessionToolResult` and stream. This guarantees the model always has
     the numbers, matching Vegapunk's high-confidence-intent pattern.
  - Drop `ragContext` from the send path (tool replaces it). Keep `_backfillRag`
    + `syncMonth` so the store stays populated (NF-18).
  - Keep existing token-buffer/timer streaming + welcome message.

## 6. i18n (new keys, en + pt)
`reserves`, `addReserve`, `reservePurpose`, `reserveNote`, `reserveGoal`,
`reserveGoalOptional`, `reserveProgress`, `accumulatedReserves`,
purpose labels (`reservePurposeEmergency/Travel/Goal/Investment/Other`),
`selectMonth`, `futureMonthBlocked`, `noDataForMonth`. Reuse existing `savings`
where a generic label still fits.

## 7. Testing
- `test/features/nami_finances/get_finances_handler_test.dart`: mock
  `INamiFinancesService`; assert JSON contains reserves/goal/accumulated and the
  `hasData:false` path.
- `test/features/nami_finances/nami_finances_bloc_test.dart` (extend if exists):
  save with reserves → model has `totalReserves`, `savings` denormalized,
  future-month rejected, edit preserves id.

## 8. Risk Notes
- **Hive**: only append fields + new typeIds 14/15; never reorder/reuse. Verified free.
- **GemmaService**: session tools change is additive (default `const []` keeps
  Vegapunk/other sessions unchanged).
- **Migration of value**: legacy `savings` preserved via `totalReserves` fallback
  and seeded into the form on first edit so it is never silently dropped.
