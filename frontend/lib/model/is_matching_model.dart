import 'package:flutter/material.dart';

class MatchingInfoModel extends ChangeNotifier {
  bool _isMatching = false;
  String? _matchId;
  int? _senderId;
  String? _senderCompany;
  String? _senderNickname;

  bool get isMatching => _isMatching;
  String? get matchId => _matchId;
  int? get senderId => _senderId;
  String? get senderCompany => _senderCompany;
  String? get senderNickname => _senderNickname;

  void setIsMatching(bool value) {
    _isMatching = value;
    notifyListeners();
  }

  void setMatching(
      {String? matchId,
      int? senderId,
      String? senderCompany,
      String? senderNickname}) {
    _matchId = matchId;
    _senderId = senderId;
    _senderCompany = senderCompany;
    _senderNickname = senderNickname;
    notifyListeners();
  }
}
