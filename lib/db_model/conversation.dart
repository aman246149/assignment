import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 2)
class ConversationHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final int unreadCount;

  @HiveField(3)
  final DateTime? lastMessageTime;

  ConversationHive({
    required this.id,
    required this.userId,
    this.unreadCount = 0,
    this.lastMessageTime,
  });
}
