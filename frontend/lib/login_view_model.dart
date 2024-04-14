import 'package:flutter/material.dart';
import 'package:frontend/user_model.dart';

// provider: 여기에 user가 있는지 없는지로 상태관리

class LoginViewModel extends ChangeNotifier {
  UserModel? _user;
  /*
  String _name = " - ";
  String _loginType = " - ";
  bool _isLogined = false;
  */

  // 생성자
  LoginViewModel({required UserModel? user}) : _user = user;

  // get 메소드
  UserModel? get user => _user;
  /*
  String get name => _name;
  String get loginType => _loginType;
  bool get isLogined => _isLogined;
  */

/*
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
*/

  void login(UserModel user) {
    _user = user;
    notifyListeners();
    /*
      // 서버에 요청
      name = inputName;
      loginType = inputLoginType;
      isLogined = true;
      notifyListeners();
    } catch (error) {
      // 예외처리
    }
    */
  }

  //메소드
  void logout() {
    _user = null;
    notifyListeners();
  }
}
