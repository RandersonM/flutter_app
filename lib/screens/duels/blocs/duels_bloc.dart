// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/repository/featured_character_repository.dart';
import 'package:opfan/core/repository/custom_character_repository.dart';
import 'duels_event.dart';
import 'duels_state.dart';

class DuelsBloc extends Bloc<DuelsEvent, DuelsState> {
  final FeaturedCharacterRepository _featuredCharacterRepository;
  final CustomCharacterRepository _customCharacterRepository;
  final Random _random = Random();

  DuelsBloc({
    required FeaturedCharacterRepository featuredCharacterRepository,
    required CustomCharacterRepository customCharacterRepository,
  })  : _featuredCharacterRepository = featuredCharacterRepository,
        _customCharacterRepository = customCharacterRepository,
        super(const DuelsInitial()) {
    on<LoadDuelsScreen>(_onLoadDuelsScreen);
    on<SelectFirstCharacter>(_onSelectFirstCharacter);
    on<SelectSecondCharacter>(_onSelectSecondCharacter);
    on<ClearCharacterSelection>(_onClearCharacterSelection);
    on<StartDuel>(_onStartDuel);
    on<ResetDuel>(_onResetDuel);
    on<RandomizeCharacters>(_onRandomizeCharacters);
  }

  Future<void> _onLoadDuelsScreen(
    LoadDuelsScreen event,
    Emitter<DuelsState> emit,
  ) async {
    try {
      emit(const DuelsLoading());

    

      final onePieceCharacters = await _featuredCharacterRepository
          .getAllOnePieceCharacters(limit: 100);

      final customCharacters =
          await _customCharacterRepository.getAllCustomCharacters();
      final allCharacters = [...customCharacters, ...onePieceCharacters];

      emit(DuelsReady(
        availableCharacters: allCharacters,
      ));
    } catch (e) {
      debugPrint('DuelsBloc: Error loading characters - $e');
      emit(DuelsError('Erro ao carregar personagens: $e'));
    }
  }

