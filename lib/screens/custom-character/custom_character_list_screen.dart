// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/screens/custom-character/blocs/custom_character_bloc.dart';
import 'package:opfan/utils/app_routes.dart';

import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/custom_character_grid_list.dart';

class CustomCharacterListScreen extends StatelessWidget {
  const CustomCharacterListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider(
      create: (context) => CustomCharacterBloc(
        customCharacterService: getIt.customCharacterService,
        crewRepository: getIt.crewRepository,
      ),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: Text(l10n.myCharacters),
          actions: [
            IconButton(
              onPressed: () => _navigateToCreateCharacter(context),
              icon: const Icon(Icons.add),
              tooltip: l10n.createCustomCharacter,
            ),
          ],
        ),
        body: CustomCharacterGridList(
          onCharacterTap: (character) => _onCharacterTap(context, character),
          onCharacterEdit: (character) => _onCharacterEdit(context, character),
        ),
      ),
    );
  }

  static void _navigateToCreateCharacter(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.createCustomCharacter);

  static void _onCharacterTap(
          BuildContext context, CustomCharacterModel character) =>
      Navigator.pushNamed(context, AppRoutes.characterDetails,
          arguments: character.toCharacterModel());

  static void _onCharacterEdit(BuildContext context, CustomCharacterModel character) {
    final l10n = AppLocalizations.of(context)!;
    
    // TODO: Implementar navegação para edição do personagem
    // Por enquanto, apenas mostra um snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.editingCharacter(character.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 