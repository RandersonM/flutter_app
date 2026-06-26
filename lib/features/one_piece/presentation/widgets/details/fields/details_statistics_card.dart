import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/zodiac_icons.dart';
import 'package:opfan/shared/widgets/molecules/statistic_item.dart';

class DetailsStatisticsCard extends StatelessWidget {
  const DetailsStatisticsCard({
    super.key,
    required this.character,
    required this.l10n,
  });

  final CustomCharacterModel character;
  final AppLocalizations l10n;

  IconData _hakiIcon(String haki) {
    final lower = haki.toLowerCase();
    if (lower.contains('busoshoku')) return PhosphorIconsRegular.boxingGlove;
    if (lower.contains('kenbunshoku')) return PhosphorIconsRegular.target;
    if (lower.contains('haoshoku')) return PhosphorIconsRegular.crown;
    return PhosphorIconsRegular.lightning;
  }

  String? _raceDisplayValue(BuildContext context) {
    if (character.race?.isNotEmpty == true) {
      return CharacterLocalizationMapper.getRaceLabel(
          character.race!, AppLocalizations.of(context)!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var hakiList = character.haki;
    if (character.isCustomCharacter && hakiList != null) {
      hakiList =
          CharacterLocalizationMapper.mapHakiListToLocalized(hakiList, l10n);
    }

    final hasHaki = hakiList != null && hakiList.isNotEmpty;
    final raceVal = _raceDisplayValue(context);
    final theme = Theme.of(context);

    final hasRow2 = character.calculatedAge != null ||
        character.signo != null ||
        raceVal != null;

    final hasRow3 = (character.crew != null && character.crew!.isNotEmpty) ||
        character.devilFruit != null ||
        character.birthDate != null;

    if (!hasHaki && !hasRow2 && !hasRow3) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.margin * 2, vertical: Constants.margin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasHaki) ...[
                  Padding(
                    padding: const EdgeInsets.all(Constants.margin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hakiList
                          .map((haki) => Expanded(
                                child: Center(
                                  child: StatisticItem(
                                    label: l10n.haki,
                                    value: haki.split(' (').first,
                                    icon: _hakiIcon(haki),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
                if (hasHaki && (hasRow2 || hasRow3))
                  Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                if (hasRow2) ...[
                  Padding(
                    padding: const EdgeInsets.all(Constants.margin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (character.calculatedAge != null)
                          Expanded(
                              child: Center(
                                  child: StatisticItem(
                                      label: l10n.age,
                                      value: character.calculatedAge!.toString(),
                                      icon: PhosphorIconsRegular.cake))),
                        if (character.signo != null)
                          Expanded(
                              child: Center(
                                  child: StatisticItem(
                            label: l10n.signo,
                            value: ZodiacIcons.getLocalizedZodiacSign(
                                context, character.signo!),
                            svgPath:
                                ZodiacIcons.getZodiacIconPath(character.signo),
                            icon: ZodiacIcons.getZodiacIconPath(
                                        character.signo) ==
                                    null
                                ? PhosphorIconsRegular.star
                                : null,
                          ))),
                        if (raceVal != null)
                          Expanded(
                              child: Center(
                                  child: StatisticItem(
                                      label: l10n.race,
                                      value: raceVal,
                                      icon: PhosphorIconsRegular.users))),
                      ],
                    ),
                  ),
                ],
                if (hasRow2 && hasRow3)
                  Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                if (hasRow3) ...[
                  Padding(
                    padding: const EdgeInsets.all(Constants.margin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                if (character.devilFruit != null &&
                            character.devilFruit!.isNotEmpty)
                          Expanded(
                              child: Center(
                                  child: StatisticItem(
                                      label: 'Akuma no Mi',
                                      value: character.devilFruit!,
                                      icon: PhosphorIconsRegular.plant))),
                        if (character.crew != null && character.crew!.isNotEmpty)
                          Expanded(
                              child: Center(
                                  child: StatisticItem(
                                      label: l10n.crew(0),
                                      value: character.crew!,
                                      icon: PhosphorIconsRegular.sailboat))),
                        if (character.birthDate != null)
                          Expanded(
                              child: Center(
                                  child: StatisticItem(
                            label: l10n.birthDate,
                            value:
                                '${character.birthDate!.day.toString().padLeft(2, '0')}/${character.birthDate!.month.toString().padLeft(2, '0')}/${character.birthDate!.year}',
                            icon: PhosphorIconsRegular.calendar,
                          ))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
