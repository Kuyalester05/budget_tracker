import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.offWhite,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryGreen,
          surface: AppColors.surface,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      );
}