import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/screens/custom-character/blocs/custom_character_bloc.dart';
import 'package:opfan/screens/custom-character/blocs/custom_character_event.dart';
import 'package:opfan/utils/app_routes.dart';

import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/custom_character_grid_list.dart';

class CustomCharacterListScreen extends StatelessWidget {
  const CustomCharacterListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomCharacterBloc(
        customCharacterService: getIt.customCharacterService,
        crewRepository: getIt.crewRepository,
      ),
      child: const _CustomCharacterListScreenContent(),
    );
  }
}

class _CustomCharacterListScreenContent extends StatelessWidget {
  const _CustomCharacterListScreenContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
        onCharacterDelete: (character) =>
            _onCharacterDelete(context, character),
      ),
    );
  }

  Future<void> _navigateToCreateCharacter(BuildContext context) async {
    final result =
        await Navigator.pushNamed(context, AppRoutes.createCustomCharacter);

    if (result == true) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        context.read<CustomCharacterBloc>().add(const LoadCustomCharacters());
      }
    }
  }

  void _onCharacterTap(BuildContext context, CustomCharacterModel character) =>
      Navigator.pushNamed(context, AppRoutes.characterDetails,
          arguments: character);

  void _onCharacterEdit(BuildContext context, CustomCharacterModel character) {
    Navigator.pushNamed(
      context,
      AppRoutes.editCustomCharacter,
      arguments: character,
    );
  }

  void _onCharacterDelete(
      BuildContext context, CustomCharacterModel character) {
    final l10n = AppLocalizations.of(context)!;
    context
        .read<CustomCharacterBloc>()
        .add(DeleteCustomCharacter(character.id!));
    context.read<CustomCharacterBloc>().add(const LoadCustomCharacters());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${l10n.featuredCharacter} "${character.name}" ${l10n.delete}'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 