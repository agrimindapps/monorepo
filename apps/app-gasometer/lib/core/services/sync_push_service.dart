import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../sync/adapters/i_sync_adapter.dart';
import '../sync/adapters/sync_adapter_registry.dart';
import '../sync/models/sync_results.dart';
import 'contracts/i_sync_push_service.dart';

/// Modelo para resultado de push de um adapter
class SyncPushResult {
  const SyncPushResult({
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

  bool get success => error == null;

  String get summary =>
      '${recordsPushed} pushed${conflictsResolved > 0 ? ', ${conflictsResolved} conflicts' : ''}';
}

/// Serviço especializado em coordenar push (envio local → Firebase) dos adapters
///
/// **Implementação de:** ISyncPushService
///
/// **Responsabilidades:**
/// - Coordenar push de todos os adapters registrados
/// - Executar pushes em paralelo para performance
/// - Agregar resultados e estatísticas
/// - Error handling: um adapter falhando não interrompe os outros
/// - Apenas push operations, sem pull
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas coordenar pushes
/// - Open/Closed: Fácil adicionar novos adapters sem modificar este serviço
/// - Dependency Injection via constructor (registry pattern)
/// - Error handling via Either<Failure, T>
/// - Interface Segregation: Implementa ISyncPushService
/// - Dependency Inversion: Depende de ISyncAdapter, não de implementações
///
/// **Fluxo:**
/// 1. pushAll() itera sobre adapters do registry
/// 2. Executa todos em paralelo via Future.wait
/// 3. Agrega resultados
/// 4. Retorna com estatísticas
///
/// **Exemplo:**
/// ```dart
/// final registry = SyncAdapterRegistry(adapters: [...]);
/// final service = SyncPushService(registry);
/// final result = await service.pushAll(userId);
/// result.fold(
///   (failure) => print('Push failed: ${failure.message}'),
///   (phaseResult) => print('Pushed ${phaseResult.successCount} records'),
/// );
/// ```
class SyncPushService implements ISyncPushService {
  SyncPushService({required SyncAdapterRegistry adapterRegistry})
      : _adapterRegistry = adapterRegistry;

  final SyncAdapterRegistry _adapterRegistry;

  /// Executa push de todos os adapters registrados em paralelo
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
  Future<Either<Failure, SyncPhaseResult>> pushAll(String userId) async {
    try {
      developer.log(
        '📤 Starting push sync for ${_adapterRegistry.count} adapters (userId: $userId)...',
        name: 'SyncPush',
      );

      final startTime = DateTime.now();

      // Executa todos os pushes em paralelo usando registry
      final pushFutures = _adapterRegistry.adapters
          .map((adapter) => _pushAdapter(adapter, userId))
          .toList();

      final pushResults = await Future.wait(pushFutures);

      final duration = DateTime.now().difference(startTime);

      final totalPushed = pushResults.fold<int>(
        0,
        (sum, result) => sum + result.recordsPushed,
      );

      final totalFailed = pushResults.fold<int>(
        0,
        (sum, result) => sum + (result.success ? 0 : 1),
      );

      final errors = pushResults
          .where((r) => r.error != null)
          .map((r) => r.error!)
          .toList();

      developer.log(
        '✅ Push sync completed in ${duration.inSeconds}s\n'
        '   Total pushed: $totalPushed\n'
        '   Total failed: $totalFailed',
        name: 'SyncPush',
      );

      return Right(
        SyncPhaseResult(
          successCount: totalPushed,
          failureCount: totalFailed,
          errors: errors,
          duration: duration,
        ),
      );
    } catch (e) {
      developer.log(
        '❌ Push sync failed with exception: $e',
        name: 'SyncPush',
      );
      return Left(ServerFailure('Push sync failed: $e'));
    }
  }

  /// Executa push para um adapter individual usando ISyncAdapter interface
  Future<SyncPushResult> _pushAdapter(ISyncAdapter adapter, String userId) async {
    try {
      final startTime = DateTime.now();

      // Usar a interface ISyncAdapter.pushDirtyRecords() que retorna SyncPushResult from sync_results
      final result = await adapter.pushDirtyRecords(userId);

      return result.fold(
        (failure) {
          developer.log(
            '❌ ${adapter.name} push failed: ${failure.message}',
            name: 'SyncPush',
          );
          return SyncPushResult(
            adapterName: adapter.name,
            recordsPushed: 0,
            conflictsResolved: 0,
            duration: DateTime.now().difference(startTime),
            error: failure.message,
          );
        },
        (syncResult) {
          developer.log(
            '✅ ${adapter.name} push: ${syncResult.recordsPushed} records',
            name: 'SyncPush',
          );
          return SyncPushResult(
            adapterName: adapter.name,
            recordsPushed: syncResult.recordsPushed,
            conflictsResolved: 0,
            duration: DateTime.now().difference(startTime),
            error: syncResult.errors.isNotEmpty ? syncResult.errors.first : null,
          );
        },
      );
    } catch (e) {
      developer.log(
        '❌ ${adapter.name} push exception: $e',
        name: 'SyncPush',
      );
      return SyncPushResult(
        adapterName: adapter.name,
        recordsPushed: 0,
        conflictsResolved: 0,
        duration: Duration.zero,
        error: e.toString(),
      );
    }
  }

  /// Executa push para um tipo específico de entidade
  @override
  Future<Either<Failure, SyncPhaseResult>> pushByType(
    String userId,
    String entityType,
  ) async {
    try {
      developer.log(
        '📤 Starting push sync for $entityType (userId: $userId)...',
        name: 'SyncPush',
      );

      final adapter = _adapterRegistry.adapters.firstWhere(
        (a) => a.name == entityType,
        orElse: () => throw Exception('Adapter not found for $entityType'),
      );

      final startTime = DateTime.now();
      final result = await _pushAdapter(adapter, userId);
      final duration = DateTime.now().difference(startTime);

      return Right(
        SyncPhaseResult(
          successCount: result.recordsPushed,
          failureCount: result.success ? 0 : 1,
          errors: result.error != null ? [result.error!] : [],
          duration: duration,
        ),
      );
    } catch (e) {
      developer.log(
        '❌ Push sync for $entityType failed: $e',
        name: 'SyncPush',
      );
      return Left(ServerFailure('Push sync for $entityType failed: $e'));
    }
  }
}
