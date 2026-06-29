import 'package:flutter/foundation.dart';

import 'models/tool_call.dart';
import 'models/tool_result.dart';
import 'tool_handler.dart';

/// Central registry that maps function names to their [ToolHandler]s.
///
/// Usage:
/// ```dart
/// final registry = FunctionRegistry();
/// registry.register(SearchInternetHandler(webSearch: ...));
///
/// // Execute a parsed tool call:
/// final result = await registry.execute(toolCall);
///
/// // Get system prompt declarations for all registered tools:
/// final declarations = registry.systemPromptDeclarations;
/// ```
class FunctionRegistry {
  final Map<String, ToolHandler> _handlers = {};

  /// Register a [ToolHandler]. Overwrites any previously registered handler
  /// with the same name.
  void register(ToolHandler handler) {
    _handlers[handler.name] = handler;
    debugPrint('FunctionRegistry: registered tool "${handler.name}"');
  }

  /// Returns true if a handler for [name] is registered.
  bool has(String name) => _handlers.containsKey(name);

  /// Execute the tool call, dispatching to the registered [ToolHandler].
  /// Returns a [ToolResult.error] if no handler is found.
  Future<ToolResult> execute(ToolCall call) async {
    final handler = _handlers[call.name];
    if (handler == null) {
      debugPrint('FunctionRegistry: no handler for "${call.name}"');
      return ToolResult.error(
        toolName: call.name,
        reason: 'Unknown function "${call.name}".',
      );
    }
    debugPrint('FunctionRegistry: executing "${call.name}" with args ${call.arguments}');
    return handler.execute(call);
  }

  /// Builds the function declarations block injected into the system prompt.
  ///
  /// Pass [isPortuguese] to use the handlers' PT descriptions when available.
  String systemPromptDeclarations({bool isPortuguese = false}) {
    if (_handlers.isEmpty) return '';

    final buffer = StringBuffer('AVAILABLE FUNCTIONS:\n');
    for (final handler in _handlers.values) {
      final desc = isPortuguese ? handler.descriptionPt : handler.description;
      final params = isPortuguese
          ? handler.parameterDescriptionsPt
          : handler.parameterDescriptions;
      buffer.writeln();
      buffer.writeln('Function: ${handler.name}');
      buffer.writeln('Description: $desc');
      if (params.isNotEmpty) {
        buffer.writeln('Parameters:');
        for (final entry in params.entries) {
          buffer.writeln('  ${entry.key}: ${entry.value}');
        }
      }
    }
    return buffer.toString().trimRight();
  }
}
