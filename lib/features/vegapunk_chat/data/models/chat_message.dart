import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({required this.id, required this.text, required this.role});

  final String id;
  final String text;
  final MessageRole role;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  ChatMessage copyWith({String? text}) =>
      ChatMessage(id: id, text: text ?? this.text, role: role);

  @override
  List<Object?> get props => [id, text, role];
}
