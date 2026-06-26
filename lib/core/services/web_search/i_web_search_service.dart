import 'web_search_result.dart';

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
    bool includeAnswer = false,
  });
}
