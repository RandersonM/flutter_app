# Plan — Nami Finances AI Accuracy & Financial Knowledge

## Execution status (2026-07-10) — Phases 1 & 2 done

- **Layer 1** `lib/features/nami_finances/data/finance_math.dart` (pure, tested):
  `formatBrl` (pt-BR), robust `parseAmount` ("80mil"→80000, "80.000,00"→80000),
  aggregates, calculators. `GetFinancesHandler` now emits only `*_formatted`
  values + a pre-computed cross-month `summary` — no raw doubles for the LLM to
  reformat.
- **Layer 2** `tools/finance_calculator_handlers.dart`: `affordableInstallment`,
  `simulateGoalPlan`, `budgetBreakdown`. They read real income/expenses from the
  service, so the model only supplies price/target.
- **Layer 3** `NamiPrompt`: guardrails ("quote *_formatted verbatim; never
  compute/reformat; call a tool for calculations") + finance cheatsheet
  (Layer-4-lite: emergency fund, ≤30% installment, 50/30/20, consórcio vs
  financiamento).
- **Wiring**: Nami-scoped `FunctionRegistry` (DI `kNamiToolsRegistry`) with the 4
  tools; `NamiChatBloc` uses it for native calls + proactive fallback.
- **Tests**: `finance_math_test.dart` + updated `get_finances_handler_test.dart`
  (22 green; `flutter analyze` clean).

**Deferred:** Layer 4 full RAG knowledge corpus (Phase 3) and Layer 5 eval
harness. Native tool-selection for planning is best-effort on the small model;
not verified on-device here.

---

## 1. Problem (observed)

From the chat (device screenshots, Gemma 4 E2B on-device):

- **Wrong numbers.** For a month with R$10.000 income and R$6.130 expenses, the
  model reported *"Receitas Totais: 20.000,00 BRL"*, *"Despesas Totais: R$ 13.000,00 BRL
  (Julho)"*, *"Reservas Acumuladas: 4000,00 BRL"*. The tool returned correct data;
  the model **misread the raw JSON doubles and did the arithmetic wrong**.
- **Bad currency formatting.** Values render as `6000.0` / `8880.0 BRL` /
  `80.0 BRL` instead of `R$ 60.000,00` etc. The model is reformatting raw
  doubles and mangling them (drops digits, wrong separators).
- **No financial competence.** Asked to build a car-purchase plan (R$80k car,
  R$60k consórcio, affordable installment from cash flow), it couldn't reason
  correctly — it hallucinated "Objetivo Carro: 80.0 BRL … assumindo 800.000".

## 2. Root cause

A small on-device LLM is unreliable at three things the current design asks of
it: (a) **reading numeric fields** out of JSON, (b) **doing arithmetic**
(sums, averages, installments), and (c) **formatting currency** to pt-BR. It
also has **no finance domain grounding** (rules of thumb, definitions,
calculation methods).

**Design principle to adopt:** *the LLM should narrate, not calculate or
format.* Every number the user sees should be computed and formatted in Dart and
handed to the model as a ready-to-quote string. The model's job is tone,
explanation, and advice — grounded in provided facts and finance knowledge.

## 3. Goals / Non-goals

**Goals**
- G1 — Numbers shown are always correct (computed in Dart, not by the LLM).
- G2 — Currency always formatted pt-BR (`R$ 60.000,00`) at the data boundary.
- G3 — The model can answer planning questions (goals, installments, savings
  rate, emergency fund) using deterministic calculators.
- G4 — The model has finance domain knowledge (definitions + rules of thumb +
  method) so advice is sound.
- G5 — A repeatable way to measure accuracy so regressions are caught.

**Non-goals**
- Swapping the on-device model / going cloud (kept as a later fallback option).
- Full financial-planning product (loans amortization tables, tax, etc.).
- Real-time market data.

## 4. Strategy — five layers (ordered by impact)

### Layer 1 — Deterministic compute + format at the tool boundary (HIGHEST impact, fixes G1+G2)
Move all math and formatting into Dart so the model only echoes strings.

- **Format every monetary value as a pt-BR string** in `GetFinancesHandler`
  output using `intl` `NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')`.
  Keep a raw numeric field too (for any programmatic use), but surface a
  `formatted` string the prompt tells the model to quote verbatim.
- **Pre-compute aggregates** so the model never sums: per-request totals across
  the returned months, monthly averages (income/expenses/reserves), savings
  rate (%), disposable income, accumulated reserves — all pre-formatted.
- **Prompt rule:** "Use ONLY the `formatted` values provided; never compute or
  reformat numbers yourself." (guardrail; see Layer 3.)

Outcome: eliminates the `0.0` / `130.0` / `6000.0` class of errors directly.

### Layer 2 — Specialized financial calculators as tools (fixes G3)
Add deterministic calculator tools the model can call for planning questions,
so the plan math is exact:

- `simulateGoalPlan(targetAmount, currentReserves, monthlyContribution?)` →
  months to reach goal, required monthly contribution for a target date,
  feasibility given current disposable income.
- `affordableInstallment(downPayment/consórcio, price, maxIncomePct=0.30)` →
  max safe installment (default ≤30% of income), resulting term, shortfall.
- `budgetBreakdown()` → 50/30/20 split vs actuals, over/under per bucket.

Each returns pre-formatted strings + a short structured verdict. Reuse the
existing `ToolHandler`/registry pattern; wire into the Nami session (and later
Vegapunk) exactly like `GetFinancesHandler`.

### Layer 3 — Reasoning guardrails & response templates
- Tighten `NamiPrompt`: explicit rules — never invent/compute/reformat numbers;
  if data is missing, say so; always cite the provided `formatted` values.
- Provide **few-shot examples** in the prompt: one budget-analysis answer and
  one goal-plan answer using tool data, showing the desired structure and that
  numbers are quoted, not recomputed.
- Optional lightweight **post-validation**: flag/strip any `R$` number in the
  model output that doesn't appear in the tool payload (defense in depth).

### Layer 4 — Financial knowledge base (fixes G4) — *leverages the mounted RAG*
This is the concrete use for the RAG store we deliberately kept mounted.

- Author a curated **finance knowledge corpus** (pt-BR): definitions
  (consórcio vs financiamento, CDI/Selic, juros compostos, reserva de
  emergência), rules of thumb (50/30/20, emergency fund = 3–6× despesas, safe
  debt ratio), and method notes ("como avaliar uma parcela").
- Ingest into a **separate RAG namespace** (not the user's finances store) via
  the existing `RagStoreCoordinator` pattern.
- On each message, retrieve top-k relevant concepts and inject as *reference*
  context (distinct from the user's factual data). This grounds *advice* while
  Layer 1/2 grounds *numbers*.
- Alternative/complement: bake a compact "finance cheatsheet" straight into the
  system prompt for the most common rules (cheaper, no retrieval), and use RAG
  only for the long tail.

### Layer 5 — Evaluation harness (fixes G5)
- A fixture set of finances snapshots + question→expected-answer assertions
  (numbers must match computed values; key advice points present).
- Unit-level: assert calculator tools return correct figures/format.
- Optional golden/LLM-graded tests for narrative quality (manual or scripted).

## 5. Recommended phasing

- **Phase 1 (quick win, ~small):** Layer 1 — format + pre-compute in
  `GetFinancesHandler`, plus the Layer 3 prompt guardrail. Fixes the visible
  bugs (wrong/ugly numbers) with the least work.
- **Phase 2:** Layer 2 calculators (goal plan + affordable installment) — enables
  correct planning answers like the car scenario.
- **Phase 3:** Layer 4 finance knowledge base over the mounted RAG (+ prompt
  cheatsheet) for sound advice.
- **Phase 4:** Layer 5 evaluation harness to lock it in.

## 6. Risks / tradeoffs
- More tools = more chances the small model calls the wrong one → mitigate with
  the proactive-execution pattern already used (infer intent, run the right
  calculator, inject result).
- Prompt growth (few-shot + cheatsheet) eats context (4096 tokens) → keep
  examples terse; prefer RAG for the long tail.
- Guardrail post-validation can false-positive on legit derived text → start as
  logging only.
- On-device model ceiling: even grounded, narrative reasoning is limited; a
  cloud/thinking-model fallback remains the escape hatch if quality is still
  short after Phases 1–3.

## 7. Open decisions (for the user)
- D1 — Scope now: just Phase 1 (fix numbers/format) or also Phase 2 (planning
  calculators)?
- D2 — Knowledge base delivery: RAG corpus (richer, more work) vs prompt
  cheatsheet (fast, limited) vs both?
- D3 — Acceptable to keep the on-device model, or is a cloud fallback for
  complex planning on the table?
