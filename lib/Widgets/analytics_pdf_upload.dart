import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'analytics_helper.dart';

class AnalyticsBarChart extends StatelessWidget {
  final Map<String, int> complaintsBySector;

  const AnalyticsBarChart({super.key, required this.complaintsBySector});

  @override
  Widget build(BuildContext context) {
    if (complaintsBySector.isEmpty) {
      return const SizedBox(
          height: 280, child: Center(child: Text('No data available')));
    }
    final barSpots = complaintsBySector.entries.toList();
    final maxY =
        (complaintsBySector.values.reduce((a, b) => a > b ? a : b))
            .toDouble() +
            5;

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                      '${barSpots[group.x.toInt()].key}\n${rod.toY.round()} issues',
                      const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)))),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= barSpots.length) return const SizedBox();
                  final key = barSpots[index].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      key.length > 15
                          ? '${key.substring(0, 12)}...'
                          : key.replaceAll(' & ', '\n& '),
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
              show: true,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) =>
              const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
              drawVerticalLine: false),
          barGroups: barSpots.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  gradient: LinearGradient(colors: [
                    getCategoryColor(entry.value.key),
                    getCategoryColor(entry.value.key).withOpacity(0.7)
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                  width: 32,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}