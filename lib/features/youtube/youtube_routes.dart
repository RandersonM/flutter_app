import 'package:flutter/material.dart';
import 'package:opfan/features/youtube/data/models/youtube_video_model.dart';
import 'package:opfan/features/youtube/presentation/youtube_player_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class YouTubeRoutes implements FeatureRouteModule {
  static const String youtubePlayer = '/youtubePlayer';

  @override
  List<String> get routes => [youtubePlayer];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == youtubePlayer) {
      final video = settings.arguments as YouTubeVideo;
      return MaterialPageRoute<dynamic>(
        builder: (_) => YouTubePlayerScreen(video: video),
        settings: settings,
      );
    }
    return null;
  }
}
