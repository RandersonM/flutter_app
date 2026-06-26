import 'package:flutter/material.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/features/one_piece/presentation/characters_list_screen.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/character_details_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class OnePieceRoutes implements FeatureRouteModule {
  static const String onePiece = '/onePiece';
  static const String characterDetails = '/characterDetails';

  @override
  List<String> get routes => [onePiece, characterDetails];

  @override
  Set<String> get privateRoutes => {};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case onePiece:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const CharactersListScreen(),
          settings: settings,
        );
      case characterDetails:
        final character = settings.arguments as CustomCharacterModel;
        return MaterialPageRoute<dynamic>(
          builder: (_) => CharacterDetailsScreen(character: character),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
