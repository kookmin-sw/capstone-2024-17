import 'package:flutter/material.dart';
import 'package:frontend/screen/matching_screen.dart';

class MatchingInfoModel extends ChangeNotifier {
  bool _isMatching = false;
  String? _matchId;
  // 내 정보
  int? _myId;
  String? _myNickname;
  String? _myCompany;
  // 상대방 정보
  int? _partnerId;
  String? _partnerCompany;
  String? _partnerNickname;

  bool get isMatching => _isMatching;
  String? get matchId => _matchId;
  int? get myId => _myId;
  String? get myNickname => _myNickname;
  String? get myCompany => _myCompany;
  int? get partnerId => _partnerId;
  String? get partnerCompany => _partnerCompany;
  String? get partnerNickname => _partnerNickname;

  void setIsMatching(bool value) {
    _isMatching = value;
    notifyListeners();
  }

  void setMatching(
      {String? matchId,
      int? myId,
      String? myNickname,
      String? myCompany,
      int? partnerId,
      String? partnerCompany,
      String? partnerNickname}) {
    _matchId = matchId;
    _myId = myId;
    _myNickname = myNickname;
    _myCompany = myCompany;
    _partnerId = partnerId;
    _partnerCompany = partnerCompany;
    _partnerNickname = partnerNickname;
    notifyListeners();
  }
}
