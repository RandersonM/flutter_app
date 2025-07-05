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
    
    // Status mapping: English key -> Translated value
    final statusMapping = {
      'alive': l10n.alive,
      'dead': l10n.dead,
      'unknown': l10n.unknown,
    };

    // Affiliation mapping: English key -> Translated value
    final affiliationMapping = {
      'marines': l10n.marines,
      'revolutionaries': l10n.revolutionaries,
      'yonkou': l10n.yonkou,
      'shichibukai': l10n.shichibukai,
      'independent': l10n.independent,
      'pirate': l10n.pirate,
      'pirateAlliance': l10n.pirateAlliance,
    };

    final occupationMapping = {
      'captain': l10n.captain,
      'admiral': l10n.admiral,
      'viceAdmiral': l10n.viceAdmiral,
      'revolutionary': l10n.revolutionary,
      'merchant': l10n.merchant,
      'doctor': l10n.doctor,
      'navigator': l10n.navigator,
      'cook': l10n.cook,
      'sniper': l10n.sniper,
      'swordsman': l10n.swordsman,
      'carpenter': l10n.carpenter,
      'archaeologist': l10n.archaeologist,
      'sharpshooter': l10n.sharpshooter,
    };

    final statusOptions = statusMapping.values.toList();
    final affiliationOptions = affiliationMapping.values.toList();
    final occupationOptions = occupationMapping.values.toList();

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
          label: l10n.crew(0),
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
          value: selectedStatus != null ? statusMapping[selectedStatus!] : null,
          items: statusOptions,
          itemToString: (status) => status,
          onChanged: (translatedStatus) {
            final key = statusMapping.entries
                .firstWhere((entry) => entry.value == translatedStatus)
                .key;
            onStatusChanged(key);
          },
        ),
        CustomChipSelector(
          label: l10n.occupations,
          options: occupationOptions,
          selectedOptions: selectedOccupations
              .map((key) => occupationMapping[key] ?? key)
              .toList(),
          onOptionSelected: (translatedOccupation) {
            final key = occupationMapping.entries
                .firstWhere((entry) => entry.value == translatedOccupation)
                .key;
            onOccupationSelected(key);
          },
          onOptionDeselected: (translatedOccupation) {
            final key = occupationMapping.entries
                .firstWhere((entry) => entry.value == translatedOccupation)
                .key;
            onOccupationDeselected(key);
          },
          maxSelections: 3,
        ),
        CustomChipSelector(
          label: l10n.affiliations,
          options: affiliationOptions,
          selectedOptions: selectedAffiliations
              .map((key) => affiliationMapping[key] ?? key)
              .toList(),
          onOptionSelected: (translatedAffiliation) {
            final key = affiliationMapping.entries
                .firstWhere((entry) => entry.value == translatedAffiliation)
                .key;
            onAffiliationSelected(key);
          },
          onOptionDeselected: (translatedAffiliation) {
            final key = affiliationMapping.entries
                .firstWhere((entry) => entry.value == translatedAffiliation)
                .key;
            onAffiliationDeselected(key);
          },
        ),
      ],
    );
  }
} 