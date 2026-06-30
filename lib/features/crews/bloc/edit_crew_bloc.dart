import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/crews/bloc/edit_crew_event.dart';
import 'package:opfan/features/crews/bloc/edit_crew_state.dart';

class EditCrewBloc extends Bloc<EditCrewEvent, EditCrewState> {
  final ICrewRepository _crewRepository;

  EditCrewBloc({
    ICrewRepository? crewRepository,
  })  : _crewRepository = crewRepository ?? getIt<ICrewRepository>(),
        super(EditCrewInitial()) {
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
        throw Exception('Tripulação não encontrada');
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
      emit(EditCrewFailure(e.toString()));
    }
  }

  void _onEditCrewReset(
    EditCrewReset event,
    Emitter<EditCrewState> emit,
  ) {
    emit(EditCrewInitial());
  }
}
