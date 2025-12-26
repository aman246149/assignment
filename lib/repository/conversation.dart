import 'package:assignment/db_model/conversation.dart';
import 'package:hive/hive.dart';

class ConversationRepository {
  final Box<ConversationHive> _conversationsBox;

  ConversationRepository(this._conversationsBox);

  Future<void> addConversation(ConversationHive conversation) async {
    await _conversationsBox.add(conversation);
  }

  Future<List<ConversationHive>> getAllConversations() async {
    return _conversationsBox.values.toList();
  }

  Future<ConversationHive?> getConversationByUserId(String userId) async {
    try {
      return _conversationsBox.values.firstWhere((c) => c.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Future<ConversationHive?> getConversationById(String conversationId) async {
    try {
      return _conversationsBox.values.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateLastMessageTime(
    String conversationId,
    DateTime time,
  ) async {
    final conv = await getConversationById(conversationId);
    if (conv != null) {
      final index = _conversationsBox.values.toList().indexOf(conv);
      if (index >= 0) {
        final updatedConv = ConversationHive(
          id: conv.id,
          userId: conv.userId,
          unreadCount: conv.unreadCount,
          lastMessageTime: time,
        );
        await _conversationsBox.putAt(index, updatedConv);
      }
    }
  }

  Future<void> updateConversation(ConversationHive conversation) async {
    await conversation.save();
  }
}
