import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';

class CharacterBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController nicknameController;
  final TextEditingController birthDateController;

  const CharacterBasicInfoSection({
    super.key,
    required this.nameController,
    required this.nicknameController,
    required this.birthDateController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basicInfo,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: '${l10n.name} *',
          hint: l10n.nameHint,
          controller: nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.nameRequired;
            }
            return null;
          },
        ),
        CustomTextField(
          label: l10n.nickname,
          hint: l10n.nicknameHint,
          controller: nicknameController,
        ),
        DateTextField(
          label: l10n.birthDate,
          hint: l10n.birthDateHint,
          controller: birthDateController,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                return 'Data inválida. Use o formato DD/MM/AAAA';
              }

              final parts = value.split('/');
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);

              if (year < 1900 || year > 2100) {
                return 'Ano deve estar entre 1900 e 2100';
              }

              if (month < 1 || month > 12) {
                return 'Mês inválido';
              }

              if (day < 1 || day > 31) {
                return 'Dia inválido';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
