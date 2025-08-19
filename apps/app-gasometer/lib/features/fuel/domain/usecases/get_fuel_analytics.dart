import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@lazySingleton
class GetAverageConsumption implements UseCase<double, GetAverageConsumptionParams> {
  final FuelRepository repository;

  GetAverageConsumption(this.repository);

  @override
  Future<Either<Failure, double>> call(GetAverageConsumptionParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return await repository.getAverageConsumption(params.vehicleId);
  }
}

class GetAverageConsumptionParams extends UseCaseParams {
  final String vehicleId;

  const GetAverageConsumptionParams({required this.vehicleId});

  @override
  List<Object> get props => [vehicleId];
}

@lazySingleton
class GetTotalSpent implements UseCase<double, GetTotalSpentParams> {
  final FuelRepository repository;

  GetTotalSpent(this.repository);

  @override
  Future<Either<Failure, double>> call(GetTotalSpentParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return await repository.getTotalSpent(
      params.vehicleId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetTotalSpentParams extends UseCaseParams {
  final String vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetTotalSpentParams({
    required this.vehicleId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

@lazySingleton
class GetRecentFuelRecords implements UseCase<List<FuelRecordEntity>, GetRecentFuelRecordsParams> {
  final FuelRepository repository;

  GetRecentFuelRecords(this.repository);

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call(GetRecentFuelRecordsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return await repository.getRecentFuelRecords(params.vehicleId, limit: params.limit);
  }
}

class GetRecentFuelRecordsParams extends UseCaseParams {
  final String vehicleId;
  final int limit;

  const GetRecentFuelRecordsParams({
    required this.vehicleId,
    this.limit = 10,
  });

  @override
  List<Object> get props => [vehicleId, limit];
}