import 'package:equatable/equatable.dart';
import 'package:opfan/features/vegapunk_chat/data/models/chat_message.dart';

enum NamiChatFailure {
  modelNotInstalled,
  modelLoadFailed,
  connectionFailed,
  generationTimedOut,
  expenseSearchNotReady,
}

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
  final NamiChatFailure? failure;

  const NamiChatReady({
    this.messages = const [],
    this.isGenerating = false,
    this.streamingToken = '',
    this.failure,
  });

  NamiChatReady copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? streamingToken,
    NamiChatFailure? failure,
  }) {
    return NamiChatReady(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingToken: streamingToken ?? this.streamingToken,
      failure: failure, // Clear failure by default unless explicitly provided
    );
  }

  @override
  List<Object?> get props => [messages, isGenerating, streamingToken, failure];
}
