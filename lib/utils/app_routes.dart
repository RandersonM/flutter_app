// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/models/youtube_video_model.dart';
import 'package:opfan/core/models/one_piece/character.dart';
import 'package:opfan/screens/calculator/calculator_screen.dart';
import 'package:opfan/screens/fav_character_selection_screen/character_selection_screen.dart';
import 'package:opfan/screens/home/home_screen.dart';
import 'package:opfan/screens/one_piece/characters_list_screen.dart';
import 'package:opfan/screens/one_piece/widgets/details/character_details_screen.dart';
import 'package:opfan/screens/youtube/youtube_player_screen.dart';
import 'package:opfan/screens/devil_fruit/devil_fruit_list.dart';
import 'package:opfan/screens/auth/login_screen.dart';
import 'package:opfan/screens/profile/profile_screen.dart';
import 'package:opfan/screens/custom-character/create_custom_character_screen.dart';
import 'package:opfan/screens/custom-character/custom_character_list_screen.dart';

import 'package:opfan/utils/transitions/material_page_route_without_tansition.dart';

class AppRoutes {
  // Auth routes
  static const String login = '/login';
  
  // Main navigation routes (public)
  static const String home = '/home';
  static const String calculator = '/calculator';
  static const String onePiece = '/onePiece';
  static const String devilFruit = '/devilFruit';
  
  // Additional screen routes (public)
  static const String youtubePlayer = '/youtubePlayer';
  static const String characterSelection = '/characterSelection';
  static const String characterDetails = '/characterDetails';

  // Private routes (require authentication)
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String createCustomCharacter = '/createCustomCharacter';
  static const String customCharacterList = '/customCharacterList';

  // Define which routes require authentication
  static const Set<String> _privateRoutes = {
    profile,
    settings,
    favorites,
    createCustomCharacter,
    customCharacterList,
    // Add more private routes here as needed
  };

  // Define which routes are public (no authentication required)
  static const Set<String> _publicRoutes = {
    login,
    home,
    calculator,
    onePiece,
    devilFruit,
    youtubePlayer,
    characterSelection,
    characterDetails,
  };

  /// Check if a route requires authentication
  static bool requiresAuth(String routeName) {
    return _privateRoutes.contains(routeName);
  }

  /// Check if a route is public
  static bool isPublicRoute(String routeName) {
    return _publicRoutes.contains(routeName);
  }

  /// Get all private routes
  static Set<String> get privateRoutes => _privateRoutes;

  /// Get all public routes
  static Set<String> get publicRoutes => _publicRoutes;

  static MaterialPageRoute<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<dynamic>(
            builder: (_) => const LoginScreen(), settings: settings);
      case home:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const HomeScreen(), settings: settings);
      case calculator:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const CalculatorScreen(), settings: settings);
      case onePiece:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const CharactersListScreen(), settings: settings);
      case devilFruit:
        return MaterialPageRouteWithoutTransition<dynamic>(
            builder: (_) => const DevilFruitListScreen(), settings: settings);
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
      case profile:
        return MaterialPageRoute<dynamic>(
            builder: (_) => const ProfileScreen(), settings: settings);
      case createCustomCharacter:
        return MaterialPageRoute<dynamic>(
            builder: (_) => const CreateCustomCharacterScreen(),
            settings: settings);
      case customCharacterList:
        return MaterialPageRoute<dynamic>(
            builder: (_) => const CustomCharacterListScreen(),
            settings: settings);
      // Add more private routes here when they are created
      // case settings:
      //   return MaterialPageRoute<dynamic>(
      //       builder: (_) => const SettingsScreen(), settings: settings);
      // case favorites:
      //   return MaterialPageRoute<dynamic>(
      //       builder: (_) => const FavoritesScreen(), settings: settings);
    }

    return null;
  }
}

/// Middleware for route authentication
class AuthRouteMiddleware {
  static Route<dynamic>? onGenerateRoute(
    RouteSettings settings,
    AuthState authState,
  ) {
    // Check if route requires authentication
    if (AppRoutes.requiresAuth(settings.name ?? '')) {
      // If user is not authenticated, redirect to login
      if (authState is! AuthAuthenticated) {
        return MaterialPageRoute<dynamic>(
          builder: (_) => const LoginScreen(),
          settings: const RouteSettings(name: AppRoutes.login),
        );
      }
    }

    // If route is public or user is authenticated, proceed normally
    return AppRoutes.getRoute(settings);
  }
}

/// Navigation service with authentication checks
class AppNavigation {
  static Future<dynamic> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    final authState = context.read<AuthBloc>().state;

    // Check if route requires authentication
    if (AppRoutes.requiresAuth(routeName)) {
      if (authState is! AuthAuthenticated) {
        // Redirect to login with return route
        return Navigator.of(context).pushNamed(
          AppRoutes.login,
          arguments: {
            'returnRoute': routeName,
            'returnArguments': arguments,
          },
        );
      }
    }

    // Navigate to the requested route
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    final authState = context.read<AuthBloc>().state;

    // Check if route requires authentication
    if (AppRoutes.requiresAuth(routeName)) {
      if (authState is! AuthAuthenticated) {
        // Redirect to login
        return Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }

    // Navigate to the requested route
    return Navigator.of(context)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }
}
