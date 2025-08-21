import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/data/models/backup_model.dart';

/// Provider para gerenciar configurações e operações de backup
class BackupSettingsProvider extends ChangeNotifier {
  final BackupService _backupService;
  final ISubscriptionRepository _subscriptionRepository;
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
  BackupResult? _lastBackupResult;
  RestoreResult? _lastRestoreResult;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  BackupSettingsProvider({
    required BackupService backupService,
    required ISubscriptionRepository subscriptionRepository,
    required Connectivity connectivity,
  }) : _backupService = backupService,
       _subscriptionRepository = subscriptionRepository,
       _connectivity = connectivity {
    _initialize();
  }

  // Getters
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
  BackupResult? get lastBackupResult => _lastBackupResult;
  RestoreResult? get lastRestoreResult => _lastRestoreResult;

  bool get hasBackups => _backups.isNotEmpty;
  bool get canCreateBackup => !_isCreatingBackup && !_isRestoringBackup && isPremiumUser;
  bool get canRestoreBackup => !_isCreatingBackup && !_isRestoringBackup && hasBackups && isPremiumUser;

  /// Verifica se o usuário tem acesso premium
  bool get isPremiumUser {
    // Verifica através do subscription repository
    // Em uma implementação mais robusta, isso seria um stream
    return _checkPremiumStatus();
  }

  bool _checkPremiumStatus() {
    // Chama de forma síncrona o último estado conhecido
    // Na prática, isso deveria ser gerenciado via stream
    try {
      // Por enquanto, assume que usuário autenticado é premium para desenvolvimento
      return true; // TODO: Implementar verificação real com subscription
    } catch (e) {
      return false;
    }
  }

  /// Verifica se está conectado à internet
  bool get isOnline {
    // Simplified check - in practice would need async verification
    return true; // Assume online for development
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
    
    // Monitora conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        notifyListeners(); // Atualiza UI quando conectividade muda
      },
    );
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
      (failure) => _setError('Erro ao carregar backups: ${failure.message}'),
      (backupList) {
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

    // Verifica se deve usar apenas WiFi
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
      // Simula progresso durante o backup
      _updateBackupProgress(0.1);

      final result = await _backupService.createBackup();

      _updateBackupProgress(0.9);

      result.fold(
        (failure) {
          _setError('Erro ao criar backup: ${failure.message}');
          _lastBackupResult = null;
        },
        (backupResult) {
          _lastBackupResult = backupResult;
          _lastBackupTime = DateTime.now();
          _setSuccess(
            'Backup criado com sucesso! '
            'Tamanho: ${_formatFileSize(backupResult.sizeInBytes ?? 0)}'
          );
          
          // Recarrega lista de backups
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

  /// Restaura um backup específico
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
      _updateRestoreProgress(0.1);

      final result = await _backupService.restoreBackup(backupId, options);

      _updateRestoreProgress(0.9);

      result.fold(
        (failure) {
          _setError('Erro ao restaurar backup: ${failure.message}');
          _lastRestoreResult = null;
        },
        (restoreResult) {
          _lastRestoreResult = restoreResult;
          
          final itemsText = restoreResult.itemsRestored == 1 ? 'item' : 'itens';
          _setSuccess(
            'Backup restaurado com sucesso! '
            '${restoreResult.itemsRestored} $itemsText restaurados.'
          );
        },
      );

      _updateRestoreProgress(1.0);
    } catch (e) {
      _setError('Erro inesperado ao restaurar backup: $e');
      _lastRestoreResult = null;
    } finally {
      _isRestoringBackup = false;
      _restoreProgress = 0.0;
      notifyListeners();
    }
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
    await Future.wait([
      _loadSettings(),
      _loadBackups(),
      _loadLastBackupTime(),
    ]);
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

  // Métodos privados para gerenciamento de estado

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

  void _updateRestoreProgress(double progress) {
    _restoreProgress = progress.clamp(0.0, 1.0);
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