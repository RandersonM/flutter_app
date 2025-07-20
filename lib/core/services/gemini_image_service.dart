import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/environment_service.dart';

class GeminiImageService {
  final EnvironmentService _env = EnvironmentService.instance;
  
  final Map<String, String> _imageCache = {};
  final List<DateTime> _requestTimestamps = [];
  static const int _maxRequestsPerHour = 15; // Gemini tem limite mais generoso

  bool _quotaExceeded = false;
  DateTime? _quotaExceededTime;
  static const Duration _quotaResetDuration = Duration(hours: 24);

  late final Dio _dio;

  GeminiImageService() {
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
          
          debugPrint('Gemini Image Service: Network error detected, retrying...');
          
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
            debugPrint('Gemini Image Service: Retry failed - $retryError');
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

    if (_env.geminiApiKey == 'dev_mode' || 
        _env.geminiApiKey.isEmpty) {
      debugPrint('Gemini Image Service: Development mode or invalid API key, using fallback');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }

    if (_isQuotaExceeded()) {
      debugPrint('Gemini Image Service: Quota exceeded, using fallback');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }

    if (!_canMakeRequest()) {
      debugPrint('Gemini Image Service: Rate limit exceeded, using fallback');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }

    try {
      final cleanPrompt = isForcedRegeneration
          ? prompt
              .replaceAll(RegExp(r'\[regeneration_\d+_\d+_\d+\]'), '')
              .trim()
          : prompt;
          
      final enhancedPrompt = _buildEnhancedPrompt(
        prompt: cleanPrompt,
        race: race,
        haki: haki,
        status: status,
        occupations: occupations,
      );

      debugPrint('Gemini Image Service: Generating image with prompt: $enhancedPrompt');

      _recordRequest();

      // Usar a API REST do Gemini para geração de imagens conforme documentação oficial
      final imageUrl = await _generateImageWithGemini(enhancedPrompt);
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Só armazenar no cache se não for uma regeneração forçada
        if (!isForcedRegeneration) {
          _imageCache[cacheKey] = imageUrl;
        }
        debugPrint('Gemini Image Service: Success with Gemini AI');
        debugPrint('Gemini Image Service: Image URL - $imageUrl');
        return imageUrl;
      }
      
      debugPrint('Gemini Image Service: Invalid response from Gemini AI');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
      
    } catch (e) {
      debugPrint('Gemini Image Service: Error - $e');
      
      if (e.toString().contains('quota') || e.toString().contains('rate limit')) {
        _handleQuotaExceeded();
      }

      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }
  }

  Future<String?> _generateImageWithGemini(String prompt) async {
    try {
      final apiKey = _env.geminiApiKey;
      
      // Usar o modelo correto para geração de imagens conforme documentação oficial
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent?key=$apiKey';

      // Estrutura correta baseada na documentação oficial
      final body = {
        "contents": [
          {
            "parts": [
              {
                "text": prompt
              }
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": ["TEXT", "IMAGE"]
        }
      };

      debugPrint('Gemini Image Service: Sending request to Gemini API');
      debugPrint('Gemini Image Service: Request body: ${jsonEncode(body)}');

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
              if (part['inlineData'] != null && part['inlineData']['mimeType'] == 'image/png') {
                final base64Image = part['inlineData']['data'];
                final imageData = base64Decode(base64Image);
                final imageUrl = await _uploadImageToServer(imageData);
                debugPrint('Gemini Image Service: Gemini REST image generated and uploaded to Imgur');
                return imageUrl;
              }
            }
          }
        }
      }
      
      return null;
    } on DioException catch (e) {
      debugPrint('Gemini Image Service: DioException in Gemini REST image generation - ${e.message}');
      debugPrint('Gemini Image Service: DioException type - ${e.type}');
      debugPrint('Gemini Image Service: DioException response - ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('Gemini Image Service: Unexpected error in Gemini REST image generation - $e');
      return null;
    }
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
      debugPrint('Gemini Image Service: Failed to upload image - $e');
    }
    
    return 'data:image/png;base64,${base64Encode(imageData)}';
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

  Future<String> _getEnhancedFallbackImage(
    String characterName,
    String prompt,
    String? devilFruit,
    List<String>? haki,
    String? status,
    List<String>? occupations,
  ) async {
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
    } else if (promptLower.contains('marinha') || promptLower.contains('marine')) {
      colorIndex = 1; 
    } else if (promptLower.contains('água') || promptLower.contains('water')) {
      colorIndex = 2; 
    } else if (promptLower.contains('natureza') || promptLower.contains('nature')) {
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
    } else if (promptLower.contains('capitão') || promptLower.contains('captain')) {
      selectedElements.addAll(['COROA', 'CAPITAO', 'PODER']);
    } else if (promptLower.contains('espada') || promptLower.contains('sword')) {
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
    final imageUrl = 'https://dummyimage.com/512x768/$bgColor/$textColor&text=$encodedText$cacheBuster';
    
    debugPrint('Gemini Image Service: Generated fallback image URL');
    return imageUrl;
  }

  String _getCacheKey(String characterName, String prompt) {
    return '${characterName}_${prompt.hashCode}';
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
    debugPrint('Gemini Image Service: Quota exceeded, will reset in $_quotaResetDuration');
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
      'api_configured': _env.geminiApiKey.isNotEmpty && _env.geminiApiKey != 'dev_mode',
    };
  }
} 