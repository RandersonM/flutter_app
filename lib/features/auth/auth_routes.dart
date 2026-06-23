import 'package:flutter/material.dart';
import 'package:opfan/features/auth/presentation/login_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class AuthRoutes implements FeatureRouteModule {
  static const String login = '/login';

  @override
  List<String> get routes => [login];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == login) {
      return MaterialPageRoute<dynamic>(
        builder: (_) => const LoginScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
