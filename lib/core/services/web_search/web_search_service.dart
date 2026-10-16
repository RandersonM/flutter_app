import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'i_web_search_service.dart';
import 'web_search_result.dart';

/// Tavily through the `webSearch` Cloud Function, which holds the API key,
/// requires a signed-in user and enforces the daily quota.
class WebSearchService implements IWebSearchService {
  WebSearchService({required this._functions});

  final FirebaseFunctions _functions;

  @override
  Future<List<WebSearchResult>> search(
    String query, {
    int maxResults = 5,
    String searchDepth = 'advanced',
    String includeAnswer = 'advanced',
    SearchTopic searchTopic = SearchTopic.general,
  }) async {
    try {
      final response = await _functions
          .httpsCallable(
            'webSearch',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
          )
          .call<Object?>({
            'query': query,
            'maxResults': maxResults,
            'searchDepth': searchDepth,
            'includeAnswer': includeAnswer,
            'topic': searchTopic.value,
          });
      final data = response.data;
      if (data is! Map) return [];
      return resultsFromResponse(Map<String, dynamic>.from(data));
    } on FirebaseFunctionsException catch (e) {
      debugPrint('WebSearchService: webSearch failed (${e.code})');
      return [];
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
