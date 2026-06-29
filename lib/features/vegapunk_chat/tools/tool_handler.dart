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

  /// Execute the tool with the parsed [args] from the model output.
  Future<ToolResult> execute(ToolCall call);
}
