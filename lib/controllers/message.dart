import 'dart:developer';

import 'package:assignment/db_model/message.dart';
import 'package:assignment/model/message.dart';
import 'package:assignment/repository/conversation.dart';
import 'package:assignment/repository/message.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MessageController extends ChangeNotifier {
  final MessageRepository _messageRepository;
  final ConversationRepository _conversationRepository;
  final Uuid _uuid = const Uuid();

  MessageController(this._messageRepository, this._conversationRepository);

  final List<Message> messages = [];
  bool isLoading = false;

  Future<void> loadMessages(String conversationId) async {
    try {
      final result = await _messageRepository.getMessagesByConversation(
        conversationId,
      );
      messages.clear();
      messages.addAll(result.map((m) => Message.fromHive(m)));
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> sendMessage(String conversationId, String text) async {
    try {
      final now = DateTime.now();
      final messageHive = MessageHive(
        id: _uuid.v4(),
        conversationId: conversationId,
        text: text,
        isMe: true,
        timestamp: now,
      );
      await _messageRepository.addMessage(messageHive);
      messages.add(Message.fromHive(messageHive));

      // Update conversation lastMessageTime
      await _conversationRepository.updateLastMessageTime(conversationId, now);

      notifyListeners();

      // Fetch response from API
      await fetchReceiverMessage(conversationId);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> fetchReceiverMessage(String conversationId) async {
    try {
      isLoading = true;
      notifyListeners();

      final messagesHive = await _messageRepository.fetchRandomMessagesFromApi(
        conversationId,
      );
      DateTime? lastTime;
      for (final messageHive in messagesHive) {
        messages.add(Message.fromHive(messageHive));
        lastTime = messageHive.timestamp;
      }

      // Update conversation lastMessageTime with the last received message
      if (lastTime != null) {
        await _conversationRepository.updateLastMessageTime(
          conversationId,
          lastTime,
        );
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      log(e.toString());
    }
  }
}
