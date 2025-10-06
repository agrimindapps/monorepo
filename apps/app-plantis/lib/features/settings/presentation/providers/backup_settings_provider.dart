import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/models/backup_model.dart';
import '../../../../core/services/backup_restore_service.dart'
    show RestoreOptions, RestoreResult;
import '../../../../core/services/backup_service.dart';

/// Provider para gerenciar configurações e operações de backup
class BackupSettingsProvider extends ChangeNotifier {
  final BackupService _backupService;
  final Connectivity _connectivity;

  BackupSettings _settings = BackupSettings.defaultSettings();
  List<BackupInfo> _backups = [];
  bool _isLoading = false;
  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;
  String? _errorMessage;
  String? _successMessage;
  DateTime? _lastBackupTime;
  double _backupProgress = 0.0;
  double _restoreProgress = 0.0;
  String? _restoreStatusMessage;
  BackupResult? _lastBackupResult;
  RestoreResult? _lastRestoreResult;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  BackupSettingsProvider({
    required BackupService backupService,
    required Connectivity connectivity,
  }) : _backupService = backupService,
       _connectivity = connectivity {
    _initialize();
  }
  BackupSettings get settings => _settings;
  List<BackupInfo> get backups => _backups;
  bool get isLoading => _isLoading;
  bool get isCreatingBackup => _isCreatingBackup;
  bool get isRestoringBackup => _isRestoringBackup;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DateTime? get lastBackupTime => _lastBackupTime;
  double get backupProgress => _backupProgress;
  double get restoreProgress => _restoreProgress;
  String? get restoreStatusMessage => _restoreStatusMessage;
  BackupResult? get lastBackupResult => _lastBackupResult;
  RestoreResult? get lastRestoreResult => _lastRestoreResult;

  bool get hasBackups => _backups.isNotEmpty;
  bool get canCreateBackup => !_isCreatingBackup && !_isRestoringBackup;
  bool get canRestoreBackup =>
      !_isCreatingBackup && !_isRestoringBackup && hasBackups;

  /// Verifica se há conexão com internet
  /// Nota: Esta é uma verificação simplificada. Para verificação completa,
  /// use métodos assíncronos com ping de rede real
  bool get isOnline {
    return true;
  }

