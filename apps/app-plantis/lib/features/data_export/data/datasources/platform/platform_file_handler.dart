import '../../../domain/entities/export_request.dart';

/// Abstract base class for platform-specific file handling
abstract class PlatformFileHandler {
  /// Generate and save/download export file based on platform
  Future<String> generateAndSaveFile({
    required ExportRequest request,
    required String content,
    required String mimeType,
  });

  /// Check if the platform supports direct file downloads
  bool get supportsDirectDownload;

  /// Get the file extension for the export format
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

  /// Get the MIME type for the export format
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

  /// Generate filename with timestamp
  String generateFileName(ExportRequest request) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]+'), '-');
    final extension = getFileExtension(request.format);
    return 'plantis_export_${request.userId}_$timestamp.$extension';
  }
}