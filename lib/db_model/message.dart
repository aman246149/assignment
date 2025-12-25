import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class MessageHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final bool isMe;

  @HiveField(4)
  final DateTime timestamp;

  MessageHive({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.isMe,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
