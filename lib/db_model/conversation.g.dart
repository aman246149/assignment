// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationHiveAdapter extends TypeAdapter<ConversationHive> {
  @override
  final int typeId = 2;

  @override
  ConversationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationHive(
      id: fields[0] as String,
      userId: fields[1] as String,
      unreadCount: fields[2] as int,
      lastMessageTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.unreadCount)
      ..writeByte(3)
      ..write(obj.lastMessageTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
