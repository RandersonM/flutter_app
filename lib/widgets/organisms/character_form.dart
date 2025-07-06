import 'package:flutter/material.dart';
import 'package:opfan/core/models/one_piece/devil_fruit.dart';
import 'package:opfan/core/models/one_piece/crew_model.dart';
import 'package:opfan/utils/constants.dart';
import '../../screens/custom-character/widgets/character_basic_info_section.dart';
import '../../screens/custom-character/widgets/character_power_section.dart';
import '../../screens/custom-character/widgets/character_background_section.dart';
import '../../screens/custom-character/widgets/character_description_section.dart';

class CharacterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController nicknameController;
  final TextEditingController birthDateController;
  final List<DevilFruit> devilFruits;
  final DevilFruit? selectedDevilFruit;
  final void Function(DevilFruit?) onDevilFruitChanged;
  final TextEditingController bountyController;
  final TextEditingController imageUrlController;
  final TextEditingController descriptionController;
  final String? selectedStatus;
  final List<String> selectedHaki;
  final List<String> selectedAffiliations;
  final List<String> selectedOccupations;
  final void Function(String?) onStatusChanged;
  final void Function(String) onHakiSelected;
  final void Function(String) onHakiDeselected;
  final void Function(String) onAffiliationSelected;
  final void Function(String) onAffiliationDeselected;
  final void Function(String) onOccupationSelected;
  final void Function(String) onOccupationDeselected;
  final List<CrewModel> availableCrews;
  final String? selectedCrewId;
  final void Function(String?) onCrewChanged;
  final String? selectedCrewRole;
  final void Function(String?) onCrewRoleChanged;

  const CharacterForm({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.nicknameController,
    required this.birthDateController,
    required this.devilFruits,
    required this.selectedDevilFruit,
    required this.onDevilFruitChanged,
    required this.bountyController,
    required this.imageUrlController,
    required this.descriptionController,
    required this.selectedStatus,
    required this.selectedHaki,
    required this.selectedAffiliations,
    required this.selectedOccupations,
    required this.onStatusChanged,
    required this.onHakiSelected,
    required this.onHakiDeselected,
    required this.onAffiliationSelected,
    required this.onAffiliationDeselected,
    required this.onOccupationSelected,
    required this.onOccupationDeselected,
    required this.availableCrews,
    required this.selectedCrewId,
    required this.onCrewChanged,
    required this.selectedCrewRole,
    required this.onCrewRoleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        spacing: Constants.margin * 4,
        children: [
          CharacterBasicInfoSection(
            nameController: nameController,
            nicknameController: nicknameController,
            birthDateController: birthDateController,
          ),
          CharacterPowerSection(
            devilFruits: devilFruits,
            selectedDevilFruit: selectedDevilFruit,
            onDevilFruitChanged: onDevilFruitChanged,
            selectedHaki: selectedHaki,
            onHakiSelected: onHakiSelected,
            onHakiDeselected: onHakiDeselected,
          ),
          CharacterBackgroundSection(
            bountyController: bountyController,
            imageUrlController: imageUrlController,
            selectedStatus: selectedStatus,
            onStatusChanged: onStatusChanged,
            selectedOccupations: selectedOccupations,
            onOccupationSelected: onOccupationSelected,
            onOccupationDeselected: onOccupationDeselected,
            selectedAffiliations: selectedAffiliations,
            onAffiliationSelected: onAffiliationSelected,
            onAffiliationDeselected: onAffiliationDeselected,
            availableCrews: availableCrews,
            selectedCrewId: selectedCrewId,
            onCrewChanged: onCrewChanged,
            selectedCrewRole: selectedCrewRole,
            onCrewRoleChanged: onCrewRoleChanged,
          ),
          CharacterDescriptionSection(
            descriptionController: descriptionController,
          ),
        ],
      ),
    );
  }
} 