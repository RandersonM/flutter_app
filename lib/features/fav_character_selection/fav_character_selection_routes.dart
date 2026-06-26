import 'package:flutter/material.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/fav_character_selection/presentation/character_selection_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class FavCharacterSelectionRoutes implements FeatureRouteModule {
  static const String characterSelection = '/characterSelection';

  @override
  List<String> get routes => [characterSelection];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    if (settings.name == characterSelection) {
      return MaterialPageRoute<CustomCharacterModel>(
        builder: (_) => const CharacterSelectionScreen(),
        settings: settings,
      );
    }
    return null;
  }
}
