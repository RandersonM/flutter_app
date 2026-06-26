import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/one_piece/devil_fruit.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/shared/widgets/atoms/devil_fruit_search_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_chip_selector.dart';

class CharacterPowerSection extends StatelessWidget {
  final List<DevilFruit> devilFruits;
  final DevilFruit? selectedDevilFruit;
  final void Function(DevilFruit?) onDevilFruitChanged;
  final List<String> selectedHaki;
  final void Function(String) onHakiSelected;
  final void Function(String) onHakiDeselected;

  const CharacterPowerSection({
    super.key,
    required this.devilFruits,
    required this.selectedDevilFruit,
    required this.onDevilFruitChanged,
    required this.selectedHaki,
    required this.onHakiSelected,
    required this.onHakiDeselected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hakiOptions =
        CharacterLocalizationMapper.getLocalizedHakiOptions(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.powers,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        DevilFruitSearchDropdown(
          label: l10n.devilFruit,
          value: selectedDevilFruit,
          items:
              devilFruits.where((fruit) => fruit.romanName.isNotEmpty).toList(),
          onChanged: onDevilFruitChanged,
        ),
        CustomChipSelector(
          label: l10n.hakiTypes,
          options: hakiOptions,
          selectedOptions: selectedHaki,
          onOptionSelected: onHakiSelected,
          onOptionDeselected: onHakiDeselected,
        ),
      ],
    );
  }
}
