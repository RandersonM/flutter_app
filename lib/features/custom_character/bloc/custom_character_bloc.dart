import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';
import 'package:opfan/features/crews/data/repository/i_crew_repository.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'custom_character_event.dart';
import 'custom_character_state.dart';

class CustomCharacterBloc
    extends Bloc<CustomCharacterEvent, CustomCharacterState> {
  final ICustomCharacterRepository _customCharacterRepository;
  final ICrewRepository _crewRepository;

  CustomCharacterBloc({
    required this._customCharacterRepository,
    required this._crewRepository,
  }) : super(CustomCharacterInitial()) {
    on<LoadCustomCharacters>(_onLoadCustomCharacters);
    on<CreateCustomCharacter>(_onCreateCustomCharacter);
    on<UpdateCustomCharacter>(_onUpdateCustomCharacter);
    on<DeleteCustomCharacter>(_onDeleteCustomCharacter);
    on<SearchCustomCharacters>(_onSearchCustomCharacters);
    on<FilterCustomCharactersByDevilFruit>(
      _onFilterCustomCharactersByDevilFruit,
    );
    on<FilterCustomCharactersByCrew>(_onFilterCustomCharactersByCrew);
  }

  Future<void> _onLoadCustomCharacters(
    LoadCustomCharacters event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());

    try {
      final characters = await _customCharacterRepository
          .getUserCustomCharacters();

      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      debugPrint('CustomCharacterBloc: load characters failed: $e');
      emit(const CustomCharacterError(CustomCharacterFailure.loadFailed));
    }
  }

  Future<void> _onCreateCustomCharacter(
    CreateCustomCharacter event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterCreating());
    try {
      if (await _isCrewRoleTaken(event.crewId, event.crewRole)) {
        if (isClosed) return;
        emit(const CustomCharacterError(CustomCharacterFailure.crewRoleTaken));
        return;
      }

      final characterId = await _customCharacterRepository
          .createCustomCharacter(event.character);

      if (event.crewId != null && event.crewRole != null) {
        try {
          final crewMember = CrewMember(
            characterId: characterId,
            name: event.character.name,
            nickname: event.character.nickname,
            role: event.crewRole,
            bounty: event.character.bounty,
          );

          await _crewRepository.addMemberToCrew(event.crewId!, crewMember);
        } catch (e) {
          debugPrint('CustomCharacterBloc: add to crew failed: $e');
        }
      }

      emit(CustomCharacterCreated(characterId));

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final characters = await _customCharacterRepository
            .getUserCustomCharacters();
        emit(CustomCharacterLoaded(characters));
      } catch (e) {
        debugPrint('CustomCharacterBloc: list refresh after create failed: $e');
        emit(
          const CustomCharacterError(CustomCharacterFailure.listRefreshFailed),
        );
      }
    } catch (e) {
      debugPrint('CustomCharacterBloc: create character failed: $e');
      emit(const CustomCharacterError(CustomCharacterFailure.createFailed));
    }
  }

  /// Checked before the character exists, so a taken role leaves nothing
  /// half-created behind.
  Future<bool> _isCrewRoleTaken(String? crewId, String? role) async {
    if (crewId == null || role == null || role.isEmpty) return false;
    final crew = await _crewRepository.getCrew(crewId);
    return crew?.isRoleFilled(role) ?? false;
  }

  Future<void> _onUpdateCustomCharacter(
    UpdateCustomCharacter event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterUpdating());
    try {
      await _customCharacterRepository.updateCustomCharacter(
        event.characterId,
        event.character,
      );
      emit(CustomCharacterUpdated(event.characterId));

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final characters = await _customCharacterRepository
            .getUserCustomCharacters();
        emit(CustomCharacterLoaded(characters));
      } catch (e) {
        debugPrint('CustomCharacterBloc: list refresh after update failed: $e');
        emit(
          const CustomCharacterError(CustomCharacterFailure.listRefreshFailed),
        );
      }
    } catch (e) {
      debugPrint('CustomCharacterBloc: update character failed: $e');
      emit(const CustomCharacterError(CustomCharacterFailure.updateFailed));
    }
  }

  Future<void> _onDeleteCustomCharacter(
    DeleteCustomCharacter event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterDeleting());
    try {
      await _customCharacterRepository.deleteCustomCharacter(event.characterId);
      emit(CustomCharacterDeleted(event.characterId));

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final characters = await _customCharacterRepository
            .getUserCustomCharacters();
        emit(CustomCharacterLoaded(characters));
      } catch (e) {
        debugPrint('CustomCharacterBloc: list refresh after delete failed: $e');
        emit(
          const CustomCharacterError(CustomCharacterFailure.listRefreshFailed),
        );
      }
    } catch (e) {
      debugPrint('CustomCharacterBloc: delete character failed: $e');
      emit(const CustomCharacterError(CustomCharacterFailure.deleteFailed));
    }
  }

  Future<void> _onSearchCustomCharacters(
    SearchCustomCharacters event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());
    try {
      final characters = await _customCharacterRepository
          .searchCustomCharactersByName(event.query);
      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      debugPrint('CustomCharacterBloc: search characters failed: $e');
      emit(const CustomCharacterError(CustomCharacterFailure.loadFailed));
    }
  }

  Future<void> _onFilterCustomCharactersByDevilFruit(
    FilterCustomCharactersByDevilFruit event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());
    try {
      final characters = await _customCharacterRepository
          .getCustomCharactersByDevilFruit(event.devilFruit);
      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      debugPrint('CustomCharacterBloc: filter by devil fruit failed: $e');
      emit(const CustomCharacterError(CustomCharacterFailure.loadFailed));
    }
  }

  Future<void> _onFilterCustomCharactersByCrew(
    FilterCustomCharactersByCrew event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());
    try {
      final characters = await _customCharacterRepository
          .getCustomCharactersByCrew(event.crew);
      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      debugPrint('CustomCharacterBloc: filter by crew failed: $e');
      emit(const CustomCharacterError(CustomCharacterFailure.loadFailed));
    }
  }
}
