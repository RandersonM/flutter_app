import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/config/i_environment_service.dart';

import 'i_web_search_service.dart';
import 'web_search_result.dart';

/// Tavily search. The key is a build-time value on Tavily's free plan (no card
/// on file), so a leaked key can only use up that free quota.
class WebSearchService implements IWebSearchService {
  WebSearchService({required this._env, required this._dio});

  final IEnvironmentService _env;
  final Dio _dio;

  static const _url = 'https://api.tavily.com/search';

  @override
  bool get isConfigured => _env.tavilyApiKey.isNotEmpty;

  @override
  Future<List<WebSearchResult>> search(
    String query, {
    int maxResults = 5,
    String searchDepth = 'advanced',
    String includeAnswer = 'advanced',
    SearchTopic searchTopic = SearchTopic.general,
  }) async {
    if (!isConfigured) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _url,
        data: {
          'query': query,
          'search_depth': searchDepth,
          'max_results': maxResults,
          'topic': searchTopic.value,
          'include_answer': includeAnswer,
          'include_raw_content': false,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${_env.tavilyApiKey}'},
        ),
      );
      final data = response.data;
      if (response.statusCode != 200 || data == null) return [];
      return resultsFromResponse(data);
    } catch (e) {
      debugPrint('WebSearchService: error: $e');
      return [];
    }
  }

  /// Tavily returns one top-level answer; it rides on the first result.
  @visibleForTesting
  static List<WebSearchResult> resultsFromResponse(Map<String, dynamic> data) {
    final raw = data['results'] as List? ?? const [];
    final results = raw
        .whereType<Map>()
        .map(
          (r) => WebSearchResult(
            title: r['title'] as String? ?? '',
            url: r['url'] as String? ?? '',
            content: r['content'] as String? ?? '',
            score: (r['score'] as num?)?.toDouble() ?? 0.0,
          ),
        )
        .where((r) => r.content.isNotEmpty)
        .toList();

    final answer = data['answer'] as String?;
    if (results.isNotEmpty && answer != null && answer.isNotEmpty) {
      final first = results.first;
      results[0] = WebSearchResult(
        title: first.title,
        url: first.url,
        content: first.content,
        score: first.score,
        answer: answer,
      );
    }
    return results;
  }
}
