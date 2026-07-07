/// Encapsulates the result (or error) returned by a tool handler.
class ToolResult {
  const ToolResult({
    required this.toolName,
    required this.content,
    this.isError = false,
  });

  /// Convenience constructor for successful results.
  const ToolResult.success({
    required String toolName,
    required String content,
  }) : this(toolName: toolName, content: content);

  /// Convenience constructor for error results.
  const ToolResult.error({
    required String toolName,
    required String reason,
  }) : this(
          toolName: toolName,
          content:
              'Tool "$toolName" failed.\n\nReason:\n$reason\n\nAsk the user to try again later.',
          isError: true,
        );

  /// The name of the tool that produced this result.
  final String toolName;

  /// Human-readable content to inject back into the model context.
  final String content;

  /// Whether this result represents a failure.
  final bool isError;

  @override
  String toString() =>
      'ToolResult(toolName: $toolName, isError: $isError, content: $content)';
}
