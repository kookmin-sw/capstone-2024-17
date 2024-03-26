import 'package:flutter/material.dart';

// provider

class LoginViewModel extends ChangeNotifier {
  String _name = " - ";
  String _loginType = " - ";
  bool _isLogined = false;

  // get 메소드
  String get name => _name;
  String get loginType => _loginType;
  bool get isLogined => _isLogined;

  // set 메소드
  set name(String name) {
    _name = name;
    notifyListeners();
  }

  set loginType(String loginType) {
    _loginType = loginType;
    notifyListeners();
  }

  set isLogined(bool isLogined) {
    _isLogined = isLogined;
    notifyListeners();
  }

  // 메소드
  Future<void> signup() async {
    try {
      // 서버에 요청
    } catch (error) {
      // 예외처리
    }
  }

  Future<void> login(String inputName, String inputLoginType) async {
    try {
      // 서버에 요청
      name = inputName;
      loginType = inputLoginType;
      isLogined = true;
      notifyListeners();
    } catch (error) {
      // 예외처리
    }
  }

  //메소드
  Future<void> logout() async {
    try {
      // 서버에 요청
      name = ' - ';
      loginType = ' - ';
      isLogined = false;
      notifyListeners();
    } catch (error) {
      // 예외처리
    }
  }
}
