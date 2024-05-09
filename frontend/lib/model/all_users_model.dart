import 'package:flutter/material.dart';
import 'package:frontend/model/user_model.dart';

class AllUsersModel extends ChangeNotifier {
  Map<String, List<UserModel>> allUsers;

  AllUsersModel(this.allUsers);

  void setAllUsers(Map<String, List<UserModel>> allUsers) {
    this.allUsers = allUsers;
    notifyListeners();
  }

  List<UserModel> getUserList(String cafeId) {
    return allUsers[cafeId] ?? [];
  }

  void addUser(String cafeId, UserModel user) {
    allUsers[cafeId]!.add(user);
    notifyListeners();
  }

  void deleteUser(String cafeId, String loginId) {
    allUsers[cafeId]!.removeWhere((user) => user.loginId == loginId);
    notifyListeners();
  }
}
