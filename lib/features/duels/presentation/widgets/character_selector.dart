import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/duels/presentation/widgets/character_selector_modal.dart'
    show CharacterSelectionModal;
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';

class CharacterSelector extends StatelessWidget {
  final String title;
  final CustomCharacterModel? selectedCharacter;
  final List<CustomCharacterModel> availableCharacters;
  final Function(CustomCharacterModel) onCharacterSelected;
  final VoidCallback onClearSelection;
  final int position;

  const CharacterSelector({
    super.key,
    required this.title,
    this.selectedCharacter,
    required this.availableCharacters,
    required this.onCharacterSelected,
    required this.onClearSelection,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 200,
          maxWidth: 350,
        ),
        padding: const EdgeInsets.all(Constants.margin * 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(Constants.margin * 2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.margin),
            if (selectedCharacter != null)
              _buildSelectedCharacter(context)
            else
              _buildCharacterSelection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCharacter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Constants.margin * 2),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Constants.margin * 2),
            child: ClickableImage(
              imageUrl: selectedCharacter!.image,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              enableClick: false,
            ),
          ),
        ),
        const SizedBox(height: Constants.margin),
        Text(
          selectedCharacter!.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (selectedCharacter!.nickname != null) ...[
          const SizedBox(height: Constants.margin * 0.5),
          Text(
            selectedCharacter!.nickname!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (selectedCharacter!.bounty.isNotEmpty) ...[
          const SizedBox(height: Constants.margin),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.margin,
              vertical: Constants.margin * 0.5,
            ),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Constants.margin),
            ),
            child: Text(
              '${l10n.bounty}: ${Constants.formatBounty(selectedCharacter!.bounty)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: Constants.margin),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.characterDetails,
                    arguments: selectedCharacter,
                  );
                },
                icon:
                    const AppIcon(PhosphorIconsRegular.info, size: 16),
                label: Text(l10n.statistics),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.margin,
                    vertical: Constants.margin * 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Constants.margin),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onClearSelection,
                icon: const AppIcon(PhosphorIconsRegular.x, size: 16),
                label: Text(l10n.clear),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.margin,
                    vertical: Constants.margin * 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCharacterSelection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (availableCharacters.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(
            PhosphorIconsRegular.userMinus,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: Constants.margin),
          Text(
            l10n.noCharactersAvailable,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Constants.margin * 2),
            border: Border.all(
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: const AppIcon(
            PhosphorIconsRegular.userPlus,
            size: 48,
          ),
        ),
        const SizedBox(height: Constants.margin),
        Text(
          l10n.selectACharacter,
          style: theme.textTheme.bodyMedium?.copyWith(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.margin),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showCharacterSelectionModal(context),
            icon:
                const AppIcon(PhosphorIconsRegular.magnifyingGlass, size: 18),
            label: Text(l10n.selectCharacter),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              foregroundColor: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.margin * 2,
                vertical: Constants.margin,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCharacterSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CharacterSelectionModal(
        availableCharacters: availableCharacters,
        onCharacterSelected: onCharacterSelected,
        title: title,
      ),
    );
  }
}
