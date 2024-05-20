import 'package:flutter/material.dart';

// 현재 커피챗 진행중인지 여부
class IsMatchingModel extends ChangeNotifier {
  bool _isMatching = false;
  bool get isMatching => _isMatching;

  void setIsMatching(bool value) {
    _isMatching = value;
    notifyListeners();
  }
}
