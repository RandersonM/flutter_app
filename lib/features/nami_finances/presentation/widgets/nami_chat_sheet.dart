import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/shared/utils/constants.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_chat_bloc.dart';
import 'package:opfan/features/nami_finances/bloc/chat/nami_chat_state.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/services/index.dart';
import 'package:opfan/features/nami_finances/data/services/nami_rag_service.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';
import 'package:opfan/shared/widgets/atoms/chat_loading_bubbles.dart';

class NamiChatSheet extends StatelessWidget {
  const NamiChatSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NamiChatBloc(
        getIt<NamiRagService>(),
        getIt<IGemmaService>(),
        getIt<INamiFinancesService>(),
      ),
      child: const _NamiChatSheetContent(),
    );
  }
}

class _NamiChatSheetContent extends StatefulWidget {
  const _NamiChatSheetContent();

  @override
  State<_NamiChatSheetContent> createState() => _NamiChatSheetContentState();
}

class _NamiChatSheetContentState extends State<_NamiChatSheetContent> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: BlocConsumer<NamiChatBloc, NamiChatState>(
              listener: (context, state) {
                if (state is NamiChatReady && state.isGenerating) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is NamiChatReady) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(Constants.margin),
                    itemCount:
                        state.messages.length +
                        (state.isGenerating ? 1 : 0) +
                        (state.error != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < state.messages.length) {
                        return _buildMessageBubble(
                          context,
                          state.messages[index],
                        );
                      }
                      index -= state.messages.length;

                      if (state.isGenerating) {
                        if (index == 0) {
                          return state.streamingToken.isEmpty
                              ? const ChatThinkingBubble()
                              : ChatStreamingBubble(
                                  token: state.streamingToken,
                                );
                        }
                        index -= 1;
                      }

                      return _buildErrorBubble(context, state.error!);
                    },
                  );
                }
                return const _NamiChatLoadingView();
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.margin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/logo/nami-icon.png'),
              ),
              const SizedBox(width: Constants.margin),
              Text(
                'Nami Finances AI',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: Constants.margin),
        padding: const EdgeInsets.all(Constants.margin),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(message.text), // We can use markdown here if we want
      ),
    );
  }

  Widget _buildErrorBubble(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: Constants.margin),
        padding: const EdgeInsets.all(Constants.margin),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(
            16,
          ).copyWith(bottomLeft: Radius.zero),
        ),
        child: Text(
          error,
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return BlocBuilder<NamiChatBloc, NamiChatState>(
      builder: (context, state) {
        final isReady = state is NamiChatReady;
        final isGenerating = isReady && state.isGenerating;
        final canSend = isReady && !isGenerating;

        void send() {
          if (!canSend) return;
          context.read<NamiChatBloc>().sendMessage(_controller.text);
          _controller.clear();
        }

        return Padding(
          padding: const EdgeInsets.all(Constants.margin),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: isReady,
                  decoration: InputDecoration(
                    hintText: 'Pergunte sobre suas finanças...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
                onPressed: canSend ? send : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NamiChatLoadingView extends StatelessWidget {
  const _NamiChatLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: Constants.margin),
          Text(
            'Preparando Nami...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
