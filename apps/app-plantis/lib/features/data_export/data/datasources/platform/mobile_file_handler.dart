import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'platform_file_handler.dart';
import '../../../domain/entities/export_request.dart';

/// Mobile-specific implementation of file handling using File system
class MobileFileHandler implements PlatformFileHandler {
  @override
  bool get supportsDirectDownload => false;

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
      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = generateFileName(request);
      final filePath = '${directory.path}/$fileName';
      
      // Create and write file
      final file = File(filePath);
      await file.writeAsString(content);
      
      return filePath;
    } catch (e) {
      throw Exception('Erro ao salvar arquivo no mobile: ${e.toString()}');
    }
  }
}