import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/custom_character_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';

class DuelArena extends StatelessWidget {
  final CustomCharacterModel firstCharacter;
  final CustomCharacterModel secondCharacter;
  final bool isDuelInProgress;
  final CustomCharacterModel? winner;
  final VoidCallback onStartDuel;
  final bool canStartDuel;

  const DuelArena({
    super.key,
    required this.firstCharacter,
    required this.secondCharacter,
    required this.isDuelInProgress,
    this.winner,
    required this.onStartDuel,
    required this.canStartDuel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Constants.margin * 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(Constants.margin * 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        spacing: Constants.margin * 2,
        children: [
          Text(
            l10n.versus,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              fontSize: 48,
              shadows: [
                Shadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First character
              Expanded(
                child: _buildCharacterArenaDisplay(
                  context,
                  firstCharacter,
                  isLeft: true,
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: Constants.margin * 2),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.red[100]!.withValues(alpha: 0.5),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: AppIcon(
                  PhosphorIconsRegular.lightning,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 40,
                ),
              ),

              Expanded(
                child: _buildCharacterArenaDisplay(
                  context,
                  secondCharacter,
                  isLeft: false,
                ),
              ),
            ],
          ),
          if (isDuelInProgress)
            _buildDuelProgress(context)
          else if (winner != null)
            _buildWinnerDisplay(context)
          else
            _buildDuelControls(context),
        ],
      ),
    );
  }

  Widget _buildCharacterArenaDisplay(
      BuildContext context, CustomCharacterModel character,
      {required bool isLeft}) {
    final theme = Theme.of(context);
    final isWinner = winner?.id == character.id;

    return Column(
      spacing: Constants.margin,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isWinner
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.7),
              width: isWinner ? 4 : 2,
            ),
            boxShadow: isWinner
                ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: ClickableImage(
              imageUrl: character.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              enableClick: false,
            ),
          ),
        ),
        Text(
          character.name,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isWinner
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            shadows: isWinner
                ? [
                    Shadow(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.8),
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          textAlign: TextAlign.center,
        ),
        if (isWinner) ...[
          const SizedBox(height: Constants.margin * 0.5),
          AppIcon(
            PhosphorIconsRegular.trophy,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            size: 24,
          ),
        ],
      ],
    );
  }

  Widget _buildDuelProgress(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      spacing: Constants.margin,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.tertiary),
          strokeWidth: 3,
        ),
        Text(
          l10n.duelInProgress,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          '⚔️ ⚡ 💥',
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.margin * 2,
            vertical: Constants.margin,
          ),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Constants.margin * 2),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${winner!.name} ${l10n.winner}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Constants.margin),
        const Text(
          '🪙 🏴‍☠️ 👑 🏴‍☠️ 🪙',
          style: TextStyle(
            fontSize: 32,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildDuelControls(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      spacing: Constants.margin,
      children: [
        _buildStatsComparison(context),
        ElevatedButton.icon(
          onPressed: canStartDuel ? onStartDuel : null,
          icon: const AppIcon(PhosphorIconsRegular.personSimpleWalk, size: 24),
          label: Text(
            l10n.startDuel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: canStartDuel
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.margin * 3,
              vertical: Constants.margin * 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.margin * 2),
            ),
            elevation: canStartDuel ? 8 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsComparison(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.margin),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.characterStats,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Constants.margin),
          _buildStatRow(
            context,
            l10n.bounty,
            firstCharacter.bounty.isNotEmpty
                ? Constants.formatBounty(firstCharacter.bounty)
                : l10n.unknown,
            secondCharacter.bounty.isNotEmpty
                ? Constants.formatBounty(secondCharacter.bounty)
                : l10n.unknown,
          ),
          _buildStatRow(
            context,
            l10n.haki,
            '${firstCharacter.haki?.length ?? 0} ${l10n.hakiType(firstCharacter.haki?.length ?? 0)}',
            '${secondCharacter.haki?.length ?? 0} ${l10n.hakiType(secondCharacter.haki?.length ?? 0)}',
          ),
          _buildStatRow(
            context,
            l10n.devilFruit,
            firstCharacter.devilFruit?.isNotEmpty == true
                ? firstCharacter.devilFruit!
                : l10n.noDevilFruit,
            secondCharacter.devilFruit?.isNotEmpty == true
                ? secondCharacter.devilFruit!
                : l10n.noDevilFruit,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String firstValue,
    String secondValue,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Constants.margin * 0.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              firstValue,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Second character stat
          Expanded(
            child: Text(
              secondValue,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
