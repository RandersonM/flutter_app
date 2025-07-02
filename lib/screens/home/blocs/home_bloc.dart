// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/core/services/characters_backend_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CharactersBackendService _charactersService;

  HomeBloc({required CharactersBackendService charactersService})
      : _charactersService = charactersService,
        super(const HomeInitial()) {
    on<LoadFeaturedCharacter>(_onLoadFeaturedCharacter);
    on<LoadRandomCharacter>(_onLoadRandomCharacter);
    on<RefreshHome>(_onRefreshHome);
  }

  Future<void> _onLoadFeaturedCharacter(
    LoadFeaturedCharacter event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      // Por padrão, carrega um personagem aleatório como destaque
      final character = await _charactersService.fetchRandomCharacter();

      emit(HomeLoaded(
        featuredCharacter: character,
        isRandomCharacter: false,
      ));

      debugPrint('Home: Featured character loaded - ${character.name}');
    } catch (e) {
      debugPrint('Home: Error loading featured character - $e');
      emit(HomeError('Erro ao carregar personagem em destaque: $e'));
    }
  }

  Future<void> _onLoadRandomCharacter(
    LoadRandomCharacter event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Mantém o estado atual mas mostra loading se necessário
      if (state is HomeLoaded) {
        // Não emite loading para não piscar a tela, apenas atualiza
      } else {
        emit(const HomeLoading());
      }

      final character = await _charactersService.fetchRandomCharacter();

      emit(HomeLoaded(
        featuredCharacter: character,
        isRandomCharacter: true,
      ));

      debugPrint('Home: Random character loaded - ${character.name}');
    } catch (e) {
      debugPrint('Home: Error loading random character - $e');
      emit(HomeError('Erro ao carregar personagem aleatório: $e'));
    }
  }

  Future<void> _onRefreshHome(
    RefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      final character = await _charactersService.fetchRandomCharacter();

      emit(HomeLoaded(
        featuredCharacter: character,
        isRandomCharacter: false,
      ));

      debugPrint('Home: Home refreshed with character - ${character.name}');
    } catch (e) {
      debugPrint('Home: Error refreshing home - $e');
      emit(HomeError('Erro ao atualizar a tela: $e'));
    }
  }
}
