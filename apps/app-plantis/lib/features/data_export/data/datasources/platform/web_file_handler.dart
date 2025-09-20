// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

import 'platform_file_handler.dart';
import '../../../domain/entities/export_request.dart';

/// Web-specific implementation of file handling using HTML5 APIs
class WebFileHandler implements PlatformFileHandler {
  @override
  bool get supportsDirectDownload => true;

@override
  String getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'json';
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.xml:
        return 'xml';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  @override
  String getMimeType(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.xml:
        return 'application/xml';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }

  @override
  String generateFileName(ExportRequest request) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]+'), '-');
    final extension = getFileExtension(request.format);
    return 'plantis_export_${request.userId}_$timestamp.$extension';
  }

  @override
  Future<String> generateAndSaveFile({
    required ExportRequest request,
    required String content,
    required String mimeType,
  }) async {
    try {
      final fileName = generateFileName(request);
      
      // Convert content to bytes
      final bytes = utf8.encode(content);
      
      // Create blob with the content
      final blob = html.Blob([bytes], mimeType);
      
      // Create download URL
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create download link and trigger download
      final anchor = html.AnchorElement(href: url)
        ..download = fileName
        ..style.display = 'none';
      
      // Add to DOM, click, and remove
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      
      // Clean up the URL
      html.Url.revokeObjectUrl(url);
      
      // Return a mock file path for web (since we don't have actual file paths)
      return 'web_download://$fileName';
    } catch (e) {
      throw Exception('Erro ao gerar download na web: ${e.toString()}');
    }
  }
}