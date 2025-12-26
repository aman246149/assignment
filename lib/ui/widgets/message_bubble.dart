import 'package:flutter/material.dart';
import 'package:assignment/model/message.dart';
import 'package:assignment/ui/theme/app_theme.dart';
import 'package:assignment/utils/date_time_utils.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String? senderName;
  final bool showSenderAvatar;
  final bool showMyAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.senderName,
    this.showSenderAvatar = true,
    this.showMyAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left avatar for received messages
          if (!isMe && showSenderAvatar) ...[
            _buildAvatar(senderName ?? 'U', isMe: false),
            const SizedBox(width: 8),
          ],
          if (!isMe && !showSenderAvatar) const SizedBox(width: 44),

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.sentMessageBubble
                        : AppColors.receivedMessageBubble,
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                      topLeft: Radius.circular(isMe ? 16 : 6),
                      topRight: Radius.circular(isMe ? 6 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe
                          ? Colors.white
                          : AppColors.receivedMessageText,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    left: isMe ? 0 : 4,
                    right: isMe ? 4 : 0,
                  ),
                  child: Text(
                    DateTimeUtils.formatTime12Hour(message.timestamp),
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),

          // Right avatar for sent messages (pink/magenta "Y" avatar)
          if (isMe && showMyAvatar) ...[
            const SizedBox(width: 8),
            _buildAvatar('Y', isMe: true),
          ],
          if (isMe && !showMyAvatar) const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, {required bool isMe}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMe
              ? [AppColors.myAvatarColor1, AppColors.myAvatarColor2]
              : [
                  AppColors.getAvatarColorTopLeftGradient(),
                  AppColors.getAvatarColorTopCenterGradient(),
                  AppColors.getAvatarColorBottomRightGradient(),
                ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
