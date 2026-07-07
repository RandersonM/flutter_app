import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/presentation/widgets/finances_history_widget.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

// ─── Design tokens ──────────────────────────────────────────────────────────
const _purple = Color(0xFF8B5CF6);
const _gold = Color(0xFFFACC15);
const _cardBg = Color(0xFF16161C);
const _errorRed = Color(0xFFEF4444);
const _successGreen = Color(0xFF22C55E);

// ─── Main dashboard widget ───────────────────────────────────────────────────

/// Dashboard view shown when finances data exists for the current month.
class FinancesDashboardView extends StatelessWidget {
  final NamiFinancesModel finances;
  final VoidCallback onEdit;

  const FinancesDashboardView({
    super.key,
    required this.finances,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroBalanceCard(finances: finances),
        const SizedBox(height: Constants.margin * 2),
        _MonthlyBalanceDonut(finances: finances),
        const SizedBox(height: Constants.margin * 2),
        _IncomesCard(finances: finances),
        const SizedBox(height: Constants.margin * 2),
        _ExpensesCard(finances: finances),
        const SizedBox(height: Constants.margin * 2),
        _SavingsGoalCard(finances: finances),
        const SizedBox(height: Constants.margin * 2),
        _SpendingCategoriesCard(finances: finances),
        const SizedBox(height: Constants.margin * 2),
        const FinancesHistoryWidget(),
        const SizedBox(height: Constants.margin * 2),
        _DashboardActions(onEdit: onEdit),
        const SizedBox(height: Constants.margin * 2),
      ],
    );
  }
}

// ─── Hero Balance Card ───────────────────────────────────────────────────────

class _HeroBalanceCard extends StatelessWidget {
  final NamiFinancesModel finances;

  const _HeroBalanceCard({required this.finances});

  @override
  Widget build(BuildContext context) {
    final balance = finances.availableAmount;
    final isPositive = balance >= 0;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.margin * 2,
        vertical: Constants.margin * 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x597C3AED), // rgba(124,58,237,.35)
            Color(0xFF09090B),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.saveWithNami,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.financialSummary,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: Constants.margin),
          Text(
            'R\$ ${balance.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: isPositive ? _successGreen : _errorRed,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: Constants.margin * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BalancePill(
                icon: PhosphorIconsRegular.arrowUp,
                color: _successGreen,
                label: AppLocalizations.of(context)!.incomesLabel,
                value: finances.totalIncome,
              ),
              const SizedBox(width: Constants.margin * 2),
              _BalancePill(
                icon: PhosphorIconsRegular.arrowDown,
                color: _errorRed,
                label: AppLocalizations.of(context)!.expensesLabel,
                value: finances.totalExpenses,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double value;

  const _BalancePill({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white54),
            ),
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Monthly Balance Donut ───────────────────────────────────────────────────

class _MonthlyBalanceDonut extends StatefulWidget {
  final NamiFinancesModel finances;

  const _MonthlyBalanceDonut({required this.finances});

  @override
  State<_MonthlyBalanceDonut> createState() => _MonthlyBalanceDonutState();
}

class _MonthlyBalanceDonutState extends State<_MonthlyBalanceDonut> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final income = widget.finances.totalIncome;
    final expenses = widget.finances.totalExpenses;
    final savings = widget.finances.savings;
    final total = income;

    if (total == 0) return const SizedBox.shrink();

    const incomePct = 100.0;
    final expensesPct = income > 0 ? (expenses / income * 100) : 0.0;
    final savingsPct = income > 0 ? (savings / income * 100) : 0.0;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: PhosphorIconsRegular.circle,
            iconColor: _purple,
            title: AppLocalizations.of(context)!.monthBalance,
          ),
          const SizedBox(height: Constants.margin * 2),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        _buildSection(
                          title: AppLocalizations.of(context)!.incomesLabel,
                          value: incomePct,
                          color: _purple,
                          index: 0,
                        ),
                        _buildSection(
                          title: AppLocalizations.of(context)!.expensesLabel,
                          value: expensesPct,
                          color: _errorRed,
                          index: 1,
                        ),
                        _buildSection(
                          title: AppLocalizations.of(context)!.reservesLabel,
                          value: savingsPct,
                          color: _gold,
                          index: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Constants.margin * 2),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DonutLegend(
                      color: _purple,
                      label: AppLocalizations.of(context)!.incomesLabel,
                      value: 'R\$ ${income.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 12),
                    _DonutLegend(
                      color: _errorRed,
                      label: AppLocalizations.of(context)!.expensesLabel,
                      value: 'R\$ ${expenses.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 12),
                    _DonutLegend(
                      color: _gold,
                      label: AppLocalizations.of(context)!.reservesLabel,
                      value: 'R\$ ${savings.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildSection({
    required String title,
    required double value,
    required Color color,
    required int index,
  }) {
    final isTouched = index == _touchedIndex;
    final radius = isTouched ? 60.0 : 50.0;
    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(0)}%',
      radius: radius,
      titleStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _DonutLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _DonutLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white54),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Incomes Card ────────────────────────────────────────────────────────────

