// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/l10n/app_localizations.dart';
import 'package:simple_app/widgets/molecules/default_app_bar.dart';
import 'package:simple_app/widgets/organisms/character_selection_grid.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.selectCharacter),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CharacterSelectionGrid(
        onCharacterSelected: (Character character) {
          Navigator.of(context).pop(character);
        },
      ),
    );
  }
}
