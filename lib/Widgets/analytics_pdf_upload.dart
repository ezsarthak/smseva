import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Model/Issues.dart';
import 'analytics_utils.dart';

class PdfExporter {
  Future<void> export(List<Issue> issues) async {
    final pdf = pw.Document();
    final utils = AnalyticsUtils();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Analytics Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          ...issues.map((i) => pw.Text('${i.title} - ${i.status}')).toList(),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'analytics_report.pdf');
  }
}
