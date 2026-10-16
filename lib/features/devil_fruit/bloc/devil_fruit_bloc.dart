import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';
import 'package:opfan/core/services/index.dart';
import 'devil_fruit_event.dart';
import 'devil_fruit_state.dart';

class DevilFruitBloc extends Bloc<DevilFruitEvent, DevilFruitState> {
  final IDevilFruitService _devilFruitService;

  DevilFruitBloc({required this._devilFruitService})
    : super(const DevilFruitInitial()) {
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

      emit(
        DevilFruitLoaded(
          fruits: fruits,
          filteredFruits: fruits,
          availableTypes: types,
        ),
      );
    } catch (e) {
      debugPrint('DevilFruitBloc: loading devil fruits failed: $e');
      emit(const DevilFruitError(DevilFruitFailure.loadFailed));
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

      emit(
        DevilFruitLoaded(
          fruits: fruits,
          filteredFruits: fruits,
          availableTypes: types,
        ),
      );
    } catch (e) {
      debugPrint('DevilFruitBloc: refreshing devil fruits failed: $e');
      emit(const DevilFruitError(DevilFruitFailure.refreshFailed));
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

      emit(
        currentState.copyWith(
          filteredFruits: filteredFruits,
          searchQuery: event.query,
          isSearching: false,
        ),
      );
    } catch (e) {
      debugPrint('DevilFruitBloc: searching devil fruits failed: $e');
      emit(
        currentState.copyWith(
          isSearching: false,
          failure: DevilFruitFailure.searchFailed,
        ),
      );
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
            .where(
              (fruit) =>
                  fruit.name.toLowerCase().contains(
                    currentState.searchQuery.toLowerCase(),
                  ) ||
                  fruit.romanName.toLowerCase().contains(
                    currentState.searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredFruits: filteredFruits,
          selectedType: event.type.isNotEmpty ? event.type : null,
          clearSelectedType: event.type.isEmpty,
          isSearching: false,
        ),
      );
    } catch (e) {
      debugPrint('DevilFruitBloc: filtering devil fruits failed: $e');
      emit(
        currentState.copyWith(
          isSearching: false,
          failure: DevilFruitFailure.filterFailed,
        ),
      );
    }
  }

  Future<void> _onClearDevilFruitFilters(
    ClearDevilFruitFilters event,
    Emitter<DevilFruitState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DevilFruitLoaded) return;

    emit(
      currentState.copyWith(
        filteredFruits: currentState.fruits,
        searchQuery: '',
        clearSelectedType: true,
        isSearching: false,
      ),
    );
  }
}
