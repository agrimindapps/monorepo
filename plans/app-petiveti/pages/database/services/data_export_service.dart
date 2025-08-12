// Dart imports:
import 'dart:convert';

// Project imports:
import '../models/box_type_model.dart';
import '../models/database_data_model.dart';

class DataExportService {
  Future<ExportData> exportToJson({
    required DatabaseTableData tableData,
    required BoxType boxType,
  }) async {
    try {
      final exportData = {
        'boxType': boxType.key,
        'exportedAt': DateTime.now().toIso8601String(),
        'totalRecords': tableData.totalRecords,
        'records': tableData.records.map((record) => record.toJson()).toList(),
      };

      final jsonContent = const JsonEncoder.withIndent('  ').convert(exportData);
      final filename = _generateFilename(boxType, 'json');

      return ExportData(
        format: 'json',
        content: jsonContent,
        filename: filename,
        exportedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao exportar para JSON: $e');
    }
  }

  Future<ExportData> exportToCsv({
    required DatabaseTableData tableData,
    required BoxType boxType,
  }) async {
    try {
      if (tableData.isEmpty) {
        throw Exception('Nenhum dado para exportar');
      }

      final fields = tableData.sortedFields;
      final List<String> csvLines = [];

      // Header
      csvLines.add(fields.map(_escapeCsvField).join(','));

      // Data rows
      for (final record in tableData.records) {
        final row = fields.map((field) {
          final value = field == 'id' ? record.id : record.getValue(field);
          return _escapeCsvField(value);
        }).join(',');
        csvLines.add(row);
      }

      final csvContent = csvLines.join('\n');
      final filename = _generateFilename(boxType, 'csv');

      return ExportData(
        format: 'csv',
        content: csvContent,
        filename: filename,
        exportedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Erro ao exportar para CSV: $e');
    }
  }

  String _escapeCsvField(String field) {
    // Escape quotes and wrap in quotes if necessary
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  String _generateFilename(BoxType boxType, String extension) {
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    return '${boxType.key}_$timestamp.$extension';
  }

  Future<List<ExportData>> exportAllFormats({
    required DatabaseTableData tableData,
    required BoxType boxType,
  }) async {
    final List<ExportData> exports = [];

    try {
      // Export to JSON
      final jsonExport = await exportToJson(
        tableData: tableData,
        boxType: boxType,
      );
      exports.add(jsonExport);

      // Export to CSV
      final csvExport = await exportToCsv(
        tableData: tableData,
        boxType: boxType,
      );
      exports.add(csvExport);

      return exports;
    } catch (e) {
      throw Exception('Erro ao exportar dados: $e');
    }
  }

  Map<String, dynamic> generateExportSummary({
    required DatabaseTableData tableData,
    required BoxType boxType,
  }) {
    return {
      'boxType': boxType.displayName,
      'totalRecords': tableData.totalRecords,
      'filteredRecords': tableData.filteredRecordCount,
      'fields': tableData.sortedFields,
      'exportedAt': DateTime.now().toIso8601String(),
      'isEmpty': tableData.isEmpty,
      'isFiltered': tableData.isFiltered,
    };
  }

  String formatExportSummaryText({
    required DatabaseTableData tableData,
    required BoxType boxType,
  }) {
    final summary = generateExportSummary(
      tableData: tableData,
      boxType: boxType,
    );

    final buffer = StringBuffer();
    buffer.writeln('=== RESUMO DA EXPORTAÇÃO ===');
    buffer.writeln('Box: ${summary['boxType']}');
    buffer.writeln('Total de registros: ${summary['totalRecords']}');
    
    if (summary['isFiltered']) {
      buffer.writeln('Registros filtrados: ${summary['filteredRecords']}');
    }
    
    buffer.writeln('Campos: ${(summary['fields'] as List).join(', ')}');
    buffer.writeln('Exportado em: ${summary['exportedAt']}');
    
    return buffer.toString();
  }
}
