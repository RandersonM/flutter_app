import 'package:flutter/foundation.dart';
import 'package:opfan/core/services/web_search/i_web_search_service.dart';

import '../models/tool_call.dart';
import '../models/tool_result.dart';
import '../tool_handler.dart';

/// [ToolHandler] that performs a web search via the Tavily API.
///
/// Invoked when Gemma emits:
/// ```json
/// {"name": "searchInternet", "arguments": {"query": "..."}}
/// ```
class SearchInternetHandler implements ToolHandler {
  const SearchInternetHandler({required this._webSearch});

  final IWebSearchService _webSearch;

  @override
  String get name => 'searchInternet';

  @override
  String get description =>
      'Search the web for recent or external information. '
      'Use this function whenever the answer depends on current events, news, '
      'facts that may have changed, or information not available in the model.';

  @override
  String get descriptionPt =>
      'Pesquise na web por informações recentes ou externas. '
      'Use esta função sempre que a resposta depender de eventos atuais, notícias, '
      'fatos que possam ter mudado ou informações não disponíveis no modelo.';

  @override
  Map<String, String> get parameterDescriptions => {
        'query': '(string) The search query to send to the web.',
      };

  @override
  Map<String, String> get parameterDescriptionsPt => {
        'query': '(string) A consulta de busca a ser enviada para a web.',
      };

  @override
  Future<ToolResult> execute(ToolCall call) async {
    final query = call.arguments['query']?.toString() ?? '';
    if (query.isEmpty) {
      return ToolResult.error(
        toolName: name,
        reason: 'Missing required parameter: query.',
      );
    }

    debugPrint('SearchInternetHandler: searching for "$query"');

    if (!_webSearch.isConfigured) {
      return ToolResult.error(
        toolName: name,
        reason: 'Tavily API key is not configured.',
      );
    }

    try {
      final results = await _webSearch.search(
        query,
        maxResults: 5,
        searchDepth: 'advanced',
        includeAnswer: true,
      );

      if (results.isEmpty) {
        return ToolResult.error(
          toolName: name,
          reason: 'No results found for the query.',
        );
      }

      final buffer = StringBuffer();

      // Include the Tavily answer summary when available.
      final answer = results.first.answer;
      if (answer != null && answer.isNotEmpty) {
        buffer.writeln('Answer:');
        buffer.writeln(answer);
        buffer.writeln();
      }

      buffer.writeln('Sources:');
      buffer.writeln();

      for (var i = 0; i < results.length; i++) {
        final r = results[i];
        final content =
            r.content.length > 400 ? '${r.content.substring(0, 400)}…' : r.content;

        buffer.writeln('${i + 1}.');
        buffer.writeln('Title: ${r.title}');
        buffer.writeln('Content: $content');
        buffer.writeln('URL: ${r.url}');
        buffer.writeln();
      }

      return ToolResult.success(
        toolName: name,
        content: buffer.toString().trimRight(),
      );
    } catch (e) {
      debugPrint('SearchInternetHandler: error — $e');
      return ToolResult.error(toolName: name, reason: e.toString());
    }
  }
}
