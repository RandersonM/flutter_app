import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/custom_character/bloc/index.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/clickable_image.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';

class AiImageGenerator extends StatefulWidget {
  final String? initialPrompt;
  final String? characterName;
  final String race;
  final List<String>? haki;
  final String? status;
  final List<String>? occupations;
  final Function(String) onImageGenerated;
  final bool isLoading;
  final String? currentImageUrl;

  const AiImageGenerator({
    super.key,
    this.initialPrompt,
    this.characterName,
    this.haki,
    this.status,
    this.occupations,
    required this.race,
    required this.onImageGenerated,
    this.isLoading = false,
    this.currentImageUrl,
  });

  @override
  State<AiImageGenerator> createState() => _AiImageGeneratorState();
}

class _AiImageGeneratorState extends State<AiImageGenerator> {
  final _promptController = TextEditingController();

  bool _promptMissing = false;
  bool _isImageConfirmed = false;

  @override
  void initState() {
    super.initState();
    _promptController.text = widget.initialPrompt ?? '';
    _checkImageConfirmation();
  }

  @override
  void didUpdateWidget(AiImageGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentImageUrl != widget.currentImageUrl) {
      _checkImageConfirmation();
    }
  }

  void _checkImageConfirmation() {
    final generatedUrl = context.read<CharacterImageCubit>().state.imageUrl;
    if (widget.currentImageUrl != null &&
        generatedUrl != null &&
        widget.currentImageUrl == generatedUrl) {
      setState(() {
        _isImageConfirmed = true;
      });
    } else {
      setState(() {
        _isImageConfirmed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<CharacterImageCubit>().state;
    final isGenerating = state.isGenerating;
    final generatedImageUrl = state.imageUrl;
    final errorMessage = _promptMissing
        ? l10n.promptRequired
        : state.failed
        ? l10n.imageGenerationError
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiImageGeneration,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aiImageGenerationSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        CustomTextField(
          label: l10n.imagePrompt,
          hint: l10n.imagePromptHint,
          controller: _promptController,
          maxLines: 8,
          maxLength: 400,
        ),
        const SizedBox(height: 16),

        // Botão de geração
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isGenerating || widget.isLoading ? null : _generateImage,
            icon: isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const AppIcon(PhosphorIconsRegular.magicWand),
            label: Text(
              isGenerating ? l10n.generatingImage : l10n.generateImage,
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                AppIcon(
                  PhosphorIconsRegular.warningCircle,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (generatedImageUrl != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageWithSmartCrop(generatedImageUrl),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _generateImage(forceRegeneration: true),
                  icon: const AppIcon(PhosphorIconsRegular.arrowsClockwise),
                  label: Text(l10n.regenerateImage),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onImageGenerated(generatedImageUrl);
                    setState(() {
                      _isImageConfirmed = true;
                    });
                  },
                  icon: _isImageConfirmed
                      ? const AppIcon(PhosphorIconsRegular.check)
                      : const AppIcon(PhosphorIconsRegular.clock),
                  label: Text(
                    _isImageConfirmed ? l10n.imageConfirmed : l10n.useImage,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImageWithSmartCrop(String imageUrl) {
    return ClickableImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: 300,
      fit: BoxFit.fill,
      borderRadius: BorderRadius.circular(12),
      title: AppLocalizations.of(context)!.aiGeneratedImage,
      showTitleInDialog: true,
    );
  }

  Future<void> _generateImage({bool forceRegeneration = false}) async {
    final prompt = _promptController.text.trim();
    setState(() {
      _promptMissing = prompt.isEmpty;
      _isImageConfirmed = false;
    });
    if (prompt.isEmpty) return;

    await context.read<CharacterImageCubit>().generate(
      characterName: widget.characterName ?? '',
      prompt: prompt,
      race: widget.race,
      haki: widget.haki,
      status: widget.status,
      occupations: widget.occupations,
      forceRegeneration: forceRegeneration,
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
