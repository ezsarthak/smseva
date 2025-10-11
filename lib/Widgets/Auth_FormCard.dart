import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }
}