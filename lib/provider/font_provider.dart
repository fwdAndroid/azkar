import 'package:flutter/material.dart';

class FontSettings with ChangeNotifier {
  double _fontSize = 26;
  String _fontFamily = 'Amiri';

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }
}
