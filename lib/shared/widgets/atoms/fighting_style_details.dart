import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/features/duels/data/models/fighting_style_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class FightingStyleDetails extends StatelessWidget {
  final FightingStyleModel? fightingStyle;

  const FightingStyleDetails({super.key, this.fightingStyle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (fightingStyle == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.margin * 2,
        vertical: Constants.margin,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.handFist,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  l10n.fightingStyleSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 1.5),
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: Constants.margin * 1.5),

            // Info chips row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (fightingStyle!.name != null &&
                    fightingStyle!.name!.isNotEmpty)
                  _InfoChip(
                    icon: PhosphorIconsRegular.tag,
                    label: l10n.fightingStyleNameLabel,
                    value: fightingStyle!.name!,
                  ),
                _InfoChip(
                  icon: PhosphorIconsRegular.handFist,
                  label: l10n.fightingStyleTypeLabel,
                  value: CharacterLocalizationMapper.getFightingTypeLabel(
                    fightingStyle!.type,
                    l10n,
                  ),
                ),
                if (fightingStyle!.weapons != null &&
                    fightingStyle!.weapons!.isNotEmpty)
                  _InfoChip(
                    icon: PhosphorIconsRegular.sword,
                    label: l10n.fightingStyleWeaponsLabel,
                    value: fightingStyle!.weapons!.join(', '),
                  ),
              ],
            ),

            // Attacks
            if (fightingStyle!.attacks != null &&
                fightingStyle!.attacks!.isNotEmpty) ...[
              const SizedBox(height: Constants.margin * 2),
              Row(
                children: [
                  AppIcon(
                    PhosphorIconsRegular.lightning,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.fightingStyleAttacksLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.margin),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fightingStyle!.attacks!
                    .map((attack) => _AttackChip(name: attack))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              value,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttackChip extends StatelessWidget {
  const _AttackChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
