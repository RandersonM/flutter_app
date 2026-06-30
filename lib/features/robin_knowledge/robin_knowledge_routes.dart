import 'package:flutter/material.dart';
import 'package:opfan/features/robin_knowledge/presentation/robin_knowledge_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/shared/utils/transitions/material_page_route_without_transition.dart';

class RobinKnowledgeRoutes implements FeatureRouteModule {
  static const String knowledge = '/knowledge';

  @override
  List<String> get routes => [knowledge];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == knowledge) {
      return MaterialPageRouteWithoutTransition<dynamic>(
        builder: (_) => const RobinKnowledgeScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
