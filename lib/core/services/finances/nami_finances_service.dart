import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:opfan/features/nami_finances/data/finance_math.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/core/services/storage/i_user_storage_service.dart';
import 'package:opfan/core/storage/user_data_names.dart';
import 'package:opfan/l10n/app_localizations.dart';

import 'i_nami_finances_service.dart';

class NamiFinancesService implements INamiFinancesService {
  NamiFinancesService({required this._storage});

  final IUserStorageService _storage;

  Future<Box<NamiFinancesModel>> get _getBox =>
      _storage.openUserBox<NamiFinancesModel>(UserDataNames.namiFinancesBox);

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
      debugPrint('NamiFinancesService: save failed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> canEditFinances(DateTime month) async {
    // Allow the current month and any past month (historical backfill); block
    // future months. Compared against the first day of next month so any day
    // within the current month passes.
    final now = DateTime.now();
    final firstOfNextMonth = DateTime(now.year, now.month + 1, 1);
    return month.isBefore(firstOfNextMonth);
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
      debugPrint('NamiFinancesService: delete failed: $e');
      rethrow;
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
      debugPrint('NamiFinancesService: get all failed: $e');
      rethrow;
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
      debugPrint('NamiFinancesService: get year failed: $e');
      rethrow;
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
      debugPrint('NamiFinancesService: get last months failed: $e');
      rethrow;
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
      return _accumulatedSavings(box.values.toList());
    } catch (e) {
      debugPrint('NamiFinancesService: accumulated savings failed: $e');
      return _accumulatedSavings(const []);
    }
  }

  @override
  Future<Map<String, dynamic>> getAccumulatedSavingsInfoLocalized(
    AppLocalizations l10n,
  ) async {
    final info = await getAccumulatedSavingsInfo();
    final months = info['months'] as int;
    if (months == 0) return {...info, 'periodText': '', 'formattedTotal': ''};

    final periodText = savingsPeriodText(l10n, months);
    return {
      ...info,
      'periodText': periodText,
      'formattedTotal': l10n.savings_formatted_total(
        FinanceMath.formatBrl(info['totalSavings'] as double),
        periodText,
      ),
    };
  }

  static Map<String, dynamic> _accumulatedSavings(
    List<NamiFinancesModel> allFinances,
  ) {
    if (allFinances.isEmpty) {
      return {'totalSavings': 0.0, 'months': 0, 'years': 0};
    }

    final firstMonth = allFinances
        .map((f) => f.month)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final months = FinanceMath.monthsTracked(firstMonth, DateTime.now());
    return {
      'totalSavings': allFinances.fold(0.0, (sum, f) => sum + f.savings),
      'months': months,
      'years': months ~/ 12,
    };
  }

  /// "1 year and 2 months" / "1 ano e 2 meses" for a span of [months] (≥ 1).
  static String savingsPeriodText(AppLocalizations l10n, int months) {
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) return l10n.savings_period_months_only(months);
    if (remainingMonths == 0) return l10n.savings_period_years_only(years);
    return l10n.savings_period_years_and_months(years, remainingMonths);
  }
}
