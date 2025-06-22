import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSizeScale = 1.0; // 0.8 (Small), 1.0 (Medium), 1.2 (Large)
  String _fontFamily = 'Roboto'; // Default font

  ThemeMode get themeMode => _themeMode;
  double get fontSizeScale => _fontSizeScale;
  String get fontFamily => _fontFamily;

  // Constructor - no need to call _loadSettings here if we call init() publicly
  // AppSettings() {
  //   _loadSettings();
  // }

  // Define the public init method that loads settings
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    _fontSizeScale = prefs.getDouble('fontSizeScale') ?? 1.0;
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    notifyListeners();
  }

  // Setters and save to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index);
      notifyListeners();
    }
  }

  Future<void> setFontSizeScale(double scale) async {
    if (_fontSizeScale != scale) {
      _fontSizeScale = scale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontSizeScale', scale);
      notifyListeners();
    }
  }

  Future<void> setFontFamily(String family) async {
    if (_fontFamily != family) {
      _fontFamily = family;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fontFamily', family);
      notifyListeners();
    }
  }

  // Helper for font size display
  String getFontSizeLabel(double scale) {
    if (scale == 0.8) return 'Small';
    if (scale == 1.2) return 'Large';
    return 'Medium'; // Default is 1.0
  }
}