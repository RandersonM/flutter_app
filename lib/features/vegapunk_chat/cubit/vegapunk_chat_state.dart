import 'package:equatable/equatable.dart';
import '../data/models/chat_message.dart';
import '../data/models/vegapunk_satellite.dart';

sealed class VegapunkChatState extends Equatable {
  const VegapunkChatState();

  @override
  List<Object?> get props => [];
}

class VegapunkModelNotInstalled extends VegapunkChatState {
  const VegapunkModelNotInstalled();
}

class VegapunkModelDownloading extends VegapunkChatState {
  const VegapunkModelDownloading(this.progress);
  final int progress;

  @override
  List<Object?> get props => [progress];
}

class VegapunkModelLoading extends VegapunkChatState {
  const VegapunkModelLoading();
}

/// Model is ready and the user can interact with the chat.
class VegapunkChatReady extends VegapunkChatState {
  const VegapunkChatReady({
    this.messages = const [],
    this.streamingToken = '',
    this.isGenerating = false,
    this.selectedSatellite = VegapunkSatellite.stella,
    this.isThinkingMode = false,
    this.isSearchingWeb = false,
  });

  final List<ChatMessage> messages;

  /// Partial token buffer accumulated during streaming.
  final String streamingToken;

  final bool isGenerating;

  final VegapunkSatellite selectedSatellite;

  final bool isThinkingMode;

  /// True while Gemma has triggered a web search and we are awaiting
  /// the Tavily result. Used to show a "Searching the web…" indicator.
  final bool isSearchingWeb;

  @override
  List<Object?> get props =>
      [messages, streamingToken, isGenerating, selectedSatellite, isThinkingMode, isSearchingWeb];

  VegapunkChatReady copyWith({
    List<ChatMessage>? messages,
    String? streamingToken,
    bool? isGenerating,
    VegapunkSatellite? selectedSatellite,
    bool? isThinkingMode,
    bool? isSearchingWeb,
  }) =>
      VegapunkChatReady(
        messages: messages ?? this.messages,
        streamingToken: streamingToken ?? this.streamingToken,
        isGenerating: isGenerating ?? this.isGenerating,
        selectedSatellite: selectedSatellite ?? this.selectedSatellite,
        isThinkingMode: isThinkingMode ?? this.isThinkingMode,
        isSearchingWeb: isSearchingWeb ?? this.isSearchingWeb,
      );
}

class VegapunkChatError extends VegapunkChatState {
  const VegapunkChatError({
    required this.message,
    this.isInstallError = false,
  });

  final String message;

  /// True when the error occurred during model install/download.
  final bool isInstallError;

  @override
  List<Object?> get props => [message, isInstallError];
}
