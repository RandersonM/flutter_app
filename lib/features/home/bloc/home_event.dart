// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadFeaturedCharacter extends HomeEvent {
  const LoadFeaturedCharacter();
}

class LoadRandomCharacter extends HomeEvent {
  const LoadRandomCharacter();
}

class RefreshHome extends HomeEvent {
  const RefreshHome();
}

class LoadCharacterVideo extends HomeEvent {
  final String characterName;

  const LoadCharacterVideo(this.characterName);

  @override
  List<Object> get props => [characterName];
}

class SelectCharacter extends HomeEvent {
  final CustomCharacterModel character;

  const SelectCharacter(this.character);

  @override
  List<Object> get props => [character];
}

class PlayVideoInline extends HomeEvent {
  const PlayVideoInline();
}

class StopVideoInline extends HomeEvent {
  const StopVideoInline();
}

class ConnectivityRestored extends HomeEvent {
  const ConnectivityRestored();
}
