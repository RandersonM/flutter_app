import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';

import 'crew_form_card.dart';
import 'crew_prompt_generator_button.dart';

/// Prompt field + generate button + generated-image preview.
///
/// This block existed four times (jolly roger and boat, in both the create and
/// edit screens) with only the labels and callback differing. The optional
/// [extraField] slot covers the boat variant, which also asks for a ship name.
class CrewImageGeneratorSection extends StatelessWidget {
  const CrewImageGeneratorSection({
    super.key,
    required this.icon,
    required this.title,
    required this.promptController,
    required this.promptHint,
    required this.generateLabel,
    required this.isGenerating,
    required this.onGenerate,
    required this.imageUrl,
    required this.previewTitle,
    this.extraField,
  });

  final Widget icon;
  final String title;
  final TextEditingController promptController;
  final String promptHint;
  final String generateLabel;
  final bool isGenerating;
  final VoidCallback onGenerate;

  /// URL of the last generated image, or null if none yet.
  final String? imageUrl;

  /// Title for the full-screen viewer when the preview is tapped.
  final String previewTitle;

  /// Rendered above the prompt field — used by the boat section for its name.
  final Widget? extraField;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return CrewFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrewFormSectionTitle(icon: icon, label: title),
          const SizedBox(height: 12),
          if (extraField != null) ...[extraField!, const SizedBox(height: 12)],
          TextFormField(
            controller: promptController,
            decoration: InputDecoration(
              labelText: loc.aiPromptLabel,
              hintText: promptHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
            ),
            style: TextStyle(color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          CrewPromptGeneratorButton(
            isGenerating: isGenerating,
            onPressed: onGenerate,
            label: generateLabel,
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.primary),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ClickableImage(
                  imageUrl: imageUrl!,
                  height: 120,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                  title: previewTitle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Informational footer explaining what the AI generation does.
class CrewImageHelpBanner extends StatelessWidget {
  const CrewImageHelpBanner({super.key, required this.icon});

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.aiImageHelpText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
