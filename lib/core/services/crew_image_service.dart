import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/environment_service.dart';

class CrewImageService {
  late final Dio _dio;
  final EnvironmentService _env = EnvironmentService.instance;
  
  final Map<String, String> _imageCache = {};
  final List<DateTime> _requestTimestamps = [];
  static const int _maxRequestsPerHour = 10;

  bool _quotaExceeded = false;
  DateTime? _quotaExceededTime;
  static const Duration _quotaResetDuration = Duration(hours: 24);

  CrewImageService() {
    _dio = Dio(BaseOptions(
      baseUrl: _env.stabilityBaseUrl,
      connectTimeout: Duration(milliseconds: _env.networkTimeout),
      receiveTimeout: Duration(milliseconds: _env.networkTimeout),
      headers: {
        'Authorization': 'Bearer ${_env.stabilityApiKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

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

    // Verificar se a API key está configurada
    if (_env.stabilityApiKey == 'dev_mode' || 
        _env.stabilityApiKey.isEmpty || 
        !_env.stabilityApiKey.startsWith('sk-')) {
      debugPrint('Crew Image Service: Development mode or invalid API key, using fallback');
      return await _getJollyRogerFallbackImage(crewName, prompt, tags, description);
    }

    if (_isQuotaExceeded()) {
      debugPrint('Crew Image Service: Quota exceeded, using fallback');
      return await _getJollyRogerFallbackImage(crewName, prompt, tags, description);
    }

    if (!_canMakeRequest()) {
      debugPrint('Crew Image Service: Rate limit exceeded, using fallback');
      return await _getJollyRogerFallbackImage(crewName, prompt, tags, description);
    }

    try {
      final enhancedPrompt = _buildJollyRogerPrompt(
        crewName: crewName,
        prompt: prompt,
        tags: tags,
        description: description,
      );

      debugPrint('Crew Image Service: Generating Jolly Roger with prompt: $enhancedPrompt');

      _recordRequest();

      final response = await _dio.post(
        '/stable-diffusion-xl-1024-v1-0/text-to-image',
        data: {
          'text_prompts': [
            {
              'text': enhancedPrompt,
              'weight': 1.0,
            },
            {
              'text': 'blurry, low quality, distorted, ugly, bad anatomy, text, letters, words',
              'weight': -1.0,
            }
          ],
          'cfg_scale': 7,
          'height': 1024,
          'width': 1024,
          'samples': 1,
          'steps': 30,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['artifacts'] != null && data['artifacts'].isNotEmpty) {
          final artifact = data['artifacts'][0];
          if (artifact['base64'] != null) {
            final imageData = base64Decode(artifact['base64']);
            final imageUrl = await _uploadImageToServer(imageData);
            _imageCache[cacheKey] = imageUrl;
            debugPrint('Crew Image Service: Jolly Roger generated successfully');
            return imageUrl;
          }
        }
      }
      
      debugPrint('Crew Image Service: Invalid response from Stability AI');
      return await _getJollyRogerFallbackImage(crewName, prompt, tags, description);
      
    } on DioException catch (e) {
      debugPrint('Crew Image Service: DioException - ${e.message}');
      debugPrint('Crew Image Service: Response data - ${e.response?.data}');
      
      if (e.response?.statusCode == 429) {
        _handleQuotaExceeded();
      }

      return await _getJollyRogerFallbackImage(crewName, prompt, tags, description);
    } catch (e) {
      debugPrint('Crew Image Service: Unexpected error - $e');
      return await _getJollyRogerFallbackImage(crewName, prompt, tags, description);
    }
  }

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

    // Verificar se a API key está configurada
    if (_env.stabilityApiKey == 'dev_mode' || 
        _env.stabilityApiKey.isEmpty || 
        !_env.stabilityApiKey.startsWith('sk-')) {
      debugPrint('Crew Image Service: Development mode or invalid API key, using fallback');
      return await _getBoatFallbackImage(crewName, prompt, tags, description);
    }

    if (_isQuotaExceeded()) {
      debugPrint('Crew Image Service: Quota exceeded, using fallback');
      return await _getBoatFallbackImage(crewName, prompt, tags, description);
    }

    if (!_canMakeRequest()) {
      debugPrint('Crew Image Service: Rate limit exceeded, using fallback');
      return await _getBoatFallbackImage(crewName, prompt, tags, description);
    }

    try {
      final enhancedPrompt = _buildBoatPrompt(
        crewName: crewName,
        prompt: prompt,
        tags: tags,
        description: description,
      );

      debugPrint('Crew Image Service: Generating boat with prompt: $enhancedPrompt');

      _recordRequest();

      final response = await _dio.post(
        '/stable-diffusion-xl-1024-v1-0/text-to-image',
        data: {
          'text_prompts': [
            {
              'text': enhancedPrompt,
              'weight': 1.0,
            },
            {
              'text': 'blurry, low quality, distorted, ugly, bad anatomy, text, letters, words',
              'weight': -1.0,
            }
          ],
          'cfg_scale': 7,
          'height': 1024,
          'width': 1024,
          'samples': 1,
          'steps': 30,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['artifacts'] != null && data['artifacts'].isNotEmpty) {
          final artifact = data['artifacts'][0];
          if (artifact['base64'] != null) {
            final imageData = base64Decode(artifact['base64']);
            final imageUrl = await _uploadImageToServer(imageData);
            _imageCache[cacheKey] = imageUrl;
            debugPrint('Crew Image Service: Boat generated successfully');
            return imageUrl;
          }
        }
      }
      
      debugPrint('Crew Image Service: Invalid response from Stability AI');
      return await _getBoatFallbackImage(crewName, prompt, tags, description);
      
    } on DioException catch (e) {
      debugPrint('Crew Image Service: DioException - ${e.message}');
      debugPrint('Crew Image Service: Response data - ${e.response?.data}');
      
      if (e.response?.statusCode == 429) {
        _handleQuotaExceeded();
      }

      return await _getBoatFallbackImage(crewName, prompt, tags, description);
    } catch (e) {
      debugPrint('Crew Image Service: Unexpected error - $e');
      return await _getBoatFallbackImage(crewName, prompt, tags, description);
    }
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
      'skull and crossbones',
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

  Future<String> _uploadImageToServer(Uint8List imageData) async {
    try {
      final uploadDio = Dio();
      final formData = FormData.fromMap({
        'image': base64Encode(imageData),
        'type': 'base64',
      });
      
      final response = await uploadDio.post(
        'https://api.imgur.com/3/image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Client-ID 546c25a59c58ad7', 
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data']['link'];
      }
    } catch (e) {
      debugPrint('Crew Image Service: Failed to upload image - $e');
    }
    
    return 'data:image/png;base64,${base64Encode(imageData)}';
  }

  Future<String> _getJollyRogerFallbackImage(
    String crewName,
    String prompt,
    List<String>? tags,
    String? description,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final random = Random();
    
    // Cores temáticas para bandeiras piratas
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
      colorIndex = 1; // Vermelho escuro
    } else if (promptLower.contains('mar') || promptLower.contains('sea')) {
      colorIndex = 2; // Verde escuro
    } else if (promptLower.contains('mistério') || promptLower.contains('mystery')) {
      colorIndex = 3; // Roxo
    } else if (promptLower.contains('fogo') || promptLower.contains('fire')) {
      colorIndex = 4; // Laranja-avermelhado
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
    } else if (promptLower.contains('espada') || promptLower.contains('sword')) {
      selectedElements.addAll(['🗡️', '⚔️']);
    } else if (promptLower.contains('âncora') || promptLower.contains('anchor')) {
      selectedElements.addAll(['⚓', '🏴‍☠️']);
    } else {
      selectedElements = skullElements;
    }
    
    // Adicionar elementos baseados em tags
    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        final tagLower = tag.toLowerCase();
        if (tagLower.contains('pirata') || tagLower.contains('pirate')) {
          selectedElements.add('🏴‍☠️');
        } else if (tagLower.contains('guerreiro') || tagLower.contains('warrior')) {
          selectedElements.add('⚔️');
        } else if (tagLower.contains('navegador') || tagLower.contains('navigator')) {
          selectedElements.add('⚓');
        }
      }
    }
    
    // Escolher 2-3 elementos aleatórios
    selectedElements.shuffle();
    final finalElements = selectedElements.take(2 + random.nextInt(2)).toList();
    
    // Criar texto da bandeira
    final displayName = crewName.isNotEmpty ? crewName : 'Tripulação';
    final elementText = finalElements.join(' ');
    
    // Adicionar informações extras se disponíveis
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
    
    // Cores temáticas para barcos
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
      colorIndex = 0; // Marrom
    } else if (promptLower.contains('tempestade') || promptLower.contains('storm')) {
      colorIndex = 1; // Cinza escuro
    } else if (promptLower.contains('oceano') || promptLower.contains('ocean')) {
      colorIndex = 2; // Azul marinho
    } else if (promptLower.contains('mar') || promptLower.contains('sea')) {
      colorIndex = 3; // Verde escuro
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
    } else if (promptLower.contains('pirata') || promptLower.contains('pirate')) {
      selectedElements.addAll(['🏴‍☠️', '🚢']);
    } else {
      selectedElements = boatElements;
    }
    
