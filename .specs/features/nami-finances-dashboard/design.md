# Design — Nami Finances Dashboard

## Visão Geral da Arquitetura

```
NamiFinancesScreen (StatefulWidget — inalterado)
  └── BlocProvider<NamiFinancesBloc>
        └── Scaffold
              ├── DefaultAppBar (inalterado)
              ├── body: _DashboardBody (novo — extrai lógica do body)
              │     ├── [loading]  → CircularProgressIndicator
              │     ├── [hasData]  → FinancesDashboardView (NOVO)
              │     ├── [noData]   → FinancesEmptyState (NOVO)
              │     └── [error]    → ErrorMessage
              └── BottomNavigation (inalterado)
```

## Componentes Novos

### 1. `FinancesDashboardView` (substitui `FinancesResultsView`)
Responsabilidade: renderizar o dashboard completo quando há dados.

```
FinancesDashboardView
  ├── _HeroBalanceCard          (FIN-01, FIN-10)
  ├── _MonthlyBalanceDonut      (FIN-02) — usa fl_chart PieChart
  ├── _IncomesCard              (FIN-03)
  ├── _ExpensesCard             (FIN-04)
  ├── _SavingsGoalCard          (FIN-05)
  ├── _SpendingCategoriesCard   (FIN-06)
  ├── FinancesHistoryWidget     (FIN-14 — preservado)
  └── _DashboardActions         (FIN-15 — edit button pequeno)
```

### 2. `_HeroBalanceCard`
- Container com gradiente `rgba(124,58,237,.35) → #09090B`
- Exibe: "Saldo do mês", valor principal (availableAmount), receitas (+), gastos (-)
- Cor do saldo: verde se positivo, vermelho se negativo

### 3. `_MonthlyBalanceDonut`
- `PieChart` do `fl_chart` já instalado
- 3 seções: Income (roxo), Expenses (vermelho), Savings (dourado)
- Centro: texto com saldo total
- Legendas abaixo

### 4. `_IncomesCard` / `_ExpensesCard`
- Background `#16161C`, radius 24, sem borda
- Header: ícone colorido + título branco
- Lista de itens com descrição + valor
- Botão "+ Adicionar" pequeno, roxo, no final do card

### 5. `_SavingsGoalCard`
- Valor atual da poupança em destaque
- LinearProgressIndicator roxo (savings / 5000)
- Exibe % e valor da meta

### 6. `_SpendingCategoriesCard`
- Lista de categorias com ícone emoji, nome, %
- Barra horizontal proporcional à %, cor da categoria
- Ordenado por % decrescente

### 7. `FinancesEmptyState` (novo — tela de onboarding)
- Substitui o comportamento de mostrar o formulário direto
- Ilustração + texto + botão "Configurar finanças" que abre o form

## Paleta de Cores (constantes locais)

```dart
static const _purple   = Color(0xFF8B5CF6);
static const _gold     = Color(0xFFFACC15);
static const _cardBg   = Color(0xFF16161C);
static const _red      = Color(0xFFEF4444);
static const _green    = Color(0xFF22C55E);
static const _surface  = Color(0xFF09090B);
```

## Arquivos Afetados

| Arquivo | Ação |
|---------|------|
| `presentation/nami_finances_screen.dart` | Leve refactor: extrair `_DashboardBody` |
| `presentation/widgets/nami_header.dart` | REMOVIDO do uso (substituído pelo HeroCard) |
| `presentation/widgets/finances_results_view.dart` | SUBSTITUÍDO por `finances_dashboard_view.dart` |
| `presentation/widgets/finances_dashboard_view.dart` | CRIADO |
| `presentation/widgets/finances_empty_state.dart` | CRIADO |
| `presentation/widgets/finances_setup_form.dart` | INALTERADO |
| `presentation/widgets/finances_history_widget.dart` | INALTERADO |
| `presentation/widgets/add_expense_dialog.dart` | INALTERADO |
| `presentation/widgets/expense_item_widget.dart` | INALTERADO |
