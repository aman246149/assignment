import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assignment/controllers/conversation.dart';
import 'package:assignment/model/conversation.dart';
import 'package:assignment/ui/theme/app_theme.dart';
import 'package:assignment/ui/widgets/user_avatar.dart';
import 'package:assignment/utils/date_time_utils.dart';

class ChatHistoryTab extends StatefulWidget {
  final void Function(Conversation conversation) onConversationTap;

  const ChatHistoryTab({super.key, required this.onConversationTap});

  @override
  State<ChatHistoryTab> createState() => _ChatHistoryTabState();
}

class _ChatHistoryTabState extends State<ChatHistoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<ConversationController>(
      builder: (context, conversationController, child) {
        final conversations = conversationController.conversations;

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text('No chat history', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation from the Users tab',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: conversations.length,
          separatorBuilder: (context, index) =>
              const Divider(indent: 80, endIndent: 16),
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            // Use lastMessageTime or generate a random time within last few hours
            final displayTime =
                conversation.lastMessageTime ??
                DateTime.now().subtract(
                  Duration(minutes: (index + 1) * 15 + (index * 5)),
                );
            return _ConversationTile(
              conversation: conversation,
              timeText: DateTimeUtils.formatRelativeTime(displayTime),
              onTap: () => widget.onConversationTap(conversation),
            );
          },
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String timeText;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(name: conversation.userName ?? 'User', size: 48),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.userName ?? 'User',
              style: AppTextStyles.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(timeText, style: AppTextStyles.caption),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage?.text ?? 'No messages yet',
              style: AppTextStyles.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
