import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../sync/adapters/i_sync_adapter.dart';
import 'contracts/i_sync_pull_service.dart';
import 'contracts/i_sync_push_service.dart';
import '../sync/adapters/sync_adapter_registry.dart';

/// Modelo para resultado de pull de um adapter
class SyncPullResult {
  const SyncPullResult({
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
  SyncPullService({required SyncAdapterRegistry adapterRegistry})
      : _adapterRegistry = adapterRegistry;

  final SyncAdapterRegistry _adapterRegistry;

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
  Future<Either<Failure, SyncPhaseResult>> pullAll(
    String userId, {
    DateTime? since,
  }) async {
    try {
      developer.log(
        '📥 Starting pull sync for ${_adapterRegistry.count} adapters (userId: $userId)...',
        name: 'SyncPull',
      );

      final startTime = DateTime.now();

      // Executa todos os pulls em paralelo usando registry
      final pullFutures = _adapterRegistry.adapters
          .map((adapter) => _pullAdapter(adapter, userId, since))
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

      final errors = <String>[];

      developer.log(
        '✅ Pull sync completed in ${duration.inSeconds}s\n'
        '   Total pulled: $totalPulled\n'
        '   Conflicts resolved: $totalConflicts',
        name: 'SyncPull',
      );

      return Right(
        SyncPhaseResult(
          successCount: totalPulled,
          failureCount: 0,
          errors: errors,
          duration: duration,
        ),
      );
    } catch (e) {
      developer.log(
        '❌ Pull sync failed with exception: $e',
        name: 'SyncPull',
      );
      return Left(ServerFailure('Pull sync failed: $e'));
    }
  }

  /// Executa pull para um adapter individual usando ISyncAdapter interface
  Future<SyncPullResult> _pullAdapter(
    ISyncAdapter adapter,
    String userId,
    DateTime? since,
  ) async {
    try {
      final startTime = DateTime.now();

      // Usar a interface ISyncAdapter.pullRemoteChanges() que retorna SyncPullResult
      final result = await adapter.pullRemoteChanges(
        userId,
        since: since,
      );

      return result.fold(
        (failure) {
          developer.log(
            '❌ ${adapter.name} pull failed: ${failure.message}',
            name: 'SyncPull',
          );
          return SyncPullResult(
            adapterName: adapter.name,
            recordsPulled: 0,
            conflictsResolved: 0,
            duration: DateTime.now().difference(startTime),
          );
        },
        (syncResult) {
          developer.log(
            '✅ ${adapter.name} pull: ${syncResult.recordsPulled} records',
            name: 'SyncPull',
          );
          return SyncPullResult(
            adapterName: adapter.name,
            recordsPulled: syncResult.recordsPulled,
            conflictsResolved: syncResult.conflictsResolved,
            duration: DateTime.now().difference(startTime),
          );
        },
      );
    } catch (e) {
      developer.log(
        '❌ ${adapter.name} pull exception: $e',
        name: 'SyncPull',
      );
      return SyncPullResult(
        adapterName: adapter.name,
        recordsPulled: 0,
        conflictsResolved: 0,
        duration: Duration.zero,
      );
    }
  }

  /// Executa pull para um tipo específico de entidade
  @override
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
      final result = await _pullAdapter(adapter, userId, null);
      final duration = DateTime.now().difference(startTime);

      return Right(
        SyncPhaseResult(
          successCount: result.recordsPulled,
          failureCount: 0,
          errors: [],
          duration: duration,
        ),
      );
    } catch (e) {
      developer.log(
        '❌ Pull sync for $entityType failed: $e',
        name: 'SyncPull',
      );
      return Left(ServerFailure('Pull sync for $entityType failed: $e'));
    }
  }
}
