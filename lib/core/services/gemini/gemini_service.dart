import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'i_gemini_service.dart';

/// Gemini through the `geminiGenerateText` / `geminiGenerateImage` Cloud
/// Functions: the API and Imgur keys live only on the server, which also
/// requires a signed-in user and enforces the daily quota.
class GeminiService implements IGeminiService {
  GeminiService({required this._functions});

  final FirebaseFunctions _functions;

  final Map<String, String> _imageCache = {};
  DateTime? _cooldownUntil;
  static const Duration _quotaCooldown = Duration(minutes: 2);

  bool get _inCooldown {
    final until = _cooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  @override
  Future<String?> generateText({
    required String prompt,
    String? systemInstruction,
    String? context,
    double? temperature,
    int? topK,
    double? topP,
    int? maxOutputTokens,
  }) async {
    if (_inCooldown) return null;
    final data = await _call('geminiGenerateText', {
      'prompt': _withContext(prompt, context),
      'systemInstruction': ?systemInstruction,
      'temperature': ?temperature,
      'topK': ?topK,
      'topP': ?topP,
      'maxOutputTokens': ?maxOutputTokens,
    });
    final text = data?['text'] as String?;
    return text == null || text.isEmpty ? null : text;
  }

  // Callers write their own detailed prompts; only the optional context is
  // prepended, never generic suffixes that would contradict them.
  String _withContext(String prompt, String? context) =>
      context == null || context.isEmpty
      ? prompt
      : 'Context: $context\n\n$prompt';

  @override
  Future<String?> generateImage({
    required String prompt,
    bool forceRefresh = false,
  }) async {
    final cacheKey = prompt.hashCode.toString();
    if (!forceRefresh && _imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }
    if (_inCooldown) return null;

    final data = await _call('geminiGenerateImage', {
      'prompt': prompt,
    }, timeout: const Duration(minutes: 3));
    final url = data?['url'] as String?;
    if (url == null || url.isEmpty) return null;
    _imageCache[cacheKey] = url;
    return url;
  }

  /// Every failure becomes `null`, which callers already treat as "no AI
  /// result"; a quota hit also pauses calls for [_quotaCooldown].
  Future<Map<String, dynamic>?> _call(
    String function,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final result = await _functions
          .httpsCallable(
            function,
            options: HttpsCallableOptions(timeout: timeout),
          )
          .call<Object?>(payload);
      final data = result.data;
      return data is Map ? Map<String, dynamic>.from(data) : null;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Gemini Service: $function failed (${e.code})');
      if (e.code == 'resource-exhausted') {
        _cooldownUntil = DateTime.now().add(_quotaCooldown);
      }
      return null;
    } catch (e) {
      debugPrint('Gemini Service: $function failed - $e');
      return null;
    }
  }
}
