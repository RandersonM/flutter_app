// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';

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
