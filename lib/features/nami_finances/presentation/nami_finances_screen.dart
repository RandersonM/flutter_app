import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) =>
          getIt<NamiFinancesBloc>()..add(LoadCurrentMonthFinances()),
      child: Scaffold(
        bottomNavigationBar:
            const BottomNavigation(BottomNavigationPages.finances),
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
                      onSave: (incomes, expenses, savings) =>
                          _onSaveFinances(context, incomes, expenses, savings),
                      existingFinances: _editingFinances,
                    ),
                  );
                }

                // Setup mode: no record yet, user tapped "Configurar"
                if (_showSetupForm) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(Constants.margin),
                    child: FinancesSetupForm(
                      onSave: (incomes, expenses, savings) =>
                          _onSaveFinances(context, incomes, expenses, savings),
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
                      onEdit: () => _onEditFinances(context, state.finances!),
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
                    child: Text(AppLocalizations.of(context)!
                        .errorPrefix(state.message)));
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _onSaveFinances(
    BuildContext context,
    List<MonthlyIncomeModel> incomes,
    List<ExpenseModel> expenses,
    double savings,
  ) {
    context.read<NamiFinancesBloc>().add(SaveFinances(
          incomes: incomes,
          expenses: expenses,
          savings: savings,
          month: DateTime.now(),
        ));
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
