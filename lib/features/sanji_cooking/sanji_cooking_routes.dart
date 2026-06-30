import 'package:flutter/material.dart';
import 'package:opfan/features/sanji_cooking/presentation/cooking_tips_screen.dart';
import 'package:opfan/features/sanji_cooking/presentation/sanji_cooking_screen.dart';
import 'package:opfan/features/sanji_cooking/presentation/widgets/plate_guide_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/shared/utils/transitions/material_page_route_without_transition.dart';

class SanjiCookingRoutes implements FeatureRouteModule {
  static const String cooking = '/cooking';
  static const String cookingTips = '/cookingTips';
  static const String plateGuide = '/plateGuide';

  @override
  List<String> get routes => [cooking, cookingTips, plateGuide];

  @override
  Set<String> get privateRoutes => {cooking, cookingTips, plateGuide};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case cooking:
        return MaterialPageRouteWithoutTransition<dynamic>(
          builder: (_) => const SanjiCookingScreen(),
          settings: settings,
        );
      case cookingTips:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => CookingTipsScreen(
            targetCalories: args?['targetCalories'] as double?,
            goal: args?['goal'] as String?,
          ),
          settings: settings,
        );
      case plateGuide:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const PlateGuideScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
