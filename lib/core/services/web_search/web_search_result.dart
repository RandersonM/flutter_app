class WebSearchResult {
  final String title;
  final String url;
  final String content;
  final double score;

  /// Top-level answer summary returned by Tavily when `include_answer` is true.
  /// Only present on the first result in the list (shared answer).
  final String? answer;

  const WebSearchResult({
    required this.title,
    required this.url,
    required this.content,
    required this.score,
    this.answer,
  });
}
