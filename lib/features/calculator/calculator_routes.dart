import 'package:flutter/material.dart';
import 'package:opfan/features/calculator/presentation/calculator_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/shared/utils/transitions/material_page_route_without_transition.dart';

class CalculatorRoutes implements FeatureRouteModule {
  static const String calculator = '/calculator';

  @override
  List<String> get routes => [calculator];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == calculator) {
      return MaterialPageRouteWithoutTransition<dynamic>(
        builder: (_) => const CalculatorScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
