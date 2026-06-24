// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/features/onboarding/presentation/onboarding_screen.dart';

class OnboardingRoutes implements FeatureRouteModule {
  static const String onboarding = '/onboarding';

  @override
  List<String> get routes => [
        onboarding,
      ];

  @override
  Set<String> get privateRoutes => {}; // É acessada durante o setup inicial

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
