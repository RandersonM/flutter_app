// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

abstract class DuelsEvent extends Equatable {
  const DuelsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDuelsScreen extends DuelsEvent {
  const LoadDuelsScreen();
}

class SelectFirstCharacter extends DuelsEvent {
  final CustomCharacterModel character;

  const SelectFirstCharacter(this.character);

  @override
  List<Object?> get props => [character];
}

class SelectSecondCharacter extends DuelsEvent {
  final CustomCharacterModel character;

  const SelectSecondCharacter(this.character);

  @override
  List<Object?> get props => [character];
}

class ClearCharacterSelection extends DuelsEvent {
  final int position; // 1 for first character, 2 for second character

  const ClearCharacterSelection(this.position);

  @override
  List<Object?> get props => [position];
}

class StartDuel extends DuelsEvent {
  const StartDuel();
}

class ResetDuel extends DuelsEvent {
  const ResetDuel();
}

class RandomizeCharacters extends DuelsEvent {
  const RandomizeCharacters();
}
