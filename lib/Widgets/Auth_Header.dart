import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../View/WorkerLogin.dart';
import '../constants/AppColors.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 64, color: kWorkerPrimaryColor),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: kHintTextColor),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, curve: Curves.easeOut);
  }
}