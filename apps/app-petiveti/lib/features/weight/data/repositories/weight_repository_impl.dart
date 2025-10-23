import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart' as local_failures;
import '../../domain/entities/weight.dart';
import '../../domain/repositories/weight_repository.dart';
import '../datasources/weight_local_datasource.dart';
import '../models/weight_model.dart';
import '../../domain/entities/sync/weight_sync_entity.dart' hide WeightTrend, BodyCondition;

/// WeightRepository implementation using UnifiedSyncManager for offline-first sync
///
/// **Características especiais para Weights:**
/// - **Health Tracking**: Análise de tendências e alertas de peso
/// - **Statistics**: Cálculos complexos de estatísticas
/// - **Trend Analysis**: Análise de tendência com regressão linear
/// - **Offline-first**: Sempre lê do cache local
///
/// **Mudanças da versão anterior:**
/// - Usa UnifiedSyncManager para sincronização automática
/// - Marca entidades como dirty após operações CRUD
/// - Auto-sync triggers após operações de escrita
///
/// **Fluxo de operações:**
/// 1. CREATE: Salva local → Marca dirty → UnifiedSyncManager sincroniza em background
/// 2. UPDATE: Atualiza local → Marca dirty + incrementVersion → Sync em background
/// 3. DELETE: Marca como deleted (soft delete) → Sync em background
/// 4. READ: Sempre lê do cache local (extremamente rápido)
class WeightRepositoryImpl implements WeightRepository {
  const WeightRepositoryImpl(this._localDataSource);

  final WeightLocalDataSource _localDataSource;

  /// UnifiedSyncManager singleton instance (for future use)
  // ignore: unused_element
  UnifiedSyncManager get _syncManager => UnifiedSyncManager.instance;

