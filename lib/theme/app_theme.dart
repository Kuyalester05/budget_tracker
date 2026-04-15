import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.darkGreen,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryGreen,
          surface: AppColors.darkGreen,
        ),
      );
}