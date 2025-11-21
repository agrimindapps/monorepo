import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../../../../core/services/contracts/i_sync_pull_service.dart';
import '../../../../core/services/contracts/i_sync_push_service.dart'; // For SyncPhaseResult
import '../../../../core/sync/adapters/sync_adapter_registry.dart';
import 'sync_checkpoint_store.dart';

/// Modelo para resultado de pull de um adapter
class ServicePullSnapshot {
  const ServicePullSnapshot({
    required this.adapterName,
    required this.recordsPulled,
    required this.conflictsResolved,
    required this.duration,
    this.error,
  });

  final String adapterName;
  final int recordsPulled;
  final int conflictsResolved;
  final Duration duration;
  final String? error;
}


class SyncPullService implements ISyncPullService {
  SyncPullService(this.registry, this.checkpointStore);

  final SyncAdapterRegistry registry;
  final SyncCheckpointStore checkpointStore;

  @override
  Future<Either<Failure, SyncPhaseResult>> pullAll(String userId) async {
    developer.log('🚀 Starting Pull All for user: $userId', name: 'SyncPull');
    final stopwatch = Stopwatch()..start();

    final results = <ServicePullSnapshot>[];
    final errors = <String>[];
    int successCount = 0;
    int failureCount = 0;

    // Executar pulls em série (pode ser paralelizado se necessário)
    for (final adapter in registry.adapters) {
      final result = await _pullAdapter(adapter, userId);
      results.add(result);

      if (result.error != null) {
        errors.add('${adapter.collectionName}: ${result.error}');
        failureCount++;
      } else {
        successCount++;
      }
    }

    stopwatch.stop();
    _logSummary(results, stopwatch.elapsed);

    return Right(
      SyncPhaseResult(
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
        duration: stopwatch.elapsed,
      ),
    );
  }

  @override
  Future<Either<Failure, SyncPhaseResult>> pullByType(
    String userId,
    String entityType,
  ) async {
    final adapter = registry.findByName(entityType);
    if (adapter == null) {
      return Left(ValidationFailure('Adapter not found for type: $entityType'));
    }

    final stopwatch = Stopwatch()..start();
    final result = await _pullAdapter(adapter, userId);
    stopwatch.stop();

    final errors = <String>[];
    if (result.error != null) {
      errors.add('${adapter.collectionName}: ${result.error}');
    }

    return Right(
      SyncPhaseResult(
        successCount: result.error == null ? 1 : 0,
        failureCount: result.error != null ? 1 : 0,
        errors: errors,
        duration: stopwatch.elapsed,
      ),
    );
  }

  Future<ServicePullSnapshot> _pullAdapter(
    IDriftSyncAdapter<dynamic, dynamic> adapter,
    String userId,
  ) async {
    try {
      developer.log(
        '📥 Pulling ${adapter.collectionName}...',
        name: 'SyncPull',
      );

      final lastSync = await checkpointStore.getCursor(
        userId: userId,
        adapter: adapter.collectionName,
      );

      final startTime = DateTime.now();
      final result = await adapter.pullRemoteChanges(userId, since: lastSync);

      return result.fold(
        (failure) {
          developer.log(
            '❌ ${adapter.collectionName} pull failed: ${failure.message}',
            name: 'SyncPull',
            error: failure,
          );
          return ServicePullSnapshot(
            adapterName: adapter.collectionName,
            recordsPulled: 0,
            conflictsResolved: 0,
            duration: DateTime.now().difference(startTime),
            error: failure.message,
          );
        },
        (syncResult) async {
          developer.log(
            '✅ ${adapter.collectionName} pull: ${syncResult.recordsPulled} records',
            name: 'SyncPull',
          );

          // Atualizar checkpoint se sucesso
          await checkpointStore.saveCursor(
            userId: userId,
            adapter: adapter.collectionName,
            timestamp: startTime,
          );

          return ServicePullSnapshot(
            adapterName: adapter.collectionName,
            recordsPulled: syncResult.recordsPulled,
            conflictsResolved:
                0, // Core SyncPullResult doesn't expose conflicts count yet
            duration: DateTime.now().difference(startTime),
            error: syncResult.errors.isNotEmpty
                ? syncResult.errors.first
                : null,
          );
        },
      );
    } catch (e, stack) {
      developer.log(
        '❌ Unexpected error pulling ${adapter.collectionName}',
        name: 'SyncPull',
        error: e,
        stackTrace: stack,
      );
      return ServicePullSnapshot(
        adapterName: adapter.collectionName,
        recordsPulled: 0,
        conflictsResolved: 0,
        duration: Duration.zero,
        error: e.toString(),
      );
    }
  }

  void _logSummary(List<ServicePullSnapshot> results, Duration totalDuration) {
    final totalPulled = results.fold<int>(
      0,
      (sum, result) => sum + result.recordsPulled,
    );

    developer.log(
      '🏁 Pull Summary (Total: ${totalDuration.inMilliseconds}ms)',
      name: 'SyncPull',
    );
    developer.log('   Total Records Pulled: $totalPulled', name: 'SyncPull');

    for (final result in results) {
      final status = result.error == null ? '✅' : '❌';
      developer.log(
        '   $status ${result.adapterName}: ${result.recordsPulled} records (${result.duration.inMilliseconds}ms)',
        name: 'SyncPull',
      );
      if (result.error != null) {
        developer.log('      Error: ${result.error}', name: 'SyncPull');
      }
    }
  }
}
