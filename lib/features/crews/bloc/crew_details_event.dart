import 'package:equatable/equatable.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

sealed class CrewDetailsEvent extends Equatable {
  const CrewDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class ConfirmCrewDeletion extends CrewDetailsEvent {
  const ConfirmCrewDeletion();
}

final class LoadAvailableCharacters extends CrewDetailsEvent {
  const LoadAvailableCharacters();
}

final class AddCrewMember extends CrewDetailsEvent {
  const AddCrewMember({required this.character, required this.roleKey});

  final CustomCharacterModel character;
  final String roleKey;

  @override
  List<Object?> get props => [character, roleKey];
}

final class OpenCrewMember extends CrewDetailsEvent {
  const OpenCrewMember(this.member);

  final CrewMember member;

  @override
  List<Object?> get props => [member];
}
