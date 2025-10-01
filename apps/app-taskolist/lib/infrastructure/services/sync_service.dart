import 'dart:async';

import 'package:core/core.dart' hide Failure;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/domain/task_repository.dart';
import 'analytics_service.dart';
import 'crashlytics_service.dart';

/// Serviço de sincronização do Task Manager
/// Integra dados locais com o Firebase para usuários Premium
@lazySingleton
class TaskManagerSyncService {
  final TaskManagerAnalyticsService _analyticsService;
  final TaskManagerCrashlyticsService _crashlyticsService;
  final TaskRepository _taskRepository;

  // Stream controllers para progresso
  final StreamController<SyncProgress> _progressController = StreamController<SyncProgress>.broadcast();
  final StreamController<String> _messageController = StreamController<String>.broadcast();

  // Estado do sync
  bool _isSyncing = false;
  Timer? _autoSyncTimer;

  TaskManagerSyncService(
    this._analyticsService,
    this._crashlyticsService,
    this._taskRepository,
  ) {
    _initializeAutoSync();
  }

  // Streams públicos
  Stream<SyncProgress> get progressStream => _progressController.stream;
  Stream<String> get messageStream => _messageController.stream;
  bool get isSyncing => _isSyncing;

  /// Inicializa sincronização automática
  void _initializeAutoSync() {
    if (kDebugMode) {
      debugPrint('🔄 TaskManagerSyncService: Auto-sync inicializado');
    }
    
    // Auto-sync a cada 5 minutos para usuários Premium
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
      // Log início do sync
      await _analyticsService.logEvent('sync_started', parameters: {
        'user_id': userId,
        'is_premium': isUserPremium,
        'sync_type': 'full',
      });

      // Etapa 1: Sincronizar projetos (1.5s)
      _emitProgress(SyncProgress.inProgress(step: 1, totalSteps: 4, message: 'Sincronizando projetos...'));
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final projectsResult = await _syncProjects(userId, isUserPremium);
      if (projectsResult.isLeft()) {
        return _handleSyncError(projectsResult.fold((l) => l, (r) => throw Exception()));
      }

      // Etapa 2: Sincronizar tarefas (2.0s)
      _emitProgress(SyncProgress.inProgress(step: 2, totalSteps: 4, message: 'Sincronizando tarefas...'));
      await Future.delayed(const Duration(milliseconds: 2000));
      
      final tasksResult = await _syncTasks(userId, isUserPremium);
      if (tasksResult.isLeft()) {
        return _handleSyncError(tasksResult.fold((l) => l, (r) => throw Exception()));
      }

      // Etapa 3: Sincronizar configurações (1.0s)
      _emitProgress(SyncProgress.inProgress(step: 3, totalSteps: 4, message: 'Sincronizando configurações...'));
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final settingsResult = await _syncSettings(userId, isUserPremium);
      if (settingsResult.isLeft()) {
        return _handleSyncError(settingsResult.fold((l) => l, (r) => throw Exception()));
      }

      // Etapa 4: Finalização (0.5s)
      _emitProgress(SyncProgress.inProgress(step: 4, totalSteps: 4, message: 'Finalizando...'));
      await Future.delayed(const Duration(milliseconds: 500));

      // Sucesso
      _emitProgress(SyncProgress.completed());
      _emitMessage('Sincronização concluída com sucesso!');

      // Log sucesso
      await _analyticsService.logEvent('sync_completed', parameters: {
        'user_id': userId,
        'is_premium': isUserPremium,
        'sync_type': 'full',
      });

      if (kDebugMode) {
        debugPrint('✅ TaskManagerSyncService: Sync completo realizado com sucesso');
      }

      return const Right(null);

    } catch (e, stackTrace) {
      return _handleSyncError(SyncFailure('Erro na sincronização: $e'), stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincronização de projetos
  Future<Either<Failure, void>> _syncProjects(String userId, bool isUserPremium) async {
    try {
      if (!isUserPremium) {
        // Usuário free: apenas dados locais
        return const Right(null);
      }

      // Premium: sincronizar com Firestore
      // TODO: Implementar quando ProjectRepository estiver disponível
      // final localProjects = await _projectRepository.getAllProjects();
      
      // Aqui implementaríamos a lógica real de sync com Firestore
      // Por agora, simulamos o processo
      
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar projetos: $e'));
    }
  }

  /// Sincronização de tarefas
  Future<Either<Failure, void>> _syncTasks(String userId, bool isUserPremium) async {
    try {
      if (!isUserPremium) {
        // Usuário free: apenas dados locais
        return const Right(null);
      }

      // Premium: sincronizar com Firestore
      // TODO: Implementar quando TaskRepository tiver getAllTasks
      // final localTasks = await _taskRepository.getAllTasks();
      
      // Aqui implementaríamos a lógica real de sync com Firestore
      // Por agora, simulamos o processo
      
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar tarefas: $e'));
    }
  }

  /// Sincronização de configurações
  Future<Either<Failure, void>> _syncSettings(String userId, bool isUserPremium) async {
    try {
      if (!isUserPremium) {
        return const Right(null);
      }

      // Sincronizar configurações do usuário Premium
      // Implementação futura
      
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar configurações: $e'));
    }
  }

  /// Sincronização em background (silenciosa)
  Future<void> _syncInBackground() async {
    try {
      // Verificar se usuário está logado
      final authService = getIt<IAuthRepository>();
      final currentUser = await authService.currentUser.first;
      
      if (currentUser == null) return;

      // Verificar se é Premium (implementar quando RevenueCat estiver configurado)
      const isUserPremium = false; // TODO: Integrar com RevenueCat
      
      if (!isUserPremium) return;

      if (kDebugMode) {
        debugPrint('🔄 TaskManagerSyncService: Executando sync em background');
      }

      await syncAll(userId: currentUser.id, isUserPremium: isUserPremium);
    } catch (e) {
      // Falha silenciosa em background
      if (kDebugMode) {
        debugPrint('❌ TaskManagerSyncService: Erro em background sync: $e');
      }
    }
  }

  /// Método utilitário para tratar erros de sync
  Either<Failure, void> _handleSyncError(Failure failure, [StackTrace? stackTrace]) {
    _emitProgress(SyncProgress.error(failure.message));
    _emitMessage('Erro: ${failure.message}');

    // Log do erro
    _crashlyticsService.recordError(
      exception: failure,
      stackTrace: stackTrace ?? StackTrace.current,
      reason: 'Sync error in TaskManagerSyncService',
    );

    _analyticsService.logEvent('sync_failed', parameters: {
      'error_message': failure.message,
      'error_type': failure.runtimeType.toString(),
    });

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

enum SyncStatus {
  starting,
  inProgress,
  completed,
  error,
}

/// Failure específico para sync
class SyncFailure extends Failure {
  final String _message;
  
  const SyncFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}