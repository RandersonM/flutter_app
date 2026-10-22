import 'package:equatable/equatable.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

enum CrewDetailsFailure {
  deleteFailed,
  addMemberFailed,
  memberLoadFailed,
  roleTaken,
}

final class CrewDetailsState extends Equatable {
  const CrewDetailsState({
    required this.crew,
    required this.isOwner,
    this.isBusy = false,
    this.availableCharacters,
    this.effect,
  });

  final CrewModel crew;
  final bool isOwner;
  final bool isBusy;

  /// Null until [LoadAvailableCharacters] completes.
  final List<CustomCharacterModel>? availableCharacters;

  /// One-shot outcome of the last action, for snackbars and navigation.
  final CrewDetailsEffect? effect;

  CrewDetailsState copyWith({
    CrewModel? crew,
    bool? isBusy,
    List<CustomCharacterModel>? availableCharacters,
    bool clearAvailableCharacters = false,
    CrewDetailsEffect? effect,
  }) {
    return CrewDetailsState(
      crew: crew ?? this.crew,
      isOwner: isOwner,
      isBusy: isBusy ?? this.isBusy,
      availableCharacters: clearAvailableCharacters
          ? null
          : availableCharacters ?? this.availableCharacters,
      effect: effect,
    );
  }

  @override
  List<Object?> get props => [
    crew,
    isOwner,
    isBusy,
    availableCharacters,
    effect,
  ];
}

sealed class CrewDetailsEffect extends Equatable {
  const CrewDetailsEffect();

  @override
  List<Object?> get props => [];
}

final class CrewDeleted extends CrewDetailsEffect {
  const CrewDeleted();
}

final class CrewMemberAdded extends CrewDetailsEffect {
  const CrewMemberAdded({required this.characterName, required this.roleKey});

  final String characterName;
  final String roleKey;

  @override
  List<Object?> get props => [characterName, roleKey];
}

final class CrewMemberOpened extends CrewDetailsEffect {
  const CrewMemberOpened(this.character);

  final CustomCharacterModel character;

  @override
  List<Object?> get props => [character];
}

final class CrewMemberNotFound extends CrewDetailsEffect {
  const CrewMemberNotFound();
}

final class CrewDetailsFailed extends CrewDetailsEffect {
  const CrewDetailsFailed(this.failure);

  final CrewDetailsFailure failure;

  @override
  List<Object?> get props => [failure];
}
