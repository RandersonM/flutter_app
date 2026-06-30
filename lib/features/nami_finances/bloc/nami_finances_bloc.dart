import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/core/services/index.dart';
import 'nami_finances_event.dart';
import 'nami_finances_state.dart';

class NamiFinancesBloc extends Bloc<NamiFinancesEvent, NamiFinancesState> {
  final INamiFinancesService _service;

  NamiFinancesBloc(this._service) : super(NamiFinancesInitial()) {
    on<LoadFinances>(_onLoadFinances);
    on<LoadCurrentMonthFinances>(_onLoadCurrentMonthFinances);
    on<LoadFinancesHistory>(_onLoadFinancesHistory);
    on<SaveFinances>(_onSaveFinances);
    on<DeleteFinances>(_onDeleteFinances);
  }

  Future<void> _onLoadFinances(
    LoadFinances event,
    Emitter<NamiFinancesState> emit,
  ) async {
    emit(NamiFinancesLoading());

    try {
      final finances = await _service.getFinancesForMonth(event.month);
      emit(NamiFinancesLoaded(
        finances: finances,
        hasData: finances != null,
      ));
    } catch (e) {
      emit(NamiFinancesError('Erro ao carregar finanças: $e'));
    }
  }

  Future<void> _onLoadCurrentMonthFinances(
    LoadCurrentMonthFinances event,
    Emitter<NamiFinancesState> emit,
  ) async {
    emit(NamiFinancesLoading());

    try {
      final finances = await _service.getCurrentMonthFinances();
      emit(NamiFinancesLoaded(
        finances: finances,
        hasData: finances != null,
      ));
    } catch (e) {
      emit(NamiFinancesError('Erro ao carregar finanças do mês atual: $e'));
    }
  }

  Future<void> _onLoadFinancesHistory(
    LoadFinancesHistory event,
    Emitter<NamiFinancesState> emit,
  ) async {
    try {
      final financesHistory =
          await _service.getLastMonthsFinances(event.months);
      emit(NamiFinancesHistoryLoaded(financesHistory));
    } catch (e) {
      emit(NamiFinancesError('Erro ao carregar histórico de finanças: $e'));
    }
  }

  Future<void> _onSaveFinances(
    SaveFinances event,
    Emitter<NamiFinancesState> emit,
  ) async {
    emit(NamiFinancesLoading());

    try {
      final canEdit = await _service.canEditFinances(event.month);
      if (!canEdit) {
        emit(NamiFinancesError('Só é possível editar finanças do mês atual'));
        return;
      }

      final finances = NamiFinancesModel(
        id: const Uuid().v4(),
        month: event.month,
        monthlyIncomes: event.incomes,
        expenses: event.expenses,
        savings: event.savings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.saveFinances(finances);
      emit(NamiFinancesLoaded(
        finances: finances,
        hasData: true,
      ));
    } catch (e) {
      emit(NamiFinancesError('Erro ao salvar finanças: $e'));
    }
  }

  Future<void> _onDeleteFinances(
    DeleteFinances event,
    Emitter<NamiFinancesState> emit,
  ) async {
    emit(NamiFinancesLoading());

    try {
      await _service.deleteFinances(event.id);
      emit(NamiFinancesLoaded(finances: null, hasData: false));
    } catch (e) {
      emit(NamiFinancesError('Erro ao deletar finanças: $e'));
    }
  }
}
