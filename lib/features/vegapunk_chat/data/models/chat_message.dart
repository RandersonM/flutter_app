import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/storage/hive_type_ids.dart';

enum MessageRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.satelliteId,
  });

  final String id;
  final String text;
  final MessageRole role;

  /// When this message was created. Needed for deterministic ordering when
  /// loading history and for the session-document retention policy (see
  /// `.specs/features/vegapunk-chat-memory/context.md`, D1).
  final DateTime timestamp;

  /// Name of the `VegapunkSatellite` active when this message was generated
  /// (null for user messages). Display metadata only — does not partition
  /// the history into separate threads.
  final String? satelliteId;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  ChatMessage copyWith({String? text}) => ChatMessage(
    id: id,
    text: text ?? this.text,
    role: role,
    timestamp: timestamp,
    satelliteId: satelliteId,
  );

  @override
  List<Object?> get props => [id, text, role, timestamp, satelliteId];
}

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = HiveTypeIds.vegapunkChatMessage;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      id: fields[0] as String,
      text: fields[1] as String,
      role: fields[2] as MessageRole,
      timestamp: fields[3] as DateTime,
      satelliteId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.satelliteId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageRoleAdapter extends TypeAdapter<MessageRole> {
  @override
  final int typeId = HiveTypeIds.vegapunkMessageRole;

  @override
  MessageRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageRole.user;
      case 1:
        return MessageRole.assistant;
      default:
        return MessageRole.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageRole obj) {
    switch (obj) {
      case MessageRole.user:
        writer.writeByte(0);
        break;
      case MessageRole.assistant:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
