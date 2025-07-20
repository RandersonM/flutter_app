import 'package:flutter/material.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/l10n/app_localizations.dart';
import '../atoms/custom_text_field.dart';
import '../atoms/clickable_image.dart';
import 'dart:math';

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
    Key? key,
    this.initialPrompt,
    this.characterName,
    this.haki,
    this.status,
    this.occupations,
    required this.race,
    required this.onImageGenerated,
    this.isLoading = false,
    this.currentImageUrl,
  }) : super(key: key);

  @override
  State<AiImageGenerator> createState() => _AiImageGeneratorState();
}

class _AiImageGeneratorState extends State<AiImageGenerator> {
  final _promptController = TextEditingController();
  final _geminiImageService = getIt.geminiImageService;
  
  String? _generatedImageUrl;
  bool _isGenerating = false;
  String? _errorMessage;
  bool _isImageConfirmed = false;
  int _regenerationCount = 0;

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
    if (widget.currentImageUrl != null &&
        _generatedImageUrl != null &&
        widget.currentImageUrl == _generatedImageUrl) {
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiImageGeneration,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aiImageGenerationSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
            onPressed: _isGenerating || widget.isLoading ? null : _generateImage,
            icon: _isGenerating 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? l10n.generatingImage : l10n.generateImage),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (_generatedImageUrl != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageWithSmartCrop(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _generateImage(forceRegeneration: true),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.regenerateImage),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_generatedImageUrl != null) {
                      widget.onImageGenerated(_generatedImageUrl!);
                      setState(() {
                        _isImageConfirmed = true;
                      });
                    }
                  },
                  icon: _isImageConfirmed
                      ? const Icon(Icons.check)
                      : const Icon(Icons.pending),
                  label: Text(
                      _isImageConfirmed ? l10n.imageConfirmed : l10n.useImage),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImageWithSmartCrop() {
    return ClickableImage(
      imageUrl: _generatedImageUrl!,
      width: double.infinity,
      height: 300,
      fit: BoxFit.fill,
      borderRadius: BorderRadius.circular(12),
      title: 'Imagem Gerada por IA',
      showTitleInDialog: true,
    );
  }

  Future<void> _generateImage({bool forceRegeneration = false}) async {
    if (_promptController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.promptRequired;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _isImageConfirmed = false;
    });

    try {
      // Se for uma regeneração forçada, adicionar um sufixo único ao prompt
      String prompt = _promptController.text.trim();
      if (forceRegeneration) {
        _regenerationCount++;
        final random = Random();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final randomSuffix = random.nextInt(1000);
        prompt =
            '$prompt [regeneration_${_regenerationCount}_${timestamp}_$randomSuffix]';
      }

      final imageUrl = await _geminiImageService.generateCharacterImage(
        characterName: widget.characterName ?? '',
        prompt: prompt,
        race: widget.race,
        haki: widget.haki,
        status: widget.status,
        occupations: widget.occupations,
      );

      if (imageUrl != null) {
        setState(() {
          _generatedImageUrl = imageUrl;
          _isGenerating = false;
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.imageGenerationError;
          _isGenerating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.imageGenerationError;
        _isGenerating = false;
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
} 