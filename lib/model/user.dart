import 'package:assignment/db_model/user.dart';

class User {
  final String id;
  final String name;
  final bool isOnline;
  final DateTime lastActive;

  User({
    required this.id,
    required this.name,
    this.isOnline = true,
    DateTime? lastActive,
  }) : lastActive = lastActive ?? DateTime.now();

  factory User.fromHive(UserHive user) {
    return User(
      id: user.id,
      name: user.name,
      isOnline: user.isOnline,
      lastActive: user.lastActive,
    );
  }
}
