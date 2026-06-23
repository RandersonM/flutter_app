import 'package:flutter/material.dart';
import 'package:opfan/features/duels/presentation/duels_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class DuelsRoutes implements FeatureRouteModule {
  static const String duels = '/duels';

  @override
  List<String> get routes => [duels];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == duels) {
      return MaterialPageRoute<dynamic>(
        builder: (_) => const DuelsScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
