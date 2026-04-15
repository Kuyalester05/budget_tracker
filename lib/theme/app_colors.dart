import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color darkGreen = Color(0xFF1A2E1A);
  static const Color primaryGreen = Color(0xFF2D5A2D);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color buttonGreen = Color(0xFF2D5A2D);
  static const Color iconBg = Color(0xFFE8F5E9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF9F9F9);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF888888);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color dollarYellow = Color(0xFFFFD700);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2D0F), Color(0xFF1A4A1A), Color(0xFF2D6A2D)],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A8A3A), Color(0xFF1F5C1F)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A8A3A), Color(0xFF1F5C1F)],
  );

  static const LinearGradient iconBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD0EDCF), Color(0xFFE8F5E9)],
  );
}