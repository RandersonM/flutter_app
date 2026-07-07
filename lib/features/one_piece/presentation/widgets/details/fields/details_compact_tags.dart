import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';

class DetailsCompactTags extends StatelessWidget {
  const DetailsCompactTags({
    super.key,
    required this.character,
    required this.l10n,
  });

  final CustomCharacterModel character;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    var affiliations = character.affiliations;
    var occupations = character.occupation;

    if (character.isCustomCharacter) {
      affiliations = CharacterLocalizationMapper.mapAffiliationsToLocalized(
        affiliations,
        l10n,
      );
      occupations = CharacterLocalizationMapper.mapOccupationsToLocalized(
        occupations,
        l10n,
      );
    }

    if (affiliations.isEmpty && occupations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.margin * 2,
        vertical: Constants.margin,
      ),
      child: Container(
        padding: const EdgeInsets.all(Constants.margin * 1.5),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (affiliations.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(
                    PhosphorIconsRegular.users,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: affiliations
                          .map((v) => _SmallTag(text: v))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
            if (affiliations.isNotEmpty && occupations.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, thickness: 0.5),
              ),
            if (occupations.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(
                    PhosphorIconsRegular.briefcase,
                    size: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: occupations
                          .map((v) => _SmallTag(text: v))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
