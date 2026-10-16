// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

abstract class DevilFruitState extends Equatable {
  const DevilFruitState();

  @override
  List<Object?> get props => [];
}

class DevilFruitInitial extends DevilFruitState {
  const DevilFruitInitial();
}

class DevilFruitLoading extends DevilFruitState {
  const DevilFruitLoading();
}

class DevilFruitLoaded extends DevilFruitState {
  final List<DevilFruit> fruits;
  final List<DevilFruit> filteredFruits;
  final List<String> availableTypes;
  final String searchQuery;
  final String? selectedType;
  final bool isSearching;
  final DevilFruitFailure? failure;

  const DevilFruitLoaded({
    required this.fruits,
    required this.filteredFruits,
    required this.availableTypes,
    this.searchQuery = '',
    this.selectedType,
    this.isSearching = false,
    this.failure,
  });

  @override
  List<Object?> get props => [
    fruits,
    filteredFruits,
    availableTypes,
    searchQuery,
    selectedType,
    isSearching,
    failure,
  ];

  DevilFruitLoaded copyWith({
    List<DevilFruit>? fruits,
    List<DevilFruit>? filteredFruits,
    List<String>? availableTypes,
    String? searchQuery,
    String? selectedType,
    bool? isSearching,
    DevilFruitFailure? failure,
  }) {
    return DevilFruitLoaded(
      fruits: fruits ?? this.fruits,
      filteredFruits: filteredFruits ?? this.filteredFruits,
      availableTypes: availableTypes ?? this.availableTypes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      isSearching: isSearching ?? this.isSearching,
      failure: failure ?? this.failure,
    );
  }
}

class DevilFruitError extends DevilFruitState {
  final DevilFruitFailure failure;

  const DevilFruitError(this.failure);

  @override
  List<Object?> get props => [failure];
}

enum DevilFruitFailure { loadFailed, refreshFailed, searchFailed, filterFailed }
