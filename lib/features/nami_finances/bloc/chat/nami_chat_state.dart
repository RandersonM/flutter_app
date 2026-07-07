import 'package:equatable/equatable.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';

abstract class NamiChatState extends Equatable {
  const NamiChatState();

  @override
  List<Object?> get props => [];
}

class NamiChatInitial extends NamiChatState {}

/// Emitted while the shared Gemma model and the finances RAG store are
/// being prepared — the sheet should block input and show a loading
/// affordance instead of letting the user send a message that can't
/// possibly get a response yet.
class NamiChatLoading extends NamiChatState {}

class NamiChatReady extends NamiChatState {
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String streamingToken;
  final String? error;

  const NamiChatReady({
    this.messages = const [],
    this.isGenerating = false,
    this.streamingToken = '',
    this.error,
  });

  NamiChatReady copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? streamingToken,
    String? error,
  }) {
    return NamiChatReady(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingToken: streamingToken ?? this.streamingToken,
      error: error, // Clear error by default unless explicitly provided
    );
  }

  @override
  List<Object?> get props => [messages, isGenerating, streamingToken, error];
}
