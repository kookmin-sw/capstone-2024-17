import 'package:flutter/material.dart';

class UserProfileModel extends ChangeNotifier {
  int? _userId;
  String _nickname = '';
  String _logoUrl = '';
  String _company = '미인증';
  String _position = '선택안함';
  String _introduction = '';
  double _rating = 0;

  int? get userId => _userId;
  Map<String, dynamic> get profile => {
        "userId": _userId,
        "nickname": _nickname,
        "logoUrl": _logoUrl,
        "company": _company,
        "position": _position,
        "introduction": _introduction,
        "rating": _rating,
      };

  void setUserId(int userId) {
    _userId = userId;
    notifyListeners();
  }

  void setProfile(int userId, String nickname, String logoUrl, String company,
      String position, String introduction, double rating) {
    _userId = userId;
    _nickname = nickname;
    _logoUrl = logoUrl;
    _company = company;
    _position = position;
    _introduction = introduction;
    _rating = rating;
    notifyListeners();
  }

  void setNicknameIntroduction(String nickname, String introduction) {
    _nickname = nickname;
    _introduction = introduction;
    notifyListeners();
  }

  void setPosition(String position) {
    _position = position;
    notifyListeners();
  }

  void setCompanyLogoUrl(String company, String logoUrl) {
    _company = company;
    _logoUrl = logoUrl;
    notifyListeners();
  }
}
