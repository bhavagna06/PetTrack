import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF9C7649),
    scaffoldBackgroundColor: const Color(0xFFFCFAF8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFCFAF8),
      foregroundColor: Color(0xFF1C150D),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF1C150D)),
    ),
    cardColor: Colors.white,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF9C7649),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    cardColor: const Color(0xFF1E1E1E),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(const Color(0xFF9C7649)),
      trackColor:
          WidgetStateProperty.all(const Color(0xFF9C7649).withOpacity(0.5)),
    ),
  );
}
