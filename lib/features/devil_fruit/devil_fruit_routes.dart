import 'package:flutter/material.dart';
import 'package:opfan/features/devil_fruit/presentation/devil_fruit_list.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class DevilFruitRoutes implements FeatureRouteModule {
  static const String devilFruit = '/devilFruit';

  @override
  List<String> get routes => [devilFruit];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == devilFruit) {
      return MaterialPageRoute<dynamic>(
        builder: (_) => const DevilFruitListScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
