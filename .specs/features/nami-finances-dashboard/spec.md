# Feature Spec — Nami Finances Dashboard

## Intent

Transformar a tela `NamiFinancesScreen` de um formulário de cadastro em um **painel financeiro premium** (dashboard), seguindo o estilo visual de Monarch Money, Revolut e Wallet by BudgetBakers.

---

## Requirements

| ID | Requisito |
|----|-----------|
| FIN-01 | A tela SHALL exibir um Hero Card de saldo do mês com totalIncome, totalExpenses e saldo líquido (availableAmount) |
| FIN-02 | A tela SHALL exibir um Monthly Balance Donut Chart mostrando proporção Income / Expenses / Savings |
| FIN-03 | A tela SHALL exibir um card de Receitas listando cada `MonthlyIncomeModel` com descrição e valor |
| FIN-04 | A tela SHALL exibir um card de Gastos listando cada `ExpenseModel` com categoria e valor |
| FIN-05 | A tela SHALL exibir um card de Reserva (Savings Goal) com progress bar mostrando % de meta |
| FIN-06 | A tela SHALL exibir um card de Spending Categories com barras horizontais por `ExpenseCategory` |
| FIN-07 | A paleta de cores SHALL usar roxo `#8B5CF6` como primária e dourado `#FACC15` como secundária |
| FIN-08 | Cards SHALL ter background `#16161C`, border-radius 24, sem borda colorida |
| FIN-09 | Cada card SHALL ter ícone colorido como único elemento de cor (🟢 income, 🟣 savings, 🔴 expenses) |
| FIN-10 | O header SHALL usar gradiente `rgba(124,58,237,.35) → #09090B` (vertical, suave) |
| FIN-11 | Botões de adicionar SHALL ser pequenos, estilo inline, cor roxa |
| FIN-12 | A NamiHeader (imagem gif) SHALL ser substituída pelo Hero Card de saldo (FIN-01) |
| FIN-13 | A lógica de BLoC e models NÃO devem ser alterados (preservar contrato existente) |
| FIN-14 | O widget `FinancesHistoryWidget` SHALL ser preservado e integrado ao dashboard |
| FIN-15 | A tela SHALL manter o fluxo de formulário (edit mode) acessível via botão no dashboard |

---

## Acceptance Criteria

- [ ] Dashboard carrega e exibe Hero Card com `saldo = totalIncome - totalExpenses - savings`
- [ ] Donut chart renderiza sem erros quando há dados e quando não há dados
- [ ] Cards de Receitas e Gastos listam itens reais do `NamiFinancesModel`
- [ ] Progress bar de Savings calcula `savings / savingsGoal * 100` (meta padrão: R$ 5.000)
- [ ] Spending Categories renderiza barra horizontal por categoria com % correto
- [ ] Estado vazio (sem dados) exibe mensagem de onboarding com botão para iniciar cadastro
- [ ] Cores respeitam a paleta FIN-07 sem variações extras
- [ ] `flutter analyze` não reporta novos erros ou warnings

---

## Phase 2: Form Redesign Requirements

| ID | Requisito |
|----|-----------|
| FIN-16 | A tela de setup (FinancesSetupForm) SHALL usar a mesma paleta de cores do dashboard (`#8B5CF6`, `#16161C`, etc) |
| FIN-17 | As seções de Income, Expenses e Savings do formulário SHALL ter background `#16161C`, border-radius 24, e sem bordas coloridas |
| FIN-18 | O cabeçalho de cada seção do form SHALL usar o mesmo estilo de `_CardHeader` do dashboard |
| FIN-19 | Os botões de adicionar item (Income/Expense) SHALL usar um estilo menor ou outline, com a cor da seção (ou roxo) |
| FIN-20 | O botão de salvar SHALL seguir o design premium (Roxo primário) |
| FIN-21 | O `ExpenseItemWidget` e `AddExpenseDialog` SHALL ser atualizados para remover bordas coloridas e usar o estilo escuro |
| FIN-22 | Os inputs (`FinanceCurrencyTextField`, etc) devem se integrar bem visualmente no fundo `#16161C` |

---

## Phase 2 Acceptance Criteria

- [ ] `FinancesSetupForm` seções usam `#16161C` sem bordas com radius 24.
- [ ] Títulos das seções de formulário usam ícones com o mesmo box e background alpha do dashboard.
- [ ] `ExpenseItemWidget` não possui borda e se integra ao design.
- [ ] `AddExpenseDialog` adota o tema escuro.

---

## Constraints

- NÃO alterar `NamiFinancesModel`, `NamiFinancesBloc`, `NamiFinancesService`
- NÃO alterar `nami_finances_event.dart` e `nami_finances_state.dart`
- NÃO adicionar novas dependências além das já instaladas (`fl_chart` já disponível)
- Preservar `FinancesHistoryWidget` e `FinancesSetupForm` sem modificar sua lógica interna
- Manter suporte a i18n com `AppLocalizations`
- Preservar `BottomNavigation` e `DefaultAppBar`
