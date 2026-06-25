// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';

abstract class DuelsState extends Equatable {
  const DuelsState();

  @override
  List<Object?> get props => [];
}

class DuelsInitial extends DuelsState {
  const DuelsInitial();
}

class DuelsLoading extends DuelsState {
  const DuelsLoading();
}

class DuelsReady extends DuelsState {
  final CustomCharacterModel? firstCharacter;
  final CustomCharacterModel? secondCharacter;
  final List<CustomCharacterModel> availableCharacters;
  final bool isDuelInProgress;
  final CustomCharacterModel? winner;

  const DuelsReady({
    this.firstCharacter,
    this.secondCharacter,
    this.availableCharacters = const [],
    this.isDuelInProgress = false,
    this.winner,
  });

  @override
  List<Object?> get props => [
        firstCharacter,
        secondCharacter,
        availableCharacters,
        isDuelInProgress,
        winner,
      ];

  DuelsReady copyWith({
    CustomCharacterModel? firstCharacter,
    CustomCharacterModel? secondCharacter,
    List<CustomCharacterModel>? availableCharacters,
    bool? isDuelInProgress,
    CustomCharacterModel? winner,
    bool clearFirstCharacter = false,
    bool clearSecondCharacter = false,
    bool clearWinner = false,
  }) {
    return DuelsReady(
      firstCharacter:
          clearFirstCharacter ? null : (firstCharacter ?? this.firstCharacter),
      secondCharacter: clearSecondCharacter
          ? null
          : (secondCharacter ?? this.secondCharacter),
      availableCharacters: availableCharacters ?? this.availableCharacters,
      isDuelInProgress: isDuelInProgress ?? this.isDuelInProgress,
      winner: clearWinner ? null : (winner ?? this.winner),
    );
  }

  bool get canStartDuel =>
      firstCharacter != null && secondCharacter != null && !isDuelInProgress;

  bool get hasCharactersSelected =>
      firstCharacter != null || secondCharacter != null;
}

class DuelsError extends DuelsState {
  final String message;

  const DuelsError(this.message);

  @override
  List<Object?> get props => [message];
}
