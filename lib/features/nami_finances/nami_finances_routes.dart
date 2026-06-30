import 'package:flutter/material.dart';
import 'package:opfan/features/nami_finances/presentation/nami_detailed_finances_screen.dart';
import 'package:opfan/features/nami_finances/presentation/nami_finances_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/shared/utils/transitions/material_page_route_without_transition.dart';

class NamiFinancesRoutes implements FeatureRouteModule {
  static const String finances = '/finances';
  static const String namiDetailedFinances = '/namiDetailedFinances';

  @override
  List<String> get routes => [finances, namiDetailedFinances];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case finances:
        return MaterialPageRouteWithoutTransition<dynamic>(
          builder: (_) => const NamiFinancesScreen(),
          settings: settings,
        );
      case namiDetailedFinances:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const NamiDetailedFinancesScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
