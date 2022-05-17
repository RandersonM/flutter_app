// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/shared/transitions/material_page_route_without_tansition.dart';
import 'package:simple_app/ui/screens/calculator/calculator_screen.dart';
import 'package:simple_app/ui/screens/movies/movie_search_screen.dart';
import 'package:simple_app/ui/screens/one_piece/characters_list_screen.dart';

class AppRoutes {
  static const String counter = '/movie_search';
  static const String calculator = '/calculator';
  static const String onePiece = '/onePiece';

  static MaterialPageRoute<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case counter:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const MovieSearchSreen(), settings: settings);
      case calculator:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const CalculatorScreen(), settings: settings);
      case onePiece:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const CharactersListScreen(), settings: settings);
    }

    return null;
  }
}
