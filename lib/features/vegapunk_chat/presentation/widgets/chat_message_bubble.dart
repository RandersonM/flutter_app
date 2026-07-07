import 'package:flutter/material.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/shared/utils/constants.dart';

import 'package:markdown_widget/markdown_widget.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: Constants.margin,
            bottom: Constants.margin,
            left: isUser ? Constants.size40 : 0,
            right: isUser ? 0 : Constants.size40,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.size16,
            vertical: Constants.size12,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isUser
              ? Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    height: 1.5,
                  ),
                )
              : MarkdownBlock(
                  data: message.text,
                  config:
                      (isDark
                              ? MarkdownConfig.darkConfig
                              : MarkdownConfig.defaultConfig)
                          .copy(
                            configs: [
                              PConfig(
                                textStyle:
                                    theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      height: 1.5,
                                    ) ??
                                    const TextStyle(),
                              ),
                            ],
                          ),
                ),
        ),
      ),
    );
  }
}
