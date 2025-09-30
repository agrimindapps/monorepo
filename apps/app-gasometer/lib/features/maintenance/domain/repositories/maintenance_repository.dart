import 'package:core/core.dart';



import '../entities/maintenance_entity.dart';

abstract class MaintenanceRepository {
  Future<Either<Failure, List<MaintenanceEntity>>> getAllMaintenanceRecords();
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByVehicle(String vehicleId);
  Future<Either<Failure, MaintenanceEntity?>> getMaintenanceRecordById(String id);
  Future<Either<Failure, MaintenanceEntity>> addMaintenanceRecord(MaintenanceEntity maintenance);
  Future<Either<Failure, MaintenanceEntity>> updateMaintenanceRecord(MaintenanceEntity maintenance);
  Future<Either<Failure, Unit>> deleteMaintenanceRecord(String id);
  Future<Either<Failure, List<MaintenanceEntity>>> searchMaintenanceRecords(String query);
  Stream<Either<Failure, List<MaintenanceEntity>>> watchMaintenanceRecords();
  Stream<Either<Failure, List<MaintenanceEntity>>> watchMaintenanceRecordsByVehicle(String vehicleId);

  // Maintenance-specific queries
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByType(String vehicleId, MaintenanceType type);
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByStatus(String vehicleId, MaintenanceStatus status);
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByDateRange(String vehicleId, DateTime startDate, DateTime endDate);
  Future<Either<Failure, List<MaintenanceEntity>>> getUpcomingMaintenanceRecords(String vehicleId, {int days = 30});
  Future<Either<Failure, List<MaintenanceEntity>>> getOverdueMaintenanceRecords(String vehicleId);
  
  // Analytics methods
  Future<Either<Failure, double>> getTotalMaintenanceCost(String vehicleId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, Map<String, int>>> getMaintenanceCountByType(String vehicleId);
  Future<Either<Failure, double>> getAverageMaintenanceCost(String vehicleId);
  Future<Either<Failure, List<MaintenanceEntity>>> getRecentMaintenanceRecords(String vehicleId, {int limit = 10});
  Future<Either<Failure, MaintenanceEntity?>> getLastMaintenanceRecord(String vehicleId);
}