import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/atoms/finance_currency_text_field.dart';
import 'package:opfan/features/nami_finances/presentation/widgets/add_expense_dialog.dart';

class ExpenseItemWidget extends StatelessWidget {
  final ExpenseItem expenseItem;
  final VoidCallback onRemove;
  final VoidCallback onUpdateTotal;

  const ExpenseItemWidget({
    super.key,
    required this.expenseItem,
    required this.onRemove,
    required this.onUpdateTotal,
  });

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getCategoryColor(expenseItem.category),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCategoryLabel(expenseItem.category, l10n),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getCategoryColor(expenseItem.category),
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const AppIcon(
                  PhosphorIconsRegular.minusCircle,
                  color: Colors.red,
                ),
                tooltip: l10n.remove,
              ),
            ],
          ),
          const SizedBox(height: Constants.margin),
          FinanceCurrencyTextField(
            label: l10n.value,
            controller: expenseItem.controller,
          ),
          if (expenseItem.description.isNotEmpty) ...[
            const SizedBox(height: Constants.margin),
            Text(
              expenseItem.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
