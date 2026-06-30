import 'package:equatable/equatable.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

abstract class CustomCharacterState extends Equatable {
  const CustomCharacterState();

  @override
  List<Object?> get props => [];
}

class CustomCharacterInitial extends CustomCharacterState {}

class CustomCharacterLoading extends CustomCharacterState {}

class CustomCharacterLoaded extends CustomCharacterState {
  final List<CustomCharacterModel> characters;

  const CustomCharacterLoaded(this.characters);

  @override
  List<Object?> get props => [characters];
}

class CustomCharacterError extends CustomCharacterState {
  final String message;

  const CustomCharacterError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomCharacterCreating extends CustomCharacterState {}

class CustomCharacterCreated extends CustomCharacterState {
  final String characterId;

  const CustomCharacterCreated(this.characterId);

  @override
  List<Object?> get props => [characterId];
}

class CustomCharacterUpdating extends CustomCharacterState {}

class CustomCharacterUpdated extends CustomCharacterState {
  final String characterId;

  const CustomCharacterUpdated(this.characterId);

  @override
  List<Object?> get props => [characterId];
}

class CustomCharacterDeleting extends CustomCharacterState {}

class CustomCharacterDeleted extends CustomCharacterState {
  final String characterId;

  const CustomCharacterDeleted(this.characterId);

  @override
  List<Object?> get props => [characterId];
}
