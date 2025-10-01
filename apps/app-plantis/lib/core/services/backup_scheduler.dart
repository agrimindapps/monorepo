import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../data/models/backup_model.dart';
import 'backup_service.dart';

/// Service responsável por agendar e executar backups automáticos
/// NOTE: Registrado manualmente em injection_container.dart (não via @singleton)
class BackupScheduler {
  final BackupService _backupService;
  final ISubscriptionRepository _subscriptionRepository;
  final Connectivity _connectivity;

  Timer? _schedulerTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isRunning = false;

  static const Duration _checkInterval = Duration(
    minutes: 30,
  ); // Verifica a cada 30 minutos

  BackupScheduler({
    required BackupService backupService,
    required ISubscriptionRepository subscriptionRepository,
    required Connectivity connectivity,
  }) : _backupService = backupService,
       _subscriptionRepository = subscriptionRepository,
       _connectivity = connectivity;

  /// Inicia o scheduler de backup automático
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    debugPrint('BackupScheduler: Iniciado');

    // Timer periódico para verificar se precisa fazer backup
    _schedulerTimer = Timer.periodic(_checkInterval, (timer) {
      _checkAndExecuteBackup();
    });

    // Monitora conectividade para tentar backup quando voltar online
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        // Voltou a ter conexão, verifica se precisa fazer backup
        Future.delayed(const Duration(seconds: 5), () {
          _checkAndExecuteBackup();
        });
      }
    });

    // Faz verificação inicial
    Future.delayed(const Duration(seconds: 10), () {
      _checkAndExecuteBackup();
    });
  }

  /// Para o scheduler de backup automático
  void stop() {
    if (!_isRunning) return;

    _isRunning = false;
    debugPrint('BackupScheduler: Parado');

    _schedulerTimer?.cancel();
    _schedulerTimer = null;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Força uma verificação e execução de backup se necessário
  Future<void> forceCheck() async {
    if (!_isRunning) return;
    await _checkAndExecuteBackup();
  }

  /// Verifica se precisa fazer backup e executa se necessário
  Future<void> _checkAndExecuteBackup() async {
    try {
      // Verifica se usuário tem premium
      if (!await _isPremiumUser()) {
        debugPrint('BackupScheduler: Usuário não é premium, pulando backup');
        return;
      }

      // Verifica se precisa fazer backup
      final shouldBackup = await _backupService.shouldAutoBackup();
      if (!shouldBackup) {
        debugPrint('BackupScheduler: Backup não necessário no momento');
        return;
      }

      // Carrega configurações de backup
      final settings = await _backupService.getBackupSettings();

      // Verifica se backup automático está habilitado
      if (!settings.autoBackupEnabled) {
        debugPrint('BackupScheduler: Backup automático desabilitado');
        return;
      }

      // Verifica conectividade
      if (!await _hasInternetConnection()) {
        debugPrint('BackupScheduler: Sem conexão com internet');
        return;
      }

      // Verifica se deve usar apenas WiFi
      if (settings.wifiOnlyEnabled && !await _isConnectedToWifi()) {
        debugPrint(
          'BackupScheduler: Configurado apenas para WiFi, mas não está no WiFi',
        );
        return;
      }

      debugPrint('BackupScheduler: Iniciando backup automático');

      // Executa o backup
      final result = await _backupService.createBackup();

      result.fold(
        (failure) {
          debugPrint(
            'BackupScheduler: Erro no backup automático: ${failure.message}',
          );
          // Aqui poderia enviar notificação de erro se necessário
        },
        (backupResult) {
          debugPrint(
            'BackupScheduler: Backup automático concluído com sucesso: ${backupResult.fileName}',
          );

          // Aqui poderia enviar notificação de sucesso se necessário
          _showBackupSuccessNotification(backupResult);
        },
      );
    } catch (e) {
      debugPrint(
        'BackupScheduler: Erro inesperado durante backup automático: $e',
      );
    }
  }

  /// Verifica se o usuário é premium
  Future<bool> _isPremiumUser() async {
    try {
      final subscriptionResult =
          await _subscriptionRepository.getCurrentSubscription();
      return subscriptionResult.fold(
        (failure) => false,
        (subscription) => subscription?.isActive ?? false,
      );
    } catch (e) {
      return false;
    }
  }

  /// Verifica se há conexão com internet
  Future<bool> _hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Verifica se está conectado ao WiFi
  Future<bool> _isConnectedToWifi() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }

  /// Mostra notificação de backup concluído com sucesso
  void _showBackupSuccessNotification(BackupResult result) {
    // TODO: Integrar com sistema de notificações local
    // Por enquanto apenas faz log
    debugPrint(
      'BackupScheduler: Notificação - Backup realizado com sucesso (${result.fileName})',
    );
  }

  /// Agenda um backup para ser executado em horário específico
  Future<void> scheduleBackupAt(DateTime scheduledTime) async {
    final now = DateTime.now();

    if (scheduledTime.isBefore(now)) {
      debugPrint(
        'BackupScheduler: Horário agendado já passou, executando agora',
      );
      await _checkAndExecuteBackup();
      return;
    }

    final delay = scheduledTime.difference(now);
    debugPrint(
      'BackupScheduler: Backup agendado para ${scheduledTime.toString()}',
    );

    Timer(delay, () {
      _checkAndExecuteBackup();
    });
  }

  /// Retorna o próximo horário de backup baseado na configuração
  Future<DateTime?> getNextScheduledBackup() async {
    try {
      final settings = await _backupService.getBackupSettings();

      if (!settings.autoBackupEnabled ||
          settings.frequency == BackupFrequency.manual) {
        return null;
      }

      final lastBackup = await _backupService.getLastBackupTimestamp();
      final baseTime = lastBackup ?? DateTime.now();

      switch (settings.frequency) {
        case BackupFrequency.daily:
          return baseTime.add(const Duration(days: 1));
        case BackupFrequency.weekly:
          return baseTime.add(const Duration(days: 7));
        case BackupFrequency.manual:
          return null;
      }
    } catch (e) {
      debugPrint('BackupScheduler: Erro ao calcular próximo backup: $e');
      return null;
    }
  }

  /// Retorna status do scheduler
  BackupSchedulerStatus getStatus() {
    return BackupSchedulerStatus(
      isRunning: _isRunning,
      nextCheck:
          _schedulerTimer != null ? DateTime.now().add(_checkInterval) : null,
    );
  }

  /// Limpa recursos quando não for mais necessário
  void dispose() {
    stop();
  }
}

