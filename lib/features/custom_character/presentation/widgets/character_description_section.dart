import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';

class CharacterDescriptionSection extends StatelessWidget {
  final TextEditingController descriptionController;

  const CharacterDescriptionSection({
    Key? key,
    required this.descriptionController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.description,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.characterStory,
          hint: l10n.characterStoryHint,
          controller: descriptionController,
          maxLines: 4,
        ),
      ],
    );
  }
}
