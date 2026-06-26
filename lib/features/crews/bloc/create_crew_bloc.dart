import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/crew_repository_interface.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/features/crews/bloc/create_crew_event.dart';
import 'package:opfan/features/crews/bloc/create_crew_state.dart';

class CreateCrewBloc extends Bloc<CreateCrewEvent, CreateCrewState> {
  final ICrewRepository _crewRepository;
  final String? _userId;

  CreateCrewBloc({
    ICrewRepository? crewRepository,
    this._userId,
  })
    : _crewRepository = crewRepository ?? getIt<ICrewRepository>(),
        super(CreateCrewInitial()) {
//

    on<CreateCrewSubmitted>(_onCreateCrewSubmitted);
    on<CreateCrewReset>(_onCreateCrewReset);
  }

  Future<void> _onCreateCrewSubmitted(
    CreateCrewSubmitted event,
    Emitter<CreateCrewState> emit,
  ) async {
    emit(CreateCrewLoading());

    try {
      if (_userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final crew = CrewModel(
        name: event.name.trim(),
        userId: _userId,
        description: event.description?.trim(),
        jollyRogerUrl: event.jollyRogerUrl?.trim(),
        boatImageUrl: event.boatImageUrl?.trim(),
        tags: event.tags,
        boatName: event.boatName?.trim(),
        members: [],
        captain: null,
        viceCaptain: null,
        rolesFilled: [],
      );

      final crewId = await _crewRepository.createCrew(crew);
      emit(CreateCrewSuccess(crewId));
    } catch (e) {
      emit(CreateCrewFailure(e.toString()));
    }
  }

  void _onCreateCrewReset(
    CreateCrewReset event,
    Emitter<CreateCrewState> emit,
  ) {
    emit(CreateCrewInitial());
  }
}
