import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: iconColor),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
