import 'package:flutter/material.dart';

class AppTheme {
  final String name;

  const AppTheme({required this.name});

  Color get primary {
    switch (name) {
      case 'ocean':   return const Color(0xFF1A3A5C);
      case 'forest':  return const Color(0xFF2D5016);
      case 'sunset':  return const Color(0xFFE85D4A);
      case 'lavender': return const Color(0xFF7B68EE);
      case 'midnight': return const Color(0xFF2C3E7B);
      case 'rose':    return const Color(0xFFE84393);
      case 'desert':  return const Color(0xFFCC5A3A);
      default:        return const Color(0xFF513222); // classic
    }
  }

  Color get secondary {
    switch (name) {
      case 'ocean':   return const Color(0xFF4ECDC4);
      case 'forest':  return const Color(0xFFD4A017);
      case 'sunset':  return const Color(0xFFFF6B6B);
      case 'lavender': return const Color(0xFF4A3F6B);
      case 'midnight': return const Color(0xFF00BCD4);
      case 'rose':    return const Color(0xFF6B213F);
      case 'desert':  return const Color(0xFFB8864E);
      default:        return const Color(0xFFE88432); // classic
    }
  }

  Color get scaffoldLight {
    switch (name) {
      case 'ocean':   return const Color(0xFFF0F4F8);
      case 'forest':  return const Color(0xFFF5F7F0);
      case 'sunset':  return const Color(0xFFFFF0E0);
      case 'lavender': return const Color(0xFFF5F0FF);
      case 'midnight': return const Color(0xFFF0F4FF);
      case 'rose':    return const Color(0xFFFFF0F3);
      case 'desert':  return const Color(0xFFFEF5E7);
      default:        return const Color(0xFFFAF7F0); // classic
    }
  }

  Color get scaffoldDark {
    switch (name) {
      case 'ocean':   return const Color(0xFF0D1B2A);
      case 'forest':  return const Color(0xFF1A1F0D);
      case 'sunset':  return const Color(0xFF1E1010);
      case 'lavender': return const Color(0xFF1A1625);
      case 'midnight': return const Color(0xFF0D0D1A);
      case 'rose':    return const Color(0xFF1A0D14);
      case 'desert':  return const Color(0xFF1C140E);
      default:        return const Color(0xFF121212); // classic
    }
  }

  Color get cardDark {
    switch (name) {
      case 'ocean':   return const Color(0xFF1B2838);
      case 'forest':  return const Color(0xFF242B14);
      case 'sunset':  return const Color(0xFF2E1515);
      case 'lavender': return const Color(0xFF262132);
      case 'midnight': return const Color(0xFF1A1A2E);
      case 'rose':    return const Color(0xFF2E1422);
      case 'desert':  return const Color(0xFF2B2016);
      default:        return const Color(0xFF1E1E1E); // classic
    }
  }

  ThemeData light({bool useMaterial3 = true}) {
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );
    return _baseTheme(useMaterial3, cs).copyWith(
      scaffoldBackgroundColor: scaffoldLight,
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  ThemeData dark({bool useMaterial3 = true}) {
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );
    return _baseTheme(useMaterial3, cs).copyWith(
      scaffoldBackgroundColor: scaffoldDark,
      cardTheme: CardThemeData(
        color: cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white12),
        ),
      ),
    );
  }

  ThemeData _baseTheme(bool useMaterial3, ColorScheme cs) {
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: cs,
      brightness: cs.brightness,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  String get displayName {
    switch (name) {
      case 'classic':  return 'קלאסי';
      case 'ocean':    return 'אוקיינוס';
      case 'forest':   return 'יער';
      case 'sunset':   return 'שקיעה';
      case 'lavender': return 'לבנדר';
      case 'midnight': return 'חצות';
      case 'rose':     return 'ורד';
      case 'desert':   return 'מדבר';
      default:         return name;
    }
  }

  IconData get icon {
    switch (name) {
      case 'ocean':    return Icons.water_drop;
      case 'forest':   return Icons.eco;
      case 'sunset':   return Icons.wb_sunny;
      case 'lavender': return Icons.local_florist;
      case 'midnight': return Icons.nights_stay;
      case 'rose':     return Icons.favorite;
      case 'desert':   return Icons.terrain;
      default:         return Icons.palette;
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
