import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'models/tool_call.dart';

/// Detects and parses function call JSON from a text buffer produced by Gemma.
///
/// The model is prompted to emit tool calls in this format:
/// ```json
/// {"name": "searchInternet", "arguments": {"query": "..."}}
/// ```
///
/// This executor scans the accumulated text for that JSON pattern and
/// extracts it, leaving the surrounding text intact (or empty if the
/// entire output is the function call).
class FunctionExecutor {
  // Matches the function call JSON block, optionally wrapped in a code fence.
  // Handles both raw JSON and ```json ... ``` fences.
  static final _jsonPattern = RegExp(
    r'\{[^{}]*"name"\s*:\s*"([^"]+)"[^{}]*"arguments"\s*:\s*\{[^{}]*\}[^{}]*\}',
    dotAll: true,
  );

  static final _codeFencePattern = RegExp(
    r'```(?:json)?\s*(\{[\s\S]*?\})\s*```',
  );

  /// Try to parse a [ToolCall] from [text].
  ///
  /// Returns `null` if no valid function call is found.
  ToolCall? tryParse(String text) {
    // First try to extract from a code fence block.
    final fenceMatch = _codeFencePattern.firstMatch(text);
    if (fenceMatch != null) {
      final extracted = fenceMatch.group(1);
      if (extracted != null) {
        final call = _parseJson(extracted);
        if (call != null) return call;
      }
    }

    // Then try raw JSON pattern.
    final match = _jsonPattern.firstMatch(text);
    if (match != null) {
      return _parseJson(match.group(0)!);
    }

    return null;
  }

  ToolCall? _parseJson(String raw) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final name = decoded['name'] as String?;
      final args = decoded['arguments'];

      if (name == null || name.isEmpty) return null;

      final argsMap = (args is Map<String, dynamic>) ? args : <String, dynamic>{};
      return ToolCall(name: name, arguments: argsMap);
    } catch (e) {
      debugPrint('FunctionExecutor: failed to parse JSON — $e');
      return null;
    }
  }

  /// Returns the [text] with the function call JSON block stripped out,
  /// suitable for display or further injection.
  String stripFunctionCall(String text) {
    var result = _codeFencePattern.hasMatch(text)
        ? text.replaceAll(_codeFencePattern, '')
        : text.replaceAll(_jsonPattern, '');
    return result.trim();
  }
}
