import 'package:flutter/material.dart';
import '../models/feature_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FeatureCard extends StatelessWidget {
  final FeatureItem feature;

  const FeatureCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconBox(),
          const SizedBox(width: 16),
          Expanded(child: _buildTextContent()),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: AppColors.textLight),
        ],
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.iconBgGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(feature.icon, color: AppColors.primaryGreen, size: 24),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(feature.title, style: AppTextStyles.featureTitle),
        const SizedBox(height: 3),
        Text(feature.subtitle, style: AppTextStyles.featureSubtitle),
      ],
    );
  }
}