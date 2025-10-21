import 'package:app_nutrituti/core/error/failures.dart';
import 'package:app_nutrituti/features/water/domain/entities/water_record.dart';
import 'package:app_nutrituti/features/water/domain/repositories/water_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

/// Parameters for getting water records (optional filtering)
class GetWaterRecordsParams {
  final DateTime? date; // If provided, get records for this date
  final DateTime? startDate; // If provided with endDate, get range
  final DateTime? endDate;

  const GetWaterRecordsParams({
    this.date,
    this.startDate,
    this.endDate,
  });

  /// Factory for getting all records
  const GetWaterRecordsParams.all()
      : date = null,
        startDate = null,
        endDate = null;

  /// Factory for getting records for a specific date
  GetWaterRecordsParams.forDate(this.date)
      : startDate = null,
        endDate = null;

  /// Factory for getting records in a date range
  const GetWaterRecordsParams.inRange({
    required DateTime start,
    required DateTime end,
  })  : startDate = start,
        endDate = end,
        date = null;

  /// Validation helper
  bool get isValid {
    // If date is provided, startDate and endDate should be null
    if (date != null && (startDate != null || endDate != null)) {
      return false;
    }

    // If using range, both startDate and endDate must be provided
    if ((startDate != null && endDate == null) ||
        (startDate == null && endDate != null)) {
      return false;
    }

    // If using range, startDate must be before or equal to endDate
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      return false;
    }

    return true;
  }
}

/// Use case for retrieving water intake records
/// Supports filtering by date or date range
@lazySingleton
class GetWaterRecordsUseCase {
  final WaterRepository _repository;

  const GetWaterRecordsUseCase(this._repository);

  /// Execute the use case
  /// Returns Either Failure or List of WaterRecord
  Future<Either<Failure, List<WaterRecord>>> call(
    GetWaterRecordsParams params,
  ) async {
    // Validation: Params must be valid
    if (!params.isValid) {
      return const Left(
        ValidationFailure('Parâmetros de busca inválidos'),
      );
    }

    // Scenario 1: Get records for a specific date
    if (params.date != null) {
      return await _repository.getWaterRecordsByDate(params.date!);
    }

    // Scenario 2: Get records in a date range
    if (params.startDate != null && params.endDate != null) {
      return await _repository.getWaterRecordsInRange(
        startDate: params.startDate!,
        endDate: params.endDate!,
      );
    }

    // Scenario 3: Get all records
    return await _repository.getWaterRecords();
  }

  /// Convenience method: Get today's records
  Future<Either<Failure, List<WaterRecord>>> getToday() async {
    final today = DateTime.now();
    final params = GetWaterRecordsParams.forDate(today);
    return await call(params);
  }

  /// Convenience method: Get this week's records
  Future<Either<Failure, List<WaterRecord>>> getThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final params = GetWaterRecordsParams.inRange(
      start: startOfWeek,
      end: endOfWeek,
    );

    return await call(params);
  }

  /// Convenience method: Get this month's records
  Future<Either<Failure, List<WaterRecord>>> getThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final params = GetWaterRecordsParams.inRange(
      start: startOfMonth,
      end: endOfMonth,
    );

    return await call(params);
  }

  /// Convenience method: Get last N days
  Future<Either<Failure, List<WaterRecord>>> getLastNDays(int days) async {
    if (days <= 0) {
      return const Left(
        ValidationFailure('Número de dias deve ser maior que zero'),
      );
    }

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));

    final params = GetWaterRecordsParams.inRange(
      start: startDate,
      end: now,
    );

    return await call(params);
  }
}
