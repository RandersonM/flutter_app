import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';

abstract class NamiFinancesState {}

class NamiFinancesInitial extends NamiFinancesState {}

class NamiFinancesLoading extends NamiFinancesState {}

class NamiFinancesLoaded extends NamiFinancesState {
  final NamiFinancesModel? finances;
  final bool hasData;

  NamiFinancesLoaded({
    this.finances,
    required this.hasData,
  });
}

class NamiFinancesHistoryLoaded extends NamiFinancesState {
  final List<NamiFinancesModel> financesHistory;

  NamiFinancesHistoryLoaded(this.financesHistory);
}

class NamiFinancesSaved extends NamiFinancesState {
  final NamiFinancesModel finances;

  NamiFinancesSaved(this.finances);
}

class NamiFinancesError extends NamiFinancesState {
  final String message;

  NamiFinancesError(this.message);
}
