import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BursaLogo extends StatelessWidget {
  final double size;

  const BursaLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.logoGradient,
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.logoText,
            children: const [
              TextSpan(text: 'BUR'),
              TextSpan(
                text: '\$',
                style: TextStyle(color: AppColors.dollarYellow),
              ),
              TextSpan(text: 'A'),
            ],
          ),
        ),
      ),
    );
  }
}