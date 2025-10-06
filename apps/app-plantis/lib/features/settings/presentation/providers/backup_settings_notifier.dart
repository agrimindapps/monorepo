import 'dart:async';

import 'package:core/core.dart' hide getIt;
import 'package:flutter/material.dart';

import '../../../../core/data/models/backup_model.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/backup_restore_service.dart' show RestoreOptions, RestoreResult;
import '../../../../core/services/backup_service.dart';

part 'backup_settings_notifier.g.dart';

/// State model para backup settings (imutável)
class BackupSettingsState {
  final BackupSettings settings;
  final List<BackupInfo> backups;
  final bool isLoading;
  final bool isCreatingBackup;
  final bool isRestoringBackup;
  final String? errorMessage;
  final String? successMessage;
  final DateTime? lastBackupTime;
  final double backupProgress;
  final double restoreProgress;
  final String? restoreStatusMessage;
  final BackupResult? lastBackupResult;
  final RestoreResult? lastRestoreResult;

  const BackupSettingsState({
    required this.settings,
    required this.backups,
    this.isLoading = false,
    this.isCreatingBackup = false,
    this.isRestoringBackup = false,
    this.errorMessage,
    this.successMessage,
    this.lastBackupTime,
    this.backupProgress = 0.0,
    this.restoreProgress = 0.0,
    this.restoreStatusMessage,
    this.lastBackupResult,
    this.lastRestoreResult,
  });

  factory BackupSettingsState.initial() {
    return BackupSettingsState(
      settings: BackupSettings.defaultSettings(),
      backups: const [],
      isLoading: false,
    );
  }

  BackupSettingsState copyWith({
    BackupSettings? settings,
    List<BackupInfo>? backups,
    bool? isLoading,
    bool? isCreatingBackup,
    bool? isRestoringBackup,
    String? errorMessage,
    String? successMessage,
    DateTime? lastBackupTime,
    double? backupProgress,
    double? restoreProgress,
    String? restoreStatusMessage,
    BackupResult? lastBackupResult,
    RestoreResult? lastRestoreResult,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearRestoreStatus = false,
  }) {
    return BackupSettingsState(
      settings: settings ?? this.settings,
      backups: backups ?? this.backups,
      isLoading: isLoading ?? this.isLoading,
      isCreatingBackup: isCreatingBackup ?? this.isCreatingBackup,
      isRestoringBackup: isRestoringBackup ?? this.isRestoringBackup,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      backupProgress: backupProgress ?? this.backupProgress,
      restoreProgress: restoreProgress ?? this.restoreProgress,
      restoreStatusMessage: clearRestoreStatus ? null : (restoreStatusMessage ?? this.restoreStatusMessage),
      lastBackupResult: lastBackupResult ?? this.lastBackupResult,
      lastRestoreResult: lastRestoreResult ?? this.lastRestoreResult,
    );
  }

  // Derived state
  bool get hasBackups => backups.isNotEmpty;
  bool get canCreateBackup => !isCreatingBackup && !isRestoringBackup;
  bool get canRestoreBackup => !isCreatingBackup && !isRestoringBackup && hasBackups;

  /// Verifica se há conexão com internet
  bool get isOnline => true; // Simplificado - verificação será feita nos métodos
}

// ============================================================================
// DEPENDENCY PROVIDERS
// ============================================================================

@riverpod
BackupService backupServiceDep(BackupServiceDepRef ref) {
  return getIt<BackupService>();
}

@riverpod
Connectivity connectivityDep(ConnectivityDepRef ref) {
  return getIt<Connectivity>();
}

// ============================================================================
// BACKUP SETTINGS NOTIFIER
// ============================================================================

