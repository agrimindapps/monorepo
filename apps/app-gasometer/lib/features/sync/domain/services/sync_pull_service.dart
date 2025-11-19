import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../../../../core/services/contracts/i_sync_pull_service.dart';
import '../../../../core/services/contracts/i_sync_push_service.dart';
import '../../../../core/sync/adapters/i_sync_adapter.dart';
import '../../../../core/sync/adapters/sync_adapter_registry.dart';
import '../../../../core/sync/models/sync_results.dart' as sync_models;
import 'sync_checkpoint_store.dart';

/// Modelo para resultado de pull de um adapter
class AdapterPullSnapshot {
  const AdapterPullSnapshot({
    required this.adapterName,
    required this.recordsPulled,
    required this.conflictsResolved,
    required this.duration,
    this.error,
    this.lastRemoteUpdateAt,
  });

  final String adapterName;
  final int recordsPulled;
  final int conflictsResolved;
  final Duration duration;
  final String? error;
  final DateTime? lastRemoteUpdateAt;

  bool get success => error == null;

  String get summary =>
      '${recordsPulled} pulled${conflictsResolved > 0 ? ', ${conflictsResolved} conflicts' : ''}';
}

/// Serviço especializado em coordenar pull (download Firebase → local) dos adapters
///
/// **Implementação de:** ISyncPullService
///
/// **Responsabilidades:**
/// - Coordenar pull de todos os adapters registrados
/// - Executar pulls em paralelo para performance
/// - Agregar resultados e estatísticas
/// - Error handling: um adapter falhando não interrompe os outros
/// - Apenas pull operations, sem push
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas coordenar pulls
/// - Open/Closed: Fácil adicionar novos adapters sem modificar este serviço
/// - Dependency Injection via constructor (registry pattern)
/// - Error handling via Either<Failure, T>
/// - Interface Segregation: Implementa ISyncPullService
/// - Dependency Inversion: Depende de ISyncAdapter, não de implementações
///
/// **Fluxo:**
/// 1. pullAll() itera sobre adapters do registry
/// 2. Executa todos em paralelo via Future.wait
/// 3. Agrega resultados
/// 4. Retorna com estatísticas
///
/// **Exemplo:**
/// ```dart
/// final registry = SyncAdapterRegistry(adapters: [...]);
/// final service = SyncPullService(registry);
/// final result = await service.pullAll(userId);
/// result.fold(
///   (failure) => print('Pull failed: ${failure.message}'),
///   (phaseResult) => print('Pulled ${phaseResult.successCount} records'),
/// );
/// ```
class SyncPullService implements ISyncPullService {
  SyncPullService({
    required SyncAdapterRegistry adapterRegistry,
    required SyncCheckpointStore checkpointStore,
  }) : _adapterRegistry = adapterRegistry,
       _checkpointStore = checkpointStore;

  final SyncAdapterRegistry _adapterRegistry;
  final SyncCheckpointStore _checkpointStore;
  static const _cursorSafetyGap = Duration(milliseconds: 250);

  /// Executa pull de todos os adapters registrados em paralelo
  ///
  /// **Comportamento:**
  /// - Adapters rodam em paralelo via Future.wait (não sequencial)
  /// - Um adapter falhando não interrompe os outros
  /// - Erros são agregados no resultado final
  ///
  /// **Retorna:**
  /// - Right(SyncPhaseResult): Resultado agregado com estatísticas
  /// - Left(failure): Erro crítico (ex: userId inválido)
  @override
  Future<Either<Failure, SyncPhaseResult>> pullAll(String userId) async {
    try {
      developer.log(
        '📥 Starting pull sync for ${_adapterRegistry.count} adapters (userId: $userId)...',
        name: 'SyncPull',
      );

      final startTime = DateTime.now();

      // Executa todos os pulls em paralelo usando registry
      final pullFutures = _adapterRegistry.adapters
          .map((adapter) => _pullAdapter(adapter, userId))
          .toList();

      final pullResults = await Future.wait(pullFutures);

      final duration = DateTime.now().difference(startTime);

      final totalPulled = pullResults.fold<int>(
        0,
        (sum, result) => sum + result.recordsPulled,
      );

      final totalConflicts = pullResults.fold<int>(
        0,
        (sum, result) => sum + result.conflictsResolved,
      );

      final failedPulls = pullResults
          .where((result) => !result.success)
          .toList();
      final aggregatedErrors = failedPulls
          .map(
            (result) =>
                '[${result.adapterName}] ${result.error ?? 'unknown error'}',
          )
          .toList();

      developer.log(
        '✅ Pull sync completed in ${duration.inSeconds}s\n'
        '   Total pulled: $totalPulled\n'
        '   Conflicts resolved: $totalConflicts',
        name: 'SyncPull',
      );

      return Right(
        SyncPhaseResult(
          successCount: totalPulled,
          failureCount: failedPulls.length,
          errors: aggregatedErrors,
          duration: duration,
        ),
      );
    } catch (e) {
      developer.log('❌ Pull sync failed with exception: $e', name: 'SyncPull');
      return Left(ServerFailure('Pull sync failed: $e'));
    }
  }

