import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/core/models/nami_finances_model.dart';
import 'package:opfan/features/nami_finances/bloc/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';

class FinancesHistoryWidget extends StatefulWidget {
  const FinancesHistoryWidget({super.key});

  @override
  State<FinancesHistoryWidget> createState() => _FinancesHistoryWidgetState();
}

class _FinancesHistoryWidgetState extends State<FinancesHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<NamiFinancesBloc>()..add(LoadFinancesHistory()),
      child: Container(
        padding: const EdgeInsets.all(Constants.margin),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(Constants.margin * 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(PhosphorIconsRegular.chartLine,
                    color: AppColors.blue[500], size: 24),
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

    final sortedHistory = List<NamiFinancesModel>.from(financesHistory)
      ..sort((a, b) => a.month.compareTo(b.month));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxValue(sortedHistory),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final finance = sortedHistory[group.x.toInt()];

                    switch (rodIndex) {
                      case 0:
                        return BarTooltipItem(
                          'Despesas: R\$ ${finance.totalExpenses.toStringAsFixed(0)}',
                          TextStyle(
                              color: AppColors.red[500],
                              fontWeight: FontWeight.bold),
                        );
                      case 1:
                        return BarTooltipItem(
                          'Disponível: R\$ ${finance.availableAmount.toStringAsFixed(0)}',
                          TextStyle(
                              color: AppColors.green[500],
                              fontWeight: FontWeight.bold),
                        );
                      case 2:
                        return BarTooltipItem(
                          'Poupança: R\$ ${finance.savings.toStringAsFixed(0)}',
                          TextStyle(
                              color: AppColors.orange[500],
                              fontWeight: FontWeight.bold),
                        );
                      default:
                        return BarTooltipItem('', const TextStyle());
                    }
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < sortedHistory.length) {
                        final monthName = _getMonthName(
                            sortedHistory[value.toInt()].month.month);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            monthName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'R\$ ${value.toInt()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3)),
                  left: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3)),
                ),
              ),
              barGroups: _buildBarGroups(sortedHistory),
              gridData: FlGridData(
                show: true,
                horizontalInterval: _getMaxValue(sortedHistory) / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
                drawVerticalLine: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(AppLocalizations.of(context)!.expensesLabel,
                AppColors.red[500]!),
            _buildLegendItem(AppLocalizations.of(context)!.availableLabel,
                AppColors.green[500]!),
            _buildLegendItem(AppLocalizations.of(context)!.savingsLabel,
                AppColors.orange[500]!),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(
      List<NamiFinancesModel> financesHistory) {
    return List.generate(financesHistory.length, (index) {
      final finance = financesHistory[index];
      final total = finance.totalIncome;

      if (total == 0) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(toY: 0, color: AppColors.grey[300]),
          ],
        );
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: finance.totalExpenses,
            color: AppColors.red[500],
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: finance.availableAmount,
            color: AppColors.green[500],
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: finance.savings,
            color: AppColors.orange[500],
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxValue(List<NamiFinancesModel> financesHistory) {
    double maxValue = 0;
    for (final finance in financesHistory) {
      maxValue =
          maxValue > finance.totalIncome ? maxValue : finance.totalIncome;
    }
    return maxValue;
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return AppLocalizations.of(context)!.janAbbr;
      case 2:
        return AppLocalizations.of(context)!.febAbbr;
      case 3:
        return AppLocalizations.of(context)!.marAbbr;
      case 4:
        return AppLocalizations.of(context)!.aprAbbr;
      case 5:
        return AppLocalizations.of(context)!.mayAbbr;
      case 6:
        return AppLocalizations.of(context)!.junAbbr;
      case 7:
        return AppLocalizations.of(context)!.julAbbr;
      case 8:
        return AppLocalizations.of(context)!.augAbbr;
      case 9:
        return AppLocalizations.of(context)!.sepAbbr;
      case 10:
        return AppLocalizations.of(context)!.octAbbr;
      case 11:
        return AppLocalizations.of(context)!.novAbbr;
      case 12:
        return AppLocalizations.of(context)!.decAbbr;
      default:
        return '';
    }
  }
}
