import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle logoText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
    letterSpacing: 3.0,
  );

  static const TextStyle welcomeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    color: AppColors.white,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const TextStyle featureTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.1,
  );

  static const TextStyle featureSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
    height: 1.45,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 1.2,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textGrey,
    letterSpacing: 1.4,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static const TextStyle amountLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
    letterSpacing: -1.0,
  );
}