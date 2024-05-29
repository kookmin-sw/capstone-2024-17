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
    // 중복 체크 후 추가
    if (allUsers[cafeId]!.contains(user) == false) {
      allUsers[cafeId]!.add(user);
    }
    notifyListeners();
  }

  void deleteUser(String cafeId, int userId) {
    allUsers[cafeId]!.removeWhere((user) => user.userId == userId);
    notifyListeners();
  }
}
