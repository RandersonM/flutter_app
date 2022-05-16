// Developed by Randerson Mayllon
// Copyright © 2022.

part of 'character_bloc.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object?> get props => [];
}

class StateInitial extends CharacterState {}

class StateLoading extends CharacterState {}

class StateMore2Load extends CharacterState {
  final List<Character> loadState;
  const StateMore2Load(this.loadState);
}

class StateLoaded extends CharacterState {
  final List<Character> loadState;
  const StateLoaded(this.loadState);
}

class StateError extends CharacterState {
  final String? message;
  const StateError(this.message);
}
