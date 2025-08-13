import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/theme.dart';
import 'package:opfan/core/models/nami_finances_model.dart';
import 'package:opfan/core/services/nami_finances_service.dart';
import 'package:opfan/widgets/atoms/gomu_gomu_divider.dart';
import 'package:opfan/screens/nami-finances/widgets/finances_history_widget.dart';

class FinancesResultsView extends StatefulWidget {
  final NamiFinancesModel finances;
  final VoidCallback onEdit;

  const FinancesResultsView({
    Key? key,
    required this.finances,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<FinancesResultsView> createState() => _FinancesResultsViewState();
}

class _FinancesResultsViewState extends State<FinancesResultsView> {
  Map<String, dynamic>? _accumulatedInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_accumulatedInfo == null) {
      _loadAccumulatedInfo();
    }
  }

  Future<void> _loadAccumulatedInfo() async {
    try {
      final service = NamiFinancesService();
      final info = await service
          .getAccumulatedSavingsInfoLocalized(AppLocalizations.of(context)!);
      setState(() {
        _accumulatedInfo = info;
      });
    } catch (e) {
      debugPrint('Erro ao carregar informações acumuladas: $e');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        _buildSummaryCard(l10n),
        const SizedBox(height: Constants.margin),
        _buildExpensesBreakdown(l10n),
        const SizedBox(height: Constants.margin),
        _buildSavingsCard(l10n),
        const SizedBox(height: Constants.margin),
        const FinancesHistoryWidget(),
        const SizedBox(height: Constants.margin),
        _buildEditButton(l10n),
      ],
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        gradient: LinearGradient(
          end: Alignment.topCenter,
          begin: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.financialSummary,
            style: TextTheme.of(context).titleMedium,
          ),
          const SizedBox(height: Constants.margin * 2),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  l10n.totalIncome,
                  widget.finances.totalIncome,
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: Constants.margin),
              Expanded(
                child: _buildSummaryItem(
                  l10n.totalExpenses,
                  widget.finances.totalExpenses,
                  Icons.payments,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  l10n.availableAmount,
                  widget.finances.availableAmount,
                  Icons.account_balance,
                ),
              ),
              const SizedBox(width: Constants.margin),
              Expanded(
                child: _buildSummaryItem(
                  l10n.dailyAmount,
                  widget.finances.dailyAmount,
                  Icons.today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, IconData icon) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Constants.margin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextTheme.of(context).bodyMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextTheme.of(context).bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesBreakdown(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Constants.margin * 3 ,
        horizontal: Constants.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GomuGomuDivider(
            color: Theme.of(context).colorScheme.primary,
            height: Constants.margin,
            thickness: 1,
          ),
          const SizedBox(height: Constants.margin * 3),
          Row(
            children: [
              Icon(Icons.pie_chart, color: AppColors.red[500], size: 24),
              const SizedBox(width: Constants.margin),
                             Text(
                 l10n.expensesByCategory,
                 style: TextTheme.of(context).titleLarge,
                 
               ),
            ],
          ),
          const SizedBox(height: Constants.margin * 2),
          ...widget.finances.expensesByCategory.entries.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final percentage = (amount / widget.finances.totalExpenses * 100);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getCategoryLabel(category, l10n),
                      style: TextTheme.of(context).bodySmall,
                    ),
                  ),
                  Text(
                    'R\$ ${amount.toStringAsFixed(2)}',
                    style: TextTheme.of(context).bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: TextTheme.of(context).bodyMedium,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSavingsCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.savings, size: 24),
              const SizedBox(width: Constants.margin),
              Text(
                l10n.savings,
                style: TextTheme.of(context).titleMedium,
              ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          Row(
            children: [
              Expanded(
                child: _buildSavingsItem(
                  l10n.monthlySavings,
                  'R\$ ${widget.finances.savings.toStringAsFixed(2)}',
                  Icons.savings,
                ),
              ),
              const SizedBox(width: Constants.margin),
              Expanded(
                child: _buildSavingsItem(
                  l10n.savingsPercentage,
                  '${widget.finances.savingsPercentage.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          Row(
            children: [
              Expanded(
                child: _buildSavingsItem(
                  _accumulatedInfo != null &&
                          _accumulatedInfo!['totalSavings'] > 0
                      ? '${l10n.accumulatedSavings} ${_accumulatedInfo!['periodText']}'
                      : l10n.yearlySavings,
                  _accumulatedInfo != null &&
                          _accumulatedInfo!['totalSavings'] > 0
                      ? '${l10n.currency} ${_accumulatedInfo!['totalSavings'].toStringAsFixed(2)}'
                      : '${l10n.currency} ${widget.finances.yearlySavings.toStringAsFixed(2)}',
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: Constants.margin),
              Expanded(
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(Constants.margin),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(Constants.margin),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.finances.savingsPercentage >= 10 
                          ? 'assets/logo/nami-icon.png'
                          : 'assets/logo/luffy-approve.png',
                        width: 52,
                        height: 52,
                      ),
                      const SizedBox(height: Constants.margin),
                      Text(
                        widget.finances.savingsPercentage >= 10 
                          ? l10n.namiApproves
                          : l10n.namiNeedsReview,
                        style: TextTheme.of(context).bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.finances.savingsPercentage >= 10 
                                  ? AppColors.yellow[500]!
                            : AppColors.red[500]!,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsItem(String label, String value, IconData icon) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Constants.margin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextTheme.of(context).bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextTheme.of(context).titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onEdit,
        icon: const Icon(Icons.edit),
        label: Text(l10n.edit),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fixed:
        return AppColors.red[500]!;
      case ExpenseCategory.food:
        return AppColors.orange[500]!;
      case ExpenseCategory.transport:
        return AppColors.blue[500]!;
      case ExpenseCategory.entertainment:
        return AppColors.purple[500]!;
      case ExpenseCategory.health:
        return AppColors.green[500]!;
      case ExpenseCategory.other:
        return AppColors.grey[500]!;
    }
  }

  String _getCategoryLabel(ExpenseCategory category, AppLocalizations l10n) {
    switch (category) {
      case ExpenseCategory.fixed:
        return l10n.fixedExpenses;
      case ExpenseCategory.food:
        return l10n.foodExpenses;
      case ExpenseCategory.transport:
        return l10n.transportExpenses;
      case ExpenseCategory.entertainment:
        return l10n.entertainmentExpenses;
      case ExpenseCategory.health:
        return l10n.health;
      case ExpenseCategory.other:
        return l10n.otherExpenses;
    }
  }
}
