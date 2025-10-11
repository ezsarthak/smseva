import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import '../Model/Issues.dart';

class CsvExporter {
  Future<void> export(List<Issue> issues) async {
    final buffer = StringBuffer();
    buffer.writeln('Ticket ID,Title,Category,Status,Created At');
    for (final issue in issues) {
      buffer.writeln('"${issue.ticketId}","${issue.title}","${issue.category}","${issue.status}","${issue.createdAt}"');
    }
    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    await FileSaver.instance.saveFile(name: 'issues.csv', bytes: bytes, mimeType: MimeType.csv);
  }
}
