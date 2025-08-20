// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../models/backup_model.dart';

class BackupService {
  static const List<String> _supportedBoxes = [
    'box_vet_animais',
    'box_vet_pesos',
    'box_vet_vacinas',
    'box_vet_lembrete',
    'box_vet_medicamentos',
    'box_vet_despesas',
  ];

  Future<BackupData> getBackupData() async {
    try {
      final stats = await getDatabaseStats();
      
      return BackupData(
        lastBackupDate: await _getLastBackupDate(),
        totalRecords: stats.totalRecords,
        recordCounts: stats.tableCounts,
        hasBackupAvailable: await _hasBackupAvailable(),
      );
    } catch (e) {
      debugPrint('Error getting backup data: $e');
      return const BackupData();
    }
  }

  Future<DatabaseStats> getDatabaseStats() async {
    try {
      final tableCounts = <String, int>{};
      int totalRecords = 0;
      double totalSizeKB = 0.0;
      DateTime? lastModified;

      for (final boxName in _supportedBoxes) {
        try {
          final box = await Hive.openBox(boxName);
          final count = box.length;
          tableCounts[boxName] = count;
          totalRecords += count;
          
          // Estimate size (rough calculation)
          if (count > 0) {
            totalSizeKB += count * 0.5; // Assume 0.5KB per record average
          }
          
          // Check if box was modified recently
          if (count > 0) {
            lastModified ??= DateTime.now();
          }
          
          await box.close();
        } catch (e) {
          debugPrint('Error reading box $boxName: $e');
          tableCounts[boxName] = 0;
        }
      }

      return DatabaseStats(
        tableCounts: tableCounts,
        totalRecords: totalRecords,
        totalSizeKB: totalSizeKB,
        lastModified: lastModified ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting database stats: $e');
      return DatabaseStats.empty();
    }
  }

  Future<BackupOperationResult> createBackup() async {
    try {
      final backupData = <String, dynamic>{};
      final recordCounts = <String, int>{};
      
      // Create metadata
      final metadata = BackupRepository.createBackupMetadata(
        timestamp: DateTime.now(),
        recordCounts: {},
        appVersion: '1.0.0',
      );
      
      backupData.addAll(metadata);

      // Export data from each box
      for (final boxName in _supportedBoxes) {
        try {
          final box = await Hive.openBox(boxName);
          final boxData = <String, dynamic>{};
          
          for (int i = 0; i < box.length; i++) {
            final key = box.keyAt(i);
            final value = box.getAt(i);
            if (value != null) {
              boxData[key.toString()] = _serializeValue(value);
            }
          }
          
          backupData[boxName] = boxData;
          recordCounts[boxName] = box.length;
          
          await box.close();
        } catch (e) {
          debugPrint('Error backing up box $boxName: $e');
          recordCounts[boxName] = 0;
        }
      }

      // Update metadata with actual counts
      backupData['metadata']['recordCounts'] = recordCounts;
      backupData['metadata']['totalRecords'] = recordCounts.values.fold(0, (sum, count) => sum + count);

      // Save backup data (in a real implementation, this would save to file/cloud)
      await _saveBackupData(backupData);
      await _updateLastBackupDate(DateTime.now());

      return BackupOperationResult(
        operation: BackupOperation.backup,
        status: BackupStatus.success,
        message: 'Backup realizado com sucesso',
        timestamp: DateTime.now(),
        data: {
          'recordCounts': recordCounts,
          'totalRecords': recordCounts.values.fold(0, (sum, count) => sum + count),
        },
      );
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return BackupOperationResult(
        operation: BackupOperation.backup,
        status: BackupStatus.error,
        message: 'Erro ao criar backup: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  Future<BackupOperationResult> restoreBackup() async {
    try {
      final backupData = await _loadBackupData();
      if (backupData == null) {
        return BackupOperationResult(
          operation: BackupOperation.restore,
          status: BackupStatus.error,
          message: 'Nenhum backup encontrado',
          timestamp: DateTime.now(),
        );
      }

      if (!BackupRepository.validateBackupData(backupData)) {
        return BackupOperationResult(
          operation: BackupOperation.restore,
          status: BackupStatus.error,
          message: 'Dados de backup inválidos',
          timestamp: DateTime.now(),
        );
      }

      final recordCounts = <String, int>{};

      // Restore data to each box
      for (final boxName in _supportedBoxes) {
        try {
          final box = await Hive.openBox(boxName);
          await box.clear(); // Clear existing data
          
          final boxData = backupData[boxName] as Map<String, dynamic>?;
          if (boxData != null) {
            for (final entry in boxData.entries) {
              await box.put(entry.key, _deserializeValue(entry.value));
            }
            recordCounts[boxName] = boxData.length;
          } else {
            recordCounts[boxName] = 0;
          }
          
          await box.close();
        } catch (e) {
          debugPrint('Error restoring box $boxName: $e');
          recordCounts[boxName] = 0;
        }
      }

      return BackupOperationResult(
        operation: BackupOperation.restore,
        status: BackupStatus.success,
        message: 'Dados restaurados com sucesso',
        timestamp: DateTime.now(),
        data: {
          'recordCounts': recordCounts,
          'totalRecords': recordCounts.values.fold(0, (sum, count) => sum + count),
        },
      );
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return BackupOperationResult(
        operation: BackupOperation.restore,
        status: BackupStatus.error,
        message: 'Erro ao restaurar dados: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  Future<BackupOperationResult> clearAllData() async {
    try {
      final recordCounts = <String, int>{};

      for (final boxName in _supportedBoxes) {
        try {
          final box = await Hive.openBox(boxName);
          final count = box.length;
          await box.clear();
          recordCounts[boxName] = count;
          await box.close();
        } catch (e) {
          debugPrint('Error clearing box $boxName: $e');
          recordCounts[boxName] = 0;
        }
      }

      return BackupOperationResult(
        operation: BackupOperation.delete,
        status: BackupStatus.success,
        message: 'Todos os dados foram removidos',
        timestamp: DateTime.now(),
        data: {
          'clearedCounts': recordCounts,
          'totalCleared': recordCounts.values.fold(0, (sum, count) => sum + count),
        },
      );
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return BackupOperationResult(
        operation: BackupOperation.delete,
        status: BackupStatus.error,
        message: 'Erro ao remover dados: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  // Helper methods
  dynamic _serializeValue(dynamic value) {
    if (value == null) return null;
    
    try {
      // If it's already a primitive type, return as is
      if (value is String || value is num || value is bool) {
        return value;
      }
      
      // Try to convert to JSON if it has toJson method
      if (value is Map) {
        return value;
      }
      
      // For other types, convert to string
      return value.toString();
    } catch (e) {
      debugPrint('Error serializing value: $e');
      return value.toString();
    }
  }

  dynamic _deserializeValue(dynamic value) {
    // For now, just return the value as is
    // In a real implementation, you'd properly deserialize based on the original type
    return value;
  }

  Future<void> _saveBackupData(Map<String, dynamic> data) async {
    try {
      final box = await Hive.openBox<String>('backup_box');
      final jsonString = jsonEncode(data);
      await box.put('last_backup', jsonString);
      await box.close();
    } catch (e) {
      debugPrint('Error saving backup data: $e');
      throw Exception('Failed to save backup data');
    }
  }

  Future<Map<String, dynamic>?> _loadBackupData() async {
    try {
      final box = await Hive.openBox<String>('backup_box');
      final jsonString = box.get('last_backup');
      await box.close();
      
      if (jsonString == null) return null;
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading backup data: $e');
      return null;
    }
  }

  Future<DateTime?> _getLastBackupDate() async {
    try {
      final box = await Hive.openBox<String>('backup_box');
      final dateString = box.get('last_backup_date');
      await box.close();
      
      if (dateString == null) return null;
      
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('Error getting last backup date: $e');
      return null;
    }
  }

  Future<void> _updateLastBackupDate(DateTime date) async {
    try {
      final box = await Hive.openBox<String>('backup_box');
      await box.put('last_backup_date', date.toIso8601String());
      await box.close();
    } catch (e) {
      debugPrint('Error updating last backup date: $e');
    }
  }

  Future<bool> _hasBackupAvailable() async {
    try {
      final backupData = await _loadBackupData();
      return backupData != null && BackupRepository.validateBackupData(backupData);
    } catch (e) {
      debugPrint('Error checking backup availability: $e');
      return false;
    }
  }
}
