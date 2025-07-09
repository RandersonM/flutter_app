import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../widgets/atoms/custom_dropdown.dart';
import '../../../widgets/atoms/custom_chip_selector.dart';
import '../../../widgets/molecules/ai_image_generator.dart';

class CharacterBackgroundSection extends StatelessWidget {
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
  final List<CrewModel> availableCrews;
  final String? selectedCrewId;
  final void Function(String?) onCrewChanged;
  final String? selectedCrewRole;
  final void Function(String?) onCrewRoleChanged;
  final String? characterName;
  final String? devilFruit;
  final List<String>? haki;
  final bool showAiGenerator;

  const CharacterBackgroundSection({
    Key? key,
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
    required this.availableCrews,
    required this.selectedCrewId,
    required this.onCrewChanged,
    required this.selectedCrewRole,
    required this.onCrewRoleChanged,
    this.characterName,
    this.devilFruit,
    this.haki,
    this.showAiGenerator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final statusMapping = {
      'alive': l10n.alive,
      'dead': l10n.dead,
      'unknown': l10n.unknown,
    };

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
      'viceCaptain': l10n.viceCaptain,
      'navigator': l10n.navigator,
      'cook': l10n.cook,
      'doctor': l10n.doctor,
      'sniper': l10n.sniper,
      'carpenter': l10n.carpenter,
      'archaeologist': l10n.archaeologist,
      'musician': l10n.musician,
      'helmsman': l10n.helmsman,
      'boatswain': l10n.boatswain,
    };

    final crewRoleMapping = {
      'helmsman': l10n.helmsman,
      'captain': l10n.captain,
      'viceCaptain': l10n.viceCaptain,
      'navigator': l10n.navigator,
      'cook': l10n.cook,
      'doctor': l10n.doctor,
      'musician': l10n.musician,
      'carpenter': l10n.carpenter,
      'sharpshooter': l10n.sharpshooter,
      'archaeologist': l10n.archaeologist,
      'boatswain': l10n.boatswain,
    };

    final statusOptions = statusMapping.values.toList();
    final affiliationOptions = affiliationMapping.values.toList();
    final occupationOptions = occupationMapping.values.toList();
    final crewRoleOptions = crewRoleMapping.values.toList();

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
        CustomDropdown<String>(
          label: l10n.crew(0),
          value: selectedCrewId != null
              ? availableCrews
                  .firstWhere((crew) => crew.id == selectedCrewId,
                      orElse: () => CrewModel(name: '', userId: ''))
                  .name
              : null,
          items: availableCrews.map((crew) => crew.name).toList(),
          itemToString: (crewName) => crewName,
          onChanged: (crewName) {
            final selectedCrew = availableCrews.firstWhere(
              (crew) => crew.name == crewName,
              orElse: () => CrewModel(name: '', userId: ''),
            );
            onCrewChanged(
                selectedCrew.name.isNotEmpty ? selectedCrew.id : null);
          },
        ),
        if (selectedCrewId != null) ...[
          const SizedBox(height: 16),
          CustomDropdown<String>(
            label: l10n.crewRole,
            value: selectedCrewRole != null
                ? crewRoleMapping[selectedCrewRole!]
                : null,
            items: crewRoleOptions,
            itemToString: (role) => role,
            onChanged: (translatedRole) {
              final key = crewRoleMapping.entries
                  .firstWhere((entry) => entry.value == translatedRole)
                  .key;
              onCrewRoleChanged(key);
            },
          ),
        ],
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
        if (showAiGenerator) ...[
          const SizedBox(height: 16),
          AiImageGenerator(
            characterName: characterName,
            devilFruit: devilFruit,
            haki: haki,
            status: selectedStatus,
            occupations: selectedOccupations,
            currentImageUrl: imageUrlController.text,
            onImageGenerated: (imageUrl) {
              imageUrlController.text = imageUrl;
            },
          ),
          const SizedBox(height: 16),
        ],
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