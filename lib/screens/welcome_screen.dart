import 'package:flutter/material.dart';
import '../models/feature_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/bursa_logo.dart';
import '../widgets/continue_button.dart';
import '../widgets/feature_card.dart';
import 'setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const List<FeatureItem> _features = [
    FeatureItem(
      icon: Icons.receipt_long_rounded,
      title: 'Track every expense',
      subtitle: 'Log spending in seconds and see\nwhere your money actually goes.',
    ),
    FeatureItem(
      icon: Icons.bar_chart_rounded,
      title: 'Visual budget reports',
      subtitle: 'Clear charts that show spending\npatterns at a glance.',
    ),
    FeatureItem(
      icon: Icons.savings_rounded,
      title: 'Smart savings goals',
      subtitle: 'Set goals and watch your progress\nupdate in real time.',
    ),
  ];

  void _onContinue(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Column(
          children: [
            Expanded(child: _buildTopSection()),
            _buildBottomSheet(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative ring around logo
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldPrimary.withOpacity(0.25),
                width: 2,
              ),
            ),
            child: Center(child: const BursaLogo(size: 110)),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to\nBURSA',
            textAlign: TextAlign.center,
            style: AppTextStyles.welcomeTitle,
          ),
          const SizedBox(height: 14),
          Text(
            'Your personal finance companion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.55),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 32, 22, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pull handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Everything you need',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          ..._features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FeatureCard(feature: feature),
            ),
          ),
          const SizedBox(height: 16),
          ContinueButton(onPressed: () => _onContinue(context)),
        ],
      ),
    );
  }
}