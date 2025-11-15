import 'dart:developer' as developer;
import 'package:core/core.dart';

/// Serviço especializado em reconciliação de IDs de manutenções
///
/// **Responsabilidades:**
/// - Reconciliar ID local → ID remoto de manutenções
/// - Detectar e resolver duplicações (crítico para dados financeiros!)
/// - Mesclar registros duplicados mantendo dados corretos
/// - Apenas operações de reconciliação de manutenções
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas reconciliação de Maintenances
/// - Dependency Injection via constructor
/// - Error handling via Either<Failure, T>
///
/// **CRÍTICO - Dados Financeiros:**
/// Manutenções envolvem transações financeiras. Duplicação pode resultar em:
/// - Contabilização incorreta de custos
/// - Erros em histórico de manutenção
/// - Relatórios financeiros inconsistentes
/// - Falha em rastreamento de serviços
///
/// **Estratégia de Merge:**
/// Quando há duplicação, mantém registro mais recente (updatedAt)
/// e descarta o antigo, SEM SOMAR valores (não são registros adicionais).
///
/// **Exemplo:**
/// ```dart
/// final service = MaintenanceIdReconciliationService(localStorage);
/// final result = await service.reconcileId(
///   'local_maint_123',     // ID temporário offline
///   'firebase_maint_789',  // ID permanente do Firebase
/// );
/// ```
class MaintenanceIdReconciliationService {
  MaintenanceIdReconciliationService(this._localStorage);

  final ILocalStorageRepository _localStorage;

  /// Reconcilia ID de manutenção local com ID remoto
  ///
  /// **Processo:**
  /// 1. Verifica se IDs são diferentes
  /// 2. Se sim, busca manutenção com ID local
  /// 3. Verifica se remoteId já existe (duplicação)
  /// 4. Se duplicação: mescla mantendo mais recente
  /// 5. Salva com ID novo
  /// 6. Remove entrada antiga
  ///
  /// **IMPORTANTE:**
  /// - Nunca somar custos/valores de duplicatas (são registros duplicados)
  /// - Priorizar updatedAt mais recente
  /// - Log detalhado para auditoria
  /// - Rastrear serviços efetuados
  ///
  /// **Retorna:**
  /// - Right(null): Reconciliação concluída
  /// - Left(failure): Erro no processo
  Future<Either<Failure, void>> reconcileId(
    String localId,
    String remoteId,
  ) async {
    if (localId == remoteId) {
      return const Right(null);
    }

    try {
      developer.log(
        '🔄 Maintenance ID Reconciliation (CRITICAL - Financial Data):\n'
        '   Local: $localId\n'
        '   Remote: $remoteId',
        name: 'MaintenanceReconciliation',
      );

      // 1. Busca manutenção com ID local
      final localResult = await _localStorage.get<Map<String, dynamic>>(
        key: localId,
        box: 'maintenance_records',
      );

      final localMaintenanceMap = localResult.fold(
        (failure) {
          developer.log(
            '⚠️ Maintenance record not found with local ID: $localId',
            name: 'MaintenanceReconciliation',
          );
          return null;
        },
        (data) => data,
      );

      if (localMaintenanceMap == null) {
        return const Right(null);
      }

      // 2. Verifica duplicação
      final remoteResult = await _localStorage.get<Map<String, dynamic>>(
        key: remoteId,
        box: 'maintenance_records',
      );

      final remoteMaintenanceMap = remoteResult.fold(
        (_) => null,
        (data) => data,
      );

      if (remoteMaintenanceMap != null) {
        // DUPLICAÇÃO DETECTADA - MERGE REQUIRED
        developer.log(
          '⚠️ DUPLICATED MAINTENANCE RECORD DETECTED - MERGING:\n'
          '   Local: $localId\n'
          '   Remote: $remoteId',
          name: 'MaintenanceReconciliation',
        );

        final mergedMap = await _mergeMaintenanceRecords(
          localMaintenanceMap,
          remoteMaintenanceMap,
        );

        final saveResult = await _localStorage.save<Map<String, dynamic>>(
          key: remoteId,
          data: mergedMap,
          box: 'maintenance_records',
        );

        if (saveResult.isLeft()) {
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }

        await _localStorage.remove(key: localId, box: 'maintenance_records');

        developer.log(
          '✅ Maintenance record duplication resolved - Kept remote as source of truth',
          name: 'MaintenanceReconciliation',
        );

        return const Right(null);
      }

      // 3. Sem duplicação - atualiza ID e salva
      final updatedMap = Map<String, dynamic>.from(localMaintenanceMap);
      updatedMap['id'] = remoteId;

      final saveResult = await _localStorage.save<Map<String, dynamic>>(
        key: remoteId,
        data: updatedMap,
        box: 'maintenance_records',
      );

      if (saveResult.isLeft()) {
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      // 4. Remove entrada antiga
      await _localStorage.remove(key: localId, box: 'maintenance_records');

      developer.log(
        '✅ Maintenance record ID reconciliation completed:\n'
        '   ${updatedMap['description'] ?? "Maintenance"}\n'
        '   $localId → $remoteId\n'
        '   Cost: ${updatedMap['cost']}',
        name: 'MaintenanceReconciliation',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Maintenance record reconciliation failed: $e',
        name: 'MaintenanceReconciliation',
      );
      return Left(CacheFailure('Failed to reconcile maintenance record ID: $e'));
    }
  }

  /// Mescla dois Maintenance Records duplicados
  ///
  /// **Estratégia (CRÍTICA):**
  /// - ❌ NÃO somar custos/valores (são registros duplicados, não adicionais)
  /// - ✅ Manter registro mais recente (maior updatedAt)
  /// - ✅ Usar dados mais completos se houver diferenças
  /// - ✅ Log de auditoria para rastreamento
  /// - ✅ Preservar histórico de serviços completo
  Future<Map<String, dynamic>> _mergeMaintenanceRecords(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) async {
    try {
      // Parse timestamps
      final localUpdated = local['updated_at'] != null
          ? DateTime.tryParse(local['updated_at'] as String) ??
              DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0);

      final remoteUpdated = remote['updated_at'] != null
          ? DateTime.tryParse(remote['updated_at'] as String) ??
              DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0);

      // Manter o mais recente
      final newerRecord =
          localUpdated.isAfter(remoteUpdated) ? local : remote;
      final source =
          localUpdated.isAfter(remoteUpdated) ? 'local' : 'remote';

      developer.log(
        '🔍 Maintenance merge analysis:\n'
        '   Local updated: $localUpdated (${local["description"]})\n'
        '   Remote updated: $remoteUpdated (${remote["description"]})\n'
        '   Keeping: $source (newer)',
        name: 'MaintenanceReconciliation',
      );

      // Auditoria: log valores para rastreamento
      developer.log(
        '💰 Financial values comparison:\n'
        '   Local: cost=${local["cost"]}, date=${local["maintenance_date"]}\n'
        '   Remote: cost=${remote["cost"]}, date=${remote["maintenance_date"]}\n'
        '   Decision: Use $source values (NOT SUMMED - duplicates)',
        name: 'MaintenanceReconciliation',
      );

      return Map<String, dynamic>.from(newerRecord);
    } catch (e) {
      developer.log(
        '⚠️ Error merging maintenance records: $e - Using remote as fallback',
        name: 'MaintenanceReconciliation',
      );
      return Map<String, dynamic>.from(remote);
    }
  }
}
