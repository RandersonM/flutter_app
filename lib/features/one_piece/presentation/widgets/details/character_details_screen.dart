import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_bounty.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_name.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';
import 'package:opfan/shared/widgets/atoms/fighting_style_details.dart';
import 'package:opfan/shared/widgets/molecules/statistic_item.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/zodiac_icons.dart';

class CharacterDetailsScreen extends StatelessWidget {
  const CharacterDetailsScreen({
    Key? key,
    required this.character,
  }) : super(key: key);

  final CustomCharacterModel character;

  Widget _buildCompactTagsSection(BuildContext context, AppLocalizations l10n) {
    List<String> affiliations = character.affiliations;
    List<String> occupations = character.occupation;

    if (character.isCustomCharacter) {
      affiliations = CharacterLocalizationMapper.mapAffiliationsToLocalized(
          affiliations, l10n);
      occupations = CharacterLocalizationMapper.mapOccupationsToLocalized(
          occupations, l10n);
    }

    if (affiliations.isEmpty && occupations.isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.margin * 2, vertical: Constants.margin),
      child: Container(
        padding: const EdgeInsets.all(Constants.margin * 1.5),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHigh
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (affiliations.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(PhosphorIconsRegular.users,
                      size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: affiliations
                          .map((v) => _buildSmallTag(context, v))
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
                  AppIcon(PhosphorIconsRegular.briefcase,
                      size: 16, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: occupations
                          .map((v) => _buildSmallTag(context, v))
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

  Widget _buildSmallTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.4),
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

  Widget _buildCombinedStatisticsCard(
      BuildContext context, AppLocalizations l10n) {
    List<String>? hakiList = character.haki;
    if (character.isCustomCharacter && hakiList != null) {
      hakiList =
          CharacterLocalizationMapper.mapHakiListToLocalized(hakiList, l10n);
    }

    final hasHaki = hakiList != null && hakiList.isNotEmpty;
    final raceVal = _getRaceDisplayValue(context);

    // Check if row 2 has items
    final hasRow2 = character.calculatedAge != null ||
        character.devilFruit != null ||
        character.signo != null ||
        raceVal != null;

    // Check if row 3 has items
    final hasRow3 = (character.crew != null && character.crew!.isNotEmpty) ||
        character.birthDate != null;

    if (!hasHaki && !hasRow2 && !hasRow3) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.margin * 2, vertical: Constants.margin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
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
                                    icon: PhosphorIconsRegular.lightning,
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
                                      value:
                                          character.calculatedAge!.toString(),
                                      icon: PhosphorIconsRegular.cake))),
                        if (character.devilFruit != null &&
                            character.devilFruit!.isNotEmpty)
                          Expanded(
                              child: Center(
                                  child: StatisticItem(
                                      label: 'Akuma no Mi',
                                      value: character.devilFruit!,
                                      icon: PhosphorIconsRegular.plant))),
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
                        if (character.crew != null &&
                            character.crew!.isNotEmpty)
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

  Map<String, dynamic> _getStatusTheme(String? status, AppLocalizations l10n) {
    final statusLower = status?.toLowerCase() ?? '';

    if (statusLower.contains('captured') ||
        statusLower.contains('imprisoned')) {
      return {
        'backgroundColor': Colors.grey,
        'textColor': Colors.white,
        'icon': PhosphorIconsRegular.lock,
        'displayText': l10n.captured,
      };
    }

    if (statusLower.contains('deceased')) {
      return {
        'backgroundColor': Colors.red,
        'textColor': Colors.white,
        'icon': PhosphorIconsRegular.skull,
        'displayText': l10n.dead,
      };
    }

    if (statusLower.contains('living') || statusLower.contains('live')) {
      return {
        'backgroundColor': Colors.green[500],
        'textColor': Colors.white,
        'icon': PhosphorIconsRegular.wind,
        'displayText': l10n.alive,
      };
    }

    return {
      'backgroundColor': Colors.grey.withValues(alpha: 0.6),
      'textColor': Colors.white,
      'icon': PhosphorIconsRegular.question,
      'displayText': l10n.unknown,
    };
  }

  String? _getRaceDisplayValue(BuildContext context) {
    if (character.race?.isNotEmpty == true) {
      return CharacterLocalizationMapper.getRaceLabel(
          character.race!, AppLocalizations.of(context)!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusTheme = _getStatusTheme(character.status, l10n);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                character.nickname ?? character.name,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(1, 1))
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ClickableImage(
                    imageUrl: character.image,
                    width: double.infinity,
                    height: 450,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.zero,
                    showTitleInDialog: false,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          theme.colorScheme.surface,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusTheme['backgroundColor'],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusTheme['icon'],
                            size: 16,
                            color: statusTheme['textColor'],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusTheme['displayText'],
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: statusTheme['textColor'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Constants.margin * 2,
                      vertical: Constants.margin),
                  child: DetailsName(
                    name: character.name,
                    nickname: character.nickname,
                  ),
                ),
                DetailsBounty(bounty: character.bounty),
                _buildCompactTagsSection(context, l10n),
                _buildCombinedStatisticsCard(context, l10n),
                if (character.fightingStyle != null) ...[
                  FightingStyleDetails(fightingStyle: character.fightingStyle),
                ],
                if (character.description != null &&
                    character.description!.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: Constants.margin * 2,
                        vertical: Constants.margin),
                    child: Padding(
                      padding: const EdgeInsets.all(Constants.margin * 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: Constants.margin,
                            children: [
                              const AppIcon(PhosphorIconsRegular.fileText,
                                  size: 20),
                              Text(
                                l10n.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(character.description!),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
