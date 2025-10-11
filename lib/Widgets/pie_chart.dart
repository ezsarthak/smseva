import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'analytics_utils.dart';

class AnalyticsPieChart extends StatelessWidget {
  final Map<String, int> statusData;
  const AnalyticsPieChart({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
    if (statusData.isEmpty) {
      return const SizedBox(
          height: 280, child: Center(child: Text('No data available')));
    }
    final total = statusData.values.isNotEmpty
        ? statusData.values.reduce((a, b) => a + b)
        : 1;

    return SizedBox(
      height: 280,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: statusData.entries.map((entry) {
                  final percentage = (entry.value / total * 100);
                  return PieChartSectionData(
                    color: getStatusColor(entry.key),
                    value: entry.value.toDouble(),
                    title: percentage > 8
                        ? '${percentage.toStringAsFixed(1)}%'
                        : '',
                    radius: 70,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  );
                }).toList(),
                sectionsSpace: 3,
                centerSpaceRadius: 45,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: statusData.entries.map((entry) {
              final percentage = (entry.value / total * 100);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: getStatusColor(entry.key),
                          shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('${entry.key} (${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}