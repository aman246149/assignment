import 'dart:developer';

import 'package:assignment/db_model/user.dart';
import 'package:assignment/model/user.dart';
import 'package:assignment/repository/user.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserController extends ChangeNotifier {
  final UserRepository _userRepository;
  final Uuid _uuid = const Uuid();

  UserController(this._userRepository);

  final List<User> users = [];

  Future<void> addUser(String name) async {
    try {
      final userHive = UserHive(id: _uuid.v4(), name: name);
      await _userRepository.addUser(userHive);
      users.add(User.fromHive(userHive));
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> getAllUsers() async {
    try {
      final users = await _userRepository.getAllUsers();
      this.users.clear();
      this.users.addAll(users.map((user) => User.fromHive(user)));
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }
}
