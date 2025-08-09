import 'package:flutter/material.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/theme.dart';
import 'package:opfan/core/models/nami_finances_model.dart';
import 'package:opfan/screens/nami-finances/blocs/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/l10n/app_localizations.dart';

class FinancesHistoryWidget extends StatefulWidget {
  const FinancesHistoryWidget({Key? key}) : super(key: key);

  @override
  State<FinancesHistoryWidget> createState() => _FinancesHistoryWidgetState();
}

class _FinancesHistoryWidgetState extends State<FinancesHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NamiFinancesBloc>()..add(LoadFinancesHistory()),
      child: Container(
        padding: const EdgeInsets.all(Constants.margin),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(Constants.margin * 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.blue[500], size: 24),
                const SizedBox(width: Constants.margin),
                                  Text(
                    AppLocalizations.of(context)!.historyLast6Months,
                    style: TextTheme.of(context).titleMedium,
                  ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            SizedBox(
              height: 250,
              child: BlocBuilder<NamiFinancesBloc, NamiFinancesState>(
                builder: (context, state) {
                  if (state is NamiFinancesHistoryLoaded) {
                    return _buildHistoryChart(state.financesHistory);
                  }
                  
                                   return Center(
                   child: Text(AppLocalizations.of(context)!.loadingHistory),
                 );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryChart(List<NamiFinancesModel> financesHistory) {
    if (financesHistory.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noHistoryAvailable),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: financesHistory.length,
      itemBuilder: (context, index) {
        final finance = financesHistory[index];
        final monthName = _getMonthName(finance.month.month);
        const totalHeight = 200.0;
        
        return Container(
          width: 120,
          margin: const EdgeInsets.only(right: Constants.margin),
          child: Column(
            children: [
              Text(
                monthName,
                style: TextTheme.of(context).bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'R\$ ${finance.totalIncome.toStringAsFixed(0)}',
                style: TextTheme.of(context).bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 40,
                      height: totalHeight,
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: _calculateProportionalHeight(finance.totalExpenses, finance.totalIncome, totalHeight),
                            decoration: BoxDecoration(
                              color: AppColors.red[500],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                finance.totalExpenses.toStringAsFixed(0),
                                style: TextTheme.of(context).bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: _calculateProportionalHeight(finance.availableAmount, finance.totalIncome, totalHeight),
                            decoration: BoxDecoration(
                              color: AppColors.green[500],
                            ),
                            child: Center(
                              child: Text(
                                finance.availableAmount.toStringAsFixed(0),
                                style: TextTheme.of(context).bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: _calculateProportionalHeight(finance.savings, finance.totalIncome, totalHeight),
                            decoration: BoxDecoration(
                              color: AppColors.purple[500],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                finance.savings.toStringAsFixed(0),
                                style: TextTheme.of(context).bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateProportionalHeight(double value, double total, double maxHeight) {
    if (total == 0) return 0;
    final proportion = value / total;
    return (proportion * maxHeight).clamp(0, maxHeight);
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Fev';
      case 3: return 'Mar';
      case 4: return 'Abr';
      case 5: return 'Mai';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Ago';
      case 9: return 'Set';
      case 10: return 'Out';
      case 11: return 'Nov';
      case 12: return 'Dez';
      default: return '';
    }
  }
}
