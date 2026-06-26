import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/character_selection_grid.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.selectCharacter),
        leading: IconButton(
          icon: const AppIcon(PhosphorIconsRegular.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CharacterSelectionGrid(
        onCharacterSelected: (CustomCharacterModel character) {
          Navigator.of(context).pop(character);
        },
      ),
    );
  }
}
