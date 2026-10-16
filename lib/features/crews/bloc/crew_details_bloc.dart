import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/auth_db/i_auth_service.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';

import 'crew_details_event.dart';
import 'crew_details_state.dart';

class CrewDetailsBloc extends Bloc<CrewDetailsEvent, CrewDetailsState> {
  CrewDetailsBloc({
    required CrewModel crew,
    required this._crewRepository,
    required this._customCharacterRepository,
    required IAuthService authService,
  }) : super(
         CrewDetailsState(
           crew: crew,
           isOwner: crew.userId == authService.currentUser?.uid,
         ),
       ) {
    on<ConfirmCrewDeletion>(_onConfirmCrewDeletion);
    on<LoadAvailableCharacters>(_onLoadAvailableCharacters);
    on<AddCrewMember>(_onAddCrewMember);
    on<OpenCrewMember>(_onOpenCrewMember);
  }

  final ICrewRepository _crewRepository;
  final ICustomCharacterRepository _customCharacterRepository;

  Future<void> _onConfirmCrewDeletion(
    ConfirmCrewDeletion event,
    Emitter<CrewDetailsState> emit,
  ) async {
    if (!state.isOwner || state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    try {
      await _crewRepository.deleteCrew(state.crew.id!);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, effect: const CrewDeleted()));
    } catch (e) {
      debugPrint('CrewDetailsBloc: delete failed: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          effect: const CrewDetailsFailed(CrewDetailsFailure.deleteFailed),
        ),
      );
    }
  }

  /// Lists the user's characters that are not in any of their crews yet, since
  /// a character can belong to only one crew.
  Future<void> _onLoadAvailableCharacters(
    LoadAvailableCharacters event,
    Emitter<CrewDetailsState> emit,
  ) async {
    emit(state.copyWith(clearAvailableCharacters: true));

    try {
      final characters = await _customCharacterRepository
          .getUserCustomCharacters();
      if (characters.isEmpty) {
        if (isClosed) return;
        emit(state.copyWith(availableCharacters: const []));
        return;
      }

      final crews = await _crewRepository.getUserCrews();
      final usedCharacterIds = {
        for (final crew in crews)
          for (final member in crew.members) member.characterId,
      };
      if (isClosed) return;
      emit(
        state.copyWith(
          availableCharacters: characters
              .where((character) => !usedCharacterIds.contains(character.id))
              .toList(),
        ),
      );
    } catch (e) {
      debugPrint('CrewDetailsBloc: loading available characters failed: $e');
      if (isClosed) return;
      emit(state.copyWith(availableCharacters: const []));
    }
  }

  Future<void> _onAddCrewMember(
    AddCrewMember event,
    Emitter<CrewDetailsState> emit,
  ) async {
    if (!state.isOwner || state.isBusy) return;
    final character = event.character;
    final crew = state.crew;
    emit(state.copyWith(isBusy: true));

    try {
      final updatedCrew = crew.copyWith(
        members: [
          ...crew.members,
          CrewMember(
            characterId: character.id!,
            name: character.name,
            nickname: character.nickname,
            role: event.roleKey,
            bounty: character.bounty,
          ),
        ],
        rolesFilled: [...crew.rolesFilled, event.roleKey],
      );

      await _crewRepository.updateCrew(crew.id!, updatedCrew);
      await _customCharacterRepository.updateCustomCharacter(
        character.id!,
        character.copyWith(crew: crew.name),
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          crew: updatedCrew,
          isBusy: false,
          effect: CrewMemberAdded(
            characterName: character.name,
            roleKey: event.roleKey,
          ),
        ),
      );
    } catch (e) {
      debugPrint('CrewDetailsBloc: adding member failed: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          effect: const CrewDetailsFailed(CrewDetailsFailure.addMemberFailed),
        ),
      );
    }
  }

  Future<void> _onOpenCrewMember(
    OpenCrewMember event,
    Emitter<CrewDetailsState> emit,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    try {
      final character = await _customCharacterRepository.getCustomCharacter(
        event.member.characterId,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          effect: character == null
              ? const CrewMemberNotFound()
              : CrewMemberOpened(character),
        ),
      );
    } catch (e) {
      debugPrint('CrewDetailsBloc: loading member failed: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          effect: const CrewDetailsFailed(CrewDetailsFailure.memberLoadFailed),
        ),
      );
    }
  }
}
