// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/core/services/youtube_service.dart';
import 'package:simple_app/core/services/featured_character_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final YouTubeService _youTubeService;
  final FeaturedCharacterService _featuredCharacterService;

  HomeBloc({
    required YouTubeService youTubeService,
    required FeaturedCharacterService featuredCharacterService,
  })  : _youTubeService = youTubeService,
        _featuredCharacterService = featuredCharacterService,
        super(const HomeInitial()) {
    on<LoadFeaturedCharacter>(_onLoadFeaturedCharacter);
    on<LoadRandomCharacter>(_onLoadRandomCharacter);
    on<RefreshHome>(_onRefreshHome);
    on<LoadCharacterVideo>(_onLoadCharacterVideo);
    on<SelectCharacter>(_onSelectCharacter);
  }

  Future<void> _onLoadFeaturedCharacter(
    LoadFeaturedCharacter event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      await _featuredCharacterService.init();

      final character =
          await _featuredCharacterService.getTodaysFeaturedCharacter();

      emit(HomeLoaded(
        featuredCharacter: character,
        isRandomCharacter: false,
      ));

      add(LoadCharacterVideo(character.name));
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
      if (state is HomeLoaded) {
      } else {
        emit(const HomeLoading());
      }

      final character = await _featuredCharacterService.getRandomCharacter();

      emit(HomeLoaded(
        featuredCharacter: character,
        isRandomCharacter: true,
      ));

      add(LoadCharacterVideo(character.name));
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

      final character =
          await _featuredCharacterService.getTodaysFeaturedCharacter();

      emit(HomeLoaded(
        featuredCharacter: character,
        isRandomCharacter: false,
      ));
      add(LoadCharacterVideo(character.name));
    } catch (e) {
      debugPrint('Home: Error refreshing home - $e');
      emit(HomeError('Erro ao atualizar a tela: $e'));
    }
  }

  Future<void> _onLoadCharacterVideo(
    LoadCharacterVideo event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      emit(currentState.copyWith(isLoadingVideo: true));

      final video = await _youTubeService
          .searchCharacterAMVWithFallback(event.characterName);

      if (video != null) {
        emit(currentState.copyWith(
          currentVideo: video,
          isLoadingVideo: false,
        ));
      } else {
        emit(currentState.copyWith(
          clearVideo: true,
          isLoadingVideo: false,
        ));
        debugPrint('Home: No video found for ${event.characterName}');
      }
    } catch (e) {
      debugPrint('Home: Error loading video - $e');
      emit(currentState.copyWith(
        clearVideo: true,
        isLoadingVideo: false,
      ));
    }
  }

  Future<void> _onSelectCharacter(
    SelectCharacter event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    await _featuredCharacterService.saveSelectedCharacter(event.character);

    emit(currentState.copyWith(
      featuredCharacter: event.character,
      isRandomCharacter: false,
      clearVideo: true,
      isLoadingVideo: false,
    ));

    add(LoadCharacterVideo(event.character.name));
  }
}
