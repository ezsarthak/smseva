import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Parses a date string with the specific format "HH:mm dd-MM-yyyy".
DateTime? parseDate(String dateString) {
  if (dateString.isEmpty) return null;
  try {
    return DateFormat("HH:mm dd-MM-yyyy").parse(dateString);
  } catch (e) {
    print('Failed to parse date "$dateString" with expected format.');
    try {
      return DateTime.parse(dateString); // Fallback
    } catch (_) {
      return null;
    }
  }
}

/// Converts a date string into a relative time format (e.g., "5d ago").
String getTimeAgo(String dateString) {
  try {
    final date = parseDate(dateString);
    if (date == null) return 'Invalid date';
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  } catch (e) {
    return 'Unknown';
  }
}

/// Provides a consistent color for a given category key.
Color getCategoryColor(String key) {
  final hash = key.hashCode.abs();
  final colors = [
    const Color(0xFF3B82F6), const Color(0xFF10B981),
    const Color(0xFF8B5CF6), const Color(0xFFEF4444),
    const Color(0xFFF59E0B), const Color(0xFF06B6D4),
    const Color(0xFF84CC16), const Color(0xFFEC4899),
  ];
  return colors[hash % colors.length];
}

/// Provides a specific color for a given status key.
Color getStatusColor(String key) {
  switch (key.toLowerCase()) {
    case 'in progress':
      return const Color(0xFF3B82F6);
    case 'completed':
      return const Color(0xFF10B981);
    case 'new':
      return const Color(0xFF8B5CF6);
    case 'other':
    default:
      return const Color(0xFF64748B);
  }
}

/// Formats the status string for consistency.
String getFormattedStatus(String status) {
  switch (status.toLowerCase()) {
    case 'new': return 'New';
    case 'in_progress':
    case 'in progress': return 'In Progress';
    case 'completed': return 'Completed';
    default: return 'Other';
  }
}