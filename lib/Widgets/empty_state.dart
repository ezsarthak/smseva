import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 60),
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No Data Available',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          SizedBox(height: 8),
          Text('No issues found to display analytics',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}