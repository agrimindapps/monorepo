import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../shared/utils/result.dart';

/// Serviço de backup e restore para storage
///
/// Responsabilidades:
/// - Backup creation em JSON
/// - Restore de backups
/// - Backup scheduling
/// - Validation
class StorageBackupService {
  final Directory backupDirectory;
  final bool autoBackupOnWrite;

  StorageBackupService({
    required this.backupDirectory,
    this.autoBackupOnWrite = false,
  });

  /// Cria um backup completo em formato JSON
  ///
  /// [backupName]: nome do arquivo de backup (opcional)
  /// [data]: dados a serem salvos no backup
  ///
  /// Retorna o caminho do arquivo de backup
  Future<Result<String>> createBackup({
    String? backupName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = backupName ?? 'storage_backup_$timestamp.json';
      final backupFile = File(path.join(backupDirectory.path, fileName));

      // Ensure backup directory exists
      if (!await backupDirectory.exists()) {
        await backupDirectory.create(recursive: true);
      }

      final backupData = {
        'timestamp': timestamp,
        'version': '1.0',
        'created_at': DateTime.now().toIso8601String(),
        'data': data,
      };

      await backupFile.writeAsString(jsonEncode(backupData));

      return Result.success(backupFile.path);
    } catch (e, stackTrace) {
      return Result.error(
        StorageBackupError(
          message: 'Erro ao criar backup: ${e.toString()}',
          code: 'BACKUP_CREATE_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Restaura um backup
  ///
  /// [backupPath]: caminho do arquivo de backup
  /// [clearFirst]: se true, limpa dados existentes antes de restaurar
  ///
  /// Retorna os dados restaurados
  Future<Result<Map<String, dynamic>>> restoreBackup(
    String backupPath, {
    bool clearFirst = true,
  }) async {
    try {
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        return Result.error(
          StorageBackupError(
            message: 'Arquivo de backup não encontrado',
            code: 'BACKUP_FILE_NOT_FOUND',
          ),
        );
      }

      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;

      // Validate backup structure
      if (!backupData.containsKey('data')) {
        return Result.error(
          StorageBackupError(
            message: 'Backup inválido: estrutura incorreta',
            code: 'INVALID_BACKUP_STRUCTURE',
          ),
        );
      }

      final data = backupData['data'] as Map<String, dynamic>;

      return Result.success(data);
    } catch (e, stackTrace) {
      return Result.error(
        StorageBackupError(
          message: 'Erro ao restaurar backup: ${e.toString()}',
          code: 'BACKUP_RESTORE_ERROR',
          details: 'backupPath: $backupPath',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Cria backup incremental de um item específico
  ///
  /// Útil para auto-backup em writes
  Future<Result<void>> createItemBackup({
    required String key,
    required dynamic value,
    required String storageType,
  }) async {
    try {
      if (!await backupDirectory.exists()) {
        await backupDirectory.create(recursive: true);
      }

      final backupKey = '${storageType}_$key';
      final backupFile = File(path.join(backupDirectory.path, '$backupKey.backup'));

      final backupData = {
        'key': key,
        'value': value,
        'type': storageType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await backupFile.writeAsString(jsonEncode(backupData));

      return Result.success(null);
    } catch (e) {
      // Backup failures não devem bloquear operação principal
      // Log warning mas retorna success
      return Result.success(null);
    }
  }

  /// Remove backup de um item específico
  Future<Result<void>> removeItemBackup(String key) async {
    try {
      if (!await backupDirectory.exists()) {
        return Result.success(null);
      }

      await for (final file in backupDirectory.list()) {
        if (file is File && file.path.contains(key)) {
          await file.delete();
        }
      }

      return Result.success(null);
    } catch (e) {
      // Backup cleanup failures não são críticos
      return Result.success(null);
    }
  }

  /// Lista todos os backups disponíveis
  Future<List<BackupInfo>> listBackups() async {
    final backups = <BackupInfo>[];

    try {
      if (!await backupDirectory.exists()) {
        return backups;
      }

      await for (final file in backupDirectory.list()) {
        if (file is File && file.path.endsWith('.json')) {
          final stat = await file.stat();
          final fileName = path.basename(file.path);

          backups.add(
            BackupInfo(
              path: file.path,
              name: fileName,
              size: stat.size,
              createdAt: stat.modified,
            ),
          );
        }
      }

      // Sort by date (most recent first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      // Retorna lista vazia em caso de erro
    }

    return backups;
  }

  /// Valida estrutura de um backup
  Future<bool> validateBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) return false;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Validate required fields
      return data.containsKey('version') &&
          data.containsKey('timestamp') &&
          data.containsKey('data');
    } catch (e) {
      return false;
    }
  }

  /// Limpa backups antigos
  ///
  /// [olderThan]: remove backups mais antigos que esta duração
  Future<int> cleanOldBackups({Duration olderThan = const Duration(days: 30)}) async {
    int deletedCount = 0;

    try {
      if (!await backupDirectory.exists()) {
        return 0;
      }

      final cutoffDate = DateTime.now().subtract(olderThan);

      await for (final file in backupDirectory.list()) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await file.delete();
            deletedCount++;
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }

    return deletedCount;
  }
}

/// Informações sobre um backup
class BackupInfo {
  final String path;
  final String name;
  final int size;
  final DateTime createdAt;

  BackupInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.createdAt,
  });

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  String toString() {
    return 'BackupInfo(name: $name, size: $sizeFormatted, created: $createdAt)';
  }
}

/// Erro de backup
class StorageBackupError implements Exception {
  final String message;
  final String code;
  final String? details;
  final StackTrace? stackTrace;

  StorageBackupError({
    required this.message,
    required this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'StorageBackupError($code): $message';
}
