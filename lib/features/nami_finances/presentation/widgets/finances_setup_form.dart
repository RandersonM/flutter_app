import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/finance_currency_text_field.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';
import 'package:opfan/features/nami_finances/presentation/widgets/add_expense_dialog.dart'
    as dialog;
import 'package:opfan/features/nami_finances/presentation/widgets/expense_item_widget.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:uuid/uuid.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

const _purple = Color(0xFF8B5CF6);
const _cardBg = Color(0xFF16161C);
const _errorRed = Color(0xFFEF4444);
const _successGreen = Color(0xFF22C55E);

class FinancesSetupForm extends StatefulWidget {
  final Function(
    List<MonthlyIncomeModel> incomes,
    List<ExpenseModel> expenses,
    List<ReserveModel> reserves,
    double? reserveGoal,
  )
  onSave;
  final NamiFinancesModel? existingFinances;

  const FinancesSetupForm({
    super.key,
    required this.onSave,
    this.existingFinances,
  });

  @override
  State<FinancesSetupForm> createState() => _FinancesSetupFormState();
}

class _FinancesSetupFormState extends State<FinancesSetupForm> {
  final List<IncomeItem> _incomeItems = [];
  final List<dialog.ExpenseItem> _expenseItems = [];
  final List<ReserveItem> _reserveItems = [];
  final _reserveGoalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _reserveGoalController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.existingFinances != null) {
        _loadExistingData();
      } else {
        _addIncomeItem();
      }
    });
  }

  void _loadExistingData() {
    final finances = widget.existingFinances!;

    for (final income in finances.monthlyIncomes) {
      final controller = TextEditingController(
        text: _formatCurrencyForDisplay(income.amount),
      );
      controller.addListener(_validateForm);

      _incomeItems.add(
        IncomeItem(controller: controller, description: income.description),
      );
    }

    for (final expense in finances.expenses) {
      final controller = TextEditingController(
        text: _formatCurrencyForDisplay(expense.amount),
      );
      controller.addListener(_validateForm);

      _expenseItems.add(
        dialog.ExpenseItem(
          controller: controller,
          category: _mapModelCategoryToDialog(expense.category),
          description: expense.description,
        ),
      );
    }

    if (finances.reserves.isNotEmpty) {
      for (final reserve in finances.reserves) {
        _reserveItems.add(_buildReserveItem(reserve));
      }
    } else if (finances.savings > 0) {
      // Legacy record stored a single savings value with no itemized reserves —
      // seed it as one "other" reserve so the amount isn't lost on first edit.
      _reserveItems.add(
        _buildReserveItem(
          ReserveModel(
            id: const Uuid().v4(),
            amount: finances.savings,
            purpose: ReservePurpose.other,
          ),
        ),
      );
    }

    if (finances.reserveGoal != null && finances.reserveGoal! > 0) {
      _reserveGoalController.text = _formatCurrencyForDisplay(
        finances.reserveGoal!,
      );
    }

    setState(() {});
  }

  ReserveItem _buildReserveItem(ReserveModel reserve) {
    final controller = TextEditingController(
      text: _formatCurrencyForDisplay(reserve.amount),
    );
    controller.addListener(_validateForm);
    return ReserveItem(
      controller: controller,
      noteController: TextEditingController(text: reserve.note),
      purpose: reserve.purpose,
    );
  }

  String _formatCurrencyForDisplay(double amount) {
    final reais = amount.toInt();
    final centavos = ((amount - reais) * 100).round();

    if (reais == 0) {
      return '0,${centavos.toString().padLeft(2, '0')}';
    }

    final reaisStr = reais.toString();
    final formattedReais = _addThousandSeparator(reaisStr);

    return '$formattedReais,${centavos.toString().padLeft(2, '0')}';
  }

  String _addThousandSeparator(String value) {
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
    }
    return buffer.toString();
  }

  dialog.ExpenseCategory _mapModelCategoryToDialog(
    ExpenseCategory modelCategory,
  ) {
    switch (modelCategory) {
      case ExpenseCategory.fixed:
        return dialog.ExpenseCategory.fixed;
      case ExpenseCategory.food:
        return dialog.ExpenseCategory.food;
      case ExpenseCategory.transport:
        return dialog.ExpenseCategory.transport;
      case ExpenseCategory.entertainment:
        return dialog.ExpenseCategory.entertainment;
      case ExpenseCategory.health:
        return dialog.ExpenseCategory.health;
      case ExpenseCategory.other:
        return dialog.ExpenseCategory.other;
    }
  }

  void _addIncomeItem() {
    final controller = TextEditingController();
    controller.addListener(_validateForm);

    setState(() {
      _incomeItems.add(IncomeItem(controller: controller, description: ''));
    });
  }

  void _removeIncomeItem(int index) {
    if (_incomeItems.length > 1) {
      setState(() {
        _incomeItems[index].controller.dispose();
        _incomeItems.removeAt(index);
      });
      _validateForm();
    }
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog.AddExpenseDialog(
          onExpenseAdded: (expenseItem) {
            expenseItem.controller.addListener(_validateForm);
            setState(() {
              _expenseItems.add(expenseItem);
            });
          },
        );
      },
    );
  }

  void _removeExpenseItem(int index) {
    setState(() {
      _expenseItems[index].controller.dispose();
      _expenseItems.removeAt(index);
    });
    _validateForm();
  }

  void _addReserveItem() {
    final controller = TextEditingController();
    controller.addListener(_validateForm);
    setState(() {
      _reserveItems.add(
        ReserveItem(
          controller: controller,
          noteController: TextEditingController(),
          purpose: ReservePurpose.emergency,
        ),
      );
    });
  }

  void _removeReserveItem(int index) {
    setState(() {
      _reserveItems[index].controller.dispose();
      _reserveItems[index].noteController.dispose();
      _reserveItems.removeAt(index);
    });
    _validateForm();
  }

  void _validateForm() {
    setState(() {});
  }

  bool get _isFormValid {
    final hasIncome = _incomeItems.any(
      (item) =>
          (double.tryParse(
                item.controller.text.replaceAll(RegExp(r'[^\d]'), ''),
              ) ??
              0) >
          0,
    );

    final hasExpense = _expenseItems.any(
      (item) =>
          (double.tryParse(
                item.controller.text.replaceAll(RegExp(r'[^\d]'), ''),
              ) ??
              0) >
          0,
    );

    // Reserves are optional — a month may have none.
    return hasIncome && hasExpense;
  }

  double _parseCurrency(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    return (double.tryParse(digits) ?? 0.0) / 100;
  }

  void _saveFinances() {
    if (!_isFormValid) return;

    final incomes = _incomeItems
        .where(
          (item) =>
              (double.tryParse(
                    item.controller.text.replaceAll(RegExp(r'[^\d]'), ''),
                  ) ??
                  0) >
              0,
        )
        .map(
          (item) => MonthlyIncomeModel(
            id: const Uuid().v4(),
            amount:
                double.parse(
                  item.controller.text.replaceAll(RegExp(r'[^\d]'), ''),
                ) /
                100,
            description: item.description,
          ),
        )
        .toList();

    final expenses = _expenseItems
        .where(
          (item) =>
              (double.tryParse(
                    item.controller.text.replaceAll(RegExp(r'[^\d]'), ''),
                  ) ??
                  0) >
              0,
        )
        .map(
          (item) => ExpenseModel(
            id: const Uuid().v4(),
            amount:
                double.parse(
                  item.controller.text.replaceAll(RegExp(r'[^\d]'), ''),
                ) /
                100,
            category: _mapDialogCategoryToModel(item.category),
            description: item.description,
          ),
        )
        .toList();

    final reserves = _reserveItems
        .where((item) => _parseCurrency(item.controller.text) > 0)
        .map(
          (item) => ReserveModel(
            id: const Uuid().v4(),
            amount: _parseCurrency(item.controller.text),
            purpose: item.purpose,
            note: item.noteController.text.trim(),
          ),
        )
        .toList();

    final goalAmount = _parseCurrency(_reserveGoalController.text);
    final reserveGoal = goalAmount > 0 ? goalAmount : null;

    widget.onSave(incomes, expenses, reserves, reserveGoal);
  }

  ExpenseCategory _mapDialogCategoryToModel(
    dialog.ExpenseCategory dialogCategory,
  ) {
    switch (dialogCategory) {
      case dialog.ExpenseCategory.fixed:
        return ExpenseCategory.fixed;
      case dialog.ExpenseCategory.food:
        return ExpenseCategory.food;
      case dialog.ExpenseCategory.transport:
        return ExpenseCategory.transport;
      case dialog.ExpenseCategory.entertainment:
        return ExpenseCategory.entertainment;
      case dialog.ExpenseCategory.health:
        return ExpenseCategory.health;
      case dialog.ExpenseCategory.other:
        return ExpenseCategory.other;
    }
  }

  @override
  void dispose() {
    for (final item in _incomeItems) {
      item.controller.dispose();
    }
    for (final item in _expenseItems) {
      item.controller.dispose();
    }
    for (final item in _reserveItems) {
      item.controller.dispose();
      item.noteController.dispose();
    }
    _reserveGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildIncomeSection(l10n),
          const SizedBox(height: Constants.margin * 4),
          _buildReservesSection(l10n),
          const SizedBox(height: Constants.margin * 4),
          _buildExpensesSection(l10n),
          const SizedBox(height: Constants.margin * 2),
          _buildSaveButton(l10n),
        ],
      ),
    );
  }

  Widget _buildIncomeSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.monthlyIncome,
      icon: PhosphorIconsRegular.bank,
      color: _successGreen,
      children: [
        AppButton(
          onPressed: _addIncomeItem,
          variant: AppButtonVariant.outline,
          icon: const AppIcon(PhosphorIconsRegular.plus, size: 16),
          label: l10n.addIncome,
          foregroundColor: _successGreen,
          padding: const EdgeInsets.symmetric(vertical: 12),
          borderRadius: 12,
          isFullWidth: true,
        ),
        const SizedBox(height: Constants.margin),
        ..._incomeItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _incomeItems.length - 1 ? Constants.margin : 0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FinanceCurrencyTextField(
                    label: '${l10n.monthlyIncome} ${index + 1}',
                    controller: item.controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um valor';
                      }
                      final amount = double.tryParse(
                        value.replaceAll(RegExp(r'[^\d]'), ''),
                      );
                      if (amount == null || amount <= 0) {
                        return 'Por favor, insira um valor válido';
                      }
                      return null;
                    },
                  ),
                ),
                if (_incomeItems.length > 1) ...[
                  const SizedBox(width: Constants.margin),
                  IconButton(
                    onPressed: () => _removeIncomeItem(index),
                    icon: const AppIcon(
                      PhosphorIconsRegular.minusCircle,
                      color: _errorRed,
                    ),
                    tooltip: l10n.remove,
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: Constants.margin),
      ],
    );
  }

  String _reservePurposeLabel(ReservePurpose purpose, AppLocalizations l10n) {
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

  Widget _buildReservesSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.reserves,
      icon: PhosphorIconsRegular.piggyBank,
      color: _purple,
      children: [
        // Optional monthly reserve target.
        FinanceCurrencyTextField(
          label: l10n.reserveGoalOptional,
          controller: _reserveGoalController,
        ),
        const SizedBox(height: Constants.margin * 2),
        AppButton(
          onPressed: _addReserveItem,
          variant: AppButtonVariant.outline,
          icon: const AppIcon(PhosphorIconsRegular.plus, size: 16),
          label: l10n.addReserve,
          foregroundColor: _purple,
          padding: const EdgeInsets.symmetric(vertical: 12),
          borderRadius: 12,
          isFullWidth: true,
        ),
        const SizedBox(height: Constants.margin),
        ..._reserveItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _reserveItems.length - 1 ? Constants.margin : 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(Constants.margin),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown<ReservePurpose>(
                          label: l10n.reservePurpose,
                          value: item.purpose,
                          items: ReservePurpose.values,
                          itemToString: (purpose) =>
                              _reservePurposeLabel(purpose, l10n),
                          onChanged: (purpose) {
                            if (purpose == null) return;
                            setState(() => item.purpose = purpose);
                          },
                        ),
                      ),
                      const SizedBox(width: Constants.margin),
                      IconButton(
                        onPressed: () => _removeReserveItem(index),
                        icon: const AppIcon(
                          PhosphorIconsRegular.minusCircle,
                          color: _errorRed,
                        ),
                        tooltip: l10n.remove,
                      ),
                    ],
                  ),
                  const SizedBox(height: Constants.margin),
                  FinanceCurrencyTextField(
                    label: l10n.value,
                    controller: item.controller,
                  ),
                  const SizedBox(height: Constants.margin),
                  CustomTextField(
                    label: l10n.reserveNote,
                    controller: item.noteController,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: Constants.margin),
      ],
    );
  }

  Widget _buildExpensesSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.expenses,
      icon: PhosphorIconsRegular.money,
      color: _errorRed,
      children: [
        AppButton(
          onPressed: _showAddExpenseDialog,
          variant: AppButtonVariant.outline,
          icon: const AppIcon(PhosphorIconsRegular.plus, size: 16),
          label: l10n.addExpense,
          foregroundColor: _errorRed,
          padding: const EdgeInsets.symmetric(vertical: 12),
          borderRadius: 12,
          isFullWidth: true,
        ),
        const SizedBox(height: Constants.margin),
        ..._expenseItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _expenseItems.length - 1 ? Constants.margin : 0,
            ),
            child: ExpenseItemWidget(
              expenseItem: item,
              onRemove: () => _removeExpenseItem(index),
              onUpdateTotal: _validateForm,
            ),
          );
        }),
        const SizedBox(height: Constants.margin),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return AppButton(
      onPressed: _isFormValid ? _saveFinances : null,
      icon: const AppIcon(PhosphorIconsRegular.floppyDisk, size: 18),
      label: l10n.save,
      backgroundColor: _purple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: 16,
      isFullWidth: true,
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Constants.margin * 1.5),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
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
          ),
          const SizedBox(height: Constants.margin * 2),
          ...children,
        ],
      ),
    );
  }
}

class IncomeItem {
  final TextEditingController controller;
  String description;

  IncomeItem({required this.controller, required this.description});
}

class ReserveItem {
  final TextEditingController controller;
  final TextEditingController noteController;
  ReservePurpose purpose;

  ReserveItem({
    required this.controller,
    required this.noteController,
    required this.purpose,
  });
}
