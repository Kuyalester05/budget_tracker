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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconBox(),
          const SizedBox(width: 14),
          Expanded(child: _buildTextContent()),
        ],
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.iconBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        feature.icon,
        color: AppColors.primaryGreen,
        size: 24,
      ),
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