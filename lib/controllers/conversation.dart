import 'dart:developer';

import 'package:assignment/db_model/conversation.dart';
import 'package:assignment/model/conversation.dart';
import 'package:assignment/model/message.dart';
import 'package:assignment/repository/conversation.dart';
import 'package:assignment/repository/message.dart';
import 'package:assignment/repository/user.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ConversationController extends ChangeNotifier {
  final ConversationRepository _conversationRepository;
  final MessageRepository _messageRepository;
  final UserRepository _userRepository;
  final Uuid _uuid = const Uuid();

  ConversationController(
    this._conversationRepository,
    this._messageRepository,
    this._userRepository,
  );

  final List<Conversation> conversations = [];

  Future<void> loadConversations() async {
    try {
      final result = await _conversationRepository.getAllConversations();
      conversations.clear();

      for (final conv in result) {
        final conversation = Conversation.fromHive(conv);

        // Load last message for this conversation
        final lastMessage = await _messageRepository.getLastMessage(conv.id);
        if (lastMessage != null) {
          conversation.lastMessage = Message.fromHive(lastMessage);
        }

        // Load user name
        final users = await _userRepository.getAllUsers();
        final user = users.where((u) => u.id == conv.userId).firstOrNull;
        conversation.userName = user?.name;

        conversations.add(conversation);
      }

      // Sort by last message time (newest first)
      conversations.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(1970);
        final bTime = b.lastMessageTime ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<Conversation> getOrCreateConversation(String userId) async {
    try {
      // Check if conversation already exists
      var existingConv = await _conversationRepository.getConversationByUserId(
        userId,
      );

      if (existingConv != null) {
        return Conversation.fromHive(existingConv);
      }

      // Create new conversation
      final newConv = ConversationHive(id: _uuid.v4(), userId: userId);
      await _conversationRepository.addConversation(newConv);

      final conversation = Conversation.fromHive(newConv);
      conversations.add(conversation);
      notifyListeners();

      return conversation;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
