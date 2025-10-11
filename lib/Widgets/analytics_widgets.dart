import 'package:flutter/material.dart';
import '../Model/Issues.dart';

class ExportOptions extends StatelessWidget {
  final Future<void> Function() onExportPdf;
  final Future<void> Function() onExportCsv;

  const ExportOptions({super.key, required this.onExportPdf, required this.onExportCsv});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Export PDF'),
            onTap: () {
              Navigator.pop(context);
              onExportPdf();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: const Text('Export CSV'),
            onTap: () {
              Navigator.pop(context);
              onExportCsv();
            },
          ),
        ],
      ),
    );
  }
}

class AnalyticsContent extends StatelessWidget {
  final dynamic data;

  const AnalyticsContent({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final issues = data.issues as List<Issue>;
    return ListView.builder(
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        return ListTile(
          title: Text(issue.title),
          subtitle: Text(issue.status),
        );
      },
    );
  }
}
