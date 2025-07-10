import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'package:opfan/screens/crews/blocs/create_crew_event.dart';
import 'package:opfan/screens/crews/blocs/create_crew_state.dart';

class CreateCrewBloc extends Bloc<CreateCrewEvent, CreateCrewState> {
  final CrewRepository _crewRepository;
  final String? _userId;

  CreateCrewBloc({
    CrewRepository? crewRepository,
    String? userId,
  })  : _crewRepository = crewRepository ?? CrewRepository(),
        _userId = userId,
        super(CreateCrewInitial()) {
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
        userId: _userId!, 
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