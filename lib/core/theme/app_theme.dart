import 'package:flutter/material.dart';

abstract final class AppColors {
  static const seed = Color(0xFF00897B);
  static const income = Color(0xFF2E7D32);
  static const expense = Color(0xFFC62828);
  static const warning = Color(0xFFEF6C00);
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
    );
  }
}
