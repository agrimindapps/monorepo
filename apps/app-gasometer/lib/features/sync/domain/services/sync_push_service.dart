import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../../../../core/services/contracts/i_sync_push_service.dart';
import '../../../../core/sync/adapters/sync_adapter_registry.dart';

/// Modelo para resultado de push de um adapter
class ServicePushResult {
  const ServicePushResult({
    required this.adapterName,
    required this.recordsPushed,
    required this.conflictsResolved,
    required this.duration,
    this.error,
  });

  final String adapterName;
  final int recordsPushed;
  final int conflictsResolved;
  final Duration duration;
  final String? error;
}


class SyncPushService implements ISyncPushService {
  SyncPushService(this.registry);

  final SyncAdapterRegistry registry;

  @override
  Future<Either<Failure, SyncPhaseResult>> pushAll(String userId) async {
    developer.log('🚀 Starting Push All for user: $userId', name: 'SyncPush');
    final stopwatch = Stopwatch()..start();

    final results = <ServicePushResult>[];
    final errors = <String>[];
    int successCount = 0;
    int failureCount = 0;

    for (final adapter in registry.adapters) {
      final result = await _pushAdapter(adapter, userId);
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
  Future<Either<Failure, SyncPhaseResult>> pushByType(
    String userId,
    String entityType,
  ) async {
    final adapter = registry.findByName(entityType);
    if (adapter == null) {
      return Left(ValidationFailure('Adapter not found for type: $entityType'));
    }

    final stopwatch = Stopwatch()..start();
    final result = await _pushAdapter(adapter, userId);
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

  Future<ServicePushResult> _pushAdapter(
    IDriftSyncAdapter<dynamic, dynamic> adapter,
    String userId,
  ) async {
    try {
      developer.log(
        '📤 Pushing ${adapter.collectionName}...',
        name: 'SyncPush',
      );

      final startTime = DateTime.now();
      final result = await adapter.pushDirtyRecords(userId);

      return result.fold(
        (failure) {
          developer.log(
            '❌ ${adapter.collectionName} push failed: ${failure.message}',
            name: 'SyncPush',
            error: failure,
          );
          return ServicePushResult(
            adapterName: adapter.collectionName,
            recordsPushed: 0,
            conflictsResolved: 0,
            duration: DateTime.now().difference(startTime),
            error: failure.message,
          );
        },
        (syncResult) {
          developer.log(
            '✅ ${adapter.collectionName} push: ${syncResult.recordsPushed} records',
            name: 'SyncPush',
          );
          return ServicePushResult(
            adapterName: adapter.collectionName,
            recordsPushed: syncResult.recordsPushed,
            conflictsResolved: 0,
            duration: DateTime.now().difference(startTime),
            error: syncResult.errors.isNotEmpty
                ? syncResult.errors.first
                : null,
          );
        },
      );
    } catch (e, stack) {
      developer.log(
        '❌ Unexpected error pushing ${adapter.collectionName}',
        name: 'SyncPush',
        error: e,
        stackTrace: stack,
      );
      return ServicePushResult(
        adapterName: adapter.collectionName,
        recordsPushed: 0,
        conflictsResolved: 0,
        duration: Duration.zero,
        error: e.toString(),
      );
    }
  }

  void _logSummary(List<ServicePushResult> results, Duration totalDuration) {
    final totalPushed = results.fold<int>(
      0,
      (total, result) => total + result.recordsPushed,
    );

    developer.log(
      '🏁 Push Summary (Total: ${totalDuration.inMilliseconds}ms)',
      name: 'SyncPush',
    );
    developer.log('   Total Records Pushed: $totalPushed', name: 'SyncPush');

    for (final result in results) {
      final status = result.error == null ? '✅' : '❌';
      developer.log(
        '   $status ${result.adapterName}: ${result.recordsPushed} records (${result.duration.inMilliseconds}ms)',
        name: 'SyncPush',
      );
      if (result.error != null) {
        developer.log('      Error: ${result.error}', name: 'SyncPush');
      }
    }
  }
}
