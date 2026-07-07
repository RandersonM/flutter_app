import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.onStop,
    required this.isGenerating,
    this.enabled = true,
  });

  final void Function(String text) onSend;
  final VoidCallback onStop;
  final bool isGenerating;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _hasText = false);
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Constants.size16,
          vertical: Constants.size12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled && !widget.isGenerating,
                maxLines: 4,
                minLines: 1,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: l10n.vegapunkChatHint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Constants.size16,
                    vertical: Constants.size12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Constants.size24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Constants.size24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Constants.size24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Constants.margin),
            _ActionButton(
              isGenerating: widget.isGenerating,
              canSend: _hasText && widget.enabled,
              onSend: _submit,
              onStop: widget.onStop,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isGenerating,
    required this.canSend,
    required this.onSend,
    required this.onStop,
  });

  final bool isGenerating;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isGenerating) {
      return _circleButton(
        context,
        icon: PhosphorIconsRegular.stop,
        color: theme.colorScheme.error,
        onTap: onStop,
      );
    }

    return _circleButton(
      context,
      icon: PhosphorIconsRegular.paperPlaneRight,
      color: canSend
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      onTap: canSend ? onSend : null,
    );
  }

  Widget _circleButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: Constants.size48,
      height: Constants.size48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: Constants.size20),
    ),
  );
}
