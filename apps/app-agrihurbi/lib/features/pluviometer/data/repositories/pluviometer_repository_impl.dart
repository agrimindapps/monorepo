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
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar pluviômetros')),
      (data) => Right(data.toEntities()),
    );
  }

  @override
  Future<Either<Failure, RainGaugeEntity>> getRainGaugeById(String id) async {
    final result = await _rainGaugeRepository.getById(id);
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar pluviômetro')),
      (data) {
        if (data == null) {
          return const Left(CacheFailure('Pluviômetro não encontrado'));
        }
        return Right(RainGaugeModel.fromDrift(data).toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, RainGaugeEntity>> createRainGauge(
    RainGaugeEntity rainGauge,
  ) async {
    final model = RainGaugeModel.fromEntity(rainGauge);
    final result = await _rainGaugeRepository.insert(model.toDriftCompanion());
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao criar pluviômetro')),
      (data) => Right(rainGauge),
    );
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
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao atualizar pluviômetro')),
      (data) => Right(rainGauge),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteRainGauge(String id) async {
    // Primeiro, soft delete das medições associadas
    await _measurementRepository.softDeleteByRainGauge(id);

    // Depois, soft delete do pluviômetro
    final result = await _rainGaugeRepository.softDelete(id);
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao excluir pluviômetro')),
      (data) => const Right(unit),
    );
  }

  @override
  Future<Either<Failure, List<RainGaugeEntity>>> getRainGaugesByGroup(
    String groupId,
  ) async {
    final result = await _rainGaugeRepository.getByGroup(groupId);
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar pluviômetros por grupo')),
      (data) => Right(data.toEntities()),
    );
  }

  @override
  Future<Either<Failure, List<RainGaugeEntity>>>
      getRainGaugesWithLocation() async {
    final result = await _rainGaugeRepository.getWithLocation();
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar pluviômetros com localização')),
      (data) => Right(data.toEntities()),
    );
  }

  // ==================== MEASUREMENTS ====================

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurements() async {
    final result = await _measurementRepository.getAll();
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar medições')),
      (data) => Right(data.toEntities()),
    );
  }

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> getMeasurementById(
    String id,
  ) async {
    final result = await _measurementRepository.getById(id);
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar medição')),
      (data) {
        if (data == null) {
          return const Left(CacheFailure('Medição não encontrada'));
        }
        return Right(RainfallMeasurementModel.fromDrift(data).toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> createMeasurement(
    RainfallMeasurementEntity measurement,
  ) async {
    final model = RainfallMeasurementModel.fromEntity(measurement);
    final result =
        await _measurementRepository.insert(model.toDriftCompanion());
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao criar medição')),
      (data) => Right(measurement),
    );
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
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao atualizar medição')),
      (data) => Right(measurement),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteMeasurement(String id) async {
    final result = await _measurementRepository.softDelete(id);
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao excluir medição')),
      (data) => const Right(unit),
    );
  }

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurementsByRainGauge(String rainGaugeId) async {
    final result = await _measurementRepository.getByRainGauge(rainGaugeId);
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar medições')),
      (data) => Right(data.toEntities()),
    );
  }

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurementsByPeriod(DateTime start, DateTime end) async {
    final result = await _measurementRepository.getByPeriod(start, end);
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar medições por período')),
      (data) => Right(data.toEntities()),
    );
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
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar medições')),
      (data) => Right(data.toEntities()),
    );
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
      final total = totalResult.fold((failure) => 0.0, (data) => data);

      // Média
      final avgResult = await _measurementRepository.getAverageByPeriod(
        effectiveStart,
        effectiveEnd,
      );
      final average = avgResult.fold((failure) => 0.0, (data) => data);

      // Máximo
      final maxResult = await _measurementRepository.getMaxByPeriod(
        effectiveStart,
        effectiveEnd,
      );
      final max = maxResult.fold((failure) => 0.0, (data) => data);

      // Mínimo
      final minResult = await _measurementRepository.getMinByPeriod(
        effectiveStart,
        effectiveEnd,
      );
      final min = minResult.fold((failure) => 0.0, (data) => data);

      // Contagem
      final countResult = rainGaugeId != null
          ? await _measurementRepository.countByRainGauge(rainGaugeId)
          : await _measurementRepository.countActive();
      final count = countResult.fold((failure) => 0, (data) => data);

      // Totais mensais
      final monthlyResult = await _measurementRepository.getMonthlyTotals(
        effectiveStart.year,
      );
      final monthlyTotals = monthlyResult.fold(
          (failure) => <int, double>{},
          (data) => data);

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
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar totais mensais')),
      (data) => Right(data),
    );
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
    return result.fold(
      (failure) => const Left(CacheFailure('Erro ao buscar totais anuais')),
      (data) => Right(data),
    );
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
