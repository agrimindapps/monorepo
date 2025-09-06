import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<Either<Failure, List<VehicleEntity>>> getAllVehicles();
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id);
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle);
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle);
  Future<Either<Failure, Unit>> deleteVehicle(String id);
  Future<Either<Failure, Unit>> syncVehicles();
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(String query);
  Stream<Either<Failure, List<VehicleEntity>>> watchVehicles();
}