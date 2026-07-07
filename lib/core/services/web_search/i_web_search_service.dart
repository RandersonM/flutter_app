import 'web_search_result.dart';

enum SearchTopic {
  general,
  news,
  finance;

  String get value => name;
}

abstract class IWebSearchService {
  bool get isConfigured;

  /// Search the web for [query].
  ///
  /// [maxResults] limits the number of results returned.
  /// [searchDepth] is either `'basic'` or `'advanced'` (Tavily-specific).
  /// [includeAnswer] requests a top-level answer summary from Tavily.
  Future<List<WebSearchResult>> search(
    String query, {
    int maxResults = 2,
    String searchDepth = 'basic',
    String includeAnswer = 'basic',
    SearchTopic searchTopic = SearchTopic.general,
  });
}
