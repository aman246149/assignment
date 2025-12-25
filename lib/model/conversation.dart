import 'package:assignment/db_model/conversation.dart';
import 'package:assignment/model/message.dart';

class Conversation {
  final String id;
  final String userId;
  final int unreadCount;
  final DateTime? lastMessageTime;

  // These are computed/loaded separately, not stored in Hive
  Message? lastMessage;
  String? userName;

  Conversation({
    required this.id,
    required this.userId,
    this.unreadCount = 0,
    this.lastMessageTime,
    this.lastMessage,
    this.userName,
  });

  factory Conversation.fromHive(ConversationHive conversation) {
    return Conversation(
      id: conversation.id,
      userId: conversation.userId,
      unreadCount: conversation.unreadCount,
      lastMessageTime: conversation.lastMessageTime,
    );
  }
}
