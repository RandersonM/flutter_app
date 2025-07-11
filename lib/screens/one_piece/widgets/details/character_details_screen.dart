// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_bounty.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_image.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_name.dart';
import 'package:opfan/widgets/atoms/fighting_style_details.dart'
    show FightingStyleDetails;
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/zodiac_icons.dart';

class CharacterDetailsScreen extends StatelessWidget {
  const CharacterDetailsScreen({
    Key? key,
    required this.character,
  }) : super(key: key);

  final CustomCharacterModel character;

  Widget _buildInfoTile({
    required Widget leading,
    required String label,
    required String? value,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: leading,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _buildChipSection({
    required String label,
    required List<String> values,
    IconData? icon,
    required BuildContext context,
  }) {
    if (values.isEmpty) return const SizedBox.shrink();
    
    final l10n = AppLocalizations.of(context)!;

    List<String> displayValues = values;
    if (character.isCustomCharacter) {
      if (label == l10n.affiliations) {
        displayValues =
            CharacterLocalizationMapper.mapAffiliationsToLocalized(
            values, l10n);
      } else if (label == l10n.occupations) {
        displayValues =
            CharacterLocalizationMapper.mapOccupationsToLocalized(values, l10n);
      } else if (label == l10n.haki) {
        displayValues =
            CharacterLocalizationMapper.mapHakiListToLocalized(values, l10n);
      }
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Constants.margin * 2, vertical: Constants.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, size: 20),
              if (icon != null) const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: displayValues.map((v) => Chip(label: Text(v))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacIcon(String? zodiacSign) {
    final iconPath = ZodiacIcons.getZodiacIconPath(zodiacSign);
    if (iconPath != null) {
      return SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      );
    }
    return const Icon(Icons.star, color: Colors.grey);
  }

  Map<String, dynamic> _getStatusTheme(String? status, AppLocalizations l10n) {
    final statusLower = status?.toLowerCase() ?? '';

    if (statusLower.contains('captured') ||
        statusLower.contains('imprisoned')) {
      return {
        'backgroundColor': Colors.grey,
        'textColor': Colors.white,
        'icon': Icons.lock,
        'displayText': l10n.captured,
      };
    }

    if (statusLower.contains('deceased')) {
      return {
        'backgroundColor': Colors.red,
        'textColor': Colors.white,
        'icon': FontAwesomeIcons.skullCrossbones,
        'displayText': l10n.dead,
      };
    }

    if (statusLower.contains('living') || statusLower.contains('live')) {
      return {
        'backgroundColor': Colors.green[500],
        'textColor': Colors.white,
        'icon': FontAwesomeIcons.wind,
        'displayText': l10n.alive,
      };
    }

    return {
      'backgroundColor': Colors.grey.withValues(alpha: 0.6),
      'textColor': Colors.white,
      'icon': Icons.question_mark,
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
      appBar: DefaultAppBar(
        title: Text(character.nickname ?? character.name),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              DetailsImage(image: character.image),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusTheme['backgroundColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusTheme['icon'],
                        size: 16,
                        color: statusTheme['textColor'],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusTheme['displayText'],
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(color: statusTheme['textColor']),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Constants.margin * 2, vertical: Constants.margin),
            child: DetailsName(
              name: character.name,
              nickname: character.nickname,
              devilFruit: character.devilFruit,
            ),
          ),
          DetailsBounty(bounty: character.bounty),
          _buildChipSection(
              label: l10n.affiliations,
              values: character.affiliations,
              icon: Icons.groups,
              context: context),
          _buildChipSection(
              label: l10n.occupations,
              values: character.occupation,
              icon: Icons.work,
              context: context),
          _buildChipSection(
              label: l10n.haki,
              values: character.haki ?? [],
              icon: Icons.flash_on,
              context: context),
          Card(
            margin: const EdgeInsets.symmetric(
                horizontal: Constants.margin * 2, vertical: Constants.margin),
            child: Column(
              children: [
                _buildInfoTile(
                  leading: const Icon(Icons.people),
                  label: l10n.race,
                  value: _getRaceDisplayValue(context),
                ),
                _buildInfoTile(
                  leading: _buildZodiacIcon(character.signo),
                  label: l10n.signo,
                  value: character.signo != null
                      ? ZodiacIcons.getLocalizedZodiacSign(
                          context, character.signo!)
                      : null,
                ),
                _buildInfoTile(
                  leading: const Icon(Icons.cake),
                  label: l10n.age,
                  value: character.calculatedAge?.toString(),
                ),
                _buildInfoTile(
                  leading: const Icon(Icons.sailing),
                  label: l10n.crew(0),
                  value: character.crew,
                ),
                _buildInfoTile(
                  leading: const Icon(Icons.info),
                  label: l10n.status,
                  value: character.status != null
                      ? CharacterLocalizationMapper.mapStatusToLocalized(
                          character.status, l10n)
                      : character.status,
                ),
                _buildInfoTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  label: l10n.birthDate,
                  value: character.birthDate != null
                      ? '${character.birthDate!.day.toString().padLeft(2, '0')}/${character.birthDate!.month.toString().padLeft(2, '0')}/${character.birthDate!.year}'
                      : null,
                ),
              ],
            ),
          ),
          if (character.fightingStyle != null) ...[
            FightingStyleDetails(fightingStyle: character.fightingStyle),
          ],
          if (character.description != null &&
              character.description!.isNotEmpty)
            Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: Constants.margin * 2, vertical: Constants.margin),
              child: Padding(
                padding: const EdgeInsets.all(Constants.margin * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, size: 20),
                        SizedBox(width: 6),
                        Text('Descrição',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
      bottomNavigationBar:
          const BottomNavigation(BottomNavigationPages.onePiece),
    );
  }
}
