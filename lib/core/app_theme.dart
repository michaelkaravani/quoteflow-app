import 'package:flutter/material.dart';

class AppTheme {
  final String name;

  const AppTheme({required this.name});

  ThemeData light({bool useMaterial3 = true}) {
    return ThemeData(
      useMaterial3: useMaterial3,
      colorSchemeSeed: seedColor,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2, scrolledUnderElevation: 4),
    );
  }

  ThemeData dark({bool useMaterial3 = true}) {
    return ThemeData(
      useMaterial3: useMaterial3,
      colorSchemeSeed: seedColor,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2, scrolledUnderElevation: 4),
    );
  }

  Color get seedColor {
    switch (name) {
      case 'ocean':
        return Colors.teal;
      case 'forest':
        return Colors.green;
      case 'sunset':
        return Colors.deepOrange;
      case 'lavender':
        return Colors.deepPurple;
      case 'midnight':
        return const Color(0xFF1A237E);
      case 'rose':
        return Colors.pink;
      case 'desert':
        return Colors.brown;
      default:
        return const Color(0xFF513222); // classic warm brown
    }
  }

  String get displayName {
    switch (name) {
      case 'classic':
        return 'קלאסי';
      case 'ocean':
        return 'אוקיינוס';
      case 'forest':
        return 'יער';
      case 'sunset':
        return 'שקיעה';
      case 'lavender':
        return 'לבנדר';
      case 'midnight':
        return 'חצות';
      case 'rose':
        return 'ורד';
      case 'desert':
        return 'מדבר';
      default:
        return name;
    }
  }

  static const List<AppTheme> all = [
    AppTheme(name: 'classic'),
    AppTheme(name: 'ocean'),
    AppTheme(name: 'forest'),
    AppTheme(name: 'sunset'),
    AppTheme(name: 'lavender'),
    AppTheme(name: 'midnight'),
    AppTheme(name: 'rose'),
    AppTheme(name: 'desert'),
  ];

  static AppTheme fromName(String name) =>
      all.firstWhere((t) => t.name == name, orElse: () => all.first);
}
