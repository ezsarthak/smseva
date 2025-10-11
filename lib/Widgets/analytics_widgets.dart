import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final int totalComplaints;
  final int inProgressCount;
  final int completedCount;
  final int criticalCount;

  const StatsGrid({
    super.key,
    required this.totalComplaints,
    required this.inProgressCount,
    required this.completedCount,
    required this.criticalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard('Total Issues', totalComplaints.toString(),
                Icons.analytics_outlined, const Color(0xFF3B82F6))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('In Progress', inProgressCount.toString(),
                Icons.hourglass_top_rounded, const Color(0xFFF59E0B))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('Completed', completedCount.toString(),
                Icons.check_circle_outline_rounded, const Color(0xFF10B981))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildStatCard('Critical', criticalCount.toString(),
                Icons.warning_amber_rounded, const Color(0xFFEF4444))),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 16),
        Text(value,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B))),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}