  /// Executa pull para um adapter individual usando ISyncAdapter interface
  Future<AdapterPullSnapshot> _pullAdapter(
    ISyncAdapter adapter,
    String userId,
  ) async {
    try {
      final since = await _checkpointStore.getCursor(
        userId: userId,
        adapter: adapter.name,
      );
      final startTime = DateTime.now();

      // Usar a interface ISyncAdapter.pullRemoteChanges() que retorna SyncPullResult
      final result = await adapter.pullRemoteChanges(userId, since: since);

      if (result.isLeft()) {
        final failure =
            (result as Left<Failure, sync_models.SyncPullResult>).value;
        developer.log(
          '❌ ${adapter.name} pull failed: ${failure.message}',
          name: 'SyncPull',
        );
        return AdapterPullSnapshot(
          adapterName: adapter.name,
          recordsPulled: 0,
          conflictsResolved: 0,
          duration: DateTime.now().difference(startTime),
          error: failure.message,
        );
      }

      final syncResult =
          (result as Right<Failure, sync_models.SyncPullResult>).value;
      final nextCursor = _resolveNextCursor(
        since,
        syncResult.latestRemoteUpdateAt,
      );
      await _checkpointStore.saveCursor(
        userId: userId,
        adapter: adapter.name,
        timestamp: nextCursor,
      );

      developer.log(
        '✅ ${adapter.name} pull: ${syncResult.recordsPulled + syncResult.recordsUpdated} records (cursor -> ${nextCursor.toIso8601String()})',
        name: 'SyncPull',
      );

      return AdapterPullSnapshot(
        adapterName: adapter.name,
        recordsPulled: syncResult.recordsPulled + syncResult.recordsUpdated,
        conflictsResolved: syncResult.conflictsResolved,
        duration: DateTime.now().difference(startTime),
        lastRemoteUpdateAt: syncResult.latestRemoteUpdateAt,
      );
    } catch (e) {
      developer.log('❌ ${adapter.name} pull exception: $e', name: 'SyncPull');
      return AdapterPullSnapshot(
        adapterName: adapter.name,
        recordsPulled: 0,
        conflictsResolved: 0,
        duration: Duration.zero,
        error: e.toString(),
      );
    }
  }

  DateTime _resolveNextCursor(DateTime? currentCursor, DateTime? latestRemote) {
    if (latestRemote != null) {
      final buffered = latestRemote.toUtc().subtract(_cursorSafetyGap);
      if (currentCursor == null) return buffered;
      return buffered.isAfter(currentCursor) ? buffered : currentCursor;
    }

    final now = DateTime.now().toUtc();
    if (currentCursor == null) return now;
    return now.isAfter(currentCursor) ? now : currentCursor;
  }

  /// Executa pull para um tipo específico de entidade
  Future<Either<Failure, SyncPhaseResult>> pullByType(
    String userId,
    String entityType,
  ) async {
    try {
      developer.log(
        '📥 Starting pull sync for $entityType (userId: $userId)...',
        name: 'SyncPull',
      );

      final adapter = _adapterRegistry.adapters.firstWhere(
        (a) => a.name == entityType,
        orElse: () => throw Exception('Adapter not found for $entityType'),
      );

      final startTime = DateTime.now();
      final result = await _pullAdapter(adapter, userId);
      final duration = DateTime.now().difference(startTime);

      final errors = result.error != null
          ? ['[${adapter.name}] ${result.error}']
          : const <String>[];

      return Right(
        SyncPhaseResult(
          successCount: result.recordsPulled,
          failureCount: result.success ? 0 : 1,
          errors: errors,
          duration: duration,
        ),
      );
    } catch (e) {
      developer.log('❌ Pull sync for $entityType failed: $e', name: 'SyncPull');
      return Left(ServerFailure('Pull sync for $entityType failed: $e'));
    }
  }
}
