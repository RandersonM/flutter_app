import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/presentation/expense_category_palette.dart';
import 'package:opfan/features/nami_finances/bloc/index.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';
import 'package:opfan/shared/utils/app_semantic_colors.dart';

class NamiDetailedFinancesScreen extends StatefulWidget {
  final DateTime? selectedMonth;

  const NamiDetailedFinancesScreen({super.key, this.selectedMonth});

  @override
  State<NamiDetailedFinancesScreen> createState() =>
      _NamiDetailedFinancesScreenState();
}

class _NamiDetailedFinancesScreenState
    extends State<NamiDetailedFinancesScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedMonth != null) {
      _selectedMonth = widget.selectedMonth!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      key: ValueKey('${_selectedMonth.year}-${_selectedMonth.month}'),
      create: (context) =>
          getIt<NamiFinancesBloc>()..add(LoadFinances(_selectedMonth)),
      child: Scaffold(
        bottomNavigationBar: const BottomNavigation(
          BottomNavigationPages.finances,
        ),
        appBar: DefaultAppBar(title: Text(l10n.financialSummary)),
        body: Container(
          padding: const EdgeInsets.all(Constants.margin),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const AppIcon(PhosphorIconsRegular.caretLeft),
                    onPressed: _canGoToPreviousMonth()
                        ? _goToPreviousMonth
                        : null,
                    style: IconButton.styleFrom(
                      foregroundColor: _canGoToPreviousMonth()
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                  Text(
                    _formatMonth(_selectedMonth),
                    style: TextTheme.of(context).titleMedium,
                  ),
                  IconButton(
                    icon: const AppIcon(PhosphorIconsRegular.caretRight),
                    onPressed: _canGoToNextMonth() ? _goToNextMonth : null,
                    style: IconButton.styleFrom(
                      foregroundColor: _canGoToNextMonth()
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.margin * 2),
              Expanded(
                child: BlocListener<NamiFinancesBloc, NamiFinancesState>(
                  listener: (context, state) {
                    // Listener para detectar mudanças de estado
                  },
                  child: BlocBuilder<NamiFinancesBloc, NamiFinancesState>(
                    builder: (context, state) {
                      if (state is NamiFinancesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is NamiFinancesLoaded) {
                        if (state.hasData && state.finances != null) {
                          return _buildDetailedFinancesView(
                            state.finances!,
                            l10n,
                          );
                        } else {
                          return _buildNoDataView(l10n);
                        }
                      }

                      if (state is NamiFinancesError) {
                        return _buildErrorView(state.failure, l10n);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedFinancesView(
    NamiFinancesModel finances,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthOverviewCard(finances, l10n),
          const SizedBox(height: Constants.margin),
          _buildIncomeDetailsCard(finances, l10n),
          const SizedBox(height: Constants.margin),
          _buildExpensesDetailsCard(finances, l10n),
          const SizedBox(height: Constants.margin),
          _buildSavingsDetailsCard(finances, l10n),
          const SizedBox(height: Constants.margin),
          _buildFinancialMetricsCard(finances, l10n),
          const SizedBox(height: Constants.margin * 2),
        ],
      ),
    );
  }

  Widget _buildMonthOverviewCard(
    NamiFinancesModel finances,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.financialSummary,
            style: TextTheme.of(context).titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Constants.margin * 2),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  l10n.totalIncome,
                  finances.totalIncome,
                  PhosphorIconsRegular.bank,
                  Theme.of(context).semanticColors.success,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  l10n.totalExpenses,
                  finances.totalExpenses,
                  PhosphorIconsRegular.shoppingCart,
                  Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  AppLocalizations.of(context)!.reservesLabel,
                  finances.totalReserves,
                  PhosphorIconsRegular.piggyBank,
                  Theme.of(context).semanticColors.info,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  AppLocalizations.of(context)!.availableLabel,
                  finances.availableAmount,
                  PhosphorIconsRegular.bank,
                  finances.availableAmount >= 0
                      ? Theme.of(context).semanticColors.success
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.margin),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: Constants.iconSize * 1.5),
          const SizedBox(height: Constants.margin),
          Text(
            label,
            style: TextTheme.of(context).bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.margin),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextTheme.of(context).titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeDetailsCard(
    NamiFinancesModel finances,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.bank,
                  color: Theme.of(context).semanticColors.success,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.incomeDetailsTitle,
                  style: TextTheme.of(
                    context,
                  ).titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            if (finances.monthlyIncomes.isNotEmpty)
              ...finances.monthlyIncomes.map(
                (income) => _buildIncomeItem(income),
              )
            else
              Padding(
                padding: const EdgeInsets.all(Constants.margin),
                child: Text(AppLocalizations.of(context)!.noIncomesRegistered),
              ),
            const SizedBox(height: Constants.margin),
            Container(
              padding: const EdgeInsets.all(Constants.margin),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).semanticColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Constants.margin),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.namiTotalIncomeLabel,
                    style: TextTheme.of(
                      context,
                    ).titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'R\$ ${(finances.totalIncome).toStringAsFixed(2)}',
                    style: TextTheme.of(context).titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).semanticColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeItem(MonthlyIncomeModel income) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.margin / 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              income.description,
              style: TextTheme.of(context).bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              'R\$ ${(income.amount).toStringAsFixed(2)}',
              style: TextTheme.of(context).bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).semanticColors.success,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesDetailsCard(
    NamiFinancesModel finances,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.shoppingCart,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.expensesDetails,
                  style: TextTheme.of(
                    context,
                  ).titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            if (finances.expenses.isNotEmpty) ...[
              ...finances.expenses.map((expense) => _buildExpenseItem(expense)),
              const SizedBox(height: Constants.margin * 2),
              Container(
                padding: const EdgeInsets.all(Constants.margin * 1.5),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Constants.margin),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppIcon(
                          PhosphorIconsRegular.shoppingCart,
                          color: Theme.of(context).colorScheme.error,
                          size: Constants.iconSize,
                        ),
                        const SizedBox(width: Constants.margin),
                        Text(
                          AppLocalizations.of(context)!.totalExpensesLabel,
                          style: TextTheme.of(context).titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'R\$ ${finances.totalExpenses.toStringAsFixed(2)}',
                      style: TextTheme.of(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(Constants.margin * 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(Constants.margin),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      PhosphorIconsRegular.info,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: Constants.iconSize,
                    ),
                    const SizedBox(width: Constants.margin),
                    Text(
                      AppLocalizations.of(context)!.noExpensesRegistered,
                      style: TextTheme.of(context).bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.margin),
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Constants.margin),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Constants.margin),
            decoration: BoxDecoration(
              color: ExpenseCategoryPalette.of(
                context,
                expense.category,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Constants.margin / 2),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: ExpenseCategoryPalette.of(context, expense.category),
              size: Constants.iconSize,
            ),
          ),
          const SizedBox(width: Constants.margin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: TextTheme.of(
                    context,
                  ).bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Constants.margin / 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.margin,
                    vertical: Constants.margin / 2,
                  ),
                  decoration: BoxDecoration(
                    color: ExpenseCategoryPalette.of(
                      context,
                      expense.category,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Constants.margin),
                  ),
                  child: Text(
                    _categoryLabel(expense.category).toUpperCase(),
                    style: TextTheme.of(context).bodySmall?.copyWith(
                      color: ExpenseCategoryPalette.of(
                        context,
                        expense.category,
                      ),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Constants.margin),
          Text(
            'R\$ ${expense.amount.toStringAsFixed(2)}',
            style: TextTheme.of(context).titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fixed:
        return PhosphorIconsRegular.house;
      case ExpenseCategory.food:
        return PhosphorIconsRegular.forkKnife;
      case ExpenseCategory.transport:
        return PhosphorIconsRegular.car;
      case ExpenseCategory.entertainment:
        return PhosphorIconsRegular.filmStrip;
      case ExpenseCategory.health:
        return PhosphorIconsRegular.firstAid;
      case ExpenseCategory.other:
        return PhosphorIconsRegular.dotsThree;
    }
  }

  String _categoryLabel(ExpenseCategory category) {
    final l10n = AppLocalizations.of(context)!;
    return switch (category) {
      ExpenseCategory.fixed => l10n.categoryFixed,
      ExpenseCategory.food => l10n.categoryFood,
      ExpenseCategory.transport => l10n.categoryTransport,
      ExpenseCategory.entertainment => l10n.categoryEntertainment,
      ExpenseCategory.health => l10n.categoryHealth,
      ExpenseCategory.other => l10n.categoryOther,
    };
  }

  String _reservePurposeLabel(ReservePurpose purpose) {
    final l10n = AppLocalizations.of(context)!;
    switch (purpose) {
      case ReservePurpose.emergency:
        return l10n.reservePurposeEmergency;
      case ReservePurpose.travel:
        return l10n.reservePurposeTravel;
      case ReservePurpose.goal:
        return l10n.reservePurposeGoal;
      case ReservePurpose.investment:
        return l10n.reservePurposeInvestment;
      case ReservePurpose.other:
        return l10n.reservePurposeOther;
    }
  }

  Widget _buildSavingsDetailsCard(
    NamiFinancesModel finances,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.piggyBank,
                  color: Theme.of(context).semanticColors.info,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.savingsDetailsTitle,
                  style: TextTheme.of(
                    context,
                  ).titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin),
            const SizedBox(height: Constants.margin),
            _buildSavingsMetric(
              AppLocalizations.of(context)!.monthSavings,
              finances.totalReserves,
              Theme.of(context).semanticColors.info,
            ),
            if (finances.reserveGoal != null && finances.reserveGoal! > 0)
              _buildSavingsMetric(
                AppLocalizations.of(context)!.reserveGoalMetricLabel,
                finances.reserveGoal!,
                Theme.of(context).colorScheme.primary,
              ),
            _buildSavingsMetric(
              AppLocalizations.of(context)!.savingsPercentage,
              finances.savingsPercentage,
              Theme.of(context).semanticColors.success,
            ),
            _buildSavingsMetric(
              AppLocalizations.of(context)!.yearlySavings,
              finances.yearlySavings,
              Theme.of(context).colorScheme.primary,
            ),
            // Per-reserve breakdown (purpose + optional note).
            if (finances.reserves.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              ...finances.reserves.map(
                (reserve) => _buildSavingsMetric(
                  reserve.note.isNotEmpty
                      ? '${_reservePurposeLabel(reserve.purpose)} · ${reserve.note}'
                      : _reservePurposeLabel(reserve.purpose),
                  reserve.amount,
                  Theme.of(context).semanticColors.info,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsMetric(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.margin / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextTheme.of(context).bodyMedium),
          Text(
            label == AppLocalizations.of(context)!.savingsPercentage
                ? '${value.toStringAsFixed(1)}%'
                : 'R\$ ${value.toStringAsFixed(2)}',
            style: TextTheme.of(
              context,
            ).bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetricsCard(
    NamiFinancesModel finances,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.chartLineUp,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.financialMetricsTitle,
                  style: TextTheme.of(
                    context,
                  ).titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin),
            const SizedBox(height: Constants.margin),
            _buildMetricItem(
              AppLocalizations.of(context)!.dailyAvailableAmount,
              finances.dailyAmount,
              PhosphorIconsRegular.calendarStar,
            ),
            _buildMetricItem(
              AppLocalizations.of(context)!.availableBalance,
              finances.availableAmount,
              PhosphorIconsRegular.bank,
            ),
            _buildMetricItem(
              AppLocalizations.of(context)!.currentMonthLabel,
              finances.isCurrentMonth
                  ? AppLocalizations.of(context)!.yesLabel
                  : AppLocalizations.of(context)!.noLabel,
              PhosphorIconsRegular.calendar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.margin / 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: Constants.iconSize,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: Constants.margin),
          Expanded(child: Text(label, style: TextTheme.of(context).bodyMedium)),
          Text(
            value is double
                ? 'R\$ ${value.toStringAsFixed(2)}'
                : value.toString(),
            style: TextTheme.of(context).bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            PhosphorIconsRegular.bank,
            size: Constants.iconSize * 4,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: Constants.margin * 2),
          Text(
            l10n.namiNoFinancialDataForMonth(_formatMonth(_selectedMonth)),
            style: TextTheme.of(context).titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.margin * 2),
          AppButton(
            onPressed: () => context.read<NamiFinancesBloc>().add(
              LoadFinances(_selectedMonth),
            ),
            label: AppLocalizations.of(context)!.tryAgain,
          ),
        ],
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, NamiFinancesFailure failure) =>
      switch (failure) {
        NamiFinancesFailure.loadFailed => l10n.namiFinancesLoadFailed,
        NamiFinancesFailure.historyLoadFailed =>
          l10n.namiFinancesHistoryLoadFailed,
        NamiFinancesFailure.saveFailed => l10n.namiFinancesSaveFailed,
        NamiFinancesFailure.deleteFailed => l10n.namiFinancesDeleteFailed,
        NamiFinancesFailure.futureMonthNotEditable =>
          l10n.namiFinancesFutureMonthNotEditable,
      };

  Widget _buildErrorView(NamiFinancesFailure failure, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            PhosphorIconsRegular.warningCircle,
            size: Constants.iconSize * 4,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: Constants.margin * 2),
          Text(
            l10n.namiErrorLoadingData,
            style: TextTheme.of(
              context,
            ).titleMedium?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: Constants.margin),
          Text(
            _failureMessage(l10n, failure),
            style: TextTheme.of(context).bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.margin * 2),
          AppButton(
            onPressed: () => context.read<NamiFinancesBloc>().add(
              LoadFinances(_selectedMonth),
            ),
            label: AppLocalizations.of(context)!.tryAgain,
          ),
        ],
      ),
    );
  }

  bool _canGoToPreviousMonth() {
    final previousMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
      1,
    );
    return previousMonth.isAfter(DateTime(2019, 12, 31));
  }

  bool _canGoToNextMonth() {
    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    );
    return nextMonth.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  void _goToPreviousMonth() {
    if (_canGoToPreviousMonth()) {
      setState(() {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
          1,
        );
      });
    }
  }

  void _goToNextMonth() {
    if (_canGoToNextMonth()) {
      setState(() {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
          1,
        );
      });
    }
  }

  String _formatMonth(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    final formatted = DateFormat.yMMMM(locale).format(date);
    return formatted.isEmpty
        ? formatted
        : formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
