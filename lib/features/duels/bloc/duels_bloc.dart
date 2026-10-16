// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/home/data/repository/i_featured_character_repository.dart';
import 'package:opfan/features/custom_character/data/repository/i_custom_character_repository.dart';
import 'duel_scoring.dart';
import 'duels_event.dart';
import 'duels_state.dart';

class DuelsBloc extends Bloc<DuelsEvent, DuelsState> {
  final IFeaturedCharacterRepository _featuredCharacterRepository;
  final ICustomCharacterRepository _customCharacterRepository;
  final Random _random = Random();

  DuelsBloc({
    required this._featuredCharacterRepository,
    required this._customCharacterRepository,
  }) : super(const DuelsInitial()) {
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

      final customCharacters = await _customCharacterRepository
          .getAllCustomCharacters();
      final allCharacters = [...customCharacters, ...onePieceCharacters];

      emit(DuelsReady(availableCharacters: allCharacters));
    } catch (e) {
      debugPrint('DuelsBloc: load characters failed: $e');
      emit(const DuelsError(DuelsFailure.loadFailed));
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
        emit(
          currentState.copyWith(
            firstCharacter: event.character,
            clearSecondCharacter: true,
          ),
        );
      } else {
        emit(currentState.copyWith(firstCharacter: event.character));
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
        emit(
          currentState.copyWith(
            secondCharacter: event.character,
            clearFirstCharacter: true,
          ),
        );
      } else {
        emit(currentState.copyWith(secondCharacter: event.character));
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

  Future<void> _onStartDuel(StartDuel event, Emitter<DuelsState> emit) async {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;

      if (!currentState.canStartDuel) {
        return;
      }

      emit(currentState.copyWith(isDuelInProgress: true, clearWinner: true));

      await Future.delayed(const Duration(seconds: 2));

      final winner = DuelScoring.winner(
        currentState.firstCharacter!,
        currentState.secondCharacter!,
        roll1: _random.nextInt(DuelScoring.rollRange),
        roll2: _random.nextInt(DuelScoring.rollRange),
      );

      emit(currentState.copyWith(isDuelInProgress: false, winner: winner));
    }
  }

  void _onResetDuel(ResetDuel event, Emitter<DuelsState> emit) {
    if (state is DuelsReady) {
      final currentState = state as DuelsReady;

      emit(
        currentState.copyWith(
          clearFirstCharacter: true,
          clearSecondCharacter: true,
          isDuelInProgress: false,
          clearWinner: true,
        ),
      );
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

        emit(
          currentState.copyWith(
            firstCharacter: shuffledCharacters[0],
            secondCharacter: shuffledCharacters[1],
            clearWinner: true,
          ),
        );
      }
    }
  }
}
