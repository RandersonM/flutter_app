// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'character_bloc.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class GetCharactersList extends CharacterEvent {
  const GetCharactersList();
}
