import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/fighting_style_model.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';

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
                Icon(
                  Icons.sports_kabaddi,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  'Estilo de Luta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            
            // Nome do estilo (se existir)
            if (fightingStyle!.name != null && fightingStyle!.name!.isNotEmpty) ...[
              _buildDetailRow(context, 'Nome do Estilo', fightingStyle!.name!),
              const SizedBox(height: Constants.margin),
            ],
            
            // Tipo do estilo
            _buildDetailRow(context, 'Tipo de Luta', CharacterLocalizationMapper.getFightingTypeLabel(fightingStyle!.type, l10n)),
            
            // Armas (se existirem)
            if (fightingStyle!.weapons != null && fightingStyle!.weapons!.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              _buildDetailRow(context, 'Armas', fightingStyle!.weapons!.join(', ')),
            ],
            
            // Ataques (se existirem)
            if (fightingStyle!.attacks != null && fightingStyle!.attacks!.isNotEmpty) ...[
              const SizedBox(height: Constants.margin),
              _buildDetailRow(context, 'Ataques', fightingStyle!.attacks!.join(', ')),
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
} 