import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:opfan/features/nami_finances/data/models/nami_finances_model.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/nami_finances/data/services/i_nami_rag_service.dart';
import 'nami_finances_event.dart';
import 'nami_finances_state.dart';

class NamiFinancesBloc extends Bloc<NamiFinancesEvent, NamiFinancesState> {
  final INamiFinancesService _service;
  final INamiRagService _ragService;

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
      debugPrint('NamiFinancesBloc: load month failed: $e');
      emit(NamiFinancesError(NamiFinancesFailure.loadFailed));
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
      debugPrint('NamiFinancesBloc: load current month failed: $e');
      emit(NamiFinancesError(NamiFinancesFailure.loadFailed));
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
      debugPrint('NamiFinancesBloc: load history failed: $e');
      emit(NamiFinancesError(NamiFinancesFailure.historyLoadFailed));
    }
  }

  Future<void> _onSaveFinances(
    SaveFinances event,
    Emitter<NamiFinancesState> emit,
  ) async {
    // No loading state: the form stays on screen, so a failed save keeps what
    // the user typed.
    try {
      final canEdit = await _service.canEditFinances(event.month);
      if (!canEdit) {
        emit(NamiFinancesError(NamiFinancesFailure.futureMonthNotEditable));
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
      // The first sync downloads the ~110 MB embedder; the save is done once
      // Hive has the month, so the index catches up in the background.
      unawaited(_syncSearchIndex(finances));

      emit(NamiFinancesLoaded(finances: finances, hasData: true));
    } catch (e) {
      debugPrint('NamiFinancesBloc: save failed: $e');
      emit(NamiFinancesError(NamiFinancesFailure.saveFailed));
    }
  }

  Future<void> _syncSearchIndex(NamiFinancesModel finances) async {
    try {
      await _ragService.syncMonth(finances);
    } catch (e) {
      debugPrint('NamiFinancesBloc: search index sync failed: $e');
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
      debugPrint('NamiFinancesBloc: delete failed: $e');
      emit(NamiFinancesError(NamiFinancesFailure.deleteFailed));
    }
  }
}
