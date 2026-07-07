import 'package:flutter/material.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/features/vegapunk_chat/presentation/widgets/index.dart'; // For StreamingText

class ChatStreamingBubble extends StatelessWidget {
  const ChatStreamingBubble({super.key, required this.token});
  final String token;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(
            top: Constants.margin,
            bottom: Constants.margin,
            right: Constants.size40,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.size16,
            vertical: Constants.size12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: StreamingText(text: token, isStreaming: true),
        ),
      ),
    );
  }
}

class ChatThinkingBubble extends StatelessWidget {
  const ChatThinkingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(
            top: Constants.margin,
            bottom: Constants.margin,
            right: Constants.size40,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.size20,
            vertical: Constants.size16,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const ChatTypingIndicator(),
        ),
      ),
    );
  }
}

class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final animationValue = _controller.value;
            // Create a staggered bounce effect
            final offset = (animationValue * 3 - index) % 3;
            double opacity = 0.3;
            double translateY = 0;
            
            if (offset >= 0 && offset <= 1) {
              // Up and down bounce
              translateY = -3 * (0.5 - (offset - 0.5).abs());
              opacity = 0.3 + 0.7 * (1 - (offset - 0.5).abs() * 2);
            }

            return Transform.translate(
              offset: Offset(0, translateY),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
