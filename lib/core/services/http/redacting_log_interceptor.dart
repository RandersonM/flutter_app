import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final _secretQueryParam = RegExp(
  r'([?&](?:key|api_key|apikey|access_token|token)=)[^&\s#]+',
  caseSensitive: false,
);
final _secretField = RegExp(
  r'''\b(x-goog-api-key|api_key|apikey|authorization)(["']?\s*[:=]\s*["']?)([^"'\s,}\]]+(?: [^"'\s,}\]]+)?)''',
  caseSensitive: false,
);

/// Masks API keys and auth values in a logged request or response: query
/// parameters (`?key=…`), headers (`x-goog-api-key: …`, `Authorization: …`)
/// and JSON fields (`"api_key": "…"`).
String redactSecrets(String text) => text
    .replaceAllMapped(_secretQueryParam, (m) => '${m[1]}***')
    .replaceAllMapped(_secretField, (m) => '${m[1]}${m[2]}***');

/// Dio's [LogInterceptor] with secrets masked, for debug builds.
class RedactingLogInterceptor extends LogInterceptor {
  RedactingLogInterceptor()
    : super(requestBody: true, responseBody: true, logPrint: _print);

  static void _print(Object line) => debugPrint(redactSecrets('$line'));
}
