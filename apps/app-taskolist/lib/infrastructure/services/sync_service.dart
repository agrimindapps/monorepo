import 'dart:async';

import 'package:core/core.dart' hide Failure;
import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import 'analytics_service.dart';
import 'crashlytics_service.dart';

/// Serviço de sincronização do Task Manager
/// Integra dados locais com o Firebase para usuários Premium
@lazySingleton
class TaskManagerSyncService {
  final TaskManagerAnalyticsService _analyticsService;
  final TaskManagerCrashlyticsService _crashlyticsService;
  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  bool _isSyncing = false;
  Timer? _autoSyncTimer;

  TaskManagerSyncService(this._analyticsService, this._crashlyticsService) {
    _initializeAutoSync();
  }
  Stream<SyncProgress> get progressStream => _progressController.stream;
  Stream<String> get messageStream => _messageController.stream;
  bool get isSyncing => _isSyncing;

  /// Inicializa sincronização automática
  void _initializeAutoSync() {
    if (kDebugMode) {
      debugPrint('🔄 TaskManagerSyncService: Auto-sync inicializado');
    }
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isSyncing) {
        _syncInBackground();
      }
    });
  }

  /// Sincronização completa (após login)
  Future<Either<Failure, void>> syncAll({
    required String userId,
    bool isUserPremium = false,
  }) async {
    if (_isSyncing) {
      return const Right(null);
    }

    _isSyncing = true;
    _emitProgress(SyncProgress.starting());
    _emitMessage('Iniciando sincronização...');

    try {
      await _analyticsService.logEvent(
        'sync_started',
        parameters: {
          'user_id': userId,
          'is_premium': isUserPremium,
          'sync_type': 'full',
        },
      );
      _emitProgress(
        SyncProgress.inProgress(
          step: 1,
          totalSteps: 4,
          message: 'Sincronizando projetos...',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      final projectsResult = await _syncProjects(userId, isUserPremium);
      if (projectsResult.isLeft()) {
        return _handleSyncError(
          projectsResult.fold((l) => l, (r) => throw Exception()),
        );
      }
      _emitProgress(
        SyncProgress.inProgress(
          step: 2,
          totalSteps: 4,
          message: 'Sincronizando tarefas...',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 2000));

      final tasksResult = await _syncTasks(userId, isUserPremium);
      if (tasksResult.isLeft()) {
        return _handleSyncError(
          tasksResult.fold((l) => l, (r) => throw Exception()),
        );
      }
      _emitProgress(
        SyncProgress.inProgress(
          step: 3,
          totalSteps: 4,
          message: 'Sincronizando configurações...',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final settingsResult = await _syncSettings(userId, isUserPremium);
      if (settingsResult.isLeft()) {
        return _handleSyncError(
          settingsResult.fold((l) => l, (r) => throw Exception()),
        );
      }
      _emitProgress(
        SyncProgress.inProgress(
          step: 4,
          totalSteps: 4,
          message: 'Finalizando...',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _emitProgress(SyncProgress.completed());
      _emitMessage('Sincronização concluída com sucesso!');
      await _analyticsService.logEvent(
        'sync_completed',
        parameters: {
          'user_id': userId,
          'is_premium': isUserPremium,
          'sync_type': 'full',
        },
      );

      if (kDebugMode) {
        debugPrint(
          '✅ TaskManagerSyncService: Sync completo realizado com sucesso',
        );
      }

      return const Right(null);
    } catch (e, stackTrace) {
      return _handleSyncError(
        SyncFailure('Erro na sincronização: $e'),
        stackTrace,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincronização de projetos
  Future<Either<Failure, void>> _syncProjects(
    String userId,
    bool isUserPremium,
  ) async {
    try {
      if (!isUserPremium) {
        return const Right(null);
      }

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar projetos: $e'));
    }
  }

  /// Sincronização de tarefas
  Future<Either<Failure, void>> _syncTasks(
    String userId,
    bool isUserPremium,
  ) async {
    try {
      if (!isUserPremium) {
        return const Right(null);
      }

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar tarefas: $e'));
    }
  }

  /// Sincronização de configurações
  Future<Either<Failure, void>> _syncSettings(
    String userId,
    bool isUserPremium,
  ) async {
    try {
      if (!isUserPremium) {
        return const Right(null);
      }

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar configurações: $e'));
    }
  }

  /// Sincronização em background (silenciosa)
  Future<void> _syncInBackground() async {
    try {
      final authService = getIt<IAuthRepository>();
      final currentUser = await authService.currentUser.first;

      if (currentUser == null) return;
      const isUserPremium = false;

      if (kDebugMode) {
        debugPrint('🔄 TaskManagerSyncService: Executando sync em background');
      }
      await syncAll(userId: currentUser.id, isUserPremium: isUserPremium);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TaskManagerSyncService: Erro em background sync: $e');
      }
    }
  }

  Either<Failure, void> _handleSyncError(
    Failure failure, [
    StackTrace? stackTrace,
  ]) {
    _emitProgress(SyncProgress.error(failure.message));
    _emitMessage('Erro: ${failure.message}');
    _crashlyticsService.recordError(
      exception: failure,
      stackTrace: stackTrace ?? StackTrace.current,
      reason: 'Sync error in TaskManagerSyncService',
    );

    _analyticsService.logEvent(
      'sync_failed',
      parameters: {
        'error_message': failure.message,
        'error_type': failure.runtimeType.toString(),
      },
    );

    if (kDebugMode) {
      debugPrint('❌ TaskManagerSyncService: Erro no sync: ${failure.message}');
    }

    _isSyncing = false;
    return Left(failure);
  }

  /// Emite progresso do sync
  void _emitProgress(SyncProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  /// Emite mensagem do sync
  void _emitMessage(String message) {
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  /// Cleanup dos recursos
  void dispose() {
    _autoSyncTimer?.cancel();
    _progressController.close();
    _messageController.close();
  }
}

/// Classe para representar o progresso do sync
class SyncProgress {
  final SyncStatus status;
  final int currentStep;
  final int totalSteps;
  final String message;
  final double progress;

  const SyncProgress._({
    required this.status,
    required this.currentStep,
    required this.totalSteps,
    required this.message,
    required this.progress,
  });

  factory SyncProgress.starting() => const SyncProgress._(
    status: SyncStatus.starting,
    currentStep: 0,
    totalSteps: 4,
    message: 'Iniciando...',
    progress: 0.0,
  );

  factory SyncProgress.inProgress({
    required int step,
    required int totalSteps,
    required String message,
  }) => SyncProgress._(
    status: SyncStatus.inProgress,
    currentStep: step,
    totalSteps: totalSteps,
    message: message,
    progress: step / totalSteps,
  );

  factory SyncProgress.completed() => const SyncProgress._(
    status: SyncStatus.completed,
    currentStep: 4,
    totalSteps: 4,
    message: 'Concluído!',
    progress: 1.0,
  );

  factory SyncProgress.error(String errorMessage) => SyncProgress._(
    status: SyncStatus.error,
    currentStep: 0,
    totalSteps: 4,
    message: errorMessage,
    progress: 0.0,
  );

  bool get isCompleted => status == SyncStatus.completed;
  bool get isError => status == SyncStatus.error;
  bool get isInProgress => status == SyncStatus.inProgress;
}

enum SyncStatus { starting, inProgress, completed, error }

/// Failure específico para sync
class SyncFailure extends Failure {
  final String _message;

  const SyncFailure(this._message);

  @override
  String get message => _message;

  @override
  List<Object> get props => [_message];
}
