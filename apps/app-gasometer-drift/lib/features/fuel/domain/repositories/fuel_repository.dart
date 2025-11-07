import 'package:core/core.dart';

import '../entities/fuel_record_entity.dart';

abstract class FuelRepository {
  Future<Either<Failure, List<FuelRecordEntity>>> getAllFuelRecords();
  Future<Either<Failure, List<FuelRecordEntity>>> getFuelRecordsByVehicle(String vehicleId);
  Future<Either<Failure, FuelRecordEntity?>> getFuelRecordById(String id);
  Future<Either<Failure, FuelRecordEntity>> addFuelRecord(FuelRecordEntity fuelRecord);
  Future<Either<Failure, FuelRecordEntity>> updateFuelRecord(FuelRecordEntity fuelRecord);
  Future<Either<Failure, Unit>> deleteFuelRecord(String id);
  Future<Either<Failure, List<FuelRecordEntity>>> searchFuelRecords(String query);
  Stream<Either<Failure, List<FuelRecordEntity>>> watchFuelRecords();
  Stream<Either<Failure, List<FuelRecordEntity>>> watchFuelRecordsByVehicle(String vehicleId);
  Future<Either<Failure, double>> getAverageConsumption(String vehicleId);
  Future<Either<Failure, double>> getTotalSpent(String vehicleId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, List<FuelRecordEntity>>> getRecentFuelRecords(String vehicleId, {int limit = 10});
}
