import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/index.dart';

import 'i_web_search_service.dart';
import 'web_search_result.dart';

class WebSearchService implements IWebSearchService {
  WebSearchService() : _env = GetIt.I.get<IEnvironmentService>() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  final IEnvironmentService _env;
  late final Dio _dio;

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
      final response = await _dio.post(
        _url,
        data: {
          'api_key': _env.tavilyApiKey,
          'query': query,
          'search_depth': searchDepth,
          'max_results': maxResults,
          'search_topic': searchTopic.value,
          'include_answer': includeAnswer,
          'include_raw_content': false,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final raw = data['results'] as List?;
        if (raw == null) return [];

        // Tavily returns a single top-level answer when include_answer=true.
        final topAnswer = data['answer'] as String?;

        final results = raw
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

        // Attach the top-level answer to the first result.
        if (results.isNotEmpty && topAnswer != null && topAnswer.isNotEmpty) {
          results[0] = WebSearchResult(
            title: results[0].title,
            url: results[0].url,
            content: results[0].content,
            score: results[0].score,
            answer: topAnswer,
          );
        }

        return results;
      }
      return [];
    } catch (e) {
      debugPrint('WebSearchService: error: $e');
      return [];
    }
  }
}
