import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';

class DuelResult extends StatelessWidget {
  final CustomCharacterModel winner;
  final VoidCallback onNewDuel;

  const DuelResult({super.key, required this.winner, required this.onNewDuel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Constants.margin * 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            AppColors.orange[1000]!.withValues(alpha: 0.3),
            AppColors.orange[700]!.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            AppColors.orange[700]!.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(Constants.margin * 3),
        border: Border.all(color: AppColors.orange[700]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange[1000]!.withValues(alpha: 0.5),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Victory title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                PhosphorIconsRegular.trophy,
                color: AppColors.orange[700],
                size: 40,
              ),
              const SizedBox(width: Constants.margin),
              Text(
                l10n.winner,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  shadows: [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                      offset: const Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Constants.margin),
              AppIcon(
                PhosphorIconsRegular.trophy,
                color: AppColors.orange[700],
                size: 40,
              ),
            ],
          ),

          const SizedBox(height: Constants.margin * 2),

          Container(
            padding: const EdgeInsets.all(Constants.margin * 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Constants.margin * 2),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Winner image
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiary.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: ClickableImage(
                      imageUrl: winner.image,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      enableClick: false,
                    ),
                  ),
                ),

                const SizedBox(height: Constants.margin * 1.5),

                // Winner name
                Text(
                  winner.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                if (winner.nickname != null) ...[
                  const SizedBox(height: Constants.margin * 0.5),
                  Text(
                    '"${winner.nickname}"',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: Constants.margin * 2),

          const Text(
            '🎉 🎊 ⭐ 🎊 🎉',
            style: TextStyle(fontSize: 32, letterSpacing: 8),
          ),

          const SizedBox(height: Constants.margin * 2),

          Container(
            padding: const EdgeInsets.all(Constants.margin * 1.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Constants.margin * 1.5),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getVictoryMessage(context),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: Constants.margin * 3),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.characterDetails,
                    arguments: winner,
                  );
                },
                icon: const AppIcon(PhosphorIconsRegular.info, size: 20),
                label: Text(l10n.statistics),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue[500],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.margin * 2,
                    vertical: Constants.margin,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.margin * 1.5),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onNewDuel,
                icon: const AppIcon(
                  PhosphorIconsRegular.arrowsClockwise,
                  size: 20,
                ),
                label: Text(l10n.newDuel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green[500],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.margin * 2,
                    vertical: Constants.margin,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.margin * 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getVictoryMessage(BuildContext context) {
    final messages = [
      "Uma vitória esmagadora! ${winner.name} mostrou sua força verdadeira!",
      "Incrível! ${winner.name} dominou completamente este duelo!",
      "${winner.name} provou ser um verdadeiro guerreiro dos mares!",
      "Que batalha épica! ${winner.name} emergiu como o vencedor!",
      "O poder de ${winner.name} foi decisivo nesta luta!",
    ];

    final messageIndex = (winner.id?.hashCode ?? 0).abs() % messages.length;
    return messages[messageIndex];
  }
}