  // ========================================================================
  // CREATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> addWeight(Weight weight) async {
    try {
      // 1. Converter para WeightSyncEntity e marcar como dirty para sync posterior
      final syncEntity = WeightSyncEntity.fromLegacyWeight(
        weight,
        moduleName: 'petiveti',
      ).markAsDirty();

      // 2. Salvar localmente (usando WeightModel para compatibilidade com Hive)
      final weightModel = WeightModel.fromEntity(syncEntity.toLegacyWeight());
      await _localDataSource.cacheWeight(weightModel);

      if (kDebugMode) {
        debugPrint('[WeightRepository] Weight created locally: ${weight.id}');
      }

      // 3. Trigger sync em background (não-bloqueante)
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[WeightRepository] Error creating weight: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao adicionar registro de peso: ${e.toString()}',
        ),
      );
    }
  }

  // ========================================================================
  // READ
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Weight>>> getWeights() async {
    try {
      final weightModels = await _localDataSource.getWeights();
      final weights = weightModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao buscar registros de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Weight>>> getWeightsByAnimalId(
    String animalId,
  ) async {
    try {
      final weightModels =
          await _localDataSource.getWeightsByAnimalId(animalId);
      final weights = weightModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao buscar registros de peso do animal: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, Weight?>> getLatestWeightByAnimalId(
    String animalId,
  ) async {
    try {
      final weightModel =
          await _localDataSource.getLatestWeightByAnimalId(animalId);
      if (weightModel == null) {
        return const Right(null);
      }
      return Right(weightModel.toEntity());
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao buscar último peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, Weight>> getWeightById(
    String id,
  ) async {
    try {
      final weightModel = await _localDataSource.getWeightById(id);
      if (weightModel == null) {
        return const Left(
          local_failures.CacheFailure(
            message: 'Registro de peso não encontrado',
          ),
        );
      }
      return Right(weightModel.toEntity());
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao buscar registro de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Weight>>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final weightModels = await _localDataSource.getWeightHistory(
        animalId,
        startDate,
        endDate,
      );
      final weights = weightModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao buscar histórico de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Weight>>> searchWeights(
    String animalId, {
    double? minWeight,
    double? maxWeight,
    DateTime? startDate,
    DateTime? endDate,
    int? bodyConditionScore,
  }) async {
    try {
      final weightModels =
          await _localDataSource.getWeightsByAnimalId(animalId);
      final filteredModels = weightModels.where((model) {
        final weight = model.toEntity();

        if (minWeight != null && weight.weight < minWeight) return false;
        if (maxWeight != null && weight.weight > maxWeight) return false;
        if (startDate != null && weight.date.isBefore(startDate)) return false;
        if (endDate != null && weight.date.isAfter(endDate)) return false;
        if (bodyConditionScore != null &&
            weight.bodyConditionScore != bodyConditionScore) return false;

        return true;
      }).toList();

      final weights = filteredModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao buscar registros de peso: ${e.toString()}',
        ),
      );
    }
  }

  // ========================================================================
  // UPDATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> updateWeight(
    Weight weight,
  ) async {
    try {
      // 1. Buscar weight atual para preservar sync fields
      final currentWeight = await _localDataSource.getWeightById(weight.id);
      if (currentWeight == null) {
        return const Left(
          local_failures.CacheFailure(message: 'Registro de peso não encontrado'),
        );
      }

      // 2. Converter para SyncEntity, marcar como dirty e incrementar versão
      final syncEntity = WeightSyncEntity.fromLegacyWeight(
        weight,
        moduleName: 'petiveti',
      ).markAsDirty().incrementVersion();

      // 3. Atualizar localmente
      final weightModel = WeightModel.fromEntity(syncEntity.toLegacyWeight());
      await _localDataSource.updateWeight(weightModel);

      if (kDebugMode) {
        debugPrint(
          '[WeightRepository] Weight updated locally: ${weight.id} (version: ${syncEntity.version})',
        );
      }

      // 4. Trigger sync em background
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao atualizar registro de peso: ${e.toString()}',
        ),
      );
    }
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> deleteWeight(String id) async {
    try {
      // Soft delete (datasource implementa)
      await _localDataSource.deleteWeight(id);

      if (kDebugMode) {
        debugPrint('[WeightRepository] Weight soft-deleted: $id');
      }

      // Trigger sync para propagar delete
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao excluir registro de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, void>> hardDeleteWeight(
    String id,
  ) async {
    try {
      // Hard delete (remover permanentemente)
      await _localDataSource.hardDeleteWeight(id);

      if (kDebugMode) {
        debugPrint('[WeightRepository] Weight hard-deleted: $id');
      }

      // Trigger sync para propagar delete
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao excluir permanentemente registro de peso: ${e.toString()}',
        ),
      );
    }
  }

  // ========================================================================
  // STATISTICS & ANALYTICS (mantidas sem mudanças)
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, WeightStatistics>>
      getWeightStatistics(String animalId) async {
    try {
      final weightModels =
          await _localDataSource.getWeightsByAnimalId(animalId);
      final weights = weightModels.map((model) => model.toEntity()).toList();

      if (weights.isEmpty) {
        return const Right(WeightStatistics(totalRecords: 0));
      }

      weights.sort((a, b) => a.date.compareTo(b.date));

      final currentWeight = weights.last.weight;
      final averageWeight =
          weights.map((w) => w.weight).reduce((a, b) => a + b) /
              weights.length;
      final minWeight =
          weights.map((w) => w.weight).reduce((a, b) => a < b ? a : b);
      final maxWeight =
          weights.map((w) => w.weight).reduce((a, b) => a > b ? a : b);
      final totalWeightChange = weights.length > 1
          ? weights.last.weight - weights.first.weight
          : 0.0;
      WeightTrend? overallTrend;
      if (weights.length >= 2) {
        final firstHalf = weights
                .take(weights.length ~/ 2)
                .map((w) => w.weight)
                .reduce((a, b) => a + b) /
            (weights.length ~/ 2);
        final secondHalf = weights
                .skip(weights.length ~/ 2)
                .map((w) => w.weight)
                .reduce((a, b) => a + b) /
            (weights.length - weights.length ~/ 2);

        if (secondHalf > firstHalf + 0.1) {
          overallTrend = WeightTrend.gaining;
        } else if (secondHalf < firstHalf - 0.1) {
          overallTrend = WeightTrend.losing;
        } else {
          overallTrend = WeightTrend.stable;
        }
      }
      final bodyConditionDistribution = <BodyCondition, int>{};
      for (final weight in weights) {
        final condition = weight.bodyCondition;
        bodyConditionDistribution[condition] =
            (bodyConditionDistribution[condition] ?? 0) + 1;
      }

      final statistics = WeightStatistics(
        currentWeight: currentWeight,
        averageWeight: averageWeight,
        minWeight: minWeight,
        maxWeight: maxWeight,
        overallTrend: overallTrend,
        totalWeightChange: totalWeightChange,
        averageWeightChange:
            weights.length > 1 ? totalWeightChange / (weights.length - 1) : 0.0,
        totalRecords: weights.length,
        firstRecordDate: weights.first.date,
        lastRecordDate: weights.last.date,
        bodyConditionDistribution: bodyConditionDistribution,
      );

      return Right(statistics);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao buscar estatísticas de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, WeightTrendAnalysis>>
      analyzeWeightTrend(
    String animalId, {
    int periodInDays = 90,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: periodInDays));

      final weightModels =
          await _localDataSource.getWeightHistory(animalId, startDate, now);
      final weights = weightModels.map((model) => model.toEntity()).toList();

      if (weights.length < 2) {
        return Right(
          WeightTrendAnalysis(
            trend: WeightTrend.stable,
            trendStrength: 0.0,
            dataPoints: weights
                .map(
                  (w) => WeightPoint(
                    date: w.date,
                    weight: w.weight,
                    bodyConditionScore: w.bodyConditionScore,
                  ),
                )
                .toList(),
          ),
        );
      }

      weights.sort((a, b) => a.date.compareTo(b.date));
      final n = weights.length.toDouble();
      final sumX = weights
          .asMap()
          .entries
          .map((e) => e.key.toDouble())
          .reduce((a, b) => a + b);
      final sumY = weights.map((w) => w.weight).reduce((a, b) => a + b);
      final sumXY = weights
          .asMap()
          .entries
          .map((e) => e.key.toDouble() * e.value.weight)
          .reduce((a, b) => a + b);
      final sumX2 = weights
          .asMap()
          .entries
          .map((e) => (e.key.toDouble() * e.key.toDouble()))
          .reduce((a, b) => a + b);

      final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

      final trend = slope > 0.01
          ? WeightTrend.gaining
          : slope < -0.01
              ? WeightTrend.losing
              : WeightTrend.stable;

      final trendStrength = (slope.abs() / weights.first.weight).clamp(0.0, 1.0);

      final dataPoints = weights
          .map(
            (w) => WeightPoint(
              date: w.date,
              weight: w.weight,
              bodyConditionScore: w.bodyConditionScore,
            ),
          )
          .toList();
      const daysTo30 = 30.0;
      const daysTo90 = 90.0;
      final lastWeight = weights.last.weight;

      final projectedWeightIn30Days = lastWeight + (slope * daysTo30);
      final projectedWeightIn90Days = lastWeight + (slope * daysTo90);
      final recommendations = <String>[];
      final alerts = <String>[];

      if (trend == WeightTrend.gaining && trendStrength > 0.5) {
        recommendations
            .add('Considere ajustar a dieta para controlar o ganho de peso');
        if (trendStrength > 0.8) {
          alerts.add('Ganho de peso acelerado detectado');
        }
      } else if (trend == WeightTrend.losing && trendStrength > 0.5) {
        recommendations.add(
          'Monitore a alimentação e considere consultar um veterinário',
        );
        if (trendStrength > 0.8) {
          alerts.add('Perda de peso acelerada detectada');
        }
      }

      return Right(
        WeightTrendAnalysis(
          trend: trend,
          trendStrength: trendStrength,
          dataPoints: dataPoints,
          projectedWeightIn30Days: projectedWeightIn30Days,
          projectedWeightIn90Days: projectedWeightIn90Days,
          recommendations: recommendations,
          alerts: alerts,
        ),
      );
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao analisar tendência de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Weight>>>
      getAbnormalWeightChanges(
    String animalId, {
    double thresholdPercentage = 10.0,
    int timeFrameDays = 30,
  }) async {
    try {
      final weightModels =
          await _localDataSource.getWeightsByAnimalId(animalId);
      final weights = weightModels.map((model) => model.toEntity()).toList();

      if (weights.length < 2) return const Right([]);

      weights.sort((a, b) => a.date.compareTo(b.date));

      final abnormalChanges = <Weight>[];

      for (var i = 1; i < weights.length; i++) {
        final current = weights[i];
        final previous = weights[i - 1];

        final daysDifference = current.date.difference(previous.date).inDays;
        if (daysDifference > timeFrameDays) continue;

        final percentageChange =
            ((current.weight - previous.weight) / previous.weight * 100).abs();

        if (percentageChange >= thresholdPercentage) {
          abnormalChanges.add(current);
        }
      }

      return Right(abnormalChanges);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao buscar mudanças anormais de peso: ${e.toString()}',
        ),
      );
    }
  }

  // ========================================================================
  // IMPORT/EXPORT
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Map<String, dynamic>>>>
      exportWeightData() async {
    try {
      final weightModels = await _localDataSource.getWeights();
      final data = weightModels.map((model) => model.toJson()).toList();
      return Right(data);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao exportar dados de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, void>> importWeightData(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final weightModels =
          data.map((json) => WeightModel.fromJson(json)).toList();

      // Marcar todos como dirty para sync
      final dirtyModels = weightModels.map((model) {
        final syncEntity = WeightSyncEntity.fromLegacyWeight(
          model.toEntity(),
          moduleName: 'petiveti',
        ).markAsDirty();
        return WeightModel.fromEntity(syncEntity.toLegacyWeight());
      }).toList();

      await _localDataSource.cacheWeights(dirtyModels);

      if (kDebugMode) {
        debugPrint(
          '[WeightRepository] Imported ${dirtyModels.length} weight records',
        );
      }

      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao importar dados de peso: ${e.toString()}',
        ),
      );
    }
  }

  // ========================================================================
  // UTILITIES
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, int>> getWeightRecordsCount(
    String animalId,
  ) async {
    try {
      final count = await _localDataSource.getWeightsCount(animalId);
      return Right(count);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message:
              'Erro inesperado ao contar registros de peso: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, double?>> calculateAnimalBMI(
    String animalId,
  ) async {
    try {
      // TODO: Implementar cálculo de IMC animal quando houver dados de altura/comprimento
      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Erro inesperado ao calcular IMC animal: ${e.toString()}',
        ),
      );
    }
  }

  // ========================================================================
  // WATCH OPERATIONS
  // ========================================================================

  @override
  Stream<List<Weight>> watchWeights() {
    return _localDataSource.watchWeights().map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Stream<List<Weight>> watchWeightsByAnimalId(String animalId) {
    return _localDataSource.watchWeightsByAnimalId(animalId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  // ========================================================================
  // SYNC HELPERS
  // ========================================================================

  /// Trigger sync em background (não-bloqueante)
  /// UnifiedSyncManager gerencia filas e throttling automaticamente
  void _triggerBackgroundSync() {
    // TODO: Implementar quando UnifiedSyncManager tiver método trigger manual
    // Por enquanto, AutoSyncService fará sync periódico automaticamente
    if (kDebugMode) {
      debugPrint(
        '[WeightRepository] Background sync will be triggered by AutoSyncService',
      );
    }
  }

  /// Force sync manual (bloqueante) - para uso em casos específicos
  Future<Either<local_failures.Failure, void>> forceSync() async {
    try {
      // TODO: Implementar quando UnifiedSyncManager tiver método forceSync
      // await _syncManager.forceSyncApp('petiveti');

      if (kDebugMode) {
        debugPrint(
          '[WeightRepository] Manual sync requested (not yet implemented)',
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(message: 'Failed to force sync: $e'),
      );
    }
  }
}
