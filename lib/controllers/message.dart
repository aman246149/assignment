import 'dart:developer';

import 'package:assignment/db_model/message.dart';
import 'package:assignment/model/message.dart';
import 'package:assignment/repository/message.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MessageController extends ChangeNotifier {
  final MessageRepository _messageRepository;
  final Uuid _uuid = const Uuid();

  MessageController(this._messageRepository);

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
      final messageHive = MessageHive(
        id: _uuid.v4(),
        conversationId: conversationId,
        text: text,
        isMe: true,
      );
      await _messageRepository.addMessage(messageHive);
      messages.add(Message.fromHive(messageHive));
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

      final messageHive = await _messageRepository.fetchRandomMessageFromApi(
        conversationId,
      );
      messages.add(Message.fromHive(messageHive));

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      log(e.toString());
    }
  }
}
