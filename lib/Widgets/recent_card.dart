import 'package:flutter/material.dart';
import '../Model/Issues.dart';
import 'analytics_utils.dart';


class RecentActivityCard extends StatelessWidget {
  final List<Issue> recentIssues;
  final VoidCallback onViewAll;

  const RecentActivityCard({
    super.key,
    required this.recentIssues,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Issues',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
              GestureDetector(
                onTap: onViewAll,
                child: const Text('View all',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...recentIssues.map((issue) => ActivityItem(issue: issue)),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Issue issue;
  const ActivityItem({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: issue.priorityColor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    issue.title.isNotEmpty ? issue.title : 'Untitled Issue',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(
                    issue.category.isNotEmpty
                        ? issue.category
                        : 'Uncategorized',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(getTimeAgo(issue.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: issue.statusBackgroundColor,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(issue.status.toLowerCase(),
                    style: TextStyle(
                        fontSize: 10,
                        color: issue.statusColor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}