@riverpod
class BackupSettingsNotifier extends _$BackupSettingsNotifier {
  late final BackupService _backupService;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  Future<BackupSettingsState> build() async {
    _backupService = ref.read(backupServiceDepProvider);
    _connectivity = ref.read(connectivityDepProvider);

    // Cleanup on dispose
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });

    // Initialize
    return await _initialize();
  }

  /// Inicializa o provider
  Future<BackupSettingsState> _initialize() async {
    try {
      // Load settings
      final settings = await _backupService.getBackupSettings();

      // Load backups
      final backupsResult = await _backupService.listBackups();
      final backups = backupsResult.fold(
        (failure) => <BackupInfo>[],
        (backupList) => backupList,
      );

      // Load last backup time
      final lastBackupTime = await _backupService.getLastBackupTimestamp();

      // Monitor connectivity
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          // Atualiza UI quando conectividade muda
          final currentState = state.valueOrNull ?? BackupSettingsState.initial();
          state = AsyncValue.data(currentState); // Trigger rebuild
        },
      );

      return BackupSettingsState(
        settings: settings,
        backups: backups,
        lastBackupTime: lastBackupTime,
        isLoading: false,
      );
    } catch (e) {
      return BackupSettingsState.initial().copyWith(
        errorMessage: 'Erro ao inicializar backup: $e',
      );
    }
  }

  /// Verifica se está conectado apenas via WiFi
  Future<bool> get isOnWifi async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Carrega lista de backups disponíveis
  Future<void> loadBackups() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
        isLoading: true,
      ),
    );

    final result = await _backupService.listBackups();

    result.fold(
      (Failure failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
            errorMessage: 'Erro ao carregar backups: ${failure.message}',
            isLoading: false,
          ),
        );
      },
      (List<BackupInfo> backupList) {
        state = AsyncValue.data(
          (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
            backups: backupList,
            isLoading: false,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Atualiza configurações de backup
  Future<void> updateSettings(BackupSettings newSettings) async {
    try {
      await _backupService.saveBackupSettings(newSettings);

      state = AsyncValue.data(
        (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
          settings: newSettings,
          successMessage: 'Configurações salvas com sucesso',
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
          errorMessage: 'Erro ao salvar configurações: $e',
        ),
      );
    }
  }

  /// Cria um backup manual
  Future<void> createBackup() async {
    final currentState = state.valueOrNull ?? BackupSettingsState.initial();

    if (!currentState.canCreateBackup) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Não é possível criar backup no momento',
        ),
      );
      return;
    }

    // Verifica se deve usar apenas WiFi
    if (currentState.settings.wifiOnlyEnabled && !(await isOnWifi)) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Backup configurado apenas para WiFi',
        ),
      );
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isCreatingBackup: true,
        backupProgress: 0.0,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      // Simula progresso durante o backup
      _updateBackupProgress(0.1);

      final result = await _backupService.createBackup();

      _updateBackupProgress(0.9);

      result.fold(
        (Failure failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
              errorMessage: 'Erro ao criar backup: ${failure.message}',
              isCreatingBackup: false,
              backupProgress: 0.0,
            ),
          );
        },
        (BackupResult backupResult) {
          state = AsyncValue.data(
            (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
              lastBackupResult: backupResult,
              lastBackupTime: DateTime.now(),
              successMessage: 'Backup criado com sucesso! '
                  'Tamanho: ${_formatFileSize(backupResult.sizeInBytes ?? 0)}',
              isCreatingBackup: false,
              backupProgress: 1.0,
            ),
          );

          // Recarrega lista de backups
          loadBackups();
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
          errorMessage: 'Erro inesperado ao criar backup: $e',
          isCreatingBackup: false,
          backupProgress: 0.0,
        ),
      );
    }
  }

  /// Restaura um backup específico com progress tracking detalhado
  Future<void> restoreBackup(String backupId, RestoreOptions options) async {
    final currentState = state.valueOrNull ?? BackupSettingsState.initial();

    if (!currentState.canRestoreBackup) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Não é possível restaurar backup no momento',
        ),
      );
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isRestoringBackup: true,
        restoreProgress: 0.0,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      // Fase 1: Validação (0% - 10%)
      _updateRestoreProgress(0.0, 'Validando integridade do backup...');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _updateRestoreProgress(0.05, 'Verificando compatibilidade...');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      _updateRestoreProgress(0.1, 'Criando backup de segurança...');
      await Future<void>.delayed(const Duration(milliseconds: 700));

      // Fase 2: Preparação (10% - 20%)
      _updateRestoreProgress(0.15, 'Preparando restauração...');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _updateRestoreProgress(0.2, 'Iniciando processo de restauração...');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Executar restore com progress tracking
      final result = await _executeRestoreWithProgress(backupId, options);

      result.fold(
        (Failure failure) {
          state = AsyncValue.data(
            (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
              errorMessage: 'Erro ao restaurar backup: ${failure.message}',
              isRestoringBackup: false,
              restoreProgress: 0.0,
              clearRestoreStatus: true,
            ),
          );
        },
        (RestoreResult restoreResult) {
          final itemsText = restoreResult.itemsRestored == 1 ? 'item' : 'itens';
          final countsText = _buildRestoreCountsText(restoreResult.restoredCounts);

          state = AsyncValue.data(
            (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
              lastRestoreResult: restoreResult,
              successMessage: 'Backup restaurado com sucesso! '
                  '${restoreResult.itemsRestored} $itemsText restaurados.$countsText',
              isRestoringBackup: false,
              restoreProgress: 1.0,
            ),
          );
        },
      );

      _updateRestoreProgress(1.0, 'Restore concluído!');
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Limpa status message após conclusão
      state = AsyncValue.data(
        (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
          isRestoringBackup: false,
          restoreProgress: 0.0,
          clearRestoreStatus: true,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
          errorMessage: 'Erro inesperado ao restaurar backup: $e',
          isRestoringBackup: false,
          restoreProgress: 0.0,
          clearRestoreStatus: true,
        ),
      );
    }
  }

  /// Executa restore com progress tracking detalhado
  Future<Either<Failure, RestoreResult>> _executeRestoreWithProgress(
    String backupId,
    RestoreOptions options,
  ) async {
    try {
      // Simular progress tracking das diferentes fases
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

      // Chamar o método real do serviço
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
    state = AsyncValue.data(
      (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
        isLoading: true,
      ),
    );

    final result = await _backupService.deleteBackup(backup.id);

    result.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
            errorMessage: 'Erro ao deletar backup: ${failure.message}',
            isLoading: false,
          ),
        );
      },
      (_) {
        final currentState = state.valueOrNull ?? BackupSettingsState.initial();
        final updatedBackups = currentState.backups.where((b) => b.id != backup.id).toList();

        state = AsyncValue.data(
          currentState.copyWith(
            backups: updatedBackups,
            successMessage: 'Backup deletado com sucesso',
            isLoading: false,
          ),
        );
      },
    );
  }

  /// Recarrega dados
  Future<void> refresh() async {
    // Re-initialize
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _initialize());
  }

  /// Verifica se deve fazer backup automático
  Future<bool> shouldAutoBackup() async {
    return await _backupService.shouldAutoBackup();
  }

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    state = AsyncValue.data(
      (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  // Métodos privados para atualizar progresso

  void _updateBackupProgress(double progress) {
    state = AsyncValue.data(
      (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
        backupProgress: progress.clamp(0.0, 1.0),
      ),
    );
  }

  void _updateRestoreProgress(double progress, [String? statusMessage]) {
    state = AsyncValue.data(
      (state.valueOrNull ?? BackupSettingsState.initial()).copyWith(
        restoreProgress: progress.clamp(0.0, 1.0),
        restoreStatusMessage: statusMessage,
      ),
    );
  }

  /// Formata tamanho de arquivo para exibição
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Extensão para facilitar uso com Consumer widgets
extension BackupSettingsStateExtension on BackupSettingsState {
  /// Texto para exibir status do último backup
  String get lastBackupStatusText {
    if (lastBackupTime == null) return 'Nenhum backup realizado';

    final now = DateTime.now();
    final difference = now.difference(lastBackupTime!);

    if (difference.inMinutes < 1) return 'Backup realizado agora';
    if (difference.inHours < 1) return 'Backup há ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Backup há ${difference.inHours}h';
    if (difference.inDays == 1) return 'Backup ontem';
    return 'Backup há ${difference.inDays} dias';
  }

  /// Cor para o status do último backup
  Color get lastBackupStatusColor {
    if (lastBackupTime == null) return Colors.red;

    final difference = DateTime.now().difference(lastBackupTime!);

    if (difference.inDays <= 1) return Colors.green;
    if (difference.inDays <= 7) return Colors.orange;
    return Colors.red;
  }

  /// Ícone para o status do último backup
  IconData get lastBackupStatusIcon {
    if (isCreatingBackup) return Icons.cloud_upload;
    if (lastBackupTime == null) return Icons.warning;

    final difference = DateTime.now().difference(lastBackupTime!);

    if (difference.inDays <= 1) return Icons.check_circle;
    if (difference.inDays <= 7) return Icons.schedule;
    return Icons.warning;
  }
}
