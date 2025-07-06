// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/youtube_service.dart';
import 'package:opfan/core/services/featured_character_service.dart';
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
    on<PlayVideoInline>(_onPlayVideoInline);
    on<StopVideoInline>(_onStopVideoInline);
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
        isPlayingVideo: false,
      ));

      add(LoadCharacterVideo(character.name));
    } catch (e) {
      debugPrint('Home: Error loading featured character - $e');
      emit(HomeError('Error loading featured character: $e'));
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
        isPlayingVideo: false,
      ));

      add(LoadCharacterVideo(character.name));
    } catch (e) {
      debugPrint('Home: Error loading random character - $e');
      emit(HomeError('Error loading random character: $e'));
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
        isPlayingVideo: false,
      ));
      add(LoadCharacterVideo(character.name));
    } catch (e) {
      debugPrint('Home: Error refreshing home - $e');
      emit(HomeError('Error refreshing screen: $e'));
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
      isPlayingVideo: false,
    ));

    add(LoadCharacterVideo(event.character.name));
  }

  void _onPlayVideoInline(
    PlayVideoInline event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is! HomeLoaded || currentState.currentVideo == null) {
      return;
    }

    emit(currentState.copyWith(isPlayingVideo: true));
  }

  void _onStopVideoInline(
    StopVideoInline event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    emit(currentState.copyWith(isPlayingVideo: false));
  }
}
