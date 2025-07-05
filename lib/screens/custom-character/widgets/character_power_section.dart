import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/one_piece/devil_fruit.dart';
import '../../../widgets/atoms/custom_dropdown.dart';
import '../../../widgets/atoms/custom_chip_selector.dart';

class CharacterPowerSection extends StatelessWidget {
  final List<DevilFruit> devilFruits;
  final DevilFruit? selectedDevilFruit;
  final void Function(DevilFruit?) onDevilFruitChanged;
  final List<String> selectedHaki;
  final void Function(String) onHakiSelected;
  final void Function(String) onHakiDeselected;

  const CharacterPowerSection({
    Key? key,
    required this.devilFruits,
    required this.selectedDevilFruit,
    required this.onDevilFruitChanged,
    required this.selectedHaki,
    required this.onHakiSelected,
    required this.onHakiDeselected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final hakiOptions = [
      l10n.haoshokuHaki,
      l10n.busoshokuHaki,
      l10n.kenbunshokuHaki,
    ];

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
        CustomDropdown<DevilFruit>(
          label: l10n.devilFruit,
          value: selectedDevilFruit,
          items:
              devilFruits.where((fruit) => fruit.romanName.isNotEmpty).toList(),
          itemToString: (fruit) => fruit.romanName,
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