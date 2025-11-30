import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import 'sync_pull_service.dart';
import 'sync_push_service.dart';

/// Serviço orquestrador principal de sincronização do Gasometer
///
/// **Responsabilidades:**
/// - Orquestrar sequência: push → pull
/// - Gerenciar status e progresso da sincronização
/// - Agregar resultados finais de push e pull
/// - Emitir eventos de progresso e status
/// - Apenas orquestração, sem lógica de sync individual
///
/// **Princípio SOLID:**
/// - Single Responsibility: Orquestração apenas
/// - Dependency Injection via constructor
/// - Error handling via Either<Failure, T>
/// - Delegação para SyncPushService e SyncPullService
///
/// **Fluxo de Sincronização:**
/// 1. User chama sync() → começa com status SyncServiceStatus.syncing
/// 2. Executa push via SyncPushService (5 adapters em paralelo)
/// 3. Emite progresso: "Enviando dados..." (step 1-5)
/// 4. Executa pull via SyncPullService (5 adapters em paralelo)
/// 5. Emite progresso: "Baixando atualizações..." (step 6-10)
/// 6. Agrega resultados e finaliza com status SyncServiceStatus.completed
/// 7. Retorna ServiceSyncResult com estatísticas
///
/// **Exemplo:**
/// ```dart
/// final orchestrator = GasometerSyncOrchestrator(
///   SyncPushService(...),
///   SyncPullService(...),
/// );
/// 
/// // Listen progress
/// orchestrator.progressStream.listen((progress) {
///   print('${progress.current}/${progress.total}: ${progress.currentItem}');
/// });
/// 
/// // Listen status
/// orchestrator.statusStream.listen((status) {
///   print('Status: $status');
/// });
/// 
/// // Execute sync
/// final result = await orchestrator.sync(userId);
/// ```
class GasometerSyncOrchestrator {
  GasometerSyncOrchestrator({
    required SyncPushService pushService,
    required SyncPullService pullService,
  })  : _pushService = pushService,
        _pullService = pullService;

  final SyncPushService _pushService;
  final SyncPullService _pullService;

  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  final _progressController =
      StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.idle;

  /// Stream de status da sincronização (para atualizar UI)
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;

  /// Stream de progresso (para mostrar barra de progresso)
  Stream<ServiceProgress> get progressStream => _progressController.stream;

  /// Status atual de sincronização
  SyncServiceStatus get currentStatus => _currentStatus;

  /// Executa sincronização completa (push → pull)
  ///
  /// **Comportamento:**
  /// 1. Emite status SyncServiceStatus.syncing
  /// 2. Executa push (5 steps de progresso)
  /// 3. Executa pull (5 steps de progresso)
  /// 4. Emite status SyncServiceStatus.completed ou failed
  /// 5. Retorna resultado detalhado
  ///
  /// **Retorna:**
  /// - Right(result): Sincronização concluída
  /// - Left(failure): Erro crítico
  Future<Either<Failure, ServiceSyncResult>> sync(String userId) async {
    try {
      _updateStatus(SyncServiceStatus.syncing);

      final startTime = DateTime.now();
      final errors = <String>[];
      int totalPushed = 0;
      int totalPulled = 0;

      // ========== PUSH PHASE (Steps 1-5) ==========
      developer.log(
        '📤 Starting push phase...',
        name: 'GasometerOrchestrator',
      );

      final pushResult = await _pushService.pushAll(userId);

      pushResult.fold(
        (failure) {
          errors.add('Push failed: ${failure.message}');
          developer.log(
            '❌ Push phase failed: ${failure.message}',
            name: 'GasometerOrchestrator',
          );
        },
        (pushResults) {
          // Report push phase completion
          // pushResults is a single SyncPhaseResult combining all adapters
          const int step = 1;
          totalPushed = totalPushed + (pushResults.successCount ?? 0);

          _progressController.add(
            ServiceProgress(
              serviceId: 'gasometer',
              operation: 'push_completed',
              current: step,
              total: 10,
              currentItem: 'Push completado: '
                  '${pushResults.successCount ?? 0} sucesso, '
                  '${pushResults.failureCount ?? 0} falhas',
            ),
          );

          if ((pushResults.failureCount ?? 0) > 0) {
            errors.addAll(pushResults.errors ?? []);
          }

          developer.log(
            '✅ Push phase completed: ${pushResults.successCount ?? 0} records pushed',
            name: 'GasometerOrchestrator',
          );
        },
      );

      // ========== PULL PHASE (Steps 6-10) ==========
      developer.log(
        '📥 Starting pull phase...',
        name: 'GasometerOrchestrator',
      );

      final pullResult = await _pullService.pullAll(userId);

      pullResult.fold(
        (failure) {
          errors.add('Pull failed: ${failure.message}');
          developer.log(
            '❌ Pull phase failed: ${failure.message}',
            name: 'GasometerOrchestrator',
          );
        },
        (pullResults) {
          // Report pull phase completion
          // pullResults is a single SyncPhaseResult combining all adapters
          const int step = 6;
          totalPulled = totalPulled + (pullResults.successCount ?? 0);

          _progressController.add(
            ServiceProgress(
              serviceId: 'gasometer',
              operation: 'pull_completed',
              current: step,
              total: 10,
              currentItem: 'Pull completado: '
                  '${pullResults.successCount ?? 0} sucesso, '
                  '${pullResults.failureCount ?? 0} falhas',
            ),
          );

          if ((pullResults.failureCount ?? 0) > 0) {
            errors.addAll(pullResults.errors ?? []);
          }

          developer.log(
            '✅ Pull phase completed: ${pullResults.successCount} records pulled',
            name: 'GasometerOrchestrator',
          );
        },
      );

      // ========== FINALIZATION ==========
      _progressController.add(
        ServiceProgress(
          serviceId: 'gasometer',
          operation: 'completed',
          current: 10,
          total: 10,
          currentItem: 'Sincronização concluída',
        ),
      );

      final duration = DateTime.now().difference(startTime);
      final success = errors.isEmpty;

      if (success) {
        _updateStatus(SyncServiceStatus.completed);
      } else {
        _updateStatus(SyncServiceStatus.failed);
      }

      developer.log(
        '${success ? "✅" : "⚠️"} Sync completed in ${duration.inSeconds}s\n'
        '   Pushed: $totalPushed, Pulled: $totalPulled\n'
        '   Errors: ${errors.length}',
        name: 'GasometerOrchestrator',
      );

      if (errors.isNotEmpty) {
        developer.log('Errors: ${errors.join("; ")}',
            name: 'GasometerOrchestrator');
      }

      return Right(
        ServiceSyncResult(
          success: success,
          itemsSynced: totalPushed + totalPulled,
          itemsFailed: errors.isEmpty ? 0 : 1,
          duration: duration,
          error: errors.isEmpty ? null : errors.join('; '),
        ),
      );
    } catch (e, stackTrace) {
      _updateStatus(SyncServiceStatus.failed);

      developer.log(
        '❌ Sync failed with exception: $e',
        name: 'GasometerOrchestrator',
      );
      developer.log('$stackTrace', name: 'GasometerOrchestrator');

      return Left(ServerFailure('Sync orchestration failed: $e'));
    }
  }

  /// Para a sincronização atual
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.idle);
  }

  /// Limpa os resources (streams)
  Future<void> dispose() async {
    _updateStatus(SyncServiceStatus.disposing);
    await _statusController.close();
    await _progressController.close();
    developer.log(
      '🧹 GasometerSyncOrchestrator disposed',
      name: 'GasometerOrchestrator',
    );
  }

  void _updateStatus(SyncServiceStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
}
