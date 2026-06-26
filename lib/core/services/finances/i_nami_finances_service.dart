import 'package:opfan/core/models/nami_finances_model.dart';
import 'package:opfan/l10n/app_localizations.dart';

abstract class INamiFinancesService {
  Future<NamiFinancesModel?> getFinancesForMonth(DateTime month);
  
  Future<NamiFinancesModel?> getCurrentMonthFinances();
  
  Future<void> saveFinances(NamiFinancesModel finances);
  
  Future<bool> canEditFinances(DateTime month);
  
  Future<void> deleteFinances(String id);
  
  Future<List<NamiFinancesModel>> getAllFinances();
  
  Future<List<NamiFinancesModel>> getFinancesForYear(int year);
  
  Future<List<NamiFinancesModel>> getLastMonthsFinances(int months);
  
  Future<double> getTotalSavings();
  
  Future<Map<String, dynamic>> getAccumulatedSavingsInfo();
  
  Future<Map<String, dynamic>> getAccumulatedSavingsInfoLocalized(
      AppLocalizations l10n);
}