class _IncomesCard extends StatelessWidget {
  final NamiFinancesModel finances;

  const _IncomesCard({required this.finances});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: PhosphorIconsRegular.bank,
            iconColor: _successGreen,
            title: AppLocalizations.of(context)!.incomes,
          ),
          const SizedBox(height: Constants.margin),
          ...finances.monthlyIncomes.map(
            (income) => _FinanceLineItem(
              label: income.description.isNotEmpty
                  ? income.description
                  : AppLocalizations.of(context)!.incomeLabel,
              value: income.amount,
              valueColor: _successGreen,
            ),
          ),
          if (finances.monthlyIncomes.isEmpty)
            _EmptyListHint(
              text: AppLocalizations.of(context)!.noIncomesRegistered,
            ),
          const SizedBox(height: Constants.margin),
          _TotalRow(
            label: AppLocalizations.of(context)!.totalReceived,
            value: finances.totalIncome,
            color: _successGreen,
          ),
        ],
      ),
    );
  }
}

// ─── Expenses Card ───────────────────────────────────────────────────────────

class _ExpensesCard extends StatelessWidget {
  final NamiFinancesModel finances;

  const _ExpensesCard({required this.finances});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: PhosphorIconsRegular.money,
            iconColor: _errorRed,
            title: AppLocalizations.of(context)!.expenses,
          ),
          const SizedBox(height: Constants.margin),
          ...finances.expenses.map(
            (expense) => _FinanceLineItem(
              label: expense.description.isNotEmpty
                  ? expense.description
                  : _categoryLabel(expense.category, context),
              value: expense.amount,
              valueColor: _errorRed,
            ),
          ),
          if (finances.expenses.isEmpty)
            _EmptyListHint(
              text: AppLocalizations.of(context)!.noExpensesRegistered,
            ),
          const SizedBox(height: Constants.margin),
          _TotalRow(
            label: AppLocalizations.of(context)!.totalSpent,
            value: finances.totalExpenses,
            color: _errorRed,
          ),
        ],
      ),
    );
  }

  String _categoryLabel(ExpenseCategory category, BuildContext context) {
    switch (category) {
      case ExpenseCategory.fixed:
        return AppLocalizations.of(context)!.categoryFixed;
      case ExpenseCategory.food:
        return AppLocalizations.of(context)!.categoryFood;
      case ExpenseCategory.transport:
        return AppLocalizations.of(context)!.categoryTransport;
      case ExpenseCategory.entertainment:
        return AppLocalizations.of(context)!.categoryEntertainment;
      case ExpenseCategory.health:
        return AppLocalizations.of(context)!.categoryHealth;
      case ExpenseCategory.other:
        return AppLocalizations.of(context)!.categoryOther;
    }
  }
}

// ─── Savings Goal Card ───────────────────────────────────────────────────────

class _SavingsGoalCard extends StatelessWidget {
  final NamiFinancesModel finances;
  static const double _goalAmount = 5000.0;

  const _SavingsGoalCard({required this.finances});

