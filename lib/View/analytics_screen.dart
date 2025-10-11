import 'package:flutter/material.dart';
import '../Model/Issues.dart';
import '../Widgets/analytics_csv_export.dart';
import '../Widgets/analytics_data_manager.dart';
import '../Widgets/analytics_pdf_upload.dart';
import '../Widgets/analytics_widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsDataManager _dataManager = AnalyticsDataManager();
  final PdfExporter _pdfExporter = PdfExporter();
  final CsvExporter _csvExporter = CsvExporter();

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _dataManager.fetchIssues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _dataManager.fetchIssues(),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: _isExporting ? null : _showExportOptions,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _dataManager.dataNotifier,
        builder: (context, state, _) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.errorMessage.isNotEmpty)
            return Center(child: Text(state.errorMessage));
          return AnalyticsContent(data: state);
        },
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ExportOptions(
        onExportPdf: () async {
          setState(() => _isExporting = true);
          await _pdfExporter.export(_dataManager.issues);
          setState(() => _isExporting = false);
        },
        onExportCsv: () async {
          setState(() => _isExporting = true);
          await _csvExporter.export(_dataManager.issues);
          setState(() => _isExporting = false);
        },
      ),
    );
  }
}
