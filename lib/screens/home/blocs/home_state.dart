// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';
import 'package:simple_app/core/one_piece/models/character.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final Character featuredCharacter;
  final bool isRandomCharacter;

  const HomeLoaded({
    required this.featuredCharacter,
    this.isRandomCharacter = false,
  });

  @override
  List<Object?> get props => [featuredCharacter, isRandomCharacter];

  HomeLoaded copyWith({
    Character? featuredCharacter,
    bool? isRandomCharacter,
  }) {
    return HomeLoaded(
      featuredCharacter: featuredCharacter ?? this.featuredCharacter,
      isRandomCharacter: isRandomCharacter ?? this.isRandomCharacter,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
