import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';

class CrewHeader extends StatelessWidget {
  final CrewModel crew;
  final VoidCallback? onEdit;

  const CrewHeader({
    super.key,
    required this.crew,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      spacing: Constants.margin,
      children: [
        if (crew.jollyRogerUrl != null && crew.jollyRogerUrl!.isNotEmpty)
          ClickableImage(
            imageUrl: crew.jollyRogerUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(Constants.margin * 2),
            title: crew.name,
            showTitleInDialog: true,
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getBackgroundImageProvider(),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              ),
              borderRadius: BorderRadius.circular(Constants.margin * 2),
            ),
          ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.primaryContainer.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(Constants.margin * 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Constants.margin * 2),
            child: Column(
              spacing: Constants.margin * 2,
              children: [
                if (crew.description != null &&
                    crew.description!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Constants.margin),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(Constants.margin),
                    ),
                    child: Text(
                      crew.description!,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (crew.boatName != null)
                            _buildInfoRow(
                              context,
                              PhosphorIconsRegular.boat,
                              '${l10n.crewBoatName}: ${crew.boatName}',
                            ),
                          if (crew.captain != null)
                            _buildInfoRow(
                              context,
                              PhosphorIconsRegular.user,
                              '${l10n.captain}: ${crew.captain}',
                            ),
                          if (crew.viceCaptain != null)
                            _buildInfoRow(
                              context,
                              PhosphorIconsRegular.user,
                              '${l10n.viceCaptain}: ${crew.viceCaptain}',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _getBackgroundImageProvider() {
    if (crew.jollyRogerUrl != null && crew.jollyRogerUrl!.isNotEmpty) {
      return NetworkImage(crew.jollyRogerUrl!);
    } else if (crew.boatImageUrl != null && crew.boatImageUrl!.isNotEmpty) {
      return NetworkImage(crew.boatImageUrl!);
    } else {
      return const AssetImage('assets/logo/splash_logo.png');
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.margin / 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: Constants.margin),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
