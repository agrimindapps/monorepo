import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@injectable
class GetAverageConsumption implements UseCase<double, GetAverageConsumptionParams> {

  GetAverageConsumption(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, double>> call(GetAverageConsumptionParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return repository.getAverageConsumption(params.vehicleId);
  }
}

class GetAverageConsumptionParams with EquatableMixin {

  const GetAverageConsumptionParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}

@injectable
class GetTotalSpent implements UseCase<double, GetTotalSpentParams> {

  GetTotalSpent(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, double>> call(GetTotalSpentParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return repository.getTotalSpent(
      params.vehicleId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetTotalSpentParams with EquatableMixin {

  const GetTotalSpentParams({
    required this.vehicleId,
    this.startDate,
    this.endDate,
  });
  final String vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

@injectable
class GetRecentFuelRecords implements UseCase<List<FuelRecordEntity>, GetRecentFuelRecordsParams> {

  GetRecentFuelRecords(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call(GetRecentFuelRecordsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return repository.getRecentFuelRecords(params.vehicleId, limit: params.limit);
  }
}

class GetRecentFuelRecordsParams with EquatableMixin {

  const GetRecentFuelRecordsParams({
    required this.vehicleId,
    this.limit = 10,
  });
  final String vehicleId;
  final int limit;

  @override
  List<Object> get props => [vehicleId, limit];
}