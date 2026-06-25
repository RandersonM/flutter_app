import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/fighting_style_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class FightingStyleDetails extends StatelessWidget {
  final FightingStyleModel? fightingStyle;

  const FightingStyleDetails({
    Key? key,
    this.fightingStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (fightingStyle == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: Constants.margin * 2, vertical: Constants.margin),
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.handFist,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  l10n.fightingStyleSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            if (fightingStyle!.name != null &&
                fightingStyle!.name!.isNotEmpty) ...[
              _buildDetailRow(
                  context, l10n.fightingStyleNameLabel, fightingStyle!.name!),
              const SizedBox(height: Constants.margin),
            ],
            _buildDetailRow(
                context,
                l10n.fightingStyleTypeLabel,
                CharacterLocalizationMapper.getFightingTypeLabel(
                    fightingStyle!.type, l10n)),
            if (fightingStyle!.weapons != null &&
                fightingStyle!.weapons!.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              _buildDetailRow(context, l10n.fightingStyleWeaponsLabel,
                  fightingStyle!.weapons!.join(', ')),
            ],
            if (fightingStyle!.attacks != null &&
                fightingStyle!.attacks!.isNotEmpty) ...[
              const SizedBox(height: Constants.margin * 2),
              Text(
                l10n.fightingStyleAttacksLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: Constants.margin),
              _buildAttacksGrid(context, fightingStyle!.attacks!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: Constants.margin),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildAttacksGrid(BuildContext context, List<String> attacks) {
    return Container(
      padding: const EdgeInsets.all(Constants.margin),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHigh
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: attacks.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                attacks[index],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
