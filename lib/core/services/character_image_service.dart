import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/services/gemini_service.dart';

class CharacterImageService {
  final GeminiService _geminiService;
  final Map<String, String> _imageCache = {};

  CharacterImageService({GeminiService? geminiService})
      : _geminiService = geminiService ?? getIt<GeminiService>();

  String _getCacheKey(String characterName, String prompt) {
    return '${characterName}_${prompt.hashCode}';
  }

  void clearCache() {
    _imageCache.clear();
  }

  Future<String?> generateCharacterImage({
    required String characterName,
    required String prompt,
    required String race,
    String? devilFruit,
    List<String>? haki,
    String? status,
    List<String>? occupations,
  }) async {
    final isForcedRegeneration = prompt.contains('[regeneration_');

    final cacheKey = _getCacheKey(characterName, prompt);
    if (!isForcedRegeneration && _imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    final cleanPrompt = isForcedRegeneration
        ? prompt.replaceAll(RegExp(r'\[regeneration_\d+_\d+_\d+\]'), '').trim()
        : prompt;

    final enhancedPrompt = _buildEnhancedPrompt(
      prompt: cleanPrompt,
      race: race,
      haki: haki,
      status: status,
      occupations: occupations,
    );

    debugPrint(
        'Character Image Service: Requesting image from Gemini with prompt: $enhancedPrompt');

    final imageUrl = await _geminiService.generateImage(
      prompt: enhancedPrompt,
      forceRefresh: isForcedRegeneration,
    );

    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (!isForcedRegeneration) {
        _imageCache[cacheKey] = imageUrl;
      }
      return imageUrl;
    }

    debugPrint(
        'Character Image Service: Image generation failed or in dev mode, returning fallback');
    return await _getEnhancedFallbackImage(
      characterName: characterName,
      prompt: prompt,
      devilFruit: devilFruit,
      haki: haki,
      status: status,
      occupations: occupations,
    );
  }

  String _buildEnhancedPrompt({
    required String race,
    required String prompt,
    List<String>? haki,
    String? status,
    List<String>? occupations,
  }) {
    final basePrompt = prompt.isNotEmpty ? prompt : 'One Piece character';

    final List<String> promptParts = [
      basePrompt,
      'race: $race',
    ];

    if (status != null && status.isNotEmpty) {
      promptParts.add('status: $status');
    }

    if (occupations != null && occupations.isNotEmpty) {
      final occupationTypes = occupations.join(', ');
      promptParts.add('occupations: $occupationTypes');
    }

    promptParts.addAll([
      'anime style',
      'One Piece universe',
      'detailed character design',
      'high quality',
      'professional illustration',
      'vibrant colors',
    ]);

    return promptParts.join(', ');
  }

