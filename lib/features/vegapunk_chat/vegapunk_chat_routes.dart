import 'package:flutter/material.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';
import 'package:opfan/shared/utils/transitions/material_page_route_without_transition.dart';

import 'presentation/vegapunk_chat_screen.dart';

class VegapunkChatRoutes implements FeatureRouteModule {
  static const String vegapunkChat = '/vegapunkChat';

  @override
  List<String> get routes => [vegapunkChat];

  @override
  Set<String> get privateRoutes => {vegapunkChat};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == vegapunkChat) {
      return MaterialPageRouteWithoutTransition<dynamic>(
        builder: (_) => const VegapunkChatScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
