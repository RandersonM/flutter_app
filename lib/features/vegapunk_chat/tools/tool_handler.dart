import 'package:flutter_gemma/core/tool.dart' as gemma;

import 'models/tool_call.dart';
import 'models/tool_result.dart';

/// Abstract interface for a tool (function) the model can invoke.
///
/// Implement this to add new capabilities (e.g. getWeather, searchFirebase).
/// Register implementations via [FunctionRegistry].
abstract class ToolHandler {
  /// The unique name used in function call JSON emitted by the model.
  String get name;

  /// Short description injected into the system prompt so the model
  /// knows when and how to use this tool.
  String get description;

  /// Portuguese description. Defaults to [description] if not overridden.
  String get descriptionPt => description;

  /// JSON-schema-like parameter descriptions used in the system prompt.
  Map<String, String> get parameterDescriptions;

  /// Portuguese parameter descriptions. Defaults to [parameterDescriptions].
  Map<String, String> get parameterDescriptionsPt => parameterDescriptions;

  /// Which parameters are required for this tool. Defaults to all.
  List<String> get requiredParameters => parameterDescriptions.keys.toList();

  /// Execute the tool with the parsed [args] from the model output.
  Future<ToolResult> execute(ToolCall call);

  /// Convert this handler into a native [gemma.Tool] for the Gemma 4 SDK.
  ///
  /// Uses JSON Schema format for parameter definitions, which is what
  /// the Gemma 4 E2B model is trained to interpret natively.
  gemma.Tool toFlutterGemmaTool({bool isPortuguese = false}) {
    final desc = isPortuguese ? descriptionPt : description;
    final params = isPortuguese
        ? parameterDescriptionsPt
        : parameterDescriptions;

    final properties = <String, dynamic>{};
    for (final entry in params.entries) {
      properties[entry.key] = {'type': 'string', 'description': entry.value};
    }

    return gemma.Tool(
      name: name,
      description: desc,
      parameters: {
        'type': 'object',
        'properties': properties,
        if (requiredParameters.isNotEmpty) 'required': requiredParameters,
      },
    );
  }
}
