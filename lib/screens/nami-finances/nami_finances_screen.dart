import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/nami_finances_model.dart';
import 'package:opfan/screens/nami-finances/blocs/nami_finances_bloc.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'widgets/nami_header.dart';
import 'widgets/finances_setup_form.dart';
import 'widgets/finances_results_view.dart';

class NamiFinancesScreen extends StatefulWidget {
  const NamiFinancesScreen({super.key});

  @override
  State<NamiFinancesScreen> createState() => _NamiFinancesScreenState();
}

class _NamiFinancesScreenState extends State<NamiFinancesScreen> {
  NamiFinancesModel? _editingFinances;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider(
      create: (context) => getIt<NamiFinancesBloc>()..add(LoadCurrentMonthFinances()),
      child: Scaffold(
        appBar: DefaultAppBar(title: Text(l10n.finances)),
        body: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Constants.margin),
                  child: Column(
                    children: [
                      const NamiHeader(),
                      const SizedBox(height: Constants.margin * 2),
                      BlocBuilder<NamiFinancesBloc, NamiFinancesState>(
                        builder: (context, state) {
                          if (state is NamiFinancesLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          
                          if (state is NamiFinancesLoaded) {
                            if (state.hasData && state.finances != null && _editingFinances == null) {
                              return FinancesResultsView(
                                finances: state.finances!,
                                onEdit: () => _onEditFinances(context, state.finances!),
                              );
                            } else {
                              return FinancesSetupForm(
                                onSave: (incomes, expenses, savings) => _onSaveFinances(context, incomes, expenses, savings),
                                existingFinances: _editingFinances,
                              );
                            }
                          }
                          
                          if (state is NamiFinancesError) {
                            return Center(
                              child: Text('Erro: ${state.message}'),
                            );
                          }
                          
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const BottomNavigation(BottomNavigationPages.finances),
            ],
          ),
        ),
      ),
    );
  }

  void _onSaveFinances(BuildContext context, List<MonthlyIncomeModel> incomes, List<ExpenseModel> expenses, double savings) {
    final currentMonth = DateTime.now();
    context.read<NamiFinancesBloc>().add(SaveFinances(
      incomes: incomes,
      expenses: expenses,
      savings: savings,
      month: currentMonth,
    ));
    
    setState(() {
      _editingFinances = null;
    });
  }

  void _onEditFinances(BuildContext context, NamiFinancesModel finances) {
    debugPrint('onEditFinances');
    setState(() {
      _editingFinances = finances;
    });
  }
}