import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/services/index.dart';


class CrewImageService implements ICrewImageService {
  final GeminiService _geminiService;
  final Map<String, String> _imageCache = {};

  CrewImageService({GeminiService? geminiService})
      : _geminiService = geminiService ?? getIt<GeminiService>();

  String _getCacheKey(String prefix, String prompt) {
    return '${prefix}_${prompt.hashCode}';
  }

  @override
  void clearCache() {
    _imageCache.clear();
  }

  @override
  Future<String?> generateJollyRogerImage({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  }) async {
    final cacheKey = _getCacheKey('jolly_roger_$crewName', prompt);
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    final enhancedPrompt = _buildJollyRogerPrompt(
      crewName: crewName,
      prompt: prompt,
      tags: tags,
      description: description,
    );

    debugPrint(
        'Crew Image Service: Generating Jolly Roger with prompt: $enhancedPrompt');

    final imageUrl = await _geminiService.generateImage(prompt: enhancedPrompt);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      _imageCache[cacheKey] = imageUrl;
      return imageUrl;
    }

    debugPrint(
        'Crew Image Service: Jolly Roger generation failed or in dev mode, returning fallback');
    return await _getJollyRogerFallbackImage(
        crewName, prompt, tags, description);
  }

  @override
  Future<String?> generateBoatImage({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  }) async {
    final cacheKey = _getCacheKey('boat_$crewName', prompt);
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    final enhancedPrompt = _buildBoatPrompt(
      crewName: crewName,
      prompt: prompt,
      tags: tags,
      description: description,
    );

    debugPrint(
        'Crew Image Service: Generating Boat with prompt: $enhancedPrompt');

    final imageUrl = await _geminiService.generateImage(prompt: enhancedPrompt);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      _imageCache[cacheKey] = imageUrl;
      return imageUrl;
    }

    debugPrint(
        'Crew Image Service: Boat generation failed or in dev mode, returning fallback');
    return await _getBoatFallbackImage(crewName, prompt, tags, description);
  }

  String _buildJollyRogerPrompt({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  }) {
    final basePrompt = prompt.isNotEmpty ? prompt : 'pirate flag';

    final List<String> promptParts = [
      basePrompt,
      'crew name: $crewName',
    ];

    if (description != null && description.isNotEmpty) {
      promptParts.add('description: $description');
    }

    if (tags != null && tags.isNotEmpty) {
      final tagTypes = tags.join(', ');
      promptParts.add('tags: $tagTypes');
    }

    promptParts.addAll([
      'One Piece style',
      'pirate flag design',
      'jolly roger',
      'detailed flag design',
      'high quality',
      'professional illustration',
      'vibrant colors',
      'symbolic design',
      'flag waving',
      'anime style',
    ]);

    return promptParts.join(', ');
  }

  String _buildBoatPrompt({
    required String crewName,
    required String prompt,
    List<String>? tags,
    String? description,
  }) {
    final basePrompt = prompt.isNotEmpty ? prompt : 'pirate ship';

    final List<String> promptParts = [
      basePrompt,
      'crew name: $crewName',
    ];

    if (description != null && description.isNotEmpty) {
      promptParts.add('description: $description');
    }

    if (tags != null && tags.isNotEmpty) {
      final tagTypes = tags.join(', ');
      promptParts.add('tags: $tagTypes');
    }

    promptParts.addAll([
      'One Piece style',
      'pirate ship',
      'sailing vessel',
      'detailed ship design',
      'high quality',
      'professional illustration',
      'vibrant colors',
      'ocean background',
      'sails',
      'wooden ship',
      'anime style',
      'adventure ship',
    ]);

    return promptParts.join(', ');
  }

  Future<String> _getJollyRogerFallbackImage(
    String crewName,
    String prompt,
    List<String>? tags,
    String? description,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();

    final colors = [
      ['000000', 'FFFFFF'], // Preto e branco - Clássico
      ['8B0000', 'FFFFFF'], // Vermelho escuro - Sangue
      ['006400', 'FFFFFF'], // Verde escuro - Mar
      ['4B0082', 'FFFFFF'], // Roxo - Mistério
      ['FF4500', 'FFFFFF'], // Laranja-avermelhado - Fogo
      ['2F4F4F', 'FFFFFF'], // Cinza escuro - Tempestade
      ['8B4513', 'FFFFFF'], // Marrom - Madeira
      ['191970', 'FFFFFF'], // Azul marinho - Oceano
    ];

    int colorIndex = 0;
    final promptLower = prompt.toLowerCase();

    if (promptLower.contains('sangue') || promptLower.contains('blood')) {
      colorIndex = 1;
    } else if (promptLower.contains('mar') || promptLower.contains('sea')) {
      colorIndex = 2;
    } else if (promptLower.contains('mistério') ||
        promptLower.contains('mystery')) {
      colorIndex = 3;
    } else if (promptLower.contains('fogo') || promptLower.contains('fire')) {
      colorIndex = 4;
    } else {
      colorIndex = random.nextInt(colors.length);
    }

    final colorPair = colors[colorIndex];
    final bgColor = colorPair[0];
    final textColor = colorPair[1];

    final skullElements = [
      '💀', // Caveira
      '☠️', // Caveira e ossos cruzados
      '🏴‍☠️', // Bandeira pirata
      '⚓', // Âncora
      '🗡️', // Espada
      '⚔️', // Espadas cruzadas
    ];

    List<String> selectedElements = [];

    if (promptLower.contains('caveira') || promptLower.contains('skull')) {
      selectedElements.addAll(['💀', '☠️']);
    } else if (promptLower.contains('espada') ||
        promptLower.contains('sword')) {
      selectedElements.addAll(['🗡️', '⚔️']);
    } else if (promptLower.contains('âncora') ||
        promptLower.contains('anchor')) {
      selectedElements.addAll(['⚓', '🏴‍☠️']);
    } else {
      selectedElements = skullElements;
    }

    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        final tagLower = tag.toLowerCase();
        if (tagLower.contains('pirata') || tagLower.contains('pirate')) {
          selectedElements.add('🏴‍☠️');
        } else if (tagLower.contains('guerreiro') ||
            tagLower.contains('warrior')) {
          selectedElements.add('⚔️');
        } else if (tagLower.contains('navegador') ||
            tagLower.contains('navigator')) {
          selectedElements.add('⚓');
        }
      }
    }

    selectedElements.shuffle();
    final finalElements = selectedElements.take(2 + random.nextInt(2)).toList();

    final displayName = crewName.isNotEmpty ? crewName : 'Tripulação';
    final elementText = finalElements.join(' ');

    String extraInfo = '';
    if (tags != null && tags.isNotEmpty) {
      extraInfo += ' | ${tags.join(', ')}';
    }

    final fullText = '$elementText $displayName$extraInfo $elementText';

    return 'https://via.placeholder.com/512x512/$bgColor/$textColor?text=${Uri.encodeComponent(fullText)}';
  }

  Future<String> _getBoatFallbackImage(
    String crewName,
    String prompt,
    List<String>? tags,
    String? description,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();

    final colors = [
      ['8B4513', 'FFFFFF'], // Marrom - Madeira
      ['2F4F4F', 'FFFFFF'], // Cinza escuro - Tempestade
      ['191970', 'FFFFFF'], // Azul marinho - Oceano
      ['006400', 'FFFFFF'], // Verde escuro - Mar
      ['8B0000', 'FFFFFF'], // Vermelho escuro - Sangue
      ['4B0082', 'FFFFFF'], // Roxo - Mistério
      ['FF4500', 'FFFFFF'], // Laranja-avermelhado - Fogo
      ['000000', 'FFFFFF'], // Preto - Pirata
    ];

    int colorIndex = 0;
    final promptLower = prompt.toLowerCase();

    if (promptLower.contains('madeira') || promptLower.contains('wood')) {
      colorIndex = 0;
    } else if (promptLower.contains('tempestade') ||
        promptLower.contains('storm')) {
      colorIndex = 1;
    } else if (promptLower.contains('oceano') ||
        promptLower.contains('ocean')) {
      colorIndex = 2;
    } else if (promptLower.contains('mar') || promptLower.contains('sea')) {
      colorIndex = 3;
    } else {
      colorIndex = random.nextInt(colors.length);
    }

    final colorPair = colors[colorIndex];
    final bgColor = colorPair[0];
    final textColor = colorPair[1];

    final boatElements = [
      '🚢', // Navio
      '⛵', // Barco à vela
      '🛥️', // Lancha
      '⚓', // Âncora
      '🌊', // Onda
      '🏴‍☠️', // Bandeira pirata
      '🗺️', // Mapa
      '🧭', // Bússola
    ];

    List<String> selectedElements = [];

    if (promptLower.contains('navio') || promptLower.contains('ship')) {
      selectedElements.addAll(['🚢', '⛵']);
    } else if (promptLower.contains('lancha') || promptLower.contains('boat')) {
      selectedElements.addAll(['🛥️', '⛵']);
    } else if (promptLower.contains('pirata') ||
        promptLower.contains('pirate')) {
      selectedElements.addAll(['🏴‍☠️', '🚢']);
    } else {
      selectedElements = boatElements;
    }

    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        final tagLower = tag.toLowerCase();
        if (tagLower.contains('navegador') || tagLower.contains('navigator')) {
          selectedElements.add('🧭');
        } else if (tagLower.contains('explorador') ||
            tagLower.contains('explorer')) {
          selectedElements.add('🗺️');
        } else if (tagLower.contains('marinheiro') ||
            tagLower.contains('sailor')) {
          selectedElements.add('⚓');
        }
      }
    }

    selectedElements.shuffle();
    final finalElements = selectedElements.take(2 + random.nextInt(2)).toList();

    final displayName = crewName.isNotEmpty ? crewName : 'Tripulação';
    final elementText = finalElements.join(' ');

    String extraInfo = '';
    if (tags != null && tags.isNotEmpty) {
      extraInfo += ' | ${tags.join(', ')}';
    }

    final fullText = '$elementText $displayName$extraInfo $elementText';

    return 'https://via.placeholder.com/768x512/$bgColor/$textColor?text=${Uri.encodeComponent(fullText)}';
  }
}
