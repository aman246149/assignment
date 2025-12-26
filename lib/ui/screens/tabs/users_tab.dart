import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assignment/controllers/user.dart';
import 'package:assignment/model/user.dart';
import 'package:assignment/ui/theme/app_theme.dart';
import 'package:assignment/ui/widgets/user_avatar.dart';

class UsersTab extends StatefulWidget {
  final void Function(User user) onUserTap;

  const UsersTab({super.key, required this.onUserTap});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<UserController>(
      builder: (context, userController, child) {
        final users = userController.users;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text('No users yet', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Text('Tap + to add a new user', style: AppTextStyles.caption),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          separatorBuilder: (context, index) =>
              const Divider(indent: 80, endIndent: 16),
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserTile(user: user, onTap: () => widget.onUserTap(user));
          },
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(
        name: user.name,
        size: 52,
        showOnlineIndicator: true,
        isOnline: user.isOnline,
      ),
      title: Text(user.name, style: AppTextStyles.title),
      subtitle: Text(
        user.isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