/// Status atual do scheduler de backup
class BackupSchedulerStatus {
  final bool isRunning;
  final DateTime? nextCheck;

  const BackupSchedulerStatus({required this.isRunning, this.nextCheck});

  @override
  String toString() {
    return 'BackupSchedulerStatus(isRunning: $isRunning, nextCheck: $nextCheck)';
  }
}

/// Gerenciador de lifecycle do scheduler
/// NOTE: Registrado manualmente em injection_container.dart (não via @singleton)
class BackupSchedulerManager {
  final BackupScheduler _scheduler;
  bool _isInitialized = false;

  BackupSchedulerManager(this._scheduler);

  /// Inicializa o scheduler (chamado no startup da app)
  void initialize() {
    if (_isInitialized) return;

    _isInitialized = true;
    _scheduler.start();

    debugPrint('BackupSchedulerManager: Inicializado');
  }

  /// Para o scheduler (chamado no shutdown da app)
  void shutdown() {
    if (!_isInitialized) return;

    _scheduler.stop();
    _isInitialized = false;

    debugPrint('BackupSchedulerManager: Parado');
  }

  /// Força verificação de backup
  Future<void> forceCheck() async {
    if (!_isInitialized) return;
    await _scheduler.forceCheck();
  }

  /// Retorna o próximo backup agendado
  Future<DateTime?> getNextScheduledBackup() async {
    return await _scheduler.getNextScheduledBackup();
  }

  /// Retorna status atual
  BackupSchedulerStatus getStatus() {
    return _scheduler.getStatus();
  }
}
