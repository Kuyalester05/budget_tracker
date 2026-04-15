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
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
          const BursaLogo(size: 110),
          const SizedBox(height: 28),
          const Text(
            'Welcome to\nBURSA',
            textAlign: TextAlign.center,
            style: AppTextStyles.welcomeTitle,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FeatureCard(feature: feature),
            ),
          ),
          const SizedBox(height: 12),
          ContinueButton(onPressed: () => _onContinue(context)),
        ],
      ),
    );
  }
}