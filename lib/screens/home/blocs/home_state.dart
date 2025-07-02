// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:equatable/equatable.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/core/home/models/youtube_video_model.dart';

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

class HomeLoaded extends HomeState {
  final Character featuredCharacter;
  final bool isRandomCharacter;
  final YouTubeVideo? currentVideo;
  final bool isLoadingVideo;

  const HomeLoaded({
    required this.featuredCharacter,
    this.isRandomCharacter = false,
    this.currentVideo,
    this.isLoadingVideo = false,
  });

  @override
  List<Object?> get props => [
        featuredCharacter,
        isRandomCharacter,
        currentVideo,
        isLoadingVideo,
      ];

  HomeLoaded copyWith({
    Character? featuredCharacter,
    bool? isRandomCharacter,
    YouTubeVideo? currentVideo,
    bool? clearVideo,
    bool? isLoadingVideo,
  }) {
    return HomeLoaded(
      featuredCharacter: featuredCharacter ?? this.featuredCharacter,
      isRandomCharacter: isRandomCharacter ?? this.isRandomCharacter,
      currentVideo:
          clearVideo == true ? null : (currentVideo ?? this.currentVideo),
      isLoadingVideo: isLoadingVideo ?? this.isLoadingVideo,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
