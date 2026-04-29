import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BursaLogo extends StatelessWidget {
  final double size;
  const BursaLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D52), Color(0xFF0B1F0E)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            children: const [
              TextSpan(text: 'BUR'),
              TextSpan(
                text: '\$',
                style: TextStyle(color: Color(0xFFE6B020)),
              ),
              TextSpan(text: 'A'),
            ],
          ),
        ),
      ),
    );
  }
}