  Future<String> _getEnhancedFallbackImage({
    required String characterName,
    required String prompt,
    String? devilFruit,
    List<String>? haki,
    String? status,
    List<String>? occupations,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    final isForcedRegeneration = prompt.contains('[regeneration_');

    int variationOffset = 0;
    if (isForcedRegeneration) {
      final regenerationMatch =
          RegExp(r'\[regeneration_(\d+)_(\d+)_(\d+)\]').firstMatch(prompt);
      if (regenerationMatch != null) {
        final count = int.parse(regenerationMatch.group(1)!);
        final timestamp = int.parse(regenerationMatch.group(2)!);
        final randomSuffix = int.parse(regenerationMatch.group(3)!);

        variationOffset = (count + timestamp + randomSuffix) % 1000;
      }
    }

    final colors = [
      ['FF6B6B', 'FFFFFF'], // Vermelho - Piratas
      ['4ECDC4', 'FFFFFF'], // Turquesa - Marinha
      ['45B7D1', 'FFFFFF'], // Azul - Água
      ['96CEB4', 'FFFFFF'], // Verde - Natureza
      ['FFEAA7', '2D3436'], // Amarelo - Ouro
      ['DDA0DD', 'FFFFFF'], // Roxo - Mistério
      ['FFB347', 'FFFFFF'], // Laranja - Fogo
      ['FF69B4', 'FFFFFF'], // Rosa - Feminino
      ['20B2AA', 'FFFFFF'], // Verde-azulado - Marinha
      ['FF4500', 'FFFFFF'], // Laranja-avermelhado - Agressivo
    ];

    int colorIndex = 0;
    final promptLower = prompt.toLowerCase();

    if (promptLower.contains('pirata') || promptLower.contains('pirate')) {
      colorIndex = 0;
    } else if (promptLower.contains('marinha') ||
        promptLower.contains('marine')) {
      colorIndex = 1;
    } else if (promptLower.contains('água') || promptLower.contains('water')) {
      colorIndex = 2;
    } else if (promptLower.contains('natureza') ||
        promptLower.contains('nature')) {
      colorIndex = 3;
    } else if (promptLower.contains('ouro') || promptLower.contains('gold')) {
      colorIndex = 4;
    } else {
      colorIndex = random.nextInt(colors.length);
    }

    if (isForcedRegeneration) {
      colorIndex = (colorIndex + variationOffset) % colors.length;
    }

    final colorPair = colors[colorIndex];
    final bgColor = colorPair[0];
    final textColor = colorPair[1];

    final elements = [
      'PIRATA',
      'CAPITAO',
      'ESPADA',
      'PODER',
      'MAR',
      'ILHA',
      'TESOURO',
      'COROA',
      'NAVIO',
      'BANDEIRA',
      'LUTA',
      'AVENTURA',
    ];

    List<String> selectedElements = [];

    if (promptLower.contains('pirata') || promptLower.contains('pirate')) {
      selectedElements.addAll(['PIRATA', 'MAR', 'ESPADA']);
    } else if (promptLower.contains('capitão') ||
        promptLower.contains('captain')) {
      selectedElements.addAll(['COROA', 'CAPITAO', 'PODER']);
    } else if (promptLower.contains('espada') ||
        promptLower.contains('sword')) {
      selectedElements.addAll(['ESPADA', 'PIRATA', 'LUTA']);
    } else if (promptLower.contains('poder') || promptLower.contains('power')) {
      selectedElements.addAll(['PODER', 'TESOURO', 'COROA']);
    } else {
      selectedElements = elements;
    }

    if (devilFruit != null && devilFruit.isNotEmpty) {
      selectedElements.add('PODER');
    }
    if (haki != null && haki.isNotEmpty) {
      selectedElements.add('LUTA');
    }
    if (status == 'dead') {
      selectedElements.add('PIRATA');
    }

    selectedElements.shuffle();
    final finalElements = selectedElements.take(2 + random.nextInt(2)).toList();

    if (isForcedRegeneration) {
      final tempElements = List<String>.from(finalElements);
      for (int i = 0; i < tempElements.length; i++) {
        final newIndex = (i + variationOffset) % tempElements.length;
        finalElements[i] = tempElements[newIndex];
      }
    }

    final displayName = characterName.isNotEmpty ? characterName : 'Personagem';
    final elementText = finalElements.join(' ');

    String extraInfo = '';
    if (devilFruit != null && devilFruit.isNotEmpty) {
      extraInfo += ' | $devilFruit';
    }
    if (haki != null && haki.isNotEmpty) {
      extraInfo += ' | ${haki.join(', ')}';
    }

    final fullText = '$elementText $displayName$extraInfo $elementText';

    final cacheBuster = isForcedRegeneration
        ? '&v=${DateTime.now().millisecondsSinceEpoch}'
        : '';

    final encodedText = Uri.encodeComponent(fullText);
    final imageUrl =
        'https://dummyimage.com/512x768/$bgColor/$textColor&text=$encodedText$cacheBuster';

    debugPrint('Character Image Service: Generated fallback image URL');
    return imageUrl;
  }
}
