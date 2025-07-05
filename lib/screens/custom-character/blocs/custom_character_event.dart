import 'package:equatable/equatable.dart';
import 'package:opfan/core/models/custom_character_model.dart';

abstract class CustomCharacterEvent extends Equatable {
  const CustomCharacterEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomCharacters extends CustomCharacterEvent {
  const LoadCustomCharacters();
}

class CreateCustomCharacter extends CustomCharacterEvent {
  final CustomCharacterModel character;

  const CreateCustomCharacter(this.character);

  @override
  List<Object?> get props => [character];
}

class UpdateCustomCharacter extends CustomCharacterEvent {
  final String characterId;
  final CustomCharacterModel character;

  const UpdateCustomCharacter(this.characterId, this.character);

  @override
  List<Object?> get props => [characterId, character];
}

class DeleteCustomCharacter extends CustomCharacterEvent {
  final String characterId;

  const DeleteCustomCharacter(this.characterId);

  @override
  List<Object?> get props => [characterId];
}

class SearchCustomCharacters extends CustomCharacterEvent {
  final String query;

  const SearchCustomCharacters(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterCustomCharactersByDevilFruit extends CustomCharacterEvent {
  final String devilFruit;

  const FilterCustomCharactersByDevilFruit(this.devilFruit);

  @override
  List<Object?> get props => [devilFruit];
}

class FilterCustomCharactersByCrew extends CustomCharacterEvent {
  final String crew;

  const FilterCustomCharactersByCrew(this.crew);

  @override
  List<Object?> get props => [crew];
} 