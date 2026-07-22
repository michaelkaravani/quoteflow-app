import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier() : _mode = ThemeMode.system {
    _theme = AppTheme.fromName(_savedTheme);
  }

  String _savedTheme = 'classic';
  AppTheme _theme = AppTheme.fromName('classic');
  ThemeMode _mode;

  AppTheme get theme => _theme;
  ThemeMode get mode => _mode;

  ThemeData get light => _theme.light();
  ThemeData get dark => _theme.dark();

  void setTheme(String name) {
    _savedTheme = name;
    _theme = AppTheme.fromName(name);
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
