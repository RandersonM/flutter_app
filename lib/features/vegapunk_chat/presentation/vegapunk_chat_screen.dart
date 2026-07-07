import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:opfan/app/di/injection.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';
import 'package:opfan/shared/widgets/organisms/bottom_navigation.dart';

import '../cubit/index.dart';
import '../data/models/vegapunk_satellite.dart';
import 'widgets/index.dart';

class VegapunkChatScreen extends StatelessWidget {
  const VegapunkChatScreen({super.key, this.targetCategories});

  final List<String>? targetCategories;

  @override
  Widget build(BuildContext context) {
    List<String>? categories = targetCategories;

    if (categories == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is List<String>) {
        categories = args;
      } else if (args is List) {
        categories = args.map((e) => e.toString()).toList();
      } else if (args is String) {
        categories = [args];
      }
    }

    return BlocProvider<VegapunkChatCubit>(
      create: (_) => getIt<VegapunkChatCubit>()..initialize(targetCategories: categories),
      child: const _VegapunkChatView(),
    );
  }
}

class _VegapunkChatView extends StatefulWidget {
  const _VegapunkChatView();

  @override
  State<_VegapunkChatView> createState() => _VegapunkChatViewState();
}

class _VegapunkChatViewState extends State<_VegapunkChatView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(l10n.vegapunkChatTitle),
        actions: [
          BlocBuilder<VegapunkChatCubit, VegapunkChatState>(
            buildWhen: (prev, curr) =>
                curr is VegapunkChatReady && prev is VegapunkChatReady
                    ? prev.messages.length != curr.messages.length
                    : false,
            builder: (context, state) {
              if (state is! VegapunkChatReady ||
                  state.messages.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowCounterClockwise),
                tooltip: 'Reset chat',
                onPressed: () =>
                    context.read<VegapunkChatCubit>().reset(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar:
          const BottomNavigation(BottomNavigationPages.vegapunkChat),
      body: BlocConsumer<VegapunkChatCubit, VegapunkChatState>(
        listenWhen: (_, curr) =>
            curr is VegapunkChatReady && curr.isGenerating,
        listener: (_, __) => _scrollToBottom(),
        builder: (context, state) {
          if (state is! VegapunkChatReady) {
            return ModelDownloadOverlay(
              state: state,
              onDownload: () =>
                  context.read<VegapunkChatCubit>().downloadModel(),
              onRetry: () => context.read<VegapunkChatCubit>().initialize(),
            );
          }

          return Column(
            children: [
              _SatelliteSelector(
                selected: state.selectedSatellite,
                onSelected: (satellite) =>
                    context.read<VegapunkChatCubit>().changeSatellite(satellite),
              ),
              _ThinkingModeToggle(
                isEnabled: state.isThinkingMode,
                onChanged: (enabled) =>
                    context.read<VegapunkChatCubit>().toggleThinkingMode(enabled),
              ),
              Expanded(child: _ChatList(state: state, scrollController: _scrollController)),
              if (state.isSearchingWeb) const _WebSearchIndicator(),
              ChatInputBar(
                isGenerating: state.isGenerating,
                enabled: true,
                onSend: (text) {
                  context.read<VegapunkChatCubit>().sendMessage(text);
                  _scrollToBottom();
                },
                onStop: () =>
                    context.read<VegapunkChatCubit>().stopGeneration(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList({
    required this.state,
    required this.scrollController,
  });

  final VegapunkChatReady state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (state.messages.isEmpty && !state.isGenerating) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.size32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsRegular.robot,
                  size: Constants.size64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: Constants.size16),
                Text(
                  l10n.vegapunkChatEmpty,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = state.messages;
    final isGenerating = state.isGenerating;
    final itemCount = items.length + (isGenerating ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.size16,
        vertical: Constants.size12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (isGenerating && index == items.length) {
          if (state.streamingToken.isNotEmpty) {
            return _StreamingBubble(token: state.streamingToken);
          } else {
            return const _ThinkingBubble();
          }
        }
        return ChatMessageBubble(message: items[index]);
      },
    );
  }
}

/// Assistant bubble shown while tokens are still streaming in.
class _StreamingBubble extends StatelessWidget {
  const _StreamingBubble({required this.token});
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
            color: theme.colorScheme.surfaceContainer,
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

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

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
            color: theme.colorScheme.surfaceContainer,
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
          child: const _TypingIndicator(),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
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

class _SatelliteSelector extends StatelessWidget {
  const _SatelliteSelector({
    required this.selected,
    required this.onSelected,
  });

  final VegapunkSatellite selected;
  final ValueChanged<VegapunkSatellite> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Constants.size12, vertical: 8.0),
        itemCount: VegapunkSatellite.values.length,
        itemBuilder: (context, index) {
          final satellite = VegapunkSatellite.values[index];
          final isSelected = satellite == selected;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                satellite.getLocalizedName(l10n),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(satellite),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              elevation: isSelected ? 2 : 0,
              pressElevation: 1,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.size16),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThinkingModeToggle extends StatelessWidget {
  const _ThinkingModeToggle({
    required this.isEnabled,
    required this.onChanged,
  });

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.size16,
        vertical: Constants.size12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.size16,
        vertical: Constants.size12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Constants.size12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.brain,
            color: isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: Constants.size24,
          ),
          const SizedBox(width: Constants.size12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.vegapunkThinkingMode,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.vegapunkThinkingModeDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Constants.size12),
          Switch.adaptive(
            value: isEnabled,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

/// Animated indicator shown while Gemma is performing a web search via Tavily.
class _WebSearchIndicator extends StatefulWidget {
  const _WebSearchIndicator();

  @override
  State<_WebSearchIndicator> createState() => _WebSearchIndicatorState();
}

class _WebSearchIndicatorState extends State<_WebSearchIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(
                  alpha: _pulseAnimation.value * 0.9,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.globe,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Searching the web…',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Pulsing dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(
                        alpha: _pulseAnimation.value,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
