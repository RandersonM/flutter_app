// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/one_piece/models/devil_fruit.dart';
import 'package:opfan/core/services/devil_fruit_service.dart';
import 'devil_fruit_event.dart';
import 'devil_fruit_state.dart';

class DevilFruitBloc extends Bloc<DevilFruitEvent, DevilFruitState> {
  final DevilFruitService _devilFruitService;

  DevilFruitBloc({
    required DevilFruitService devilFruitService,
  })  : _devilFruitService = devilFruitService,
        super(const DevilFruitInitial()) {
    on<LoadDevilFruits>(_onLoadDevilFruits);
    on<RefreshDevilFruits>(_onRefreshDevilFruits);
    on<SearchDevilFruits>(_onSearchDevilFruits);
    on<FilterDevilFruitsByType>(_onFilterDevilFruitsByType);
    on<ClearDevilFruitFilters>(_onClearDevilFruitFilters);
  }

  Future<void> _onLoadDevilFruits(
    LoadDevilFruits event,
    Emitter<DevilFruitState> emit,
  ) async {
    try {
      emit(const DevilFruitLoading());

      final fruits = await _devilFruitService.fetchAll();
      final types = _devilFruitService.availableTypes;

      emit(DevilFruitLoaded(
        fruits: fruits,
        filteredFruits: fruits,
        availableTypes: types,
      ));

      debugPrint('DevilFruitBloc: Loaded ${fruits.length} devil fruits');
    } catch (e) {
      debugPrint('DevilFruitBloc: Error loading devil fruits - $e');
      emit(DevilFruitError('Erro ao carregar Akuma no Mi: $e'));
    }
  }

  Future<void> _onRefreshDevilFruits(
    RefreshDevilFruits event,
    Emitter<DevilFruitState> emit,
  ) async {
    try {
      emit(const DevilFruitLoading());

      _devilFruitService.clearCache();
      final fruits = await _devilFruitService.fetchAll();
      final types = _devilFruitService.availableTypes;

      emit(DevilFruitLoaded(
        fruits: fruits,
        filteredFruits: fruits,
        availableTypes: types,
      ));

      debugPrint('DevilFruitBloc: Refreshed ${fruits.length} devil fruits');
    } catch (e) {
      debugPrint('DevilFruitBloc: Error refreshing devil fruits - $e');
      emit(DevilFruitError('Erro ao atualizar Akuma no Mi: $e'));
    }
  }

  Future<void> _onSearchDevilFruits(
    SearchDevilFruits event,
    Emitter<DevilFruitState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DevilFruitLoaded) return;

    try {
      emit(currentState.copyWith(isSearching: true));

      List<DevilFruit> filteredFruits = currentState.fruits;

      if (event.query.isNotEmpty) {
        filteredFruits = await _devilFruitService.searchByName(event.query);
      }

      if (currentState.selectedType != null) {
        filteredFruits = filteredFruits
            .where((fruit) => fruit.type == currentState.selectedType)
            .toList();
      }

      emit(currentState.copyWith(
        filteredFruits: filteredFruits,
        searchQuery: event.query,
        isSearching: false,
      ));

      debugPrint(
          'DevilFruitBloc: Search completed - ${filteredFruits.length} results');
    } catch (e) {
      debugPrint('DevilFruitBloc: Error searching devil fruits - $e');
      emit(currentState.copyWith(
        isSearching: false,
        error: 'Erro ao buscar Akuma no Mi: $e',
      ));
    }
  }

  Future<void> _onFilterDevilFruitsByType(
    FilterDevilFruitsByType event,
    Emitter<DevilFruitState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DevilFruitLoaded) return;

    try {
      emit(currentState.copyWith(isSearching: true));

      List<DevilFruit> filteredFruits = currentState.fruits;

      if (event.type.isNotEmpty) {
        filteredFruits = await _devilFruitService.fetchByType(event.type);
      }

      if (currentState.searchQuery.isNotEmpty) {
        filteredFruits = filteredFruits
            .where((fruit) =>
                fruit.name
                    .toLowerCase()
                    .contains(currentState.searchQuery.toLowerCase()) ||
                fruit.romanName
                    .toLowerCase()
                    .contains(currentState.searchQuery.toLowerCase()))
            .toList();
      }

      emit(currentState.copyWith(
        filteredFruits: filteredFruits,
        selectedType: event.type.isNotEmpty ? event.type : null,
        isSearching: false,
      ));

      debugPrint(
          'DevilFruitBloc: Filter by type completed - ${filteredFruits.length} results');
    } catch (e) {
      debugPrint('DevilFruitBloc: Error filtering devil fruits - $e');
      emit(currentState.copyWith(
        isSearching: false,
        error: 'Erro ao filtrar Akuma no Mi: $e',
      ));
    }
  }

  Future<void> _onClearDevilFruitFilters(
    ClearDevilFruitFilters event,
    Emitter<DevilFruitState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DevilFruitLoaded) return;

    emit(currentState.copyWith(
      filteredFruits: currentState.fruits,
      searchQuery: '',
      selectedType: null,
      isSearching: false,
    ));

    debugPrint('DevilFruitBloc: Filters cleared');
  }
}
