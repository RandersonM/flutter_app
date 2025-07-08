import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/environment_service.dart';

class AiImageService {
  late final Dio _dio;
  final EnvironmentService _env = EnvironmentService.instance;
  
  final Map<String, String> _imageCache = {};
  final List<DateTime> _requestTimestamps = [];
  static const int _maxRequestsPerHour = 10;

  bool _quotaExceeded = false;
  DateTime? _quotaExceededTime;
  static const Duration _quotaResetDuration = Duration(hours: 24);

  AiImageService() {
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

  Future<String?> generateCharacterImage({
    required String characterName,
    required String prompt,
    String? devilFruit,
    List<String>? haki,
    String? status,
    List<String>? occupations,
  }) async {
    final cacheKey = _getCacheKey(characterName, prompt);
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    // Verificar se a API key está configurada
    if (_env.stabilityApiKey == 'dev_mode' || 
        _env.stabilityApiKey.isEmpty || 
        !_env.stabilityApiKey.startsWith('sk-')) {
      debugPrint('AI Image Service: Development mode or invalid API key, using fallback');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }

    if (_isQuotaExceeded()) {
      debugPrint('AI Image Service: Quota exceeded, using fallback');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }

    if (!_canMakeRequest()) {
      debugPrint('AI Image Service: Rate limit exceeded, using fallback');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }

    try {
      final enhancedPrompt = _buildEnhancedPrompt(
        characterName: characterName,
        prompt: prompt,
        devilFruit: devilFruit,
        haki: haki,
        status: status,
        occupations: occupations,
      );

      debugPrint('AI Image Service: Generating image with prompt: $enhancedPrompt');

      _recordRequest();

      // Usar o modelo Stable Diffusion XL da Stability AI
      final response = await _dio.post(
        '/stable-diffusion-xl-1024-v1-0/text-to-image',
        data: {
          'text_prompts': [
            {
              'text': enhancedPrompt,
              'weight': 1.0,
            },
            {
              'text': 'blurry, low quality, distorted, ugly, bad anatomy',
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
            debugPrint('AI Image Service: Success with Stability AI');
            return imageUrl;
          }
        }
      }
      
      debugPrint('AI Image Service: Invalid response from Stability AI');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
      
    } on DioException catch (e) {
      debugPrint('AI Image Service: DioException - ${e.message}');
      debugPrint('AI Image Service: Response data - ${e.response?.data}');
      
      if (e.response?.statusCode == 429) {
        _handleQuotaExceeded();
      }

      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    } catch (e) {
      debugPrint('AI Image Service: Unexpected error - $e');
      return await _getEnhancedFallbackImage(characterName, prompt, devilFruit, haki, status, occupations);
    }
  }

  String _buildEnhancedPrompt({
    required String characterName,
    required String prompt,
    String? devilFruit,
    List<String>? haki,
    String? status,
    List<String>? occupations,
  }) {
    final basePrompt = prompt.isNotEmpty ? prompt : 'One Piece character';
    
    final List<String> promptParts = [
      basePrompt,
      'character name: $characterName',
    ];

    if (devilFruit != null && devilFruit.isNotEmpty) {
      promptParts.add('devil fruit user: $devilFruit');
    }

    if (haki != null && haki.isNotEmpty) {
      final hakiTypes = haki.join(', ');
      promptParts.add('haki types: $hakiTypes');
    }

    if (status != null && status.isNotEmpty) {
      promptParts.add('status: $status');
    }

    if (occupations != null && occupations.isNotEmpty) {
      final occupationTypes = occupations.join(', ');
      promptParts.add('occupations: $occupationTypes');
    }

    // Adicionar elementos visuais do One Piece
    promptParts.addAll([
      'anime style',
      'One Piece universe',
      'detailed character design',
      'high quality',
      'professional illustration',
      'character portrait',
      'vibrant colors',
    ]);

    return promptParts.join(', ');
  }

  Future<String> _uploadImageToServer(Uint8List imageData) async {
    // Por enquanto, vamos usar um serviço de upload temporário
    // Em produção, você pode usar Imgur, Cloudinary, ou seu próprio servidor
    
    try {
      // Usar Imgur API para upload (gratuito)
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
            'Authorization': 'Client-ID 546c25a59c58ad7', // Imgur Client ID público
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data']['link'];
      }
    } catch (e) {
      debugPrint('AI Image Service: Failed to upload image - $e');
    }
    
    // Fallback: converter para data URL
    return 'data:image/png;base64,${base64Encode(imageData)}';
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
    
    // Cores temáticas baseadas no prompt e características
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
    
    // Escolher cor baseada no prompt
    int colorIndex = 0;
    final promptLower = prompt.toLowerCase();
    
    if (promptLower.contains('pirata') || promptLower.contains('pirate')) {
      colorIndex = 0; // Vermelho
    } else if (promptLower.contains('marinha') || promptLower.contains('marine')) {
      colorIndex = 1; // Turquesa
    } else if (promptLower.contains('água') || promptLower.contains('water')) {
      colorIndex = 2; // Azul
    } else if (promptLower.contains('natureza') || promptLower.contains('nature')) {
      colorIndex = 3; // Verde
    } else if (promptLower.contains('ouro') || promptLower.contains('gold')) {
      colorIndex = 4; // Amarelo
    } else {
      colorIndex = random.nextInt(colors.length);
    }
    
    final colorPair = colors[colorIndex];
    final bgColor = colorPair[0];
    final textColor = colorPair[1];
    
    final elements = [
      '⚓', // Âncora
      '🏴‍☠️', // Bandeira pirata
      '🗡️', // Espada
      '💀', // Caveira
      '🌊', // Onda
      '⚔️', // Espadas cruzadas
      '🏝️', // Ilha
      '⚡', // Poder
      '🔥', // Fogo
      '💎', // Tesouro
      '👑', // Coroa
      '🛡️', // Escudo
    ];
    
    List<String> selectedElements = [];
    
    if (promptLower.contains('pirata') || promptLower.contains('pirate')) {
      selectedElements.addAll(['🏴‍☠️', '⚓', '🗡️']);
    } else if (promptLower.contains('capitão') || promptLower.contains('captain')) {
      selectedElements.addAll(['👑', '⚔️', '🛡️']);
    } else if (promptLower.contains('espada') || promptLower.contains('sword')) {
      selectedElements.addAll(['🗡️', '⚔️', '🛡️']);
    } else if (promptLower.contains('poder') || promptLower.contains('power')) {
      selectedElements.addAll(['⚡', '🔥', '💎']);
    } else {
      selectedElements = elements;
    }
    
    // Adicionar elementos baseados em características específicas
    if (devilFruit != null && devilFruit.isNotEmpty) {
      selectedElements.add('⚡');
    }
    if (haki != null && haki.isNotEmpty) {
      selectedElements.add('🔥');
    }
    if (status == 'dead') {
      selectedElements.add('💀');
    }
    
    // Escolher 2-3 elementos aleatórios
    selectedElements.shuffle();
    final finalElements = selectedElements.take(2 + random.nextInt(2)).toList();
    
    // Criar texto do personagem
    final displayName = characterName.isNotEmpty ? characterName : 'Personagem';
    final elementText = finalElements.join(' ');
    
    // Adicionar informações extras se disponíveis
    String extraInfo = '';
    if (devilFruit != null && devilFruit.isNotEmpty) {
      extraInfo += ' | $devilFruit';
    }
    if (haki != null && haki.isNotEmpty) {
      extraInfo += ' | ${haki.join(', ')}';
    }
    
    final fullText = '$elementText $displayName$extraInfo $elementText';
    
    return 'https://via.placeholder.com/512x768/$bgColor/$textColor?text=${Uri.encodeComponent(fullText)}';
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
    debugPrint('AI Image Service: Quota exceeded, will reset in $_quotaResetDuration');
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