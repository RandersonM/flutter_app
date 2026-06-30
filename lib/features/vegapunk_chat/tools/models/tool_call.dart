/// Represents a function call emitted by the model.
class ToolCall {
  const ToolCall({
    required this.name,
    required this.arguments,
  });

  /// The registered function name (e.g. "searchInternet").
  final String name;

  /// Key-value arguments parsed from the model output.
  final Map<String, dynamic> arguments;

  @override
  String toString() => 'ToolCall(name: $name, arguments: $arguments)';
}
