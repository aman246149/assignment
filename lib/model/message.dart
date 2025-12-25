import 'package:assignment/db_model/message.dart';

class Message {
  final String id;
  final String conversationId;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.isMe,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Message.fromHive(MessageHive message) {
    return Message(
      id: message.id,
      conversationId: message.conversationId,
      text: message.text,
      isMe: message.isMe,
      timestamp: message.timestamp,
    );
  }
}
