import 'package:flutter/material.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';

class CharacterRaceSection extends StatelessWidget {
  final String? selectedRace;
  final void Function(String?) onRaceChanged;

  const CharacterRaceSection({
    Key? key,
    this.selectedRace,
    required this.onRaceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Constants.margin * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: Constants.margin),
                Text(
                  'Raça',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.margin * 2),
            
            DropdownButtonFormField<String>(
              value: selectedRace,
              decoration: const InputDecoration(
                labelText: 'Selecione a Raça',
                border: OutlineInputBorder(),
              ),
              items: CharacterLocalizationMapper.getRaces().map((race) {
                return DropdownMenuItem(
                  value: race,
                  child: Text(
                    CharacterLocalizationMapper.getRaceLabel(race, l10n),
                  ),
                );
              }).toList(),
              onChanged: onRaceChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Raça é obrigatória';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
} 