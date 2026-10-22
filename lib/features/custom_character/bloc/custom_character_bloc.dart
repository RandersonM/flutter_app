import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/errors/app_exceptions.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
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

      final crewId = event.crewId;
      if (crewId != null && event.crewRole != null) {
        final joinFailure = await _joinCrew(
          crewId,
          _memberOf(characterId, event.character, role: event.crewRole),
        );
        if (joinFailure != null) {
          if (isClosed) return;
          emit(CustomCharacterError(joinFailure));
          return;
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

  /// The role can be taken between the check and the write; the character
  /// just created is then deleted, so the form reports a failure instead of a
  /// success that left it outside the crew it was created for.
  Future<CustomCharacterFailure?> _joinCrew(
    String crewId,
    CrewMember member,
  ) async {
    try {
      await _crewRepository.addMemberToCrew(crewId, member);
      return null;
    } catch (e) {
      debugPrint('CustomCharacterBloc: add to crew failed: $e');
      await _discardCreated(member.characterId);
      return e is CrewRoleTakenException
          ? CustomCharacterFailure.crewRoleTaken
          : CustomCharacterFailure.createFailed;
    }
  }

  Future<void> _discardCreated(String characterId) async {
    try {
      await _customCharacterRepository.deleteCustomCharacter(characterId);
    } catch (e) {
      debugPrint('CustomCharacterBloc: discarding $characterId failed: $e');
    }
  }

  static CrewMember _memberOf(
    String characterId,
    CustomCharacterModel character, {
    String? role,
  }) => CrewMember(
    characterId: characterId,
    name: character.name,
    nickname: character.nickname,
    role: role,
    bounty: character.bounty,
  );

  /// Moves the character's membership and returns how to put it back: the
  /// character is saved next, in another collection, and if that fails it
  /// must not stay in a crew its record does not name.
  Future<Future<void> Function()> _moveMember(
    String characterId,
    CustomCharacterModel character,
    CrewAssignment assignment,
  ) async {
    final previousCrew = (await _crewRepository.getCrewsByMember(
      characterId,
    )).firstOrNull;
    final previousMember = previousCrew?.members
        .where((member) => member.characterId == characterId)
        .firstOrNull;
    await _crewRepository.moveMember(
      _memberOf(characterId, character, role: assignment.role),
      toCrewId: assignment.crewId,
    );
    return () async {
      try {
        await _crewRepository.moveMember(
          previousMember ?? _memberOf(characterId, character),
          toCrewId: previousCrew?.id,
        );
      } catch (e) {
        debugPrint(
          'CustomCharacterBloc: crew of $characterId not restored: $e',
        );
      }
    };
  }

  Future<void> _onUpdateCustomCharacter(
    UpdateCustomCharacter event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterUpdating());
    try {
      final assignment = event.crewAssignment;
      final undoMove = assignment == null
          ? null
          : await _moveMember(event.characterId, event.character, assignment);
      try {
        await _customCharacterRepository.updateCustomCharacter(
          event.characterId,
          event.character,
        );
      } catch (_) {
        await undoMove?.call();
        rethrow;
      }
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
    } on CrewRoleTakenException catch (e) {
      debugPrint('CustomCharacterBloc: update refused, $e');
      emit(const CustomCharacterError(CustomCharacterFailure.crewRoleTaken));
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
