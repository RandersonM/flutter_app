import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/crews/bloc/crews_failure.dart';
import 'package:opfan/features/crews/bloc/edit_crew_event.dart';
import 'package:opfan/features/crews/bloc/edit_crew_state.dart';

class EditCrewBloc extends Bloc<EditCrewEvent, EditCrewState> {
  final ICrewRepository _crewRepository;

  EditCrewBloc({required this._crewRepository}) : super(EditCrewInitial()) {
    on<EditCrewSubmitted>(_onEditCrewSubmitted);
    on<EditCrewReset>(_onEditCrewReset);
  }

  Future<void> _onEditCrewSubmitted(
    EditCrewSubmitted event,
    Emitter<EditCrewState> emit,
  ) async {
    emit(EditCrewLoading());

    try {
      // Buscar a crew atual para manter os dados que não estão sendo editados
      final currentCrew = await _crewRepository.getCrew(event.crewId);
      if (currentCrew == null) {
        emit(const EditCrewFailure(CrewsFailure.notFound));
        return;
      }

      final updatedCrew = currentCrew.copyWith(
        name: event.name.trim(),
        description: event.description?.trim(),
        jollyRogerUrl: event.jollyRogerUrl?.trim(),
        boatImageUrl: event.boatImageUrl?.trim(),
        tags: event.tags,
        boatName: event.boatName?.trim(),
      );

      await _crewRepository.updateCrew(event.crewId, updatedCrew);
      emit(EditCrewSuccess(event.crewId));
    } catch (e) {
      debugPrint('EditCrewBloc: update crew failed: $e');
      emit(const EditCrewFailure(CrewsFailure.saveFailed));
    }
  }

  void _onEditCrewReset(EditCrewReset event, Emitter<EditCrewState> emit) {
    emit(EditCrewInitial());
  }
}
