import 'dart:convert';
import 'dart:html' as html;

/// Web-specific export using browser download
Future<void> exportPlatformFile(String filename, String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  
  html.Url.revokeObjectUrl(url);
}
