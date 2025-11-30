import 'package:core/core.dart';

import '../entities/rain_gauge_entity.dart';
import '../entities/rainfall_measurement_entity.dart';

/// Estatísticas de pluviometria
class RainfallStatistics {
  const RainfallStatistics({
    required this.totalAmount,
    required this.averageDaily,
    required this.maxAmount,
    required this.minAmount,
    required this.measurementCount,
    required this.monthlyTotals,
  });

  /// Total acumulado no período
  final double totalAmount;

  /// Média diária
  final double averageDaily;

  /// Máximo registrado
  final double maxAmount;

  /// Mínimo registrado (excluindo zeros)
  final double minAmount;

  /// Número de medições
  final int measurementCount;

  /// Totais mensais (mês: total)
  final Map<int, double> monthlyTotals;

  factory RainfallStatistics.empty() {
    return const RainfallStatistics(
      totalAmount: 0,
      averageDaily: 0,
      maxAmount: 0,
      minAmount: 0,
      measurementCount: 0,
      monthlyTotals: {},
    );
  }
}

/// Interface do repositório de pluviometria seguindo Clean Architecture
///
/// Define os contratos para operações com pluviômetros e medições
/// Usa Either<Failure, Success> para error handling funcional
abstract class PluviometerRepository {
  // ==================== RAIN GAUGES ====================

  /// Obtém lista de todos os pluviômetros ativos
  Future<Either<Failure, List<RainGaugeEntity>>> getRainGauges();

  /// Obtém um pluviômetro específico por ID
  Future<Either<Failure, RainGaugeEntity>> getRainGaugeById(String id);

  /// Cria um novo pluviômetro com validação
  Future<Either<Failure, RainGaugeEntity>> createRainGauge(
      RainGaugeEntity rainGauge);

  /// Atualiza um pluviômetro existente
  Future<Either<Failure, RainGaugeEntity>> updateRainGauge(
      RainGaugeEntity rainGauge);

  /// Remove um pluviômetro por ID (soft delete)
  Future<Either<Failure, Unit>> deleteRainGauge(String id);

  /// Busca pluviômetros por grupo
  Future<Either<Failure, List<RainGaugeEntity>>> getRainGaugesByGroup(
      String groupId);

  /// Busca pluviômetros com localização GPS
  Future<Either<Failure, List<RainGaugeEntity>>> getRainGaugesWithLocation();

  // ==================== MEASUREMENTS ====================

  /// Obtém lista de todas as medições ativas
  Future<Either<Failure, List<RainfallMeasurementEntity>>> getMeasurements();

  /// Obtém uma medição específica por ID
  Future<Either<Failure, RainfallMeasurementEntity>> getMeasurementById(
      String id);

  /// Cria uma nova medição com validação
  Future<Either<Failure, RainfallMeasurementEntity>> createMeasurement(
      RainfallMeasurementEntity measurement);

  /// Atualiza uma medição existente
  Future<Either<Failure, RainfallMeasurementEntity>> updateMeasurement(
      RainfallMeasurementEntity measurement);

  /// Remove uma medição por ID (soft delete)
  Future<Either<Failure, Unit>> deleteMeasurement(String id);

  /// Obtém medições de um pluviômetro específico
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurementsByRainGauge(String rainGaugeId);

  /// Obtém medições por período
  Future<Either<Failure, List<RainfallMeasurementEntity>>> getMeasurementsByPeriod(
    DateTime start,
    DateTime end,
  );

  /// Obtém medições de um pluviômetro por período
  Future<Either<Failure, List<RainfallMeasurementEntity>>>
      getMeasurementsByRainGaugeAndPeriod(
    String rainGaugeId,
    DateTime start,
    DateTime end,
  );

  // ==================== STATISTICS ====================

  /// Obtém estatísticas de um período
  Future<Either<Failure, RainfallStatistics>> getStatistics({
    DateTime? start,
    DateTime? end,
    String? rainGaugeId,
  });

  /// Obtém totais mensais de um ano
  Future<Either<Failure, Map<int, double>>> getMonthlyTotals(int year);

  /// Obtém totais anuais para comparação
  Future<Either<Failure, Map<int, double>>> getYearlyTotals({
    int? startYear,
    int? endYear,
  });

  // ==================== EXPORT ====================

  /// Exporta dados para CSV
  Future<Either<Failure, String>> exportToCsv({
    DateTime? start,
    DateTime? end,
    String? rainGaugeId,
  });
}
