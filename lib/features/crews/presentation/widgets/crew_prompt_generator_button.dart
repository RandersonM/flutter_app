import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';

/// Full-width "generate with AI" button that swaps to a spinner while running.
class CrewPromptGeneratorButton extends StatelessWidget {
  const CrewPromptGeneratorButton({
    super.key,
    required this.isGenerating,
    required this.onPressed,
    required this.label,
  });

  final bool isGenerating;
  final VoidCallback onPressed;

  /// Shown when idle; replaced by the localized "generating" text while busy.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isGenerating ? null : onPressed,
        icon: isGenerating
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                ),
              )
            : const AppIcon(PhosphorIconsRegular.magicWand),
        label: Text(
          isGenerating ? AppLocalizations.of(context)!.generatingLabel : label,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
      ),
    );
  }
}
