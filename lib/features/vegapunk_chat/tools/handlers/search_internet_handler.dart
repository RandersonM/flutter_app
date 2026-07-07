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
import 'package:opfan/core/connectivity/connectivity_cubit.dart';

class SearchInternetHandler extends ToolHandler {
  SearchInternetHandler({
    required this.webSearch,
    required this.connectivityCubit,
  });

  final IWebSearchService webSearch;
  final ConnectivityCubit connectivityCubit;

  @override
  String get name => 'searchInternet';

  @override
  String get description =>
      'MUST use when asked about: sports scores, game schedules, current events, news, weather, real-world facts. Returns web search results.';

  @override
  String get descriptionPt =>
      'DEVE ser usado para: placares, jogos, notícias, clima, eventos atuais. Retorna resultados da web.';

  @override
  Map<String, String> get parameterDescriptions => {
    'query': '(string) The search query to send to the web.',
    'searchTopic':
        '(string) Optional. Must be one of: "general", "news", or "finance". Defaults to "general".',
  };

  @override
  Map<String, String> get parameterDescriptionsPt => {
    'query': '(string) A consulta de busca a ser enviada para a web.',
    'searchTopic':
        '(string) Opcional. Deve ser: "general", "news", ou "finance". O padrão é "general".',
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

    final searchTopicStr =
        call.arguments['searchTopic']?.toString() ?? 'general';
    final searchTopic = SearchTopic.values.firstWhere(
      (e) => e.name == searchTopicStr,
      orElse: () => SearchTopic.general,
    );

    debugPrint(
      'SearchInternetHandler: searching for "$query" (topic: ${searchTopic.name})',
    );

    if (!connectivityCubit.isOnline) {
      return ToolResult.error(
        toolName: name,
        reason:
            'The device is currently offline. Internet search is unavailable.',
      );
    }

    if (!webSearch.isConfigured) {
      return ToolResult.error(
        toolName: name,
        reason: 'Tavily API key is not configured.',
      );
    }

    try {
      final results = await webSearch.search(
        query,
        maxResults: 5,
        searchDepth: 'advanced',
        includeAnswer: 'advanced',
        searchTopic: searchTopic,
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
        final content = r.content.length > 400
            ? '${r.content.substring(0, 400)}…'
            : r.content;

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
