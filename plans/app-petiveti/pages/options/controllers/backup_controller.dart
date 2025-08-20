// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../models/backup_model.dart';
import '../services/backup_service.dart';

class BackupController extends ChangeNotifier {
  // Services
  late final BackupService _backupService;

  // State
  BackupData _backupData = const BackupData();
  BackupOperationResult? _lastOperation;
  DatabaseStats _databaseStats = DatabaseStats.empty();
  bool _isOperating = false;
  String? _errorMessage;

  // Getters
  BackupData get backupData => _backupData;
  BackupOperationResult? get lastOperation => _lastOperation;
  DatabaseStats get databaseStats => _databaseStats;
  bool get isOperating => _isOperating;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  // Operation status
  bool get isBackingUp => _isOperating && _lastOperation?.operation == BackupOperation.backup;
  bool get isRestoring => _isOperating && _lastOperation?.operation == BackupOperation.restore;
  bool get isDeleting => _isOperating && _lastOperation?.operation == BackupOperation.delete;

  // Data status
  bool get hasData => _databaseStats.totalRecords > 0;
  bool get needsBackup => _backupData.needsBackup;
  String get backupStatusText => _backupData.formattedLastBackup;

  BackupController() {
    _initializeServices();
  }

  void _initializeServices() {
    _backupService = BackupService();
  }

  Future<void> initialize() async {
    try {
      await _loadBackupData();
      await _loadDatabaseStats();
      _clearError();
    } catch (e) {
      _setError('Erro ao inicializar backup: $e');
    }
  }

  Future<void> _loadBackupData() async {
    try {
      _backupData = await _backupService.getBackupData();
    } catch (e) {
      debugPrint('Error loading backup data: $e');
      _backupData = const BackupData();
    }
  }

  Future<void> _loadDatabaseStats() async {
    try {
      _databaseStats = await _backupService.getDatabaseStats();
    } catch (e) {
      debugPrint('Error loading database stats: $e');
      _databaseStats = DatabaseStats.empty();
    }
  }

  Future<void> performBackup() async {
    if (_isOperating) return;

    _setOperating(true);
    _setLastOperation(BackupOperationResult.loading(
      operation: BackupOperation.backup,
      message: 'Iniciando backup...',
    ));

    try {
      final result = await _backupService.createBackup();
      
      if (result.isSuccess) {
        _setLastOperation(BackupOperationResult.success(
          operation: BackupOperation.backup,
          message: 'Backup realizado com sucesso!',
          data: result.data,
        ));
        await _loadBackupData(); // Refresh backup data
      } else {
        _setLastOperation(BackupOperationResult.error(
          operation: BackupOperation.backup,
          message: result.message ?? 'Falha no backup',
        ));
      }
    } catch (e) {
      _setLastOperation(BackupOperationResult.error(
        operation: BackupOperation.backup,
        message: 'Erro durante o backup: $e',
      ));
    } finally {
      _setOperating(false);
    }
  }

  Future<void> performRestore() async {
    if (_isOperating) return;

    _setOperating(true);
    _setLastOperation(BackupOperationResult.loading(
      operation: BackupOperation.restore,
      message: 'Restaurando dados...',
    ));

    try {
      final result = await _backupService.restoreBackup();
      
      if (result.isSuccess) {
        _setLastOperation(BackupOperationResult.success(
          operation: BackupOperation.restore,
          message: 'Dados restaurados com sucesso!',
          data: result.data,
        ));
        await _loadDatabaseStats(); // Refresh database stats
      } else {
        _setLastOperation(BackupOperationResult.error(
          operation: BackupOperation.restore,
          message: result.message ?? 'Falha na restauração',
        ));
      }
    } catch (e) {
      _setLastOperation(BackupOperationResult.error(
        operation: BackupOperation.restore,
        message: 'Erro durante a restauração: $e',
      ));
    } finally {
      _setOperating(false);
    }
  }

  Future<void> performDataDeletion() async {
    if (_isOperating) return;

    _setOperating(true);
    _setLastOperation(BackupOperationResult.loading(
      operation: BackupOperation.delete,
      message: 'Removendo dados...',
    ));

    try {
      final result = await _backupService.clearAllData();
      
      if (result.isSuccess) {
        _setLastOperation(BackupOperationResult.success(
          operation: BackupOperation.delete,
          message: 'Todos os dados foram removidos!',
          data: result.data,
        ));
        await _loadDatabaseStats(); // Refresh database stats
        await _loadBackupData(); // Refresh backup data
      } else {
        _setLastOperation(BackupOperationResult.error(
          operation: BackupOperation.delete,
          message: result.message ?? 'Falha na remoção',
        ));
      }
    } catch (e) {
      _setLastOperation(BackupOperationResult.error(
        operation: BackupOperation.delete,
        message: 'Erro durante a remoção: $e',
      ));
    } finally {
      _setOperating(false);
    }
  }

  // Utility methods
  String getBackupSummary() {
    return BackupRepository.formatBackupSummary(_backupData);
  }

  List<String> getBackupWarnings() {
    return BackupRepository.getBackupWarnings(_databaseStats);
  }

  Duration getEstimatedBackupTime() {
    return BackupRepository.estimateBackupTime(_databaseStats);
  }

  String getTableDisplayName(String tableName) {
    return BackupRepository.getTableDisplayName(tableName);
  }

  bool canPerformBackup() {
    return !_isOperating && hasData;
  }

  bool canPerformRestore() {
    return !_isOperating && _backupData.hasBackupAvailable;
  }

  bool canPerformDeletion() {
    return !_isOperating && hasData;
  }

  Map<String, String> getTableCounts() {
    final result = <String, String>{};
    for (final entry in _databaseStats.tableCounts.entries) {
      final displayName = getTableDisplayName(entry.key);
      final count = entry.value.toString();
      result[displayName] = count;
    }
    return result;
  }

  // Clear Hive boxes directly
  Future<void> clearHiveBoxes() async {
    try {
      _setOperating(true);
      
      final boxes = [
        'box_vet_animais',
        'box_vet_pesos',
        'box_vet_vacinas',
        'box_vet_lembrete',
        'box_vet_medicamentos',
        'box_vet_despesas',
      ];

      for (final boxName in boxes) {
        try {
          final box = await Hive.openBox(boxName);
          await box.clear();
          await box.close();
        } catch (e) {
          debugPrint('Error clearing box $boxName: $e');
        }
      }

      await _loadDatabaseStats();
      await _loadBackupData();
      
      _setLastOperation(BackupOperationResult.success(
        operation: BackupOperation.delete,
        message: 'Dados removidos com sucesso!',
      ));
    } catch (e) {
      _setLastOperation(BackupOperationResult.error(
        operation: BackupOperation.delete,
        message: 'Erro ao remover dados: $e',
      ));
    } finally {
      _setOperating(false);
    }
  }

  Future<void> refresh() async {
    _clearError();
    await initialize();
  }

  void _setOperating(bool operating) {
    _isOperating = operating;
    notifyListeners();
  }

  void _setLastOperation(BackupOperationResult operation) {
    _lastOperation = operation;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('BackupController Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

}
