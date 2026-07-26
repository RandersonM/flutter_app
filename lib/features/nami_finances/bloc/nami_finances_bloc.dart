import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/nami_finances/data/services/nami_rag_service.dart';
import 'nami_finances_event.dart';
import 'nami_finances_state.dart';

class NamiFinancesBloc extends Bloc<NamiFinancesEvent, NamiFinancesState> {
  final INamiFinancesService _service;
  final NamiRagService _ragService;

  NamiFinancesBloc(this._service, this._ragService)
    : super(NamiFinancesInitial()) {
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
      emit(NamiFinancesLoaded(finances: finances, hasData: finances != null));
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
      emit(NamiFinancesLoaded(finances: finances, hasData: finances != null));
    } catch (e) {
      emit(NamiFinancesError('Erro ao carregar finanças do mês atual: $e'));
    }
  }

  Future<void> _onLoadFinancesHistory(
    LoadFinancesHistory event,
    Emitter<NamiFinancesState> emit,
  ) async {
    try {
      final financesHistory = await _service.getLastMonthsFinances(
        event.months,
      );
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
        emit(NamiFinancesError('Não é possível editar finanças de meses futuros'));
        return;
      }

      // Preserve the record's identity when editing an existing month so its
      // RAG document (keyed by id) is updated in place instead of duplicated,
      // and its original creation timestamp is kept.
      final existing = await _service.getFinancesForMonth(event.month);
      final now = DateTime.now();

      final finances = NamiFinancesModel(
        id: existing?.id ?? const Uuid().v4(),
        month: event.month,
        monthlyIncomes: event.incomes,
        expenses: event.expenses,
        reserves: event.reserves,
        reserveGoal: event.reserveGoal,
        // Denormalize the legacy single-value savings to the reserves total so
        // aggregation in the service (getTotalSavings, accumulated info) keeps
        // working without reading the new list.
        savings: event.reserves.fold(0.0, (sum, r) => sum + r.amount),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await _service.saveFinances(finances);
      await _ragService.syncMonth(finances);

      emit(NamiFinancesLoaded(finances: finances, hasData: true));
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
