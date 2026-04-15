import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const ContinueButton({
    super.key,
    required this.onPressed,
    this.label = 'CONTINUE',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(label, style: AppTextStyles.buttonText),
          ),
        ),
      ),
    );
  }
}