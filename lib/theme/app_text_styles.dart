import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle logoText = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 2.0,
  );

  static const TextStyle welcomeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    height: 1.2,
  );

  static const TextStyle featureTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle featureSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 1.5,
  );
}