import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assignment/controllers/message.dart';
import 'package:assignment/model/conversation.dart';
import 'package:assignment/model/user.dart';
import 'package:assignment/ui/theme/app_theme.dart';
import 'package:assignment/ui/widgets/message_bubble.dart';
import 'package:assignment/ui/widgets/typing_indicator.dart';
import 'package:assignment/ui/widgets/user_avatar.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  final Conversation conversation;

  const ChatScreen({super.key, required this.user, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MessageController _messageControllerRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageControllerRef = context.read<MessageController>();
      _messageControllerRef.addListener(_onMessagesChanged);
      _loadMessages();
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Scroll to bottom when keyboard appears/disappears
    _scrollToBottom();
  }

  void _onMessagesChanged() {
    _scrollToBottom();
  }

  Future<void> _loadMessages() async {
    await _messageControllerRef.loadMessages(widget.conversation.id);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await _messageControllerRef.sendMessage(widget.conversation.id, text);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageControllerRef.removeListener(_onMessagesChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            UserAvatar(
              name: widget.user.name,
              size: 36,
              showOnlineIndicator: false,
              isOnline: widget.user.isOnline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: AppTextStyles.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.user.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageController>(
              builder: (context, messageController, child) {
                final messages = messageController.messages;

                if (messages.isEmpty && !messageController.isLoading) {
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
                        Text('No messages yet', style: AppTextStyles.subtitle),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to start the conversation',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount:
                      messages.length + (messageController.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length &&
                        messageController.isLoading) {
                      return TypingIndicator(senderName: widget.user.name);
                    }

                    final message = messages[index];
                    final showAvatar =
                        !message.isMe &&
                        (index == 0 ||
                            messages[index - 1].isMe ||
                            messages[index - 1].timestamp
                                    .difference(message.timestamp)
                                    .inMinutes
                                    .abs() >
                                5);

                    return MessageBubble(
                      message: message,
                      senderName: widget.user.name,
                      showSenderAvatar: showAvatar,
                    );
                  },
                );
              },
            ),
          ),
          _MessageInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.caption,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
