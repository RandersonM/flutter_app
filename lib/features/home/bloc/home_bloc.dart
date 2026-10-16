// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/home/data/repository/featured_character_repository_interface.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IYouTubeService _youTubeService;
  final IFeaturedCharacterRepository _featuredCharacterRepository;
  final IConnectivityService _connectivityService;

  HomeBloc({
    required this._youTubeService,
    required this._featuredCharacterRepository,
    required this._connectivityService,
  }) : super(const HomeInitial()) {
    on<LoadFeaturedCharacter>(_onLoadFeaturedCharacter);
    on<LoadRandomCharacter>(_onLoadRandomCharacter);
    on<RefreshHome>(_onRefreshHome);
    on<LoadCharacterVideo>(_onLoadCharacterVideo);
    on<SelectCharacter>(_onSelectCharacter);
    on<PlayVideoInline>(_onPlayVideoInline);
    on<StopVideoInline>(_onStopVideoInline);
    on<ConnectivityRestored>((event, emit) {
      add(const LoadFeaturedCharacter());
    });
  }

  Future<void> _onLoadFeaturedCharacter(
    LoadFeaturedCharacter event,
    Emitter<HomeState> emit,
  ) async {
    // Offline guard — emit placeholder state immediately.
    if (!await _connectivityService.isOnline()) {
      debugPrint('Home: Device is offline — emitting HomeOffline');
      emit(const HomeOffline());
      return;
    }

    try {
      emit(const HomeLoading());

      final character =
          await _featuredCharacterRepository.getTodaysFeaturedCharacter() ??
          await _featuredCharacterRepository.getRandomCharacter();

      emit(
        HomeLoaded(
          featuredCharacter: character,
          isRandomCharacter: false,
          isPlayingVideo: false,
        ),
      );

      add(LoadCharacterVideo(character.name));
    } catch (e) {
      debugPrint('HomeBloc: loading the featured character failed: $e');
      emit(const HomeError(HomeFailure.loadFeaturedFailed));
    }
  }

  Future<void> _onLoadRandomCharacter(
    LoadRandomCharacter event,
    Emitter<HomeState> emit,
  ) async {
    // Offline guard
    if (!await _connectivityService.isOnline()) {
      debugPrint('Home: Device is offline — cannot load random character');
      emit(const HomeOffline());
      return;
    }

    try {
      if (state is HomeLoaded) {
      } else {
        emit(const HomeLoading());
      }

      final character = await _featuredCharacterRepository.getRandomCharacter();

      emit(
        HomeLoaded(
          featuredCharacter: character,
          isRandomCharacter: true,
          isPlayingVideo: false,
        ),
      );

      add(LoadCharacterVideo(character.name));
    } catch (e) {
      debugPrint('HomeBloc: loading a random character failed: $e');
      emit(const HomeError(HomeFailure.loadRandomFailed));
    }
  }

  Future<void> _onRefreshHome(
    RefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      final character =
          await _featuredCharacterRepository.getTodaysFeaturedCharacter() ??
          await _featuredCharacterRepository.getRandomCharacter();

      emit(
        HomeLoaded(
          featuredCharacter: character,
          isRandomCharacter: false,
          isPlayingVideo: false,
        ),
      );
      add(LoadCharacterVideo(character.name));
    } catch (e) {
      debugPrint('HomeBloc: refreshing the home failed: $e');
      emit(const HomeError(HomeFailure.refreshFailed));
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

      final video = await _youTubeService.searchCharacterAMVWithFallback(
        event.characterName,
      );

      if (video != null) {
        emit(currentState.copyWith(currentVideo: video, isLoadingVideo: false));
      } else {
        emit(currentState.copyWith(clearVideo: true, isLoadingVideo: false));
        debugPrint('Home: No video found for ${event.characterName}');
      }
    } catch (e) {
      debugPrint('Home: Error loading video - $e');
      emit(currentState.copyWith(clearVideo: true, isLoadingVideo: false));
    }
  }

  Future<void> _onSelectCharacter(
    SelectCharacter event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    await _featuredCharacterRepository.saveSelectedCharacter(event.character);

    emit(
      currentState.copyWith(
        featuredCharacter: event.character,
        isRandomCharacter: false,
        clearVideo: true,
        isLoadingVideo: false,
        isPlayingVideo: false,
      ),
    );

    add(LoadCharacterVideo(event.character.name));
  }

  void _onPlayVideoInline(PlayVideoInline event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeLoaded || currentState.currentVideo == null) {
      return;
    }

    emit(currentState.copyWith(isPlayingVideo: true));
  }

  void _onStopVideoInline(StopVideoInline event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    emit(currentState.copyWith(isPlayingVideo: false));
  }
}
