import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core palette — deep emerald + warm gold
  static const Color deepForest    = Color(0xFF0B1F0E);
  static const Color forestDark    = Color(0xFF122616);
  static const Color primaryGreen  = Color(0xFF1B5E32);
  static const Color midGreen      = Color(0xFF2E7D52);
  static const Color accentGreen   = Color(0xFF4CAF78);
  static const Color mintGlow      = Color(0xFF6FCF9A);

  static const Color goldDeep      = Color(0xFFC8970A);
  static const Color goldPrimary   = Color(0xFFE6B020);
  static const Color goldLight     = Color(0xFFF5CC55);
  static const Color goldSurface   = Color(0xFFFFF8E0);

  static const Color incomeGreen   = Color(0xFF27AE60);
  static const Color expenseRed    = Color(0xFFE53935);

  static const Color white         = Color(0xFFFFFFFF);
  static const Color offWhite      = Color(0xFFF7F8F6);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceAlt    = Color(0xFFF3F6F3);

  static const Color textDark      = Color(0xFF0D1F12);
  static const Color textMid       = Color(0xFF4A5E4E);
  static const Color textGrey      = Color(0xFF8E9E92);
  static const Color textLight     = Color(0xFFBCC8BE);

  static const Color cardBorder    = Color(0xFFE4EDE6);
  static const Color divider       = Color(0xFFECF2ED);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1F0E), Color(0xFF163825), Color(0xFF1D4D32)],
  );

  static const LinearGradient cardGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFBEE), Color(0xFFFFF3CC)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D52), Color(0xFF1B5E32)],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF27AE60), Color(0xFF1B7A42)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6B020), Color(0xFFC8970A)],
  );

  static const LinearGradient iconBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD6EFE0), Color(0xFFEAF7EE)],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0B1F0E).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: const Color(0xFF0B1F0E).withOpacity(0.14),
      blurRadius: 32,
      offset: const Offset(0, 10),
      spreadRadius: -4,
    ),
  ];
}