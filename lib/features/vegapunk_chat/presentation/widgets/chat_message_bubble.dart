import 'package:flutter/material.dart';
import 'package:opfan/shared/widgets/molecules/untrusted_markdown_configs.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/shared/utils/constants.dart';

import 'package:markdown_widget/markdown_widget.dart';

class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  // Cached so a parent rebuild (e.g. a token tick from a *different*,
  // currently-streaming bubble) doesn't re-run the regexes and rebuild the
  // 6-object MarkdownConfig for every historical bubble on screen — see
  // `message` and `_configBrightness` below for the invalidation keys.
  ChatMessage? _cleanedFor;
  String? _cleanedText;
  Brightness? _configBrightness;
  MarkdownConfig? _config;

  String _cleanedTextFor(ChatMessage message) {
    if (_cleanedFor != message) {
      _cleanedFor = message;
      _cleanedText = _cleanAiText(message.text);
    }
    return _cleanedText!;
  }

  MarkdownConfig _configFor(BuildContext context, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    if (_configBrightness != brightness) {
      _configBrightness = brightness;
      _config = _buildConfig(context, isDark);
    }
    return _config!;
  }

  /// Cleans AI-generated text before rendering:
  /// - Collapses 3+ consecutive blank lines to 2
  /// - Removes duplicate consecutive separator lines (---, ***, ===)
  /// - Trims leading/trailing whitespace
  static String _cleanAiText(String text) {
    // Collapse 3+ blank lines into one blank line
    var cleaned = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    // Deduplicate back-to-back separator lines
    cleaned = cleaned.replaceAll(
      RegExp(r'(^[ \t]*[-*=]{3,}[ \t]*\n){2,}', multiLine: true),
      '---\n',
    );
    return cleaned.trim();
  }

  MarkdownConfig _buildConfig(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final baseTextStyle =
        theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurface,
          height: 1.55,
        ) ??
        const TextStyle();

    final base = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    return base.copy(
      configs: [
        ...untrustedMarkdownConfigs(context),

        // Paragraphs
        PConfig(textStyle: baseTextStyle),

        // Headings — respect the app's text theme
        H1Config(
          style:
              theme.textTheme.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ) ??
              const TextStyle(),
        ),
        H2Config(
          style:
              theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ) ??
              const TextStyle(),
        ),
        H3Config(
          style:
              theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ) ??
              const TextStyle(),
        ),

        // Inline code
        CodeConfig(
          style:
              theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: cs.primary,
                backgroundColor: cs.primaryContainer.withValues(
                  alpha: isDark ? 0.35 : 0.2,
                ),
              ) ??
              const TextStyle(),
        ),

        // Tables: wrap in horizontal scroll so they NEVER overflow the bubble
        TableConfig(
          wrapper: (tableWidget) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: tableWidget,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = widget.message;
    final isUser = message.isUser;
    final isDark = theme.brightness == Brightness.dark;

    // AI bubbles are wider (90 %) to give Markdown tables more room;
    // user bubbles stay at 78 % for the classic chat layout.
    final maxWidthFraction = isUser ? 0.78 : 0.90;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * maxWidthFraction,
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
                color: theme.colorScheme.shadow.withValues(alpha: 0.06),
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
                  data: _cleanedTextFor(message),
                  config: _configFor(context, isDark),
                ),
        ),
      ),
    );
  }
}
