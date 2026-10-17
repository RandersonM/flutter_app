import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';
import 'package:opfan/shared/widgets/atoms/finance_currency_text_field.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

class AddExpenseDialog extends StatefulWidget {
  final Function(ExpenseItem) onExpenseAdded;

  const AddExpenseDialog({super.key, required this.onExpenseAdded});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  ExpenseCategory? selectedCategory;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExpense() {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      final expenseItem = ExpenseItem(
        controller: TextEditingController(text: _valueController.text),
        category: selectedCategory!,
        description: _descriptionController.text.trim(),
      );

      widget.onExpenseAdded(expenseItem);
      Navigator.of(context).pop();
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
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          AppIcon(PhosphorIconsRegular.plusCircle, color: colorScheme.error),
          const SizedBox(width: 8),
          Text(l10n.addExpense),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown<ExpenseCategory>(
              label: l10n.category,
              value: selectedCategory,
              items: ExpenseCategory.values,
              itemToString: (category) => _getCategoryLabel(category, l10n),
              onChanged: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
              validator: (value) {
                if (value == null) {
                  return l10n.namiSelectCategoryRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: Constants.margin),
            FinanceCurrencyTextField(
              label: l10n.value,
              hint: '0,00',
              controller: _valueController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.namiAmountRequired;
                }
                final amount = double.tryParse(
                  value.replaceAll(RegExp(r'[^\d]'), ''),
                );
                if (amount == null || amount <= 0) {
                  return l10n.namiAmountInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: Constants.margin),
            CustomTextField(
              label: l10n.description,
              hint: l10n.namiDescriptionOptionalHint,
              controller: _descriptionController,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          label: l10n.cancel,
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
        AppButton(
          onPressed: _addExpense,
          label: l10n.add,
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          borderRadius: 12,
        ),
      ],
    );
  }
}

class ExpenseItem {
  /// The saved expense's id; null for a row added in this edit.
  final String? id;
  final TextEditingController controller;
  ExpenseCategory category;
  String description;

  ExpenseItem({
    this.id,
    required this.controller,
    required this.category,
    required this.description,
  });
}

enum ExpenseCategory { fixed, food, transport, entertainment, health, other }
