// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/features/auth/presentation/login_screen.dart';

import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/features/auth/auth_routes.dart';
import 'package:opfan/features/home/home_routes.dart';
import 'package:opfan/features/calculator/calculator_routes.dart';
import 'package:opfan/features/robin_knowledge/robin_knowledge_routes.dart';
import 'package:opfan/features/nami_finances/nami_finances_routes.dart';
import 'package:opfan/features/zoro_workout/zoro_workout_routes.dart';
import 'package:opfan/features/sanji_cooking/sanji_cooking_routes.dart';
import 'package:opfan/features/youtube/youtube_routes.dart';
import 'package:opfan/features/devil_fruit/devil_fruit_routes.dart';
import 'package:opfan/features/fav_character_selection/fav_character_selection_routes.dart';
import 'package:opfan/features/one_piece/one_piece_routes.dart';
import 'package:opfan/features/duels/duels_routes.dart';
import 'package:opfan/features/profile/profile_routes.dart';
import 'package:opfan/features/custom_character/custom_character_routes.dart';
import 'package:opfan/features/crews/crews_routes.dart';
import 'package:opfan/features/onboarding/onboarding_routes.dart';
import 'package:opfan/features/vegapunk_chat/vegapunk_chat_routes.dart';

class AppRoutes {
  // Auth routes
  static const String login = AuthRoutes.login;
  static const String onboarding = OnboardingRoutes.onboarding;

  // Main navigation routes (public)
  static const String home = HomeRoutes.home;
  static const String calculator = CalculatorRoutes.calculator;
  static const String finances = NamiFinancesRoutes.finances;
  static const String devilFruit = DevilFruitRoutes.devilFruit;
  static const String knowledge = RobinKnowledgeRoutes.knowledge;
  static const String vegapunkChat = VegapunkChatRoutes.vegapunkChat;

  // Additional screen routes (public)
  static const String youtubePlayer = YouTubeRoutes.youtubePlayer;
  static const String characterSelection =
      FavCharacterSelectionRoutes.characterSelection;
  static const String characterDetails = OnePieceRoutes.characterDetails;
  static const String workout = ZoroWorkoutRoutes.workout;
  static const String cooking = SanjiCookingRoutes.cooking;
  static const String plateGuide = SanjiCookingRoutes.plateGuide;

  // Private routes (require authentication)
  static const String profile = ProfileRoutes.profile;
  static const String settings = '/settings'; // Legacy/Unused
  static const String favorites = '/favorites'; // Legacy/Unused
  static const String createCustomCharacter =
      CustomCharacterRoutes.createCustomCharacter;
  static const String customCharacterList =
      CustomCharacterRoutes.customCharacterList;
  static const String editCustomCharacter =
      CustomCharacterRoutes.editCustomCharacter;
  static const String createCrew = CrewsRoutes.createCrew;
  static const String editCrew = CrewsRoutes.editCrew;
  static const String listCrews = CrewsRoutes.listCrews;
  static const String crewDetails = CrewsRoutes.crewDetails;
  static const String duels = DuelsRoutes.duels;
  static const String onePiece = OnePieceRoutes.onePiece;
  static const String cookingTips = SanjiCookingRoutes.cookingTips;
  static const String namiDetailedFinances =
      NamiFinancesRoutes.namiDetailedFinances;

  static final List<FeatureRouteModule> _modules = [
    AuthRoutes(),
    HomeRoutes(),
    CalculatorRoutes(),
    RobinKnowledgeRoutes(),
    NamiFinancesRoutes(),
    ZoroWorkoutRoutes(),
    SanjiCookingRoutes(),
    YouTubeRoutes(),
    DevilFruitRoutes(),
    FavCharacterSelectionRoutes(),
    OnePieceRoutes(),
    DuelsRoutes(),
    ProfileRoutes(),
    CustomCharacterRoutes(),
    CrewsRoutes(),
    OnboardingRoutes(),
    VegapunkChatRoutes(),
  ];

  /// Check if a route requires authentication
  static bool requiresAuth(String routeName) {
    for (final module in _modules) {
      if (module.routes.contains(routeName)) {
        return module.privateRoutes.contains(routeName);
      }
    }
    return false;
  }

  /// Check if a route is public
  static bool isPublicRoute(String routeName) {
    for (final module in _modules) {
      if (module.routes.contains(routeName)) {
        return !module.privateRoutes.contains(routeName);
      }
    }
    return false;
  }

  /// Get all private routes
  static Set<String> get privateRoutes {
    final privateSet = <String>{};
    for (final module in _modules) {
      privateSet.addAll(module.privateRoutes);
    }
    return privateSet;
  }

  /// Get all public routes
  static Set<String> get publicRoutes {
    final publicSet = <String>{};
    for (final module in _modules) {
      for (final route in module.routes) {
        if (!module.privateRoutes.contains(route)) {
          publicSet.add(route);
        }
      }
    }
    return publicSet;
  }

  static Route<dynamic>? getRoute(RouteSettings settings) {
    for (final module in _modules) {
      if (module.routes.contains(settings.name)) {
        final route = module.getRoute(settings);
        if (route != null) {
          return route;
        }
      }
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
          arguments: {'returnRoute': routeName, 'returnArguments': arguments},
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
    return Navigator.of(
      context,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }
}