  @override
  Widget build(BuildContext context) {
    final progress = math.min(finances.savings / _goalAmount, 1.0);
    final pct = (progress * 100).toStringAsFixed(0);

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: PhosphorIconsRegular.piggyBank,
            iconColor: _purple,
            title: AppLocalizations.of(context)!.reserves,
          ),
          const SizedBox(height: Constants.margin),
          Text(
            'R\$ ${finances.savings.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Meta: R\$ ${_goalAmount.toStringAsFixed(0)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: Constants.margin),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(_purple),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct% da meta',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Faltam R\$ ${math.max(_goalAmount - finances.savings, 0).toStringAsFixed(0)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Spending Categories Card ─────────────────────────────────────────────────

class _SpendingCategoriesCard extends StatelessWidget {
  final NamiFinancesModel finances;

  const _SpendingCategoriesCard({required this.finances});

  static const _categoryEmoji = {
    ExpenseCategory.fixed: '🏠',
    ExpenseCategory.food: '🍔',
    ExpenseCategory.transport: '🚗',
    ExpenseCategory.entertainment: '🎮',
    ExpenseCategory.health: '🏋️',
    ExpenseCategory.other: '📦',
  };

  String _getCategoryName(ExpenseCategory category, BuildContext context) {
    switch (category) {
      case ExpenseCategory.fixed:
        return AppLocalizations.of(context)!.categoryFixed;
      case ExpenseCategory.food:
        return AppLocalizations.of(context)!.categoryFood;
      case ExpenseCategory.transport:
        return AppLocalizations.of(context)!.categoryTransport;
      case ExpenseCategory.entertainment:
        return AppLocalizations.of(context)!.categoryEntertainment;
      case ExpenseCategory.health:
        return AppLocalizations.of(context)!.categoryHealth;
      case ExpenseCategory.other:
        return AppLocalizations.of(context)!.categoryOther;
    }
  }

  static const _categoryColor = {
    ExpenseCategory.fixed: Color(0xFFFC8181),
    ExpenseCategory.food: Color(0xFFF6AD55),
    ExpenseCategory.transport: Color(0xFF63B3ED),
    ExpenseCategory.entertainment: _purple,
    ExpenseCategory.health: _successGreen,
    ExpenseCategory.other: Color(0xFF9CA3AF),
  };

  @override
  Widget build(BuildContext context) {
    final total = finances.totalExpenses;

    if (total == 0) return const SizedBox.shrink();

    final categories = finances.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: PhosphorIconsRegular.chartPieSlice,
            iconColor: _gold,
            title: AppLocalizations.of(context)!.categories,
          ),
          const SizedBox(height: Constants.margin),
          ...categories.map((entry) {
            final pct = entry.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryBar(
                emoji: _categoryEmoji[entry.key] ?? '📦',
                name: _getCategoryName(entry.key, context),
                color: _categoryColor[entry.key] ?? Colors.grey,
                percentage: pct,
                amount: entry.value,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String emoji;
  final String name;
  final Color color;
  final double percentage;
  final double amount;

  const _CategoryBar({
    required this.emoji,
    required this.name,
    required this.color,
    required this.percentage,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final pctText = '${(percentage * 100).toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ),
            Text(
              'R\$ ${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: Text(
                pctText,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: color),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 5,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─── Dashboard Actions ────────────────────────────────────────────────────────

class _DashboardActions extends StatelessWidget {
  final VoidCallback onEdit;

  const _DashboardActions({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            onPressed: onEdit,
            variant: AppButtonVariant.outline,
            icon: const AppIcon(PhosphorIconsRegular.pencil, size: 16),
            label: AppLocalizations.of(context)!.editData,
            foregroundColor: _purple,
            padding: const EdgeInsets.symmetric(vertical: 12),
            borderRadius: 12,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }
}

// ─── Shared internal widgets ─────────────────────────────────────────────────

class _DashboardCard extends StatelessWidget {
  final Widget child;

  const _DashboardCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Constants.margin * 1.5),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _CardHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: Constants.margin),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FinanceLineItem extends StatelessWidget {
  final String label;
  final double value;
  final Color valueColor;

  const _FinanceLineItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: Constants.margin,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyListHint extends StatelessWidget {
  final String text;

  const _EmptyListHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white30,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
