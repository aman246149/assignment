import 'dart:convert';
import 'dart:math';

import 'package:assignment/db_model/message.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MessageRepository {
  final Box<MessageHive> _messagesBox;
  final Uuid _uuid = const Uuid();

  MessageRepository(this._messagesBox);

  Future<void> addMessage(MessageHive message) async {
    await _messagesBox.add(message);
  }

  Future<List<MessageHive>> getMessagesByConversation(String conversationId) {
    final messages = _messagesBox.values
        .where((m) => m.conversationId == conversationId)
        .toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return Future.value(messages);
  }

  Future<List<MessageHive>> fetchRandomMessagesFromApi(
    String conversationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://dummyjson.com/comments?limit=${Random().nextInt(4) + 1}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final comments = data['comments'] as List;
      final List<MessageHive> messages = [];

      for (final comment in comments) {
        final message = MessageHive(
          id: _uuid.v4(),
          conversationId: conversationId,
          text: comment['body'] as String,
          isMe: false,
        );
        await addMessage(message);
        messages.add(message);
      }

      if (messages.isEmpty) {
        throw Exception('No comments found');
      }

      return messages;
    } else {
      throw Exception('Failed to fetch message from API');
    }
  }

  Future<MessageHive?> getLastMessage(String conversationId) async {
    final messages = await getMessagesByConversation(conversationId);
    if (messages.isEmpty) return null;
    return messages.last;
  }
}
