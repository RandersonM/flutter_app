import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'i_nami_finances_service.dart';

class NamiFinancesService implements INamiFinancesService {
  static const String _boxName = 'nami_finances';
  Box<NamiFinancesModel>? _box;

  Future<Box<NamiFinancesModel>> get _getBox async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<NamiFinancesModel>(_boxName);
    }
    return _box!;
  }

  @override
  Future<NamiFinancesModel?> getFinancesForMonth(DateTime month) async {
    final monthKey = _getMonthKey(month);

    try {
      final box = await _getBox;
      return box.get(monthKey);
    } catch (e) {
      debugPrint('Erro ao buscar finanças para o mês: $e');
      return null;
    }
  }

  @override
  Future<NamiFinancesModel?> getCurrentMonthFinances() async {
    final now = DateTime.now();
    return getFinancesForMonth(now);
  }

  @override
  Future<void> saveFinances(NamiFinancesModel finances) async {
    final monthKey = finances.monthKey;

    try {
      final box = await _getBox;
      await box.put(monthKey, finances);
    } catch (e) {
      throw Exception('Erro ao salvar finanças: $e');
    }
  }

  @override
  Future<bool> canEditFinances(DateTime month) async {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }

  @override
  Future<void> deleteFinances(String id) async {
    try {
      final box = await _getBox;
      final key = box.keys.firstWhere(
        (key) => box.get(key)?.id == id,
        orElse: () => null,
      );

      if (key != null) {
        await box.delete(key);
      }
    } catch (e) {
      throw Exception('Erro ao deletar finanças: $e');
    }
  }

  @override
  Future<List<NamiFinancesModel>> getAllFinances() async {
    try {
      final box = await _getBox;
      final finances = box.values.toList();
      finances.sort((a, b) => b.month.compareTo(a.month));
      return finances;
    } catch (e) {
      throw Exception('Erro ao buscar todas as finanças: $e');
    }
  }

  @override
  Future<List<NamiFinancesModel>> getFinancesForYear(int year) async {
    try {
      final box = await _getBox;
      final finances = box.values
          .where((finances) => finances.month.year == year)
          .toList();
      finances.sort((a, b) => b.month.compareTo(a.month));
      return finances;
    } catch (e) {
      throw Exception('Erro ao buscar finanças do ano: $e');
    }
  }

  @override
  Future<List<NamiFinancesModel>> getLastMonthsFinances(int months) async {
    try {
      final box = await _getBox;
      final allFinances = box.values.toList();
      allFinances.sort((a, b) => b.month.compareTo(a.month));

      final now = DateTime.now();
      final cutoffDate = DateTime(now.year, now.month - months + 1, 1);

      return allFinances
          .where(
            (finances) =>
                finances.month.isAfter(cutoffDate) ||
                finances.month.isAtSameMomentAs(cutoffDate),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar finanças dos últimos meses: $e');
    }
  }

  String _getMonthKey(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }

  @override
  Future<double> getTotalSavings() async {
    try {
      final box = await _getBox;
      final allFinances = box.values.toList();

      double totalSavings = 0.0;
      for (final finances in allFinances) {
        totalSavings += finances.savings;
      }

      return totalSavings;
    } catch (e) {
      debugPrint('Erro ao calcular total de savings: $e');
      return 0.0;
    }
  }

  @override
  Future<Map<String, dynamic>> getAccumulatedSavingsInfo() async {
    try {
      final box = await _getBox;
      final allFinances = box.values.toList();

      if (allFinances.isEmpty) {
        return {'totalSavings': 0.0, 'months': 0, 'years': 0, 'periodText': ''};
      }

      allFinances.sort((a, b) => a.month.compareTo(b.month));

      double totalSavings = 0.0;
      for (final finances in allFinances) {
        totalSavings += finances.savings;
      }

      final firstMonth = allFinances.first.month;
      final now = DateTime.now();

      int months =
          (now.year - firstMonth.year) * 12 + (now.month - firstMonth.month);
      if (months < 0) months = 0;

      int years = months ~/ 12;
      int remainingMonths = months % 12;

      String periodText = '';
      if (years > 0) {
        if (remainingMonths > 0) {
          periodText =
              '$years ano${years > 1 ? 's' : ''} e $remainingMonths mês${remainingMonths > 1 ? 'es' : ''}';
        } else {
          periodText = '$years ano${years > 1 ? 's' : ''}';
        }
      } else if (months > 0) {
        periodText = '$months mês${months > 1 ? 'es' : ''}';
      } else {
        periodText = '1 mês';
      }

      return {
        'totalSavings': totalSavings,
        'months': months,
        'years': years,
        'periodText': periodText,
        'formattedTotal':
            'R\$ ${totalSavings.toStringAsFixed(2)} em $periodText',
      };
    } catch (e) {
      debugPrint('Erro ao calcular informações de savings acumulados: $e');
      return {'totalSavings': 0.0, 'months': 0, 'years': 0, 'periodText': ''};
    }
  }

  @override
  Future<Map<String, dynamic>> getAccumulatedSavingsInfoLocalized(
    AppLocalizations l10n,
  ) async {
    try {
      final box = await _getBox;
      final allFinances = box.values.toList();

      if (allFinances.isEmpty) {
        return {
          'totalSavings': 0.0,
          'months': 0,
          'years': 0,
          'periodText': '',
          'formattedTotal': '',
        };
      }

      allFinances.sort((a, b) => a.month.compareTo(b.month));

      double totalSavings = 0.0;
      for (final finances in allFinances) {
        totalSavings += finances.savings;
      }

      final firstMonth = allFinances.first.month;
      final now = DateTime.now();

      int months =
          (now.year - firstMonth.year) * 12 + (now.month - firstMonth.month);
      if (months < 0) months = 0;

      int years = months ~/ 12;
      int remainingMonths = months % 12;

      String periodText = '';
      if (years > 0) {
        if (remainingMonths > 0) {
          periodText = l10n.savings_period_years_and_months(
            years,
            remainingMonths,
          );
        } else {
          periodText = l10n.savings_period_years_only(years);
        }
      } else if (months > 0) {
        periodText = l10n.savings_period_months_only(months);
      } else {
        periodText = l10n.savings_period_one_month;
      }

      final formattedTotal = l10n.savings_formatted_total(
        totalSavings.toStringAsFixed(2),
        periodText,
      );

      return {
        'totalSavings': totalSavings,
        'months': months,
        'years': years,
        'periodText': periodText,
        'formattedTotal': formattedTotal,
      };
    } catch (e) {
      debugPrint('Erro ao calcular informações de savings acumulados: $e');
      return {
        'totalSavings': 0.0,
        'months': 0,
        'years': 0,
        'periodText': '',
        'formattedTotal': '',
      };
    }
  }
}
