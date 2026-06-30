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
  // Matches JSON wrapped in a ```json ... ``` code fence, used by stripFunctionCall.
  static final _codeFencePattern = RegExp(
    r'```(?:json)?\s*(\{[\s\S]*?\})\s*```',
  );

  ToolCall? tryParse(String text) {
    // Find the first '{' and try to parse JSON
    int startIndex = text.indexOf('{');
    while (startIndex != -1) {
      // We found a '{', now try to find the matching '}'
      int openCount = 0;
      for (int i = startIndex; i < text.length; i++) {
        if (text[i] == '{') openCount++;
        if (text[i] == '}') {
          openCount--;
          if (openCount == 0) {
            // Potential JSON object
            final candidate = text.substring(startIndex, i + 1);
            final call = _parseJson(candidate);
            if (call != null) return call;
          }
        }
      }
      // If not found or invalid, try the next '{'
      startIndex = text.indexOf('{', startIndex + 1);
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
    if (_codeFencePattern.hasMatch(text)) {
      return text.replaceAll(_codeFencePattern, '').trim();
    }
    // Strip raw JSON tool call via brace-matching (same logic as tryParse).
    final call = tryParse(text);
    if (call == null) return text.trim();
    int startIndex = text.indexOf('{');
    while (startIndex != -1) {
      int openCount = 0;
      for (int i = startIndex; i < text.length; i++) {
        if (text[i] == '{') openCount++;
        if (text[i] == '}') {
          openCount--;
          if (openCount == 0) {
            final candidate = text.substring(startIndex, i + 1);
            if (_parseJson(candidate) != null) {
              return (text.substring(0, startIndex) + text.substring(i + 1)).trim();
            }
          }
        }
      }
      startIndex = text.indexOf('{', startIndex + 1);
    }
    return text.trim();
  }
}
