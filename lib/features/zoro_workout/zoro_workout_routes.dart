import 'package:flutter/material.dart';
import 'package:opfan/features/zoro_workout/presentation/zoro_workout_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/shared/utils/transitions/material_page_route_without_transition.dart';

class ZoroWorkoutRoutes implements FeatureRouteModule {
  static const String workout = '/workout';

  @override
  List<String> get routes => [workout];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == workout) {
      return MaterialPageRouteWithoutTransition<dynamic>(
        builder: (_) => const WorkoutScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
