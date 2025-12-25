import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isOnline;

  @HiveField(3)
  final DateTime lastActive;

  UserHive({
    required this.id,
    required this.name,
    this.isOnline = true,
    DateTime? lastActive,
  }) : lastActive = lastActive ?? DateTime.now();
}
