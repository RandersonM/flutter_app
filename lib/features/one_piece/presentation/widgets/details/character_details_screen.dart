// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_bounty.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_compact_tags.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_name.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_statistics_card.dart';
import 'package:opfan/features/one_piece/presentation/widgets/details/fields/details_status_badge.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';
import 'package:opfan/shared/widgets/atoms/fighting_style_details.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CharacterDetailsScreen extends StatelessWidget {
  const CharacterDetailsScreen({
    super.key,
    required this.character,
  });

  final CustomCharacterModel character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                    child: DetailsStatusBadge(status: character.status),
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
                DetailsCompactTags(character: character, l10n: l10n),
                DetailsStatisticsCard(character: character, l10n: l10n),
                if (character.fightingStyle != null)
                  FightingStyleDetails(fightingStyle: character.fightingStyle),
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
                                style: theme.textTheme.titleMedium?.copyWith(
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
