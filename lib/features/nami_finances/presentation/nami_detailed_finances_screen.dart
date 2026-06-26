import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/bloc/index.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

class NamiDetailedFinancesScreen extends StatefulWidget {
  final DateTime? selectedMonth;

  const NamiDetailedFinancesScreen({
    super.key,
    this.selectedMonth,
  });

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
        bottomNavigationBar:
            const BottomNavigation(BottomNavigationPages.finances),
        appBar: DefaultAppBar(
          title: Text(l10n.financialSummary),
        ),
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
                    onPressed:
                        _canGoToPreviousMonth() ? _goToPreviousMonth : null,
                    style: IconButton.styleFrom(
                      foregroundColor: _canGoToPreviousMonth()
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.38),
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
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.38),
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
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is NamiFinancesLoaded) {
                        if (state.hasData && state.finances != null) {
                          return _buildDetailedFinancesView(
                              state.finances!, l10n);
                        } else {
                          return _buildNoDataView(l10n);
                        }
                      }

                      if (state is NamiFinancesError) {
                        return _buildErrorView(state.message, l10n);
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
      NamiFinancesModel finances, AppLocalizations l10n) {
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
      NamiFinancesModel finances, AppLocalizations l10n) {
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
                  AppColors.green[500]!,
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
                  AppLocalizations.of(context)!.savingsLabel,
                  finances.savings,
                  PhosphorIconsRegular.piggyBank,
                  AppColors.blue[500]!,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  AppLocalizations.of(context)!.availableLabel,
                  finances.availableAmount,
                  PhosphorIconsRegular.bank,
                  AppColors.orange[500]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
      String label, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainer
            .withValues(alpha: 0.1),
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
      NamiFinancesModel finances, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(PhosphorIconsRegular.bank,
                    color: AppColors.green[500]!),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.incomeDetailsTitle,
                  style: TextTheme.of(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            if (finances.monthlyIncomes.isNotEmpty)
              ...finances.monthlyIncomes
                  .map((income) => _buildIncomeItem(income))
                  
            else
              Padding(
                padding: const EdgeInsets.all(Constants.margin),
                child: Text(AppLocalizations.of(context)!.noIncomesRegistered),
              ),
            const SizedBox(height: Constants.margin),
            Container(
              padding: const EdgeInsets.all(Constants.margin),
              decoration: BoxDecoration(
                color: AppColors.green[500]!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Constants.margin),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total da Renda:',
                    style: TextTheme.of(context).titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'R\$ ${(finances.totalIncome).toStringAsFixed(2)}',
                    style: TextTheme.of(context).titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.green[500]!,
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
                    color: AppColors.green[500]!,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesDetailsCard(
      NamiFinancesModel finances, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(PhosphorIconsRegular.shoppingCart,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.expensesDetails,
                  style: TextTheme.of(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            if (finances.expenses.isNotEmpty) ...[
              ...finances.expenses
                  .map((expense) => _buildExpenseItem(expense))
                  ,
              const SizedBox(height: Constants.margin * 2),
              Container(
                padding: const EdgeInsets.all(Constants.margin * 1.5),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Constants.margin),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.3),
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
                  color: AppColors.grey[100] ?? Colors.grey[100],
                  borderRadius: BorderRadius.circular(Constants.margin),
                  border: Border.all(
                    color: AppColors.grey[300] ?? Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      PhosphorIconsRegular.info,
                      color: AppColors.grey[600] ?? Colors.grey[600]!,
                      size: Constants.iconSize,
                    ),
                    const SizedBox(width: Constants.margin),
                    Text(
                      AppLocalizations.of(context)!.noExpensesRegistered,
                      style: TextTheme.of(context).bodyMedium?.copyWith(
                            color: AppColors.grey[600] ?? Colors.grey[600]!,
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
              color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Constants.margin / 2),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category),
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
                  style: TextTheme.of(context).bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
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
                    color: _getCategoryColor(expense.category)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Constants.margin),
                  ),
                  child: Text(
                    expense.category.name.toUpperCase(),
                    style: TextTheme.of(context).bodySmall?.copyWith(
                          color: _getCategoryColor(expense.category),
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

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fixed:
        return AppColors.red[500] ?? Colors.red;
      case ExpenseCategory.food:
        return AppColors.orange[500] ?? Colors.orange;
      case ExpenseCategory.transport:
        return AppColors.blue[500] ?? Colors.blue;
      case ExpenseCategory.entertainment:
        return AppColors.purple[500] ?? Colors.purple;
      case ExpenseCategory.health:
        return AppColors.green[500] ?? Colors.green;
      case ExpenseCategory.other:
        return AppColors.grey[500] ?? Colors.grey;
    }
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

  Widget _buildSavingsDetailsCard(
      NamiFinancesModel finances, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(PhosphorIconsRegular.piggyBank,
                    color: AppColors.blue[500]!),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.savingsDetailsTitle,
                  style: TextTheme.of(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin),
            const SizedBox(height: Constants.margin),
            _buildSavingsMetric(AppLocalizations.of(context)!.monthSavings,
                finances.savings, AppColors.blue[500]!),
            _buildSavingsMetric(AppLocalizations.of(context)!.savingsPercentage,
                finances.savingsPercentage, AppColors.green[500]!),
            _buildSavingsMetric(AppLocalizations.of(context)!.yearlySavings,
                finances.yearlySavings, Theme.of(context).colorScheme.primary),
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
          Text(
            label,
            style: TextTheme.of(context).bodyMedium,
          ),
          Text(
            label == AppLocalizations.of(context)!.savingsPercentage
                ? '${value.toStringAsFixed(1)}%'
                : 'R\$ ${value.toStringAsFixed(2)}',
            style: TextTheme.of(context).bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetricsCard(
      NamiFinancesModel finances, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(PhosphorIconsRegular.chartLineUp,
                    color: AppColors.orange[500]!),
                const SizedBox(width: Constants.margin),
                Text(
                  AppLocalizations.of(context)!.financialMetricsTitle,
                  style: TextTheme.of(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin),
            const SizedBox(height: Constants.margin),
            _buildMetricItem(AppLocalizations.of(context)!.dailyAvailableAmount,
                finances.dailyAmount, PhosphorIconsRegular.calendarStar),
            _buildMetricItem(AppLocalizations.of(context)!.availableBalance,
                finances.availableAmount, PhosphorIconsRegular.bank),
            _buildMetricItem(
                AppLocalizations.of(context)!.currentMonthLabel,
                finances.isCurrentMonth
                    ? AppLocalizations.of(context)!.yesLabel
                    : AppLocalizations.of(context)!.noLabel,
                PhosphorIconsRegular.calendar),
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
          Icon(icon, size: Constants.iconSize, color: AppColors.orange[500]!),
          const SizedBox(width: Constants.margin),
          Expanded(
            child: Text(
              label,
              style: TextTheme.of(context).bodyMedium,
            ),
          ),
          Text(
            value is double
                ? 'R\$ ${value.toStringAsFixed(2)}'
                : value.toString(),
            style: TextTheme.of(context).bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.orange[500]!,
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
            color: AppColors.grey[400]!,
          ),
          const SizedBox(height: Constants.margin * 2),
          Text(
            'Nenhum dado financeiro encontrado para ${_formatMonth(_selectedMonth)}',
            style: TextTheme.of(context).titleMedium?.copyWith(
                  color: AppColors.grey[600]!,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.margin * 2),
          AppButton(
            onPressed: () => context
                .read<NamiFinancesBloc>()
                .add(LoadFinances(_selectedMonth)),
            label: AppLocalizations.of(context)!.tryAgain,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, AppLocalizations l10n) {
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
            'Erro ao carregar dados',
            style: TextTheme.of(context).titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: Constants.margin),
          Text(
            message,
            style: TextTheme.of(context).bodyMedium?.copyWith(
                  color: AppColors.grey[700]!,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.margin * 2),
          AppButton(
            onPressed: () => context
                .read<NamiFinancesBloc>()
                .add(LoadFinances(_selectedMonth)),
            label: AppLocalizations.of(context)!.tryAgain,
          ),
        ],
      ),
    );
  }

  bool _canGoToPreviousMonth() {
    final previousMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    return previousMonth.isAfter(DateTime(2019, 12, 31));
  }

  bool _canGoToNextMonth() {
    final nextMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    return nextMonth.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  void _goToPreviousMonth() {
    if (_canGoToPreviousMonth()) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      });
    }
  }

  void _goToNextMonth() {
    if (_canGoToNextMonth()) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      });
    }
  }

  String _formatMonth(DateTime date) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    super.dispose();
  }
}
