import 'package:get_it/get_it.dart';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/index.dart';


class GeminiService implements IGeminiService {
  final IEnvironmentService _env = GetIt.I.get<IEnvironmentService>();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _textModel = 'gemini-2.5-flash-lite';
  static const String _imageModel = 'gemini-2.5-flash-image';

  final Map<String, String> _imageCache = {};
  final List<DateTime> _requestTimestamps = [];
  static const int _maxRequestsPerHour = 15;

  bool _quotaExceeded = false;
  DateTime? _quotaExceededTime;
  static const Duration _quotaResetDuration = Duration(minutes: 2);

  late final Dio _dio;

  GeminiService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(milliseconds: _env.networkTimeout),
      receiveTimeout: Duration(milliseconds: _env.networkTimeout),
      sendTimeout: Duration(milliseconds: _env.networkTimeout),
      validateStatus: (status) => status != null && status < 500,
      maxRedirects: 3,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          debugPrint('Gemini Service: Network error detected, retrying...');

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
            debugPrint('Gemini Service: Retry failed - $retryError');
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

  // Generic Text Generation Method
  @override
  Future<String?> generateText({
    required String prompt,
    String? systemInstruction,
    String? context,
    Map<String, dynamic>? parameters,
  }) async {
    if (_env.geminiApiKey == 'dev_mode' || _env.geminiApiKey.isEmpty) {
      debugPrint('Gemini Service: Development mode or invalid API key');
      return _getFallbackText(prompt, context);
    }

    if (_isQuotaExceeded()) {
      debugPrint('Gemini Service: Quota exceeded (cached), skipping request');
      return null;
    }

    if (!_canMakeRequest()) {
      debugPrint('Gemini Service: Rate limit exceeded');
      return null;
    }

    try {
      final enhancedPrompt = _buildTextPrompt(prompt, context, parameters);
      debugPrint('Gemini Service: Generating text...');

      _recordRequest();

      final response = await _generateTextWithGemini(
        prompt: enhancedPrompt,
        systemInstruction: systemInstruction,
      );

      if (response != null && response.isNotEmpty) {
        debugPrint('Gemini Service: Text generation successful');
        return response;
      }

      debugPrint('Gemini Service: Invalid response from Gemini AI');
      return null;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('RESOURCE_EXHAUSTED') ||
          msg.contains('quota') ||
          msg.contains('rate limit') ||
          msg.contains('429')) {
        debugPrint(
            'Gemini Service: Quota/rate-limit exceeded — activating cooldown');
        _handleQuotaExceeded();
        return null;
      }
      debugPrint('Gemini Service: Error in text generation - $e');
      return null;
    }
  }

  Future<String?> _generateTextWithGemini({
    required String prompt,
    String? systemInstruction,
  }) async {
    try {
      final apiKey = _env.geminiApiKey;
      const url = '$_baseUrl/models/$_textModel:generateContent';

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 8192,
        }
      };

      if (systemInstruction != null && systemInstruction.isNotEmpty) {
        body["systemInstruction"] = {
          "parts": [
            {"text": systemInstruction}
          ]
        };
      }

      debugPrint('Gemini Service: Sending text request to Gemini API');

      final response = await _dio.post(
        url,
        data: jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'Dart/3.0',
            'x-goog-api-key': apiKey,
          },
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      // Handle quota / rate-limit (429) explicitly
      if (response.statusCode == 429) {
        final retryMsg =
            response.data?['error']?['message'] ?? 'Rate limit exceeded';
        debugPrint('Gemini Service: 429 RESOURCE_EXHAUSTED — $retryMsg');
        throw Exception('RESOURCE_EXHAUSTED: $retryMsg');
      }

      if (response.statusCode == 200 && response.data != null) {
        final candidates = response.data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            // Concatenate ALL text parts — Gemini may split long responses
            final fullText = parts
                .where((p) => p['text'] != null)
                .map((p) => p['text'] as String)
                .join();
            if (fullText.isNotEmpty) return fullText;
          }
        }
      }

      debugPrint('Gemini Service: Response body: ${response.data}');
      return null;
    } on DioException catch (e) {
      debugPrint(
          'Gemini Service: DioException in text generation - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Gemini Service: Unexpected error in text generation - $e');
      return null;
    }
  }

  String _buildTextPrompt(
      String prompt, String? context, Map<String, dynamic>? parameters) {
    // Return the prompt as-is — callers (repositories) are responsible for
    // crafting detailed prompts; generic suffixes like "keep it concise" would
    // contradict prompts that explicitly request long, structured responses.
    if (context != null && context.isNotEmpty) {
      return 'Context: $context\n\n$prompt';
    }
    return prompt;
  }

  String _getFallbackText(String prompt, String? context) {
    final random = Random();
    final fallbackResponses = [
      'Based on the information provided, I can help you with that.',
      'Here\'s what I can suggest for your request.',
      'Let me provide you with some helpful information.',
      'I understand your question and here\'s my response.',
      'Based on the context, here\'s what I recommend.',
    ];

    return fallbackResponses[random.nextInt(fallbackResponses.length)];
  }

  // Generic Image Generation Method
  @override
  Future<String?> generateImage({
    required String prompt,
    bool forceRefresh = false,
  }) async {
    final cacheKey = prompt.hashCode.toString();
    if (!forceRefresh && _imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    if (_env.geminiApiKey == 'dev_mode' || _env.geminiApiKey.isEmpty) {
      debugPrint('Gemini Service: Development mode or invalid API key');
      return null;
    }

    if (_isQuotaExceeded()) {
      debugPrint('Gemini Service: Quota exceeded');
      return null;
    }

    if (!_canMakeRequest()) {
      debugPrint('Gemini Service: Rate limit exceeded');
      return null;
    }

    try {
      debugPrint('Gemini Service: Generating image with prompt: $prompt');

      _recordRequest();

      final imageUrl = await _generateImageWithGemini(prompt);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        if (!forceRefresh) {
          _imageCache[cacheKey] = imageUrl;
        }
        debugPrint('Gemini Service: Image generation successful');
        return imageUrl;
      }

      debugPrint('Gemini Service: Invalid response from Gemini AI');
      return null;
    } catch (e) {
      debugPrint('Gemini Service: Error in image generation - $e');

      if (e.toString().contains('quota') ||
          e.toString().contains('rate limit')) {
        _handleQuotaExceeded();
      }

      return null;
    }
  }

  Future<String?> _generateImageWithGemini(String prompt) async {
    try {
      final apiKey = _env.geminiApiKey;
      const url = '$_baseUrl/models/$_imageModel:generateContent';

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": ["IMAGE"]
        }
      };

      debugPrint('Gemini Service: Sending image request to Gemini API');

      final response = await _dio.post(
        url,
        data: jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'Dart/3.0',
            'x-goog-api-key': apiKey,
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
                final base64Image = part['inlineData']['data'] as String?;
                if (base64Image != null && base64Image.isNotEmpty) {
                  final imageData = base64Decode(base64Image);
                  final imageUrl = await _uploadImageToServer(imageData);
                  debugPrint(
                      'Gemini Service: Gemini REST image generated and uploaded to Imgur');
                  return imageUrl;
                }
              }
            }
          }
        }
      }

      debugPrint(
          'Gemini Service: No image returned from Gemini REST API (Status ${response.statusCode})');
      if (response.data != null && response.data['error'] != null) {
        debugPrint(
            'Gemini Service: Error Details: ${response.data['error']['message']}');
      }
      return null;
    } on DioException catch (e) {
      debugPrint(
          'Gemini Service: DioException in Gemini REST image generation - ${e.message}');
      return null;
    } catch (e) {
      debugPrint(
          'Gemini Service: Unexpected error in Gemini REST image generation - $e');
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
      debugPrint('Gemini Service: Failed to upload image - $e');
    }

    return 'data:image/png;base64,${base64Encode(imageData)}';
  }

  // Utility Methods
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

    _requestTimestamps
        .removeWhere((timestamp) => timestamp.isBefore(oneHourAgo));

    return _requestTimestamps.length < _maxRequestsPerHour;
  }

  void _recordRequest() {
    _requestTimestamps.add(DateTime.now());
  }

  void _handleQuotaExceeded() {
    _quotaExceeded = true;
    _quotaExceededTime = DateTime.now();
    debugPrint(
        'Gemini Service: Quota exceeded, will reset in $_quotaResetDuration');
  }

  @override
  void clearCache() {
    _imageCache.clear();
  }

  @override
  Map<String, dynamic> getServiceStatus() {
    return {
      'quota_exceeded': _quotaExceeded,
      'quota_reset_time': _quotaExceededTime?.toIso8601String(),
      'requests_this_hour': _requestTimestamps.length,
      'max_requests_per_hour': _maxRequestsPerHour,
      'cache_size': _imageCache.length,
      'api_configured':
          _env.geminiApiKey.isNotEmpty && _env.geminiApiKey != 'dev_mode',
    };
  }
}
