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
  static const int _maxRequestsPerHour = 15; // Gemini tem limite mais generoso

  bool _quotaExceeded = false;
  DateTime? _quotaExceededTime;
  static const Duration _quotaResetDuration = Duration(hours: 24);

  CrewImageService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(milliseconds: _env.networkTimeout),
      receiveTimeout: Duration(milliseconds: _env.networkTimeout),
      sendTimeout: Duration(milliseconds: _env.networkTimeout),
      // Configurações para melhorar a estabilidade da conexão
      validateStatus: (status) => status != null && status < 500,
      maxRedirects: 3,
    ));

    // Adicionar interceptor para retry automático
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          debugPrint('Crew Image Service: Network error detected, retrying...');

          await Future.delayed(const Duration(milliseconds: 1000));

          try {
            final retryOptions = Options(
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 60),
            );

            final retryResponse = await _dio.request(
              error.requestOptions.path,
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
              options: retryOptions,
            );

            handler.resolve(retryResponse);
            return;
          } catch (retryError) {
            debugPrint('Crew Image Service: Retry failed - $retryError');
          }
        }

        handler.next(error);
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

    if (_env.geminiApiKey == 'dev_mode' || _env.geminiApiKey.isEmpty) {
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

      _recordRequest();

      final imageUrl = await _generateImageWithGemini(enhancedPrompt);
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        _imageCache[cacheKey] = imageUrl;
        return imageUrl;
      }
      
      debugPrint('Crew Image Service: Invalid response from Gemini AI');
      return await _getJollyRogerFallbackImage(crewName, prompt, tags, description);
      
    } catch (e) {
      debugPrint('Crew Image Service: Error - $e');
      
      if (e.toString().contains('quota') ||
          e.toString().contains('rate limit')) {
        _handleQuotaExceeded();
      }

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

    if (_env.geminiApiKey == 'dev_mode' || _env.geminiApiKey.isEmpty) {
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

      _recordRequest();

      final imageUrl = await _generateImageWithGemini(enhancedPrompt);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        _imageCache[cacheKey] = imageUrl;
        return imageUrl;
      }

      debugPrint('Crew Image Service: Invalid response from Gemini AI');
      return await _getBoatFallbackImage(crewName, prompt, tags, description);
    } catch (e) {
      debugPrint('Crew Image Service: Error - $e');

      if (e.toString().contains('quota') ||
          e.toString().contains('rate limit')) {
        _handleQuotaExceeded();
      }

      return await _getBoatFallbackImage(crewName, prompt, tags, description);
    }
  }

  Future<String?> _generateImageWithGemini(String prompt) async {
    try {
      final apiKey = _env.geminiApiKey;

      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent?key=$apiKey';

      final body = {
        "contents": [
          {
            "parts": [
              {
                "text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": ["TEXT", "IMAGE"]
        }
      };

      final response = await _dio.post(
        url,
        data: jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'Dart/3.0',
          },
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final candidates = response.data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List?;
          if (parts != null) {
            for (final part in parts) {
              if (part['inlineData'] != null &&
                  part['inlineData']['mimeType'] == 'image/png') {
                final base64Image = part['inlineData']['data'];
                final imageData = base64Decode(base64Image);
                final imageUrl = await _uploadImageToServer(imageData);
                debugPrint(
                    'Crew Image Service: Gemini REST image generated and uploaded to Imgur');
                return imageUrl;
              }
            }
          }
        }
      }
      
      debugPrint('Crew Image Service: No image returned from Gemini REST API');
      return null;
    } on DioException catch (e) {
      debugPrint(
          'Crew Image Service: DioException in Gemini REST image generation - ${e.message}');
      debugPrint('Crew Image Service: DioException type - ${e.type}');
      debugPrint(
          'Crew Image Service: DioException response - ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint(
          'Crew Image Service: Unexpected error in Gemini REST image generation - $e');
      return null;
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
    } else if (promptLower.contains('mistério') || promptLower.contains('mystery')) {
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
    } else if (promptLower.contains('espada') || promptLower.contains('sword')) {
      selectedElements.addAll(['🗡️', '⚔️']);
    } else if (promptLower.contains('âncora') || promptLower.contains('anchor')) {
      selectedElements.addAll(['⚓', '🏴‍☠️']);
    } else {
      selectedElements = skullElements;
    }
    
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
    } else if (promptLower.contains('tempestade') || promptLower.contains('storm')) {
      colorIndex = 1; 
    } else if (promptLower.contains('oceano') || promptLower.contains('ocean')) {
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
    } else if (promptLower.contains('pirata') || promptLower.contains('pirate')) {
      selectedElements.addAll(['🏴‍☠️', '🚢']);
    } else {
      selectedElements = boatElements;
    }
    
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
      'api_configured': _env.geminiApiKey.isNotEmpty,
    };
  }
} 