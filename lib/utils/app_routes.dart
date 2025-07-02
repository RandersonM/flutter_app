// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/core/home/models/youtube_video_model.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/screens/calculator/calculator_screen.dart';
import 'package:simple_app/screens/fav_character_selection_screen/character_selection_screen.dart';
import 'package:simple_app/screens/home/home_screen.dart';
import 'package:simple_app/screens/one_piece/characters_list_screen.dart';
import 'package:simple_app/screens/one_piece/widgets/details/character_details_screen.dart';
import 'package:simple_app/screens/youtube/youtube_player_screen.dart';

import 'package:simple_app/utils/transitions/material_page_route_without_tansition.dart';

class AppRoutes {
  // Main navigation routes
  static const String home = '/home';
  static const String calculator = '/calculator';
  static const String onePiece = '/onePiece';
  
  // Additional screen routes
  static const String youtubePlayer = '/youtubePlayer';
  static const String characterSelection = '/characterSelection';
  static const String characterDetails = '/characterDetails';

  static MaterialPageRoute<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const HomeScreen(), settings: settings);
      case calculator:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const CalculatorScreen(), settings: settings);
      case onePiece:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const CharactersListScreen(), settings: settings);
      case youtubePlayer:
        final video = settings.arguments as YouTubeVideo;
        return MaterialPageRoute<dynamic>(
            builder: (_) => YouTubePlayerScreen(video: video),
            settings: settings);
      case characterSelection:
        return MaterialPageRoute<Character>(
            builder: (_) => const CharacterSelectionScreen(),
            settings: settings);
      case characterDetails:
        final character = settings.arguments as Character;
        return MaterialPageRoute<dynamic>(
            builder: (_) => CharacterDetailsScreen(character: character),
            settings: settings);
    }

    return null;
  }
}
