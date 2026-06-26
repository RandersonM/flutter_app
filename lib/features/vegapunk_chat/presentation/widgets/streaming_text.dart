import 'package:flutter/material.dart';
import 'package:opfan/shared/utils/constants.dart';

/// Renders streaming LLM output with a blinking cursor while generating.
class StreamingText extends StatefulWidget {
  const StreamingText({
    super.key,
    required this.text,
    required this.isStreaming,
  });

  final String text;
  final bool isStreaming;

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursor;

  @override
  void initState() {
    super.initState();
    _cursor = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!widget.isStreaming || widget.text.isEmpty) {
      return Text(
        widget.text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _cursor,
      builder: (context, _) {
        final showCursor = _cursor.value > 0.5;
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: widget.text),
              TextSpan(
                text: showCursor ? '▋' : ' ',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: Constants.size16,
                ),
              ),
            ],
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.5,
          ),
        );
      },
    );
  }
}
