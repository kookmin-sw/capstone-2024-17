import 'package:flutter/material.dart';

class MyCafeModel extends ChangeNotifier {
  String cafeId;
  String latitude;
  String longitude;

  MyCafeModel({
    required this.cafeId,
    required this.latitude,
    required this.longitude,
  });

  void setMyCafe({
    required String cafeId,
    required String latitude,
    required String longitude,
  }) {
    this.cafeId = cafeId;
    this.latitude = latitude;
    this.longitude = longitude;
    notifyListeners();
  }
}
