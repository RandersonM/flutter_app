import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:intl/intl.dart';

class CrewInfoSection extends StatelessWidget {
  final CrewModel crew;

  const CrewInfoSection({super.key, required this.crew});

  @override
  Widget build(BuildContext context) {
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
                  'Informações',
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
              'Criada em',
              crew.createdAt != null
                  ? dateFormat.format(crew.createdAt!)
                  : 'Data não disponível',
            ),
            if (crew.updatedAt != null) ...[
              const SizedBox(height: Constants.margin),
              _buildInfoRow(
                context,
                PhosphorIconsRegular.clockCounterClockwise,
                'Atualizada em',
                dateFormat.format(crew.updatedAt!),
              ),
            ],
            if (crew.rolesFilled.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              _buildInfoRow(
                context,
                PhosphorIconsRegular.briefcase,
                'Funções preenchidas',
                crew.rolesFilled.join(', '),
              ),
            ],
            const SizedBox(height: Constants.margin),
            _buildInfoRow(
              context,
              PhosphorIconsRegular.user,
              'Proprietário',
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
                  color: Colors.grey[600],
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
