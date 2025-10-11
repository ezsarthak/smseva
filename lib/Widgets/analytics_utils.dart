import 'package:flutter/material.dart';

class AnalyticsUtils {
  Color getCategoryColor(String key) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
      const Color(0xFFEC4899),
    ];
    return colors[key.hashCode % colors.length];
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
