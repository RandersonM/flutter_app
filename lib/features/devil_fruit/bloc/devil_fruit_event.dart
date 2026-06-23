// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';

abstract class DevilFruitEvent extends Equatable {
  const DevilFruitEvent();

  @override
  List<Object> get props => [];
}

class LoadDevilFruits extends DevilFruitEvent {
  const LoadDevilFruits();
}

class RefreshDevilFruits extends DevilFruitEvent {
  const RefreshDevilFruits();
}

class SearchDevilFruits extends DevilFruitEvent {
  final String query;

  const SearchDevilFruits(this.query);

  @override
  List<Object> get props => [query];
}

class FilterDevilFruitsByType extends DevilFruitEvent {
  final String type;

  const FilterDevilFruitsByType(this.type);

  @override
  List<Object> get props => [type];
}

class ClearDevilFruitFilters extends DevilFruitEvent {
  const ClearDevilFruitFilters();
}
