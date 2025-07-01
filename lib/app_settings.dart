// Create app_settings.dart with this content:
import 'package:flutter/material.dart';

class AppSettings with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  double _fontSizeScale = 1.0;
  String _fontFamily = 'Roboto';

  ThemeMode get themeMode => _themeMode;
  double get fontSizeScale => _fontSizeScale;
  String get fontFamily => _fontFamily;

  Future<void> init() async {
    // Load saved preferences here
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontSizeScale(double scale) {
    _fontSizeScale = scale;
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }
}