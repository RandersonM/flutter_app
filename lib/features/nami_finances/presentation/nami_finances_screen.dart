import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/bloc/index.dart';
import 'package:opfan/app/di/injection.dart';
import 'widgets/finances_setup_form.dart';
import 'widgets/finances_dashboard_view.dart';
import 'widgets/finances_empty_state.dart';
import 'widgets/nami_chat_sheet.dart';

class NamiFinancesScreen extends StatefulWidget {
  const NamiFinancesScreen({super.key});

  @override
  State<NamiFinancesScreen> createState() => _NamiFinancesScreenState();
}

class _NamiFinancesScreenState extends State<NamiFinancesScreen> {
  NamiFinancesModel? _editingFinances;

  /// True when the user explicitly wants to enter new data (no existing record).
  bool _showSetupForm = false;

  /// Which month the screen is currently viewing / editing. Defaults to the
  /// current month; the navigator lets the user move to any past month, but not
  /// into the future.
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      bottomNavigationBar: const BottomNavigation(
        BottomNavigationPages.finances,
      ),
      appBar: DefaultAppBar(title: Text(l10n.financeWithNami)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const NamiChatSheet(),
          );
        },
        child: const Icon(Icons.chat),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildMonthSelector(context, l10n),
            Expanded(
              child: BlocProvider(
                // Recreate the bloc per selected month so switching months
                // reloads that month's data.
                key: ValueKey('${_selectedMonth.year}-${_selectedMonth.month}'),
                create: (context) =>
                    getIt<NamiFinancesBloc>()..add(LoadFinances(_selectedMonth)),
                child: BlocBuilder<NamiFinancesBloc, NamiFinancesState>(
                  builder: (context, state) {
                    if (state is NamiFinancesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is NamiFinancesLoaded) {
                      // Edit mode: editing an existing record
                      if (_editingFinances != null) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(Constants.margin),
                          child: FinancesSetupForm(
                            onSave: (incomes, expenses, reserves, reserveGoal) =>
                                _onSaveFinances(
                                  context,
                                  incomes,
                                  expenses,
                                  reserves,
                                  reserveGoal,
                                ),
                            existingFinances: _editingFinances,
                          ),
                        );
                      }

                      // Setup mode: no record yet, user tapped "Configurar"
                      if (_showSetupForm) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(Constants.margin),
                          child: FinancesSetupForm(
                            onSave: (incomes, expenses, reserves, reserveGoal) =>
                                _onSaveFinances(
                                  context,
                                  incomes,
                                  expenses,
                                  reserves,
                                  reserveGoal,
                                ),
                            existingFinances: null,
                          ),
                        );
                      }

                      // Dashboard mode: data exists for the month
                      if (state.hasData && state.finances != null) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(Constants.margin),
                          child: FinancesDashboardView(
                            finances: state.finances!,
                            onEdit: () =>
                                _onEditFinances(context, state.finances!),
                          ),
                        );
                      }

                      // Empty state: first time / no data
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          vertical: Constants.margin * 4,
                          horizontal: Constants.margin,
                        ),
                        child: FinancesEmptyState(
                          onSetup: () => setState(() => _showSetupForm = true),
                        ),
                      );
                    }

                    if (state is NamiFinancesError) {
                      return Center(
                        child: Text(l10n.errorPrefix(state.message)),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.margin,
        vertical: Constants.margin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const AppIcon(PhosphorIconsRegular.caretLeft),
            tooltip: l10n.previousMonth,
            onPressed: _canGoToPreviousMonth() ? _goToPreviousMonth : null,
            style: IconButton.styleFrom(
              foregroundColor: _canGoToPreviousMonth()
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
          Column(
            children: [
              Text(_formatMonth(context), style: theme.textTheme.titleMedium),
              if (!_isCurrentMonth())
                Text(
                  l10n.editingPastMonth,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const AppIcon(PhosphorIconsRegular.caretRight),
            tooltip: l10n.nextMonth,
            // No future months.
            onPressed: _canGoToNextMonth() ? _goToNextMonth : null,
            style: IconButton.styleFrom(
              foregroundColor: _canGoToNextMonth()
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  bool _canGoToPreviousMonth() {
    final previous = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    return previous.isAfter(DateTime(2019, 12, 31));
  }

  bool _canGoToNextMonth() => !_isCurrentMonth();

  void _goToPreviousMonth() {
    if (!_canGoToPreviousMonth()) return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _editingFinances = null;
      _showSetupForm = false;
    });
  }

  void _goToNextMonth() {
    if (!_canGoToNextMonth()) return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _editingFinances = null;
      _showSetupForm = false;
    });
  }

  String _formatMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final formatted = DateFormat.yMMMM(locale).format(_selectedMonth);
    return formatted.isEmpty
        ? formatted
        : formatted[0].toUpperCase() + formatted.substring(1);
  }

  void _onSaveFinances(
    BuildContext context,
    List<MonthlyIncomeModel> incomes,
    List<ExpenseModel> expenses,
    List<ReserveModel> reserves,
    double? reserveGoal,
  ) {
    context.read<NamiFinancesBloc>().add(
      SaveFinances(
        incomes: incomes,
        expenses: expenses,
        reserves: reserves,
        reserveGoal: reserveGoal,
        month: _selectedMonth,
      ),
    );
    setState(() {
      _editingFinances = null;
      _showSetupForm = false;
    });
  }

  void _onEditFinances(BuildContext context, NamiFinancesModel finances) {
    setState(() {
      _editingFinances = finances;
      _showSetupForm = false;
    });
  }
}
