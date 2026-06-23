import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';
import 'package:opfan/shared/widgets/atoms/finance_currency_text_field.dart';

class AddExpenseDialog extends StatefulWidget {
  final Function(ExpenseItem) onExpenseAdded;

  const AddExpenseDialog({
    Key? key,
    required this.onExpenseAdded,
  }) : super(key: key);

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
    
    return AlertDialog(
      backgroundColor: const Color(0xFF16161C),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Row(
        children: [
          Icon(Icons.add_circle_outline_rounded, color: AppColors.red[500]),
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
                  return 'Por favor, selecione uma categoria';
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
                  return 'Por favor, insira um valor';
                }
                final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
                if (amount == null || amount <= 0) {
                  return 'Por favor, insira um valor válido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: Constants.margin),
            
            CustomTextField(
               label: l10n.description,
               hint: 'Descrição (opcional)',
               controller: _descriptionController,
               maxLines: 2,
             ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white54,
          ),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _addExpense,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.red[500],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

class ExpenseItem {
  final TextEditingController controller;
  ExpenseCategory category;
  String description;

  ExpenseItem({
    required this.controller,
    required this.category,
    required this.description,
  });
}

enum ExpenseCategory {
  fixed,
  food,
  transport,
  entertainment,
  health,
  other,
}
