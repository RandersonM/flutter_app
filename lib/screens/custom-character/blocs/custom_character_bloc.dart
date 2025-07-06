import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'package:opfan/core/repository/crew_repository.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'custom_character_event.dart';
import 'custom_character_state.dart';

class CustomCharacterBloc extends Bloc<CustomCharacterEvent, CustomCharacterState> {
  final CustomCharacterService _customCharacterService;
  final CrewRepository _crewRepository;

  CustomCharacterBloc({
    required CustomCharacterService customCharacterService,
    required CrewRepository crewRepository,
  })  : _customCharacterService = customCharacterService,
        _crewRepository = crewRepository,
        super(CustomCharacterInitial()) {
    on<LoadCustomCharacters>(_onLoadCustomCharacters);
    on<CreateCustomCharacter>(_onCreateCustomCharacter);
    on<UpdateCustomCharacter>(_onUpdateCustomCharacter);
    on<DeleteCustomCharacter>(_onDeleteCustomCharacter);
    on<SearchCustomCharacters>(_onSearchCustomCharacters);
    on<FilterCustomCharactersByDevilFruit>(_onFilterCustomCharactersByDevilFruit);
    on<FilterCustomCharactersByCrew>(_onFilterCustomCharactersByCrew);
  }

  Future<void> _onLoadCustomCharacters(
    LoadCustomCharacters event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());
    
    try {
      final characters = await _customCharacterService.getUserCustomCharacters();
      
      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      emit(CustomCharacterError(e.toString()));
    }
  }

  Future<void> _onCreateCustomCharacter(
    CreateCustomCharacter event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterCreating());
    try {
      final characterId = await _customCharacterService.createCustomCharacter(event.character);
      
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
          debugPrint('Erro ao adicionar personagem à tripulação: $e');
        }
      }
      
      emit(CustomCharacterCreated(characterId));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final characters = await _customCharacterService.getUserCustomCharacters();
        emit(CustomCharacterLoaded(characters));
      } catch (e) {
        emit(CustomCharacterError('Personagem criado com sucesso, mas houve um erro ao atualizar a lista: $e'));
      }
    } catch (e) {
      emit(CustomCharacterError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomCharacter(
    UpdateCustomCharacter event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterUpdating());
    try {
      await _customCharacterService.updateCustomCharacter(event.characterId, event.character);
      emit(CustomCharacterUpdated(event.characterId));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final characters = await _customCharacterService.getUserCustomCharacters();
        emit(CustomCharacterLoaded(characters));
      } catch (e) {
        emit(CustomCharacterError('Personagem atualizado com sucesso, mas houve um erro ao atualizar a lista: $e'));
      }
    } catch (e) {
      emit(CustomCharacterError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomCharacter(
    DeleteCustomCharacter event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterDeleting());
    try {
      await _customCharacterService.deleteCustomCharacter(event.characterId);
      emit(CustomCharacterDeleted(event.characterId));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final characters = await _customCharacterService.getUserCustomCharacters();
        emit(CustomCharacterLoaded(characters));
      } catch (e) {
        emit(CustomCharacterError('Personagem deletado com sucesso, mas houve um erro ao atualizar a lista: $e'));
      }
    } catch (e) {
      emit(CustomCharacterError(e.toString()));
    }
  }

  Future<void> _onSearchCustomCharacters(
    SearchCustomCharacters event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());
    try {
      final characters = await _customCharacterService.searchCustomCharactersByName(event.query);
      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      emit(CustomCharacterError(e.toString()));
    }
  }

  Future<void> _onFilterCustomCharactersByDevilFruit(
    FilterCustomCharactersByDevilFruit event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());
    try {
      final characters = await _customCharacterService.getCustomCharactersByDevilFruit(event.devilFruit);
      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      emit(CustomCharacterError(e.toString()));
    }
  }

  Future<void> _onFilterCustomCharactersByCrew(
    FilterCustomCharactersByCrew event,
    Emitter<CustomCharacterState> emit,
  ) async {
    emit(CustomCharacterLoading());
    try {
      final characters = await _customCharacterService.getCustomCharactersByCrew(event.crew);
      emit(CustomCharacterLoaded(characters));
    } catch (e) {
      emit(CustomCharacterError(e.toString()));
    }
  }
} 