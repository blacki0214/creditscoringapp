import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  String _selectedPeriod = 'Current year';

  int get selectedIndex => _selectedIndex;
  String get selectedPeriod => _selectedPeriod;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