  void _onSelectFirstCharacter(
    SelectFirstCharacter event,
    Emitter<DuelsState> emit,
  ) {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;
      
      // Verificar se o personagem já está selecionado como segundo
      if (currentState.secondCharacter?.id == event.character.id) {
        emit(currentState.copyWith(
          firstCharacter: event.character,
          clearSecondCharacter: true,
        ));
      } else {
        emit(currentState.copyWith(
          firstCharacter: event.character,
        ));
      }
    }
  }

  void _onSelectSecondCharacter(
    SelectSecondCharacter event,
    Emitter<DuelsState> emit,
  ) {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;
      
      // Verificar se o personagem já está selecionado como primeiro
      if (currentState.firstCharacter?.id == event.character.id) {
        emit(currentState.copyWith(
          secondCharacter: event.character,
          clearFirstCharacter: true,
        ));
      } else {
        emit(currentState.copyWith(
          secondCharacter: event.character,
        ));
      }
    }
  }

  void _onClearCharacterSelection(
    ClearCharacterSelection event,
    Emitter<DuelsState> emit,
  ) {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;
      
      if (event.position == 1) {
        emit(currentState.copyWith(clearFirstCharacter: true));
      } else if (event.position == 2) {
        emit(currentState.copyWith(clearSecondCharacter: true));
      }
    }
  }

  Future<void> _onStartDuel(
    StartDuel event,
    Emitter<DuelsState> emit,
  ) async {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;
      
      if (!currentState.canStartDuel) {
        return;
      }

      emit(currentState.copyWith(
        isDuelInProgress: true,
        clearWinner: true,
      ));

      await Future.delayed(const Duration(seconds: 2));

      final winner = _determineWinner(
        currentState.firstCharacter!,
        currentState.secondCharacter!,
      );

      emit(currentState.copyWith(
        isDuelInProgress: false,
        winner: winner,
      ));
    }
  }

  void _onResetDuel(
    ResetDuel event,
    Emitter<DuelsState> emit,
  ) {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;
      
      emit(currentState.copyWith(
        clearFirstCharacter: true,
        clearSecondCharacter: true,
        isDuelInProgress: false,
        clearWinner: true,
      ));
    }
  }

  void _onRandomizeCharacters(
    RandomizeCharacters event,
    Emitter<DuelsState> emit,
  ) {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;
      
      if (currentState.availableCharacters.length >= 2) {
        final shuffledCharacters = List<CustomCharacterModel>.from(
          currentState.availableCharacters,
        )..shuffle(_random);
        
        emit(currentState.copyWith(
          firstCharacter: shuffledCharacters[0],
          secondCharacter: shuffledCharacters[1],
          clearWinner: true,
        ));
      }
    }
  }

  CustomCharacterModel _determineWinner(
    CustomCharacterModel character1,
    CustomCharacterModel character2,
  ) {

    int score1 = _calculateCharacterScore(character1);
    int score2 = _calculateCharacterScore(character2);
    

    score1 += _calculateStrategicBonus(character1, character2);
    score2 += _calculateStrategicBonus(character2, character1);
    
  
    score1 += _random.nextInt(80);
    score2 += _random.nextInt(80);
    
    return score1 >= score2 ? character1 : character2;
  }


  int _calculateCharacterScore(CustomCharacterModel character) {
    int score = 0;
    
    if (character.haki != null) {
      for (final hakiType in character.haki!) {
        final normalizedHaki = hakiType.toLowerCase();
        
        if (normalizedHaki.contains('haoshoku') || normalizedHaki.contains('king')) {
          score += 50; 
        }
      
        if (normalizedHaki.contains('busoshoku') || normalizedHaki.contains('armament')) {
          score += 40; 
        }
        
        if (normalizedHaki.contains('kenbunshoku') || normalizedHaki.contains('observation')) {
          score += 30; 
        }
      }
    }
    
    if (character.devilFruit != null && character.devilFruit!.isNotEmpty) {
      score += 25; 
    }
    
    final importantAffiliations = ['yonkou', 'admiral', 'shichibukai', 'four emperors'];
    for (final affiliation in character.affiliations) {
      if (importantAffiliations.any((important) => 
          affiliation.toLowerCase().contains(important))) {
        score += 30; 
      }
    }

    if (character.fightingStyle != null) {
      final fightingType = character.fightingStyle!.type.toLowerCase();
      switch (fightingType) {
        case 'swordsman':
          score += 20; 
          break;
        case 'martial_arts':
          score += 15; 
          break;
        default:
          score += 10; 
      }
    }
    
    return score;
  }

  int _calculateStrategicBonus(CustomCharacterModel attacker, CustomCharacterModel defender) {
    int bonus = 0;
    
    if (attacker.haki != null && defender.devilFruit != null && defender.devilFruit!.isNotEmpty) {
      for (final hakiType in attacker.haki!) {
        if (hakiType.toLowerCase().contains('busoshoku') || 
            hakiType.toLowerCase().contains('armament')) {
          bonus += 20; 
          break;
        }
      }
    }
    
    if (attacker.haki != null && (defender.fightingStyle?.type == 'martial_arts' || defender.fightingStyle?.type == 'swordsman')) {
      for (final hakiType in attacker.haki!) {
        if (hakiType.toLowerCase().contains('kenbunshoku') || 
            hakiType.toLowerCase().contains('observation')) {
          bonus += 10; 
          break;
        }
      }
    }
    
    bool attackerHasKingsHaki = attacker.haki?.any((h) => 
        h.toLowerCase().contains('haoshoku') || h.toLowerCase().contains('king')) ?? false;
    bool defenderHasKingsHaki = defender.haki?.any((h) => 
        h.toLowerCase().contains('haoshoku') || h.toLowerCase().contains('king')) ?? false;
    
    if (attackerHasKingsHaki && !defenderHasKingsHaki) {
      bonus += 20; 
    }
    
    if (attacker.devilFruit != null && attacker.devilFruit!.isNotEmpty && 
        defender.haki != null) {
      for (final hakiType in defender.haki!) {
        if (hakiType.toLowerCase().contains('busoshoku') || 
            hakiType.toLowerCase().contains('armament')) {
          bonus -= 20; 
          break;
        }
      }
    }
    
    return bonus;
  }
} 