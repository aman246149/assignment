import 'package:flutter/material.dart';
import 'package:assignment/ui/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  String get _initial {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.getAvatarColorTopLeftGradient(),
                AppColors.getAvatarColorTopCenterGradient(),
                AppColors.getAvatarColorBottomRightGradient(),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.online : AppColors.offline,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),
      ],
    );
  }
}
