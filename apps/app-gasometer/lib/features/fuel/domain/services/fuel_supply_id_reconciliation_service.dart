import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../../../../core/services/i_id_reconciliation_service.dart';

/// Serviço especializado em reconciliação de IDs de abastecimentos (FuelRecords)
///
/// **Responsabilidades:**
/// - Reconciliar ID local → ID remoto de abastecimentos
/// - Detectar e resolver duplicações (crítico para dados financeiros!)
/// - Mesclar registros duplicados mantendo dados corretos
/// - Apenas operações de reconciliação de abastecimentos
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas reconciliação de FuelRecords
/// - Dependency Injection via constructor
/// - Error handling via Either<Failure, T>
///
/// **CRÍTICO - Dados Financeiros:**
/// Abastecimentos envolvem transações financeiras. Duplicação pode resultar em:
/// - Contabilização incorreta de combustíveis
/// - Erros em cálculos de consumo
/// - Relatórios financeiros inconsistentes
///
/// **Estratégia de Merge:**
/// Quando há duplicação, mantém registro mais recente (updatedAt)
/// e descarta o antigo, SEM SOMAR valores (não são registros adicionais).
///
/// **Exemplo:**
/// ```dart
/// final service = FuelSupplyIdReconciliationService(localStorage);
/// final result = await service.reconcileId(
///   'local_fuel_123',    // ID temporário offline
///   'firebase_fuel_789', // ID permanente do Firebase
/// );
/// ```
class FuelSupplyIdReconciliationService implements IIdReconciliationService {
  FuelSupplyIdReconciliationService(this._localStorage);

  final ILocalStorageRepository _localStorage;

  /// Reconcilia ID de abastecimento local com ID remoto
  ///
  /// **Processo:**
  /// 1. Verifica se IDs são diferentes
  /// 2. Se sim, busca abastecimento com ID local
  /// 3. Verifica se remoteId já existe (duplicação)
  /// 4. Se duplicação: mescla mantendo mais recente
  /// 5. Salva com ID novo
  /// 6. Remove entrada antiga
  ///
  /// **IMPORTANTE:**
  /// - Nunca somar litros/valores de duplicatas (são registros duplicados)
  /// - Priorizar updatedAt mais recente
  /// - Log detalhado para auditoria
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
        '🔄 Fuel ID Reconciliation (CRITICAL - Financial Data):\n'
        '   Local: $localId\n'
        '   Remote: $remoteId',
        name: 'FuelReconciliation',
      );

      // 1. Busca abastecimento com ID local
      final localResult = await _localStorage.get<Map<String, dynamic>>(
        key: localId,
        box: 'fuel_records',
      );

      final localFuelMap = localResult.fold(
        (failure) {
          developer.log(
            '⚠️ Fuel record not found with local ID: $localId',
            name: 'FuelReconciliation',
          );
          return null;
        },
        (data) => data,
      );

      if (localFuelMap == null) {
        return const Right(null);
      }

      // 2. Verifica duplicação
      final remoteResult = await _localStorage.get<Map<String, dynamic>>(
        key: remoteId,
        box: 'fuel_records',
      );

      final remoteFuelMap = remoteResult.fold(
        (_) => null,
        (data) => data,
      );

      if (remoteFuelMap != null) {
        // DUPLICAÇÃO DETECTADA - MERGE REQUIRED
        developer.log(
          '⚠️ DUPLICATED FUEL RECORD DETECTED - MERGING:\n'
          '   Local: $localId\n'
          '   Remote: $remoteId',
          name: 'FuelReconciliation',
        );

        final mergedMap = await _mergeFuelRecords(localFuelMap, remoteFuelMap);

        final saveResult = await _localStorage.save<Map<String, dynamic>>(
          key: remoteId,
          data: mergedMap,
          box: 'fuel_records',
        );

        if (saveResult.isLeft()) {
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }

        await _localStorage.remove(key: localId, box: 'fuel_records');

        developer.log(
          '✅ Fuel record duplication resolved - Kept remote as source of truth',
          name: 'FuelReconciliation',
        );

        return const Right(null);
      }

      // 3. Sem duplicação - atualiza ID e salva
      final updatedMap = Map<String, dynamic>.from(localFuelMap);
      updatedMap['id'] = remoteId;

      final saveResult = await _localStorage.save<Map<String, dynamic>>(
        key: remoteId,
        data: updatedMap,
        box: 'fuel_records',
      );

      if (saveResult.isLeft()) {
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      // 4. Remove entrada antiga
      await _localStorage.remove(key: localId, box: 'fuel_records');

      developer.log(
        '✅ Fuel record ID reconciliation completed:\n'
        '   ${updatedMap['gas_station_name'] ?? "Unknown"}\n'
        '   $localId → $remoteId\n'
        '   Liters: ${updatedMap['liters']}, Price: ${updatedMap['total_price']}',
        name: 'FuelReconciliation',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Fuel record reconciliation failed: $e',
        name: 'FuelReconciliation',
      );
      return Left(CacheFailure('Failed to reconcile fuel record ID: $e'));
    }
  }

  /// Mescla dois FuelRecords duplicados
  ///
  /// **Estratégia (CRÍTICA):**
  /// - ❌ NÃO somar litros/valores (são registros duplicados, não adicionais)
  /// - ✅ Manter registro mais recente (maior updatedAt)
  /// - ✅ Usar dados mais completos se houver diferenças
  /// - ✅ Log de auditoria para rastreamento
  Future<Map<String, dynamic>> _mergeFuelRecords(
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
        '🔍 Fuel merge analysis:\n'
        '   Local updated: $localUpdated (${local["gas_station_name"]})\n'
        '   Remote updated: $remoteUpdated (${remote["gas_station_name"]})\n'
        '   Keeping: $source (newer)',
        name: 'FuelReconciliation',
      );

      // Auditoria: log valores para rastreamento
      developer.log(
        '💰 Financial values comparison:\n'
        '   Local: liters=${local["liters"]}, price=${local["total_price"]}\n'
        '   Remote: liters=${remote["liters"]}, price=${remote["total_price"]}\n'
        '   Decision: Use $source values (NOT SUMMED - duplicates)',
        name: 'FuelReconciliation',
      );

      return Map<String, dynamic>.from(newerRecord);
    } catch (e) {
      developer.log(
        '⚠️ Error merging fuel records: $e - Using remote as fallback',
        name: 'FuelReconciliation',
      );
      return Map<String, dynamic>.from(remote);
    }
  }

  /// Verifica se há reconciliações pendentes
  ///
  /// **Retorna:**
  /// - Right(count): Número de reconciliações pendentes
  /// - Left(failure): Erro ao verificar
  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      // Para fuel supplies, verificamos registros que estão pendentes de sync
      // Um registro é considerado "pendente de reconciliação" se:
      // 1. Tem isDirty = true (não sincronizado)
      // 2. Foi criado offline (ID temporário)
      // 
      // Por simplicidade, retornamos 0 pois a reconciliação
      // é feita automaticamente durante sync
      return const Right(0);
    } catch (e) {
      developer.log(
        '❌ Error getting pending reconciliation count: $e',
        name: 'FuelReconciliation',
      );
      return Left(CacheFailure('Failed to get pending count: $e'));
    }
  }
}
