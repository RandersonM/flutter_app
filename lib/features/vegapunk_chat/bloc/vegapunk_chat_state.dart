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
    this.activeToolName,
  });

  final List<ChatMessage> messages;

  /// Partial token buffer accumulated during streaming.
  final String streamingToken;

  final bool isGenerating;

  final VegapunkSatellite selectedSatellite;

  final bool isThinkingMode;

  /// Non-null while a tool is executing. Holds the raw registered tool name
  /// (e.g. "getWorkoutHistory") — not a display label. The cubit has no
  /// BuildContext, so localization of the label happens in the widget layer
  /// via `AppLocalizations`. Null means no tool is running.
  final String? activeToolName;

  @override
  List<Object?> get props => [
    messages,
    streamingToken,
    isGenerating,
    selectedSatellite,
    isThinkingMode,
    activeToolName,
  ];

  VegapunkChatReady copyWith({
    List<ChatMessage>? messages,
    String? streamingToken,
    bool? isGenerating,
    VegapunkSatellite? selectedSatellite,
    bool? isThinkingMode,
    // Use Object? sentinel to allow explicitly setting to null.
    Object? activeToolName = _keepCurrent,
  }) => VegapunkChatReady(
    messages: messages ?? this.messages,
    streamingToken: streamingToken ?? this.streamingToken,
    isGenerating: isGenerating ?? this.isGenerating,
    selectedSatellite: selectedSatellite ?? this.selectedSatellite,
    isThinkingMode: isThinkingMode ?? this.isThinkingMode,
    activeToolName: activeToolName == _keepCurrent
        ? this.activeToolName
        : activeToolName as String?,
  );

  static const _keepCurrent = Object();
}

class VegapunkChatError extends VegapunkChatState {
  const VegapunkChatError({required this.message, this.isInstallError = false});

  final String message;

  /// True when the error occurred during model install/download.
  final bool isInstallError;

  @override
  List<Object?> get props => [message, isInstallError];
}
