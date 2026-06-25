import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/features/custom_character/presentation/create_custom_character_screen.dart';
import 'package:opfan/features/custom_character/presentation/custom_character_list_screen.dart';
import 'package:opfan/features/custom_character/presentation/edit_custom_character_screen.dart';
import 'package:opfan/shared/utils/feature_route_module.dart';

class CustomCharacterRoutes implements FeatureRouteModule {
  static const String createCustomCharacter = '/createCustomCharacter';
  static const String customCharacterList = '/customCharacterList';
  static const String editCustomCharacter = '/editCustomCharacter';

  @override
  List<String> get routes =>
      [createCustomCharacter, customCharacterList, editCustomCharacter];

  @override
  Set<String> get privateRoutes =>
      {createCustomCharacter, customCharacterList, editCustomCharacter};

  @override
  Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case createCustomCharacter:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const CreateCustomCharacterScreen(),
          settings: settings,
        );
      case customCharacterList:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const CustomCharacterListScreen(),
          settings: settings,
        );
      case editCustomCharacter:
        final character = settings.arguments as CustomCharacterModel;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditCustomCharacterScreen(character: character),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
