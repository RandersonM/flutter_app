import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/crews/bloc/create_crew_event.dart';
import 'package:opfan/features/crews/bloc/crews_failure.dart';
import 'package:opfan/features/crews/bloc/create_crew_state.dart';

class CreateCrewBloc extends Bloc<CreateCrewEvent, CreateCrewState> {
  final ICrewRepository _crewRepository;
  final String? _userId;

  CreateCrewBloc({required this._crewRepository, this._userId})
    : super(CreateCrewInitial()) {
    //

    on<CreateCrewSubmitted>(_onCreateCrewSubmitted);
    on<CreateCrewReset>(_onCreateCrewReset);
  }

  Future<void> _onCreateCrewSubmitted(
    CreateCrewSubmitted event,
    Emitter<CreateCrewState> emit,
  ) async {
    emit(CreateCrewLoading());

    final userId = _userId;
    if (userId == null) {
      emit(const CreateCrewFailure(CrewsFailure.notSignedIn));
      return;
    }

    try {
      final crew = CrewModel(
        name: event.name.trim(),
        userId: userId,
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
      debugPrint('CreateCrewBloc: create crew failed: $e');
      emit(const CreateCrewFailure(CrewsFailure.saveFailed));
    }
  }

  void _onCreateCrewReset(
    CreateCrewReset event,
    Emitter<CreateCrewState> emit,
  ) {
    emit(CreateCrewInitial());
  }
}
