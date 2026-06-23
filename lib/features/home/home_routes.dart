import 'package:flutter/material.dart';
import 'package:opfan/features/home/presentation/home_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/shared/utils/transitions/material_page_route_without_transition.dart';

class HomeRoutes implements FeatureRouteModule {
  static const String home = '/home';

  @override
  List<String> get routes => [home];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == home) {
      return MaterialPageRouteWithoutTransition<dynamic>(
        builder: (_) => const HomeScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
