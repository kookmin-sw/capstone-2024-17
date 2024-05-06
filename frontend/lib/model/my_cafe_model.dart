import 'package:flutter/material.dart';

class MyCafeModel extends ChangeNotifier {
  String? cafeId;
  String? latitude;
  String? longitude;

  MyCafeModel({
    this.cafeId,
    this.latitude,
    this.longitude,
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