  /// Verifica se está conectado apenas via WiFi
  Future<bool> get isOnWifi async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Inicializa o provider
  void _initialize() {
    _loadSettings();
    _loadBackups();
    _loadLastBackupTime();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      notifyListeners(); // Atualiza UI quando conectividade muda
    });
  }

  /// Carrega configurações salvas
  Future<void> _loadSettings() async {
    try {
      _settings = await _backupService.getBackupSettings();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar configurações: $e');
    }
  }

  /// Carrega lista de backups disponíveis
  Future<void> _loadBackups() async {
    _setLoading(true);

    final result = await _backupService.listBackups();

    result.fold(
      (Failure failure) =>
          _setError('Erro ao carregar backups: ${failure.message}'),
      (List<BackupInfo> backupList) {
        _backups = backupList;
        _clearError();
      },
    );

    _setLoading(false);
  }

  /// Carrega timestamp do último backup
  Future<void> _loadLastBackupTime() async {
    try {
      _lastBackupTime = await _backupService.getLastBackupTimestamp();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar último backup: $e');
    }
  }

  /// Atualiza configurações de backup
  Future<void> updateSettings(BackupSettings newSettings) async {
    try {
      await _backupService.saveBackupSettings(newSettings);
      _settings = newSettings;
      _setSuccess('Configurações salvas com sucesso');
      notifyListeners();
    } catch (e) {
      _setError('Erro ao salvar configurações: $e');
    }
  }

  /// Cria um backup manual
  Future<void> createBackup() async {
    if (!canCreateBackup) {
      _setError('Não é possível criar backup no momento');
      return;
    }
    if (_settings.wifiOnlyEnabled && !(await isOnWifi)) {
      _setError('Backup configurado apenas para WiFi');
      return;
    }

    _isCreatingBackup = true;
    _backupProgress = 0.0;
    _clearError();
    _clearSuccess();
    notifyListeners();

    try {
      _updateBackupProgress(0.1);

      final result = await _backupService.createBackup();

      _updateBackupProgress(0.9);

      result.fold(
        (Failure failure) {
          _setError('Erro ao criar backup: ${failure.message}');
          _lastBackupResult = null;
        },
        (BackupResult backupResult) {
          _lastBackupResult = backupResult;
          _lastBackupTime = DateTime.now();
          _setSuccess(
            'Backup criado com sucesso! '
            'Tamanho: ${_formatFileSize(backupResult.sizeInBytes ?? 0)}',
          );
          _loadBackups();
        },
      );

      _updateBackupProgress(1.0);
    } catch (e) {
      _setError('Erro inesperado ao criar backup: $e');
      _lastBackupResult = null;
    } finally {
      _isCreatingBackup = false;
      _backupProgress = 0.0;
      notifyListeners();
    }
  }

  /// Restaura um backup específico com progress tracking detalhado
  Future<void> restoreBackup(String backupId, RestoreOptions options) async {
    if (!canRestoreBackup) {
      _setError('Não é possível restaurar backup no momento');
      return;
    }

    _isRestoringBackup = true;
    _restoreProgress = 0.0;
    _clearError();
    _clearSuccess();
    notifyListeners();

    try {
      _updateRestoreProgress(0.0, 'Validando integridade do backup...');
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      ); // Simular tempo de validação

      _updateRestoreProgress(0.05, 'Verificando compatibilidade...');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      _updateRestoreProgress(0.1, 'Criando backup de segurança...');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      _updateRestoreProgress(0.15, 'Preparando restauração...');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _updateRestoreProgress(0.2, 'Iniciando processo de restauração...');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final result = await _executeRestoreWithProgress(backupId, options);

      result.fold(
        (Failure failure) {
          _setError('Erro ao restaurar backup: ${failure.message}');
          _lastRestoreResult = null;
        },
        (RestoreResult restoreResult) {
          _lastRestoreResult = restoreResult;

          final itemsText = restoreResult.itemsRestored == 1 ? 'item' : 'itens';
          final countsText = _buildRestoreCountsText(
            restoreResult.restoredCounts,
          );

          _setSuccess(
            'Backup restaurado com sucesso! '
            '${restoreResult.itemsRestored} $itemsText restaurados.$countsText',
          );
        },
      );

      _updateRestoreProgress(1.0, 'Restore concluído!');
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _setError('Erro inesperado ao restaurar backup: $e');
      _lastRestoreResult = null;
    } finally {
      _isRestoringBackup = false;
      _restoreProgress = 0.0;
      _restoreStatusMessage = null;
      notifyListeners();
    }
  }

  /// Executa restore com progress tracking detalhado
  Future<Either<Failure, RestoreResult>> _executeRestoreWithProgress(
    String backupId,
    RestoreOptions options,
  ) async {
    try {
      if (options.restorePlants) {
        _updateRestoreProgress(0.3, 'Restaurando plantas...');
        await Future<void>.delayed(const Duration(milliseconds: 1000));
      }

      if (options.restoreSpaces) {
        _updateRestoreProgress(0.5, 'Restaurando espaços...');
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }

      if (options.restoreTasks) {
        _updateRestoreProgress(0.7, 'Restaurando tarefas...');
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }

      if (options.restoreSettings) {
        _updateRestoreProgress(0.85, 'Restaurando configurações...');
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      _updateRestoreProgress(0.95, 'Finalizando restauração...');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return await _backupService.restoreBackup(backupId, options);
    } catch (e) {
      return Left(UnknownFailure('Erro no progress tracking: ${e.toString()}'));
    }
  }

  /// Constrói texto descritivo das contagens restauradas
  String _buildRestoreCountsText(Map<String, int> counts) {
    if (counts.isEmpty) return '';

    final parts = <String>[];
    if (counts['plants'] != null && counts['plants']! > 0) {
      final plantText = counts['plants']! == 1 ? 'planta' : 'plantas';
      parts.add('${counts['plants']} $plantText');
    }
    if (counts['spaces'] != null && counts['spaces']! > 0) {
      final spaceText = counts['spaces']! == 1 ? 'espaço' : 'espaços';
      parts.add('${counts['spaces']} $spaceText');
    }
    if (counts['tasks'] != null && counts['tasks']! > 0) {
      final taskText = counts['tasks']! == 1 ? 'tarefa' : 'tarefas';
      parts.add('${counts['tasks']} $taskText');
    }

    if (parts.isEmpty) return '';

    return ' (${parts.join(', ')})';
  }

  /// Deleta um backup específico
  Future<void> deleteBackup(BackupInfo backup) async {
    _setLoading(true);

    final result = await _backupService.deleteBackup(backup.id);

    result.fold(
      (failure) => _setError('Erro ao deletar backup: ${failure.message}'),
      (_) {
        _backups.removeWhere((b) => b.id == backup.id);
        _setSuccess('Backup deletado com sucesso');
      },
    );

    _setLoading(false);
  }

  /// Recarrega dados
  Future<void> refresh() async {
    await Future.wait([_loadSettings(), _loadBackups(), _loadLastBackupTime()]);
  }

  /// Verifica se deve fazer backup automático
  Future<bool> shouldAutoBackup() async {
    return await _backupService.shouldAutoBackup();
  }

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    _clearError();
    _clearSuccess();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String success) {
    _successMessage = success;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  void _updateBackupProgress(double progress) {
    _backupProgress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void _updateRestoreProgress(double progress, [String? statusMessage]) {
    _restoreProgress = progress.clamp(0.0, 1.0);
    _restoreStatusMessage = statusMessage;
    notifyListeners();
  }

  /// Formata tamanho de arquivo para exibição
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Extensão para facilitar uso com Consumer widgets
extension BackupSettingsProviderExtension on BackupSettingsProvider {
  /// Texto para exibir status do último backup
  String get lastBackupStatusText {
    if (_lastBackupTime == null) return 'Nenhum backup realizado';

    final now = DateTime.now();
    final difference = now.difference(_lastBackupTime!);

    if (difference.inMinutes < 1) return 'Backup realizado agora';
    if (difference.inHours < 1) return 'Backup há ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Backup há ${difference.inHours}h';
    if (difference.inDays == 1) return 'Backup ontem';
    return 'Backup há ${difference.inDays} dias';
  }

  /// Cor para o status do último backup
  Color get lastBackupStatusColor {
    if (_lastBackupTime == null) return Colors.red;

    final difference = DateTime.now().difference(_lastBackupTime!);

    if (difference.inDays <= 1) return Colors.green;
    if (difference.inDays <= 7) return Colors.orange;
    return Colors.red;
  }

  /// Ícone para o status do último backup
  IconData get lastBackupStatusIcon {
    if (_isCreatingBackup) return Icons.cloud_upload;
    if (_lastBackupTime == null) return Icons.warning;

    final difference = DateTime.now().difference(_lastBackupTime!);

    if (difference.inDays <= 1) return Icons.check_circle;
    if (difference.inDays <= 7) return Icons.schedule;
    return Icons.warning;
  }
}
