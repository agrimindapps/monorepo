import 'package:core/core.dart';

import '../../../../database/repositories/rain_gauge_repository.dart';
import '../../../../database/repositories/rainfall_measurement_repository.dart';
import '../../domain/entities/rain_gauge_entity.dart';
import '../../domain/entities/rainfall_measurement_entity.dart';
import '../../domain/repositories/pluviometer_repository.dart';
import '../models/rain_gauge_model.dart';
import '../models/rainfall_measurement_model.dart';

/// Implementação do repositório de pluviometria
///
/// Conecta a camada de domínio com os repositories Drift
class PluviometerRepositoryImpl implements PluviometerRepository {
  final RainGaugeRepository _rainGaugeRepository;
  final RainfallMeasurementRepository _measurementRepository;

  PluviometerRepositoryImpl(
    this._rainGaugeRepository,
    this._measurementRepository,
  );

  // ==================== RAIN GAUGES ====================

  @override
  Future<Either<Failure, List<RainGaugeEntity>>> getRainGauges() async {
    final result = await _rainGaugeRepository.getAll();
    if (result.isSuccess && result.data != null) {
      return Right(result.data!.toEntities());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar pluviômetros'));
  }

  @override
  Future<Either<Failure, RainGaugeEntity>> getRainGaugeById(String id) async {
    final result = await _rainGaugeRepository.getById(id);
    if (result.isSuccess) {
      final gauge = result.data;
      if (gauge == null) {
        return const Left(CacheFailure('Pluviômetro não encontrado'));
      }
      return Right(RainGaugeModel.fromDrift(gauge).toEntity());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar pluviômetro'));
  }

  @override
  Future<Either<Failure, RainGaugeEntity>> createRainGauge(
    RainGaugeEntity rainGauge,
  ) async {
    final model = RainGaugeModel.fromEntity(rainGauge);
    final result = await _rainGaugeRepository.insert(model.toDriftCompanion());
    if (result.isSuccess) {
      return Right(rainGauge);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao criar pluviômetro'));
  }

  @override
  Future<Either<Failure, RainGaugeEntity>> updateRainGauge(
    RainGaugeEntity rainGauge,
  ) async {
    final model = RainGaugeModel.fromEntity(rainGauge);
    final result = await _rainGaugeRepository.update(
      rainGauge.id,
      model.toDriftCompanion(),
    );
    if (result.isSuccess) {
      return Right(rainGauge);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao atualizar pluviômetro'));
  }

  @override
  Future<Either<Failure, Unit>> deleteRainGauge(String id) async {
    // Primeiro, soft delete das medições associadas
    await _measurementRepository.softDeleteByRainGauge(id);
    
    // Depois, soft delete do pluviômetro
    final result = await _rainGaugeRepository.softDelete(id);
    if (result.isSuccess) {
      return const Right(unit);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao excluir pluviômetro'));
  }

  @override
  Future<Either<Failure, List<RainGaugeEntity>>> getRainGaugesByGroup(
    String groupId,
  ) async {
    final result = await _rainGaugeRepository.getByGroup(groupId);
    if (result.isSuccess && result.data != null) {
      return Right(result.data!.toEntities());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar pluviômetros por grupo'));
  }

  @override
  Future<Either<Failure, List<RainGaugeEntity>>>
      getRainGaugesWithLocation() async {
    final result = await _rainGaugeRepository.getWithLocation();
    if (result.isSuccess && result.data != null) {
      return Right(result.data!.toEntities());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar pluviômetros com localização'));
  }

  // ==================== MEASUREMENTS ====================

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurements() async {
    final result = await _measurementRepository.getAll();
    if (result.isSuccess && result.data != null) {
      return Right(result.data!.toEntities());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar medições'));
  }

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> getMeasurementById(
    String id,
  ) async {
    final result = await _measurementRepository.getById(id);
    if (result.isSuccess) {
      final measurement = result.data;
      if (measurement == null) {
        return const Left(CacheFailure('Medição não encontrada'));
      }
      return Right(RainfallMeasurementModel.fromDrift(measurement).toEntity());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar medição'));
  }

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> createMeasurement(
    RainfallMeasurementEntity measurement,
  ) async {
    final model = RainfallMeasurementModel.fromEntity(measurement);
    final result =
        await _measurementRepository.insert(model.toDriftCompanion());
    if (result.isSuccess) {
      return Right(measurement);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao criar medição'));
  }

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> updateMeasurement(
    RainfallMeasurementEntity measurement,
  ) async {
    final model = RainfallMeasurementModel.fromEntity(measurement);
    final result = await _measurementRepository.update(
      measurement.id,
      model.toDriftCompanion(),
    );
    if (result.isSuccess) {
      return Right(measurement);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao atualizar medição'));
  }

  @override
  Future<Either<Failure, Unit>> deleteMeasurement(String id) async {
    final result = await _measurementRepository.softDelete(id);
    if (result.isSuccess) {
      return const Right(unit);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao excluir medição'));
  }

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurementsByRainGauge(String rainGaugeId) async {
    final result = await _measurementRepository.getByRainGauge(rainGaugeId);
    if (result.isSuccess && result.data != null) {
      return Right(result.data!.toEntities());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar medições'));
  }

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurementsByPeriod(DateTime start, DateTime end) async {
    final result = await _measurementRepository.getByPeriod(start, end);
    if (result.isSuccess && result.data != null) {
      return Right(result.data!.toEntities());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar medições por período'));
  }

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurementsByRainGaugeAndPeriod(
    String rainGaugeId,
    DateTime start,
    DateTime end,
  ) async {
    final result = await _measurementRepository.getByRainGaugeAndPeriod(
      rainGaugeId,
      start,
      end,
    );
    if (result.isSuccess && result.data != null) {
      return Right(result.data!.toEntities());
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar medições'));
  }

  // ==================== STATISTICS ====================

  @override
  Future<Either<Failure, RainfallStatistics>> getStatistics({
    DateTime? start,
    DateTime? end,
    String? rainGaugeId,
  }) async {
    try {
      final effectiveStart = start ?? DateTime(DateTime.now().year, 1, 1);
      final effectiveEnd = end ?? DateTime.now();

      // Total
      final totalResult = rainGaugeId != null
          ? await _measurementRepository.getTotalByRainGaugeAndPeriod(
              rainGaugeId,
              effectiveStart,
              effectiveEnd,
            )
          : await _measurementRepository.getTotalByPeriod(
              effectiveStart,
              effectiveEnd,
            );
      final total = totalResult.isSuccess ? (totalResult.data ?? 0.0) : 0.0;

      // Média
      final avgResult = await _measurementRepository.getAverageByPeriod(
        effectiveStart,
        effectiveEnd,
      );
      final average = avgResult.isSuccess ? (avgResult.data ?? 0.0) : 0.0;

      // Máximo
      final maxResult = await _measurementRepository.getMaxByPeriod(
        effectiveStart,
        effectiveEnd,
      );
      final max = maxResult.isSuccess ? (maxResult.data ?? 0.0) : 0.0;

      // Mínimo
      final minResult = await _measurementRepository.getMinByPeriod(
        effectiveStart,
        effectiveEnd,
      );
      final min = minResult.isSuccess ? (minResult.data ?? 0.0) : 0.0;

      // Contagem
      final countResult = rainGaugeId != null
          ? await _measurementRepository.countByRainGauge(rainGaugeId)
          : await _measurementRepository.countActive();
      final count = countResult.isSuccess ? (countResult.data ?? 0) : 0;

      // Totais mensais
      final monthlyResult = await _measurementRepository.getMonthlyTotals(
        effectiveStart.year,
      );
      final monthlyTotals = monthlyResult.isSuccess 
          ? (monthlyResult.data ?? <int, double>{}) 
          : <int, double>{};

      return Right(RainfallStatistics(
        totalAmount: total,
        averageDaily: average,
        maxAmount: max,
        minAmount: min,
        measurementCount: count,
        monthlyTotals: monthlyTotals,
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<int, double>>> getMonthlyTotals(int year) async {
    final result = await _measurementRepository.getMonthlyTotals(year);
    if (result.isSuccess && result.data != null) {
      return Right(result.data!);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar totais mensais'));
  }

  @override
  Future<Either<Failure, Map<int, double>>> getYearlyTotals({
    int? startYear,
    int? endYear,
  }) async {
    final result = await _measurementRepository.getYearlyTotals(
      startYear: startYear ?? DateTime.now().year - 5,
      endYear: endYear,
    );
    if (result.isSuccess && result.data != null) {
      return Right(result.data!);
    }
    return Left(CacheFailure(result.error?.message ?? 'Erro ao buscar totais anuais'));
  }

  // ==================== EXPORT ====================

  @override
  Future<Either<Failure, String>> exportToCsv({
    DateTime? start,
    DateTime? end,
    String? rainGaugeId,
  }) async {
    try {
      // Busca medições
      List<RainfallMeasurementEntity> measurements;
      if (rainGaugeId != null && start != null && end != null) {
        final result = await getMeasurementsByRainGaugeAndPeriod(
          rainGaugeId,
          start,
          end,
        );
        measurements = result.fold((_) => [], (list) => list);
      } else if (start != null && end != null) {
        final result = await getMeasurementsByPeriod(start, end);
        measurements = result.fold((_) => [], (list) => list);
      } else {
        final result = await getMeasurements();
        measurements = result.fold((_) => [], (list) => list);
      }

      // Busca pluviômetros para descrição
      final gaugesResult = await getRainGauges();
      final gauges = gaugesResult.fold(
        (_) => <RainGaugeEntity>[],
        (list) => list,
      );
      final gaugeMap = {for (var g in gauges) g.id: g.description};

      // Gera CSV
      final buffer = StringBuffer();
      buffer.writeln(
          'ID,Data,Pluviômetro,Quantidade (mm),Observações,Criado em');

      for (final m in measurements) {
        final gaugeName = gaugeMap[m.rainGaugeId] ?? m.rainGaugeId;
        buffer.writeln(
          '${m.id},'
          '${m.measurementDate.toIso8601String()},'
          '"$gaugeName",'
          '${m.amount},'
          '"${m.observations ?? ""}",'
          '${m.createdAt?.toIso8601String() ?? ""}',
        );
      }

      return Right(buffer.toString());
    } catch (e) {
      return Left(CacheFailure('Erro ao exportar: ${e.toString()}'));
    }
  }
}
