# Tasks — Nami Finances Dashboard

## Status: ✅ CONCLUÍDO

---

## T1 — Criar `finances_dashboard_view.dart`
- **Status**: ✅ DONE
- **Entregues**: HeroBalanceCard, MonthlyBalanceDonut (PieChart interativo), IncomesCard, ExpensesCard, SavingsGoalCard (progress bar), SpendingCategoriesCard (barras horizontais), FinancesHistoryWidget integrado, botão de edição

---

## T2 — Criar `finances_empty_state.dart`
- **Status**: ✅ DONE
- **Entregues**: Card de onboarding com ícone roxo, texto motivacional, feature pills, botão CTA

---

## T3 — Atualizar `nami_finances_screen.dart`
- **Status**: ✅ DONE
- **Entregues**:
  - NamiHeader removido
  - Flag `_showSetupForm` para controle de fluxo sem uso de model.empty()
  - `hasData=true` → `FinancesDashboardView`
  - `_showSetupForm=true` → `FinancesSetupForm` (novo cadastro)
  - `_editingFinances!=null` → `FinancesSetupForm` (edição)
  - Estado vazio → `FinancesEmptyState`
  - BLoC, events, states inalterados

---

## T4 — Validação
- **Status**: ✅ DONE
- **Resultado**: `flutter analyze lib/features/nami_finances/ → No issues found!`

---

## T5 — Atualizar `finances_setup_form.dart`
- **Goal**: Refatorar o visual do form para usar o design premium (backgrounds, padding, headers).
- **Files**: `presentation/widgets/finances_setup_form.dart` (MODIFICAR)
- **Status**: ✅ DONE

---

## T6 — Atualizar `expense_item_widget.dart`
- **Goal**: Remover bordas coloridas, ajustar cores e visual para alinhar com o card de Expenses.
- **Files**: `presentation/widgets/expense_item_widget.dart` (MODIFICAR)
- **Status**: ✅ DONE

---

## T7 — Atualizar `add_expense_dialog.dart`
- **Goal**: Aplicar tema premium ao dialog (cores, fundo).
- **Files**: `presentation/widgets/add_expense_dialog.dart` (MODIFICAR)
- **Status**: ✅ DONE
