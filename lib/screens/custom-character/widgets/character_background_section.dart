import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../widgets/atoms/custom_dropdown.dart';
import '../../../widgets/atoms/custom_chip_selector.dart';

class CharacterBackgroundSection extends StatelessWidget {
  final TextEditingController crewController;
  final TextEditingController bountyController;
  final TextEditingController imageUrlController;
  final String? selectedStatus;
  final void Function(String?) onStatusChanged;
  final List<String> selectedOccupations;
  final void Function(String) onOccupationSelected;
  final void Function(String) onOccupationDeselected;
  final List<String> selectedAffiliations;
  final void Function(String) onAffiliationSelected;
  final void Function(String) onAffiliationDeselected;

  const CharacterBackgroundSection({
    Key? key,
    required this.crewController,
    required this.bountyController,
    required this.imageUrlController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedOccupations,
    required this.onOccupationSelected,
    required this.onOccupationDeselected,
    required this.selectedAffiliations,
    required this.onAffiliationSelected,
    required this.onAffiliationDeselected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final statusOptions = [l10n.alive, l10n.dead, l10n.unknown];
    final affiliationOptions = [
      l10n.marines,
      l10n.revolutionaries,
      l10n.yonkou,
      l10n.shichibukai,
      l10n.independent,
      l10n.pirate,
    ];
    final occupationOptions = [
      l10n.captain,
      l10n.admiral,
      l10n.viceAdmiral,
      l10n.revolutionary,
      l10n.merchant,
      l10n.doctor,
      l10n.navigator,
      l10n.cook,
      l10n.sniper,
      l10n.swordsman,
      l10n.carpenter,
      l10n.archaeologist,
      l10n.sharpshooter,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.background,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.crew,
          hint: l10n.crewHint,
          controller: crewController,
        ),
        CurrencyTextField(
          label: '${l10n.bounty} *',
          hint: l10n.bountyHint,
          controller: bountyController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.bountyRequired;
            }
            return null;
          },
        ),
        CustomTextField(
          label: l10n.imageUrl,
          hint: l10n.imageUrlHint,
          controller: imageUrlController,
        ),
        CustomDropdown<String>(
          label: l10n.status,
          value: selectedStatus,
          items: statusOptions,
          itemToString: (status) => status,
          onChanged: onStatusChanged,
        ),
        CustomChipSelector(
          label: l10n.occupations,
          options: occupationOptions,
          selectedOptions: selectedOccupations,
          onOptionSelected: onOccupationSelected,
          onOptionDeselected: onOccupationDeselected,
          maxSelections: 3,
        ),
        CustomChipSelector(
          label: l10n.affiliations,
          options: affiliationOptions,
          selectedOptions: selectedAffiliations,
          onOptionSelected: onAffiliationSelected,
          onOptionDeselected: onAffiliationDeselected,
        ),
      ],
    );
  }
} 