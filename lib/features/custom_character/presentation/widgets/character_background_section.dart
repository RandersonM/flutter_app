import 'package:flutter/material.dart';
import 'package:opfan/core/utils/character_localization_mapper.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_chip_selector.dart';
import 'package:opfan/shared/widgets/molecules/ai_image_generator.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';

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
  final String? race;
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
    this.race,
    this.haki,
    this.showAiGenerator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final statusOptions =
        CharacterLocalizationMapper.getLocalizedStatusOptions(l10n);
    final affiliationOptions =
        CharacterLocalizationMapper.getLocalizedAffiliationOptions(l10n);
    final occupationOptions =
        CharacterLocalizationMapper.getLocalizedOccupationOptions(l10n);

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
                ? CharacterLocalizationMapper.mapOccupationToLocalized(
                    selectedCrewRole!, l10n)
                : null,
            items: occupationOptions,
            itemToString: (role) => role,
            onChanged: (translatedRole) {
              if (translatedRole == null) return;
              final key = CharacterLocalizationMapper.mapLocalizedToOccupation(
                  translatedRole, l10n);
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
            race: race!,
            characterName: characterName,
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
        if (imageUrlController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          ClickableImage(
            imageUrl: imageUrlController.text,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
            showTitleInDialog: false,
          ),
        ],
        CustomTextField(
          label: l10n.imageUrl,
          hint: l10n.imageUrlHint,
          controller: imageUrlController,
        ),
        CustomDropdown<String>(
          label: l10n.status,
          value: selectedStatus != null
              ? CharacterLocalizationMapper.mapStatusToLocalized(
                  selectedStatus, l10n)
              : null,
          items: statusOptions,
          itemToString: (status) => status,
          onChanged: (translatedStatus) {
            if (translatedStatus == null) return;
            final key = CharacterLocalizationMapper.mapLocalizedToStatus(
                translatedStatus, l10n);
            onStatusChanged(key);
          },
        ),
        CustomChipSelector(
          label: l10n.occupations,
          options: occupationOptions,
          selectedOptions: selectedOccupations
              .map((key) =>
                  CharacterLocalizationMapper.mapOccupationToLocalized(
                      key, l10n))
              .toList(),
          onOptionSelected: (translatedOccupation) {
            final key = CharacterLocalizationMapper.mapLocalizedToOccupation(
                translatedOccupation, l10n);
            onOccupationSelected(key);
          },
          onOptionDeselected: (translatedOccupation) {
            final key = CharacterLocalizationMapper.mapLocalizedToOccupation(
                translatedOccupation, l10n);
            onOccupationDeselected(key);
          },
          maxSelections: 3,
        ),
        CustomChipSelector(
          label: l10n.affiliations,
          options: affiliationOptions,
          selectedOptions: selectedAffiliations
              .map((key) =>
                  CharacterLocalizationMapper.mapAffiliationToLocalized(
                      key, l10n))
              .toList(),
          onOptionSelected: (translatedAffiliation) {
            final key = CharacterLocalizationMapper.mapLocalizedToAffiliation(
                translatedAffiliation, l10n);
            onAffiliationSelected(key);
          },
          onOptionDeselected: (translatedAffiliation) {
            final key = CharacterLocalizationMapper.mapLocalizedToAffiliation(
                translatedAffiliation, l10n);
            onAffiliationDeselected(key);
          },
        ),
      ],
    );
  }
}
