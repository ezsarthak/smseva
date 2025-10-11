// lib/screens/analytics_helpers.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';

/// Processes issue data and caches computed statistics
Future<Map<String, dynamic>> processAndCacheData(List<Map<String, dynamic>> issues) async {
  final Map<String, int> categoryCount = {};
  final Map<String, int> regionCount = {};
  final Map<String, int> monthCount = {};

  for (var issue in issues) {
    final category = issue['category'] ?? 'Unknown';
    final region = issue['region'] ?? 'Unknown';
    final dateStr = issue['date'] ?? '';
    final date = dateStr.isNotEmpty ? DateTime.tryParse(dateStr) : null;

    categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    regionCount[region] = (regionCount[region] ?? 0) + 1;
    if (date != null) {
      final month = DateFormat('MMM yyyy').format(date);
      monthCount[month] = (monthCount[month] ?? 0) + 1;
    }
  }

  return {
    'totalComplaints': issues.length,
    'categoryCount': categoryCount,
    'regionCount': regionCount,
    'monthCount': monthCount,
  };
}

/// Generates CSV data
String generateCsvData(List<Map<String, dynamic>> issues) {
  List<List<dynamic>> rows = [
    ['Category', 'Region', 'Date', 'Description'],
    ...issues.map((i) => [
      i['category'] ?? '',
      i['region'] ?? '',
      i['date'] ?? '',
      i['description'] ?? ''
    ]),
  ];
  return const ListToCsvConverter().convert(rows);
}

/// Exports a CSV report file
Future<File> exportCsvReport(List<Map<String, dynamic>> issues) async {
  final directory = await getApplicationDocumentsDirectory();
  final fileName =
      'analytics_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
  final path = '${directory.path}/$fileName';

  final csvData = generateCsvData(issues);
  final file = File(path);
  await file.writeAsString(csvData);
  return file;
}

/// Exports a PDF analytics report
Future<File> exportPdfReport(Map<String, dynamic> stats) async {
  final pdf = pw.Document();
  final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text('Analytics Report',
            style: pw.TextStyle(font: ttf, fontSize: 26, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text('Total Complaints: ${stats['totalComplaints'] ?? 0}',
            style: pw.TextStyle(font: ttf, fontSize: 18)),
        pw.SizedBox(height: 20),
        pw.Text('Category-wise Complaints:', style: pw.TextStyle(font: ttf, fontSize: 18)),
        pw.Table.fromTextArray(
          context: context,
          headers: ['Category', 'Count'],
          data: (stats['categoryCount'] ?? {})
              .entries
              .map((e) => [e.key, e.value.toString()])
              .toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Region-wise Complaints:', style: pw.TextStyle(font: ttf, fontSize: 18)),
        pw.Table.fromTextArray(
          context: context,
          headers: ['Region', 'Count'],
          data: (stats['regionCount'] ?? {})
              .entries
              .map((e) => [e.key, e.value.toString()])
              .toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Monthly Complaint Trends:', style: pw.TextStyle(font: ttf, fontSize: 18)),
        pw.Table.fromTextArray(
          context: context,
          headers: ['Month', 'Complaints'],
          data: (stats['monthCount'] ?? {})
              .entries
              .map((e) => [e.key, e.value.toString()])
              .toList(),
        ),
      ],
    ),
  );

  final directory = await getApplicationDocumentsDirectory();
  final fileName =
      'analytics_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
  final path = '${directory.path}/$fileName';
  final file = File(path);

  await file.writeAsBytes(await pdf.save());
  return file;
}

/// Color mapping for categories
Color getCategoryColor(String category) {
  switch (category) {
    case 'Water':
      return const Color(0xFF3B82F6);
    case 'Electricity':
      return const Color(0xFFF59E0B);
    case 'Roads':
      return const Color(0xFF10B981);
    case 'Waste':
      return const Color(0xFFEF4444);
    case 'Health':
      return const Color(0xFF8B5CF6);
    case 'Education':
      return const Color(0xFFEC4899);
    default:
      return const Color(0xFF9CA3AF);
  }
}
