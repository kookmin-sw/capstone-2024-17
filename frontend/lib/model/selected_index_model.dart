import 'package:flutter/material.dart';

class SelectedIndexModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int _selectedTabIndex = 0;

  int get selectedIndex => _selectedIndex;
  int get selectedTabIndex => _selectedTabIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  set selectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}
