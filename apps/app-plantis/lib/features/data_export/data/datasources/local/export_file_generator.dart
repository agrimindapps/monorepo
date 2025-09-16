import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/export_request.dart';

class ExportFileGenerator {
  /// Generate export file in the requested format
  Future<String> generateExportFile({
    required ExportRequest request,
    required Map<DataType, dynamic> exportData,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateFileName(request);
    final filePath = '${directory.path}/$fileName';

    switch (request.format) {
      case ExportFormat.json:
        return await _generateJsonFile(filePath, exportData);
      case ExportFormat.csv:
        return await _generateCsvFile(filePath, exportData);
      case ExportFormat.xml:
        return await _generateXmlFile(filePath, exportData);
      case ExportFormat.pdf:
        return await _generatePdfFile(filePath, exportData);
    }
  }

  String _generateFileName(ExportRequest request) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]+'), '-');
    final formatExt = request.format.name.toLowerCase();
    return 'plantis_export_${request.userId}_$timestamp.$formatExt';
  }

  /// Generate JSON export file
  Future<String> _generateJsonFile(
    String filePath,
    Map<DataType, dynamic> exportData,
  ) async {
    final jsonData = <String, dynamic>{
      'export_info': {
        'app_name': 'Plantis',
        'export_date': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'format': 'JSON',
        'compliance': 'LGPD',
      },
      'user_data': {},
    };

    // Process each data type
    for (final entry in exportData.entries) {
      final dataType = entry.key;
      final data = entry.value;

      switch (dataType) {
        case DataType.plants:
          if (data is List<PlantExportData>) {
            jsonData['user_data']['plants'] = _formatPlantsForJson(data);
          }
          break;
        case DataType.plantTasks:
          if (data is List<TaskExportData>) {
            jsonData['user_data']['tasks'] = _formatTasksForJson(data);
          }
          break;
        case DataType.spaces:
          if (data is List<SpaceExportData>) {
            jsonData['user_data']['spaces'] = _formatSpacesForJson(data);
          }
          break;
        case DataType.plantPhotos:
          if (data is List<PlantPhotoExportData>) {
            jsonData['user_data']['plant_photos'] = _formatPhotosForJson(data);
          }
          break;
        case DataType.settings:
          if (data is UserSettingsExportData) {
            jsonData['user_data']['settings'] = _formatSettingsForJson(data);
          }
          break;
        case DataType.userProfile:
          jsonData['user_data']['profile'] = data;
          break;
        default:
          jsonData['user_data'][dataType.name] = data;
      }
    }

    final file = File(filePath);
    await file.writeAsString(jsonEncode(jsonData));
    return filePath;
  }

  /// Generate CSV export file
  Future<String> _generateCsvFile(
    String filePath,
    Map<DataType, dynamic> exportData,
  ) async {
    final csvRows = <List<String>>[];

    // Header
    csvRows.add([
      'Export Info',
      'Plantis - LGPD Data Export',
      DateTime.now().toIso8601String(),
    ]);
    csvRows.add([]); // Empty row

    // Process each data type
    for (final entry in exportData.entries) {
      final dataType = entry.key;
      final data = entry.value;

      csvRows.add([dataType.displayName]);
      csvRows.add([]); // Empty row

      switch (dataType) {
        case DataType.plants:
          if (data is List<PlantExportData>) {
            csvRows.addAll(_formatPlantsForCsv(data));
          }
          break;
        case DataType.plantTasks:
          if (data is List<TaskExportData>) {
            csvRows.addAll(_formatTasksForCsv(data));
          }
          break;
        case DataType.spaces:
          if (data is List<SpaceExportData>) {
            csvRows.addAll(_formatSpacesForCsv(data));
          }
          break;
        default:
          csvRows.add(['Dados não estruturados para CSV']);
      }

      csvRows.add([]); // Empty row between sections
    }

    // Simple CSV conversion without external package
    final csvString = csvRows.map((row) => row.join(',')).join('\n');
    final file = File(filePath);
    await file.writeAsString(csvString);
    return filePath;
  }

  /// Generate XML export file
  Future<String> _generateXmlFile(
    String filePath,
    Map<DataType, dynamic> exportData,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<plantis_export>');
    buffer.writeln('  <export_info>');
    buffer.writeln('    <app_name>Plantis</app_name>');
    buffer.writeln('    <export_date>${DateTime.now().toIso8601String()}</export_date>');
    buffer.writeln('    <version>1.0.0</version>');
    buffer.writeln('    <format>XML</format>');
    buffer.writeln('    <compliance>LGPD</compliance>');
    buffer.writeln('  </export_info>');
    buffer.writeln('  <user_data>');

    // Process each data type
    for (final entry in exportData.entries) {
      final dataType = entry.key;
      final data = entry.value;

      buffer.writeln('    <${dataType.name}>');
      _formatDataForXml(buffer, data, '      ');
      buffer.writeln('    </${dataType.name}>');
    }

    buffer.writeln('  </user_data>');
    buffer.writeln('</plantis_export>');

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  /// Generate PDF export file (simplified version)
  Future<String> _generatePdfFile(
    String filePath,
    Map<DataType, dynamic> exportData,
  ) async {
    // For simplicity, generate a text file with PDF extension
    // In a real implementation, you would use a PDF library like `pdf` package
    final buffer = StringBuffer();
    buffer.writeln('PLANTIS - EXPORTAÇÃO DE DADOS LGPD');
    buffer.writeln('Data: ${DateTime.now()}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final entry in exportData.entries) {
      buffer.writeln('${entry.key.displayName}:');
      buffer.writeln('-' * 30);
      buffer.writeln(entry.value.toString());
      buffer.writeln();
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  // JSON formatting helpers
  Map<String, dynamic> _formatPlantsForJson(List<PlantExportData> plants) {
    return {
      'count': plants.length,
      'plants': plants.map((plant) => {
            'id': plant.id,
            'name': plant.name,
            'species': plant.species,
            'space_id': plant.spaceId,
            'image_urls': plant.imageUrls,
            'planting_date': plant.plantingDate?.toIso8601String(),
            'notes': plant.notes,
            'is_favorited': plant.isFavorited,
            'config': plant.config != null
                ? {
                    'watering_interval_days': plant.config!.wateringIntervalDays,
                    'fertilizing_interval_days': plant.config!.fertilizingIntervalDays,
                    'pruning_interval_days': plant.config!.pruningIntervalDays,
                    'light_requirement': plant.config!.lightRequirement,
                    'water_amount': plant.config!.waterAmount,
                    'soil_type': plant.config!.soilType,
                    'enable_watering_care': plant.config!.enableWateringCare,
                    'last_watering_date': plant.config!.lastWateringDate?.toIso8601String(),
                    'enable_fertilizer_care': plant.config!.enableFertilizerCare,
                    'last_fertilizer_date': plant.config!.lastFertilizerDate?.toIso8601String(),
                  }
                : null,
            'created_at': plant.createdAt?.toIso8601String(),
            'updated_at': plant.updatedAt?.toIso8601String(),
          }).toList(),
    };
  }

  Map<String, dynamic> _formatTasksForJson(List<TaskExportData> tasks) {
    return {
      'count': tasks.length,
      'tasks': tasks.map((task) => {
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'plant_id': task.plantId,
            'plant_name': task.plantName,
            'type': task.type,
            'status': task.status,
            'priority': task.priority,
            'due_date': task.dueDate.toIso8601String(),
            'completed_at': task.completedAt?.toIso8601String(),
            'completion_notes': task.completionNotes,
            'is_recurring': task.isRecurring,
            'recurring_interval_days': task.recurringIntervalDays,
            'next_due_date': task.nextDueDate?.toIso8601String(),
            'created_at': task.createdAt?.toIso8601String(),
          }).toList(),
    };
  }

  Map<String, dynamic> _formatSpacesForJson(List<SpaceExportData> spaces) {
    return {
      'count': spaces.length,
      'spaces': spaces.map((space) => {
            'id': space.id,
            'name': space.name,
            'description': space.description,
            'created_at': space.createdAt?.toIso8601String(),
            'updated_at': space.updatedAt?.toIso8601String(),
          }).toList(),
    };
  }

  Map<String, dynamic> _formatPhotosForJson(List<PlantPhotoExportData> photos) {
    return {
      'count': photos.length,
      'photos': photos.map((photo) => {
            'plant_id': photo.plantId,
            'plant_name': photo.plantName,
            'photo_urls': photo.photoUrls,
            'taken_at': photo.takenAt?.toIso8601String(),
            'caption': photo.caption,
          }).toList(),
    };
  }

  Map<String, dynamic> _formatSettingsForJson(UserSettingsExportData settings) {
    return {
      'notification_settings': settings.notificationSettings,
      'backup_settings': settings.backupSettings,
      'app_preferences': settings.appPreferences,
      'last_backup_date': settings.lastBackupDate?.toIso8601String(),
      'last_sync_date': settings.lastSyncDate?.toIso8601String(),
    };
  }

  // CSV formatting helpers
  List<List<String>> _formatPlantsForCsv(List<PlantExportData> plants) {
    final rows = <List<String>>[];
    rows.add([
      'ID',
      'Nome',
      'Espécie',
      'Espaço',
      'Data do Plantio',
      'Notas',
      'Favorito',
      'Criado em',
      'Atualizado em',
    ]);

    for (final plant in plants) {
      rows.add([
        plant.id,
        plant.name,
        plant.species ?? '',
        plant.spaceId ?? '',
        plant.plantingDate?.toIso8601String() ?? '',
        plant.notes ?? '',
        plant.isFavorited.toString(),
        plant.createdAt?.toIso8601String() ?? '',
        plant.updatedAt?.toIso8601String() ?? '',
      ]);
    }

    return rows;
  }

  List<List<String>> _formatTasksForCsv(List<TaskExportData> tasks) {
    final rows = <List<String>>[];
    rows.add([
      'ID',
      'Título',
      'Descrição',
      'Planta',
      'Tipo',
      'Status',
      'Prioridade',
      'Data Vencimento',
      'Concluído em',
      'Observações',
      'Recorrente',
      'Criado em',
    ]);

    for (final task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description ?? '',
        task.plantName,
        task.type,
        task.status,
        task.priority,
        task.dueDate.toIso8601String(),
        task.completedAt?.toIso8601String() ?? '',
        task.completionNotes ?? '',
        task.isRecurring.toString(),
        task.createdAt?.toIso8601String() ?? '',
      ]);
    }

    return rows;
  }

  List<List<String>> _formatSpacesForCsv(List<SpaceExportData> spaces) {
    final rows = <List<String>>[];
    rows.add(['ID', 'Nome', 'Descrição', 'Criado em', 'Atualizado em']);

    for (final space in spaces) {
      rows.add([
        space.id,
        space.name,
        space.description ?? '',
        space.createdAt?.toIso8601String() ?? '',
        space.updatedAt?.toIso8601String() ?? '',
      ]);
    }

    return rows;
  }

  // XML formatting helpers
  void _formatDataForXml(StringBuffer buffer, dynamic data, String indent) {
    if (data is List) {
      for (int i = 0; i < data.length; i++) {
        buffer.writeln('$indent<item index="$i">');
        _formatDataForXml(buffer, data[i], '$indent  ');
        buffer.writeln('$indent</item>');
      }
    } else if (data is Map) {
      for (final entry in data.entries) {
        final key = entry.key.toString().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
        buffer.writeln('$indent<$key>');
        _formatDataForXml(buffer, entry.value, '$indent  ');
        buffer.writeln('$indent</$key>');
      }
    } else {
      buffer.writeln('$indent${_escapeXml(data.toString())}');
    }
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}