    // Adicionar elementos baseados em tags
    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        final tagLower = tag.toLowerCase();
        if (tagLower.contains('navegador') || tagLower.contains('navigator')) {
          selectedElements.add('🧭');
        } else if (tagLower.contains('explorador') || tagLower.contains('explorer')) {
          selectedElements.add('🗺️');
        } else if (tagLower.contains('marinheiro') || tagLower.contains('sailor')) {
          selectedElements.add('⚓');
        }
      }
    }
    
    // Escolher 2-3 elementos aleatórios
    selectedElements.shuffle();
    final finalElements = selectedElements.take(2 + random.nextInt(2)).toList();
    
    // Criar texto do barco
    final displayName = crewName.isNotEmpty ? crewName : 'Tripulação';
    final elementText = finalElements.join(' ');
    
    // Adicionar informações extras se disponíveis
    String extraInfo = '';
    if (tags != null && tags.isNotEmpty) {
      extraInfo += ' | ${tags.join(', ')}';
    }
    
    final fullText = '$elementText $displayName$extraInfo $elementText';
    
    return 'https://via.placeholder.com/768x512/$bgColor/$textColor?text=${Uri.encodeComponent(fullText)}';
  }

  String _getCacheKey(String prefix, String prompt) {
    return '${prefix}_${prompt.hashCode}';
  }

  bool _isQuotaExceeded() {
    if (!_quotaExceeded || _quotaExceededTime == null) {
      return false;
    }
    
    final timeSinceExceeded = DateTime.now().difference(_quotaExceededTime!);
    if (timeSinceExceeded >= _quotaResetDuration) {
      _quotaExceeded = false;
      _quotaExceededTime = null;
      return false;
    }
    
    return true;
  }

  bool _canMakeRequest() {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    _requestTimestamps.removeWhere((timestamp) => timestamp.isBefore(oneHourAgo));
    
    return _requestTimestamps.length < _maxRequestsPerHour;
  }

  void _recordRequest() {
    _requestTimestamps.add(DateTime.now());
  }

  void _handleQuotaExceeded() {
    _quotaExceeded = true;
    _quotaExceededTime = DateTime.now();
    debugPrint('Crew Image Service: Quota exceeded, will reset in $_quotaResetDuration');
  }

  void clearCache() {
    _imageCache.clear();
  }

  Map<String, dynamic> getServiceStatus() {
    return {
      'quota_exceeded': _quotaExceeded,
      'quota_reset_time': _quotaExceededTime?.toIso8601String(),
      'requests_this_hour': _requestTimestamps.length,
      'max_requests_per_hour': _maxRequestsPerHour,
      'cache_size': _imageCache.length,
      'api_configured': _env.stabilityApiKey.isNotEmpty && _env.stabilityApiKey.startsWith('sk-'),
    };
  }
} 