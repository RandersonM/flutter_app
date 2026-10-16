import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:intl/intl.dart';

class CrewInfoSection extends StatelessWidget {
  final CrewModel crew;

  const CrewInfoSection({super.key, required this.crew});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.info,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  l10n.crewInfoTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            _buildInfoRow(
              context,
              PhosphorIconsRegular.calendarBlank,
              l10n.crewInfoCreatedAt,
              crew.createdAt != null
                  ? dateFormat.format(crew.createdAt!)
                  : l10n.crewInfoDateUnavailable,
            ),
            if (crew.updatedAt != null) ...[
              const SizedBox(height: Constants.margin),
              _buildInfoRow(
                context,
                PhosphorIconsRegular.clockCounterClockwise,
                l10n.crewInfoUpdatedAt,
                dateFormat.format(crew.updatedAt!),
              ),
            ],
            if (crew.rolesFilled.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              _buildInfoRow(
                context,
                PhosphorIconsRegular.briefcase,
                l10n.crewInfoRolesFilled,
                crew.rolesFilled
                    .map(
                      (role) =>
                          CharacterLocalizationMapper.mapOccupationToLocalized(
                            role,
                            l10n,
                          ),
                    )
                    .join(', '),
              ),
            ],
            const SizedBox(height: Constants.margin),
            _buildInfoRow(
              context,
              PhosphorIconsRegular.user,
              l10n.crewInfoOwner,
              crew.userId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: Constants.margin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: Constants.margin / 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
