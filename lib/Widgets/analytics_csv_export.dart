import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Model/Issues.dart';
import 'analytics_utils.dart';


class ExportService {
  final List<Issue> issues;
  final Map<String, int> complaintsBySector;
  final Map<String, int> statusData;
  final int totalComplaints;
  final int inProgressCount;
  final int completedCount;
  final int criticalCount;

  ExportService({
    required this.issues,
    required this.complaintsBySector,
    required this.statusData,
    required this.totalComplaints,
    required this.inProgressCount,
    required this.completedCount,
    required this.criticalCount,
  });

  Future<void> exportPdfReport() async {
    final pdf = pw.Document();

    final sortedIssues = List<Issue>.from(issues)
      ..sort((a, b) {
        final dateA = parseDate(a.createdAt);
        final dateB = parseDate(b.createdAt);
        if (dateA != null && dateB != null) return dateB.compareTo(dateA);
        return 0;
      });

    final List<Issue> issuesForPdf = sortedIssues.take(20).toList();

    final imageFutures = issuesForPdf.map((issue) => _fetchImage(issue.photo)).toList();
    final images = await Future.wait(imageFutures);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => _buildPdfHeader(),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildPdfSummaryPage(),
          pw.NewPage(),
          pw.Text('Latest 20 Issue Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 15),
          pw.ListView.separated(
            itemBuilder: (context, index) {
              final issue = issuesForPdf[index];
              final imageResult = images[index];
              return _buildPdfIssueCard(issue, imageResult);
            },
            separatorBuilder: (context, index) => pw.SizedBox(height: 20),
            itemCount: issuesForPdf.length,
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'latest_issues_report.pdf',
    );
  }

  Future<void> exportIssuesToCsv() async {
    if (issues.isEmpty) {
      throw Exception('No data to export.');
    }
    final buffer = StringBuffer();
    buffer.writeln('Ticket ID,Title,Category,Status,Priority,Address,Latitude,Longitude,Created At');

    final sortedIssues = List<Issue>.from(issues)
      ..sort((a, b) {
        final dateA = parseDate(a.createdAt);
        final dateB = parseDate(b.createdAt);
        if (dateA != null && dateB != null) return dateB.compareTo(dateA);
        return 0;
      });

    for (final issue in sortedIssues) {
      buffer.writeln(
          '"${issue.ticketId}","${issue.title}","${issue.category}","${getFormattedStatus(issue.status)}","${issue.priorityText}","${issue.address.replaceAll('"', '""')}","${issue.location.latitude}","${issue.location.longitude}","${issue.createdAt}"');
    }
    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    await FileSaver.instance.saveFile(
      name: 'full_issue_report.csv',
      bytes: bytes,
      mimeType: MimeType.csv,
    );
  }

  // --- PDF HELPERS ---
  Future<dynamic> _fetchImage(String? base64String) async {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final String actualBase64 = base64String.contains(',') ? base64String.substring(base64String.indexOf(',') + 1) : base64String;
      final Uint8List imageBytes = base64Decode(actualBase64);
      return pw.MemoryImage(imageBytes);
    } catch (e) {
      debugPrint("Could not decode Base64 image for PDF: $e");
      return 'Invalid photo data';
    }
  }

  pw.Widget _buildPdfHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Analytics Report', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          pw.Text('Generated: ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Platform Report', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStatText(String title, String value) {
    return pw.Column(children: [
      pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 2),
      pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
    ]);
  }

  pw.Widget _buildPdfIssueCard(Issue issue, dynamic imageResult) {
    final lat = issue.location.latitude == 0.0 ? 'Not Provided' : issue.location.latitude.toStringAsFixed(5);
    final lon = issue.location.longitude == 0.0 ? 'Not Provided' : issue.location.longitude.toStringAsFixed(5);
    pw.Widget imageWidget;
    if (imageResult is pw.ImageProvider) {
      imageWidget = pw.Image(imageResult, fit: pw.BoxFit.cover);
    } else {
      imageWidget = pw.Container(
        color: PdfColors.grey200,
        child: pw.Center(child: pw.Text(imageResult ?? 'No photo provided', textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9))),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(issue.title.isNotEmpty ? issue.title : 'Untitled Issue', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.SizedBox(height: 5),
                pw.Text('ID: ${issue.ticketId}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                pw.Divider(height: 10),
                _buildPdfInfoRow('Status:', issue.status),
                _buildPdfInfoRow('Category:', issue.category),
                _buildPdfInfoRow('Priority:', issue.priorityText),
                _buildPdfInfoRow('Address:', issue.address),
                _buildPdfInfoRow('Latitude:', lat),
                _buildPdfInfoRow('Longitude:', lon),
              ],
            ),
          ),
          pw.SizedBox(width: 15),
          pw.Expanded(flex: 2, child: pw.Container(height: 100, child: imageWidget)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 60, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 9))),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummaryPage() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('📊 Analytics Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 25),
        pw.Text('Summary Statistics', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildPdfStatText('Total Issues', totalComplaints.toString()),
              _buildPdfStatText('In Progress', inProgressCount.toString()),
              _buildPdfStatText('Completed', completedCount.toString()),
              _buildPdfStatText('Critical', criticalCount.toString()),
            ],
          ),
        ),
        pw.SizedBox(height: 25),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Issues by Category', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  data: [
                    ['Category', 'Count', '%'],
                    ...complaintsBySector.entries.map((e) => [e.key, e.value.toString(), '${(totalComplaints > 0 ? (e.value / totalComplaints) * 100 : 0).toStringAsFixed(1)}%']),
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                ),
              ]),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Status Distribution', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Table.fromTextArray(
                    data: [
                      ['Status', 'Count', '%'],
                      ...statusData.entries.map((e) => [e.key, e.value.toString(), '${(totalComplaints > 0 ? (e.value / totalComplaints) * 100 : 0).toStringAsFixed(1)}%']),
                    ],
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}