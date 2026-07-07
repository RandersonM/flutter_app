// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/youtube/data/models/youtube_video_model.dart';

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

class HomeOffline extends HomeState {
  const HomeOffline();
}

class HomeLoaded extends HomeState {
  final CustomCharacterModel featuredCharacter;
  final bool isRandomCharacter;
  final YouTubeVideo? currentVideo;
  final bool isLoadingVideo;
  final bool isPlayingVideo;

  const HomeLoaded({
    required this.featuredCharacter,
    this.isRandomCharacter = false,
    this.currentVideo,
    this.isLoadingVideo = false,
    this.isPlayingVideo = false,
  });

  @override
  List<Object?> get props => [
    featuredCharacter,
    isRandomCharacter,
    currentVideo,
    isLoadingVideo,
    isPlayingVideo,
  ];

  HomeLoaded copyWith({
    CustomCharacterModel? featuredCharacter,
    bool? isRandomCharacter,
    YouTubeVideo? currentVideo,
    bool? clearVideo,
    bool? isLoadingVideo,
    bool? isPlayingVideo,
  }) {
    return HomeLoaded(
      featuredCharacter: featuredCharacter ?? this.featuredCharacter,
      isRandomCharacter: isRandomCharacter ?? this.isRandomCharacter,
      currentVideo: clearVideo == true
          ? null
          : (currentVideo ?? this.currentVideo),
      isLoadingVideo: isLoadingVideo ?? this.isLoadingVideo,
      isPlayingVideo: isPlayingVideo ?? this.isPlayingVideo,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
