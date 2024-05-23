import 'package:flutter/material.dart';
import 'package:frontend/screen/matching_screen.dart';

class MatchingInfoModel extends ChangeNotifier {
  bool _isMatching = false;
  String? _matchId;
  int? _partnerId;
  String? _partnerCompany;
  String? _partnerNickname;

  bool get isMatching => _isMatching;
  String? get matchId => _matchId;
  int? get partnerId => _partnerId;
  String? get partnerCompany => _partnerCompany;
  String? get partnerNickname => _partnerNickname;

  void setIsMatching(bool value) {
    _isMatching = value;
    notifyListeners();
  }

  void setMatching(
      {String? matchId,
      int? partnerId,
      String? partnerCompany,
      String? partnerNickname}) {
    _matchId = matchId;
    _partnerId = partnerId;
    _partnerCompany = partnerCompany;
    _partnerNickname = partnerNickname;
    notifyListeners();
  }
}
