import 'package:flutter/material.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/l10n/app_localizations.dart';
import '../atoms/custom_text_field.dart';

class AiImageGenerator extends StatefulWidget {
  final String? initialPrompt;
  final String? characterName;
  final String? devilFruit;
  final List<String>? haki;
  final String? status;
  final List<String>? occupations;
  final Function(String) onImageGenerated;
  final bool isLoading;

  const AiImageGenerator({
    Key? key,
    this.initialPrompt,
    this.characterName,
    this.devilFruit,
    this.haki,
    this.status,
    this.occupations,
    required this.onImageGenerated,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AiImageGenerator> createState() => _AiImageGeneratorState();
}

class _AiImageGeneratorState extends State<AiImageGenerator> {
  final _promptController = TextEditingController();
  final _aiImageService = getIt.aiImageService;
  
  String? _generatedImageUrl;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _promptController.text = widget.initialPrompt ?? '';
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
        
        // Campo de prompt
        CustomTextField(
          label: l10n.imagePrompt,
          hint: l10n.imagePromptHint,
          controller: _promptController,
          maxLines: 3,
          maxLength: 200,
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
                  onPressed: _generateImage,
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
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: Text(l10n.useImage),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImageWithSmartCrop() {
    final l10n = AppLocalizations.of(context)!;
    return Image.network(
      _generatedImageUrl!,
      fit: BoxFit.fill,
      alignment: Alignment.topCenter,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.imageLoadError,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.promptRequired;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final imageUrl = await _aiImageService.generateCharacterImage(
        characterName: widget.characterName ?? '',
        prompt: _promptController.text.trim(),
        devilFruit: widget.devilFruit,
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