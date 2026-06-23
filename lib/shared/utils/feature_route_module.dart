import 'package:flutter/material.dart';

abstract class FeatureRouteModule {
  List<String> get routes;
  Set<String> get privateRoutes;
  Route<dynamic>? getRoute(RouteSettings settings);
}
