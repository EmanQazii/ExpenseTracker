import 'package:flutter/material.dart';

class AppColors {
  // Primary colors for the expense tracker
  static const Color coral = Color(0xFFFF5959);
  static const Color gold = Color(0xFFFAD05A);
  static const Color teal = Color(0xFF49BEB6);
  static const Color darkTeal = Color(0xFF075F63);

  // Additional utility colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Gradient combinations
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkTeal, teal],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gold, coral],
  );
}
