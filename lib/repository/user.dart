import 'package:assignment/db_model/user.dart';
import 'package:hive/hive.dart';

class UserRepository {
  final Box<UserHive> _usersBox;

  UserRepository(this._usersBox);

  Future<void> addUser(UserHive user) async {
    await _usersBox.add(user);
  }

  Future<List<UserHive>> getAllUsers() async {
    return _usersBox.values.toList();
  }
}
