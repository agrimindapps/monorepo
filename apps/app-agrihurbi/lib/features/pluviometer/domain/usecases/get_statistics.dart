import 'package:core/core.dart';

import '../repositories/pluviometer_repository.dart';

/// Use case para obter estatísticas de pluviometria
class GetStatisticsUseCase
    implements UseCase<RainfallStatistics, GetStatisticsParams> {
  final PluviometerRepository repository;

  const GetStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, RainfallStatistics>> call(
      GetStatisticsParams params) async {
    return await repository.getStatistics(
      start: params.start,
      end: params.end,
      rainGaugeId: params.rainGaugeId,
    );
  }
}

/// Parâmetros para estatísticas
class GetStatisticsParams extends Equatable {
  const GetStatisticsParams({
    this.start,
    this.end,
    this.rainGaugeId,
  });

  final DateTime? start;
  final DateTime? end;
  final String? rainGaugeId;

  /// Factory para estatísticas do mês atual
  factory GetStatisticsParams.currentMonth() {
    final now = DateTime.now();
    return GetStatisticsParams(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  /// Factory para estatísticas do ano atual
  factory GetStatisticsParams.currentYear() {
    final now = DateTime.now();
    return GetStatisticsParams(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, 12, 31, 23, 59, 59),
    );
  }

  @override
  List<Object?> get props => [start, end, rainGaugeId];
}

/// Use case para obter totais mensais
class GetMonthlyTotalsUseCase
    implements UseCase<Map<int, double>, GetMonthlyTotalsParams> {
  final PluviometerRepository repository;

  const GetMonthlyTotalsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<int, double>>> call(
      GetMonthlyTotalsParams params) async {
    return await repository.getMonthlyTotals(params.year);
  }
}

/// Parâmetros para totais mensais
class GetMonthlyTotalsParams extends Equatable {
  const GetMonthlyTotalsParams({required this.year});

  final int year;

  @override
  List<Object> get props => [year];
}

/// Use case para obter totais anuais (comparativo)
class GetYearlyTotalsUseCase
    implements UseCase<Map<int, double>, GetYearlyTotalsParams> {
  final PluviometerRepository repository;

  const GetYearlyTotalsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<int, double>>> call(
      GetYearlyTotalsParams params) async {
    return await repository.getYearlyTotals(
      startYear: params.startYear,
      endYear: params.endYear,
    );
  }
}

/// Parâmetros para totais anuais
class GetYearlyTotalsParams extends Equatable {
  const GetYearlyTotalsParams({
    this.startYear,
    this.endYear,
  });

  final int? startYear;
  final int? endYear;

  @override
  List<Object?> get props => [startYear, endYear];
}

/// Use case para exportar dados para CSV
class ExportToCsvUseCase implements UseCase<String, ExportToCsvParams> {
  final PluviometerRepository repository;

  const ExportToCsvUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportToCsvParams params) async {
    return await repository.exportToCsv(
      start: params.start,
      end: params.end,
      rainGaugeId: params.rainGaugeId,
    );
  }
}

/// Parâmetros para exportação CSV
class ExportToCsvParams extends Equatable {
  const ExportToCsvParams({
    this.start,
    this.end,
    this.rainGaugeId,
  });

  final DateTime? start;
  final DateTime? end;
  final String? rainGaugeId;

  @override
  List<Object?> get props => [start, end, rainGaugeId];
}
