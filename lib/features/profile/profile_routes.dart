import 'package:flutter/material.dart';
import 'package:opfan/features/profile/presentation/profile_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class ProfileRoutes implements FeatureRouteModule {
  static const String profile = '/profile';

  @override
  List<String> get routes => [profile];

  @override
  Set<String> get privateRoutes => {profile};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == profile) {
      return MaterialPageRoute<dynamic>(
        builder: (_) => const ProfileScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
