import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../../../database/providers/database_providers.dart' as db_providers;
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../odometer/domain/entities/odometer_entity.dart';
import '../../domain/entities/recent_activities_entity.dart';
import '../../domain/usecases/get_recent_expenses.dart';
import '../../domain/usecases/get_recent_fuel_records.dart';
import '../../domain/usecases/get_recent_maintenance_records.dart';
import '../../domain/usecases/get_recent_odometer_records.dart';
import '../../domain/usecases/get_recent_params.dart';

part 'activities_providers.g.dart';

// ========== USE CASE PROVIDERS ==========

/// Provider for GetRecentFuelRecords use case
@riverpod
GetRecentFuelRecords getRecentFuelRecords(Ref ref) {
  final repository = ref.watch(deps.fuelRepositoryProvider);
  return GetRecentFuelRecords(repository);
}

/// Provider for GetRecentMaintenanceRecords use case
@riverpod
GetRecentMaintenanceRecords getRecentMaintenanceRecords(Ref ref) {
  final repository = ref.watch(db_providers.maintenanceDomainRepositoryProvider);
  return GetRecentMaintenanceRecords(repository);
}

/// Provider for GetRecentExpenses use case
@riverpod
GetRecentExpenses getRecentExpenses(Ref ref) {
  final repository = ref.watch(db_providers.expensesDomainRepositoryProvider);
  return GetRecentExpenses(repository);
}

/// Provider for GetRecentOdometerRecords use case
@riverpod
GetRecentOdometerRecords getRecentOdometerRecords(Ref ref) {
  final repository = ref.watch(db_providers.odometerRepositoryProvider);
  return GetRecentOdometerRecords(repository);
}

// ========== ACTIVITIES NOTIFIER ==========

/// Provider for recent activities data
/// Fetches last 3 records from each category for a specific vehicle
@riverpod
class ActivitiesNotifier extends _$ActivitiesNotifier {
  @override
  Future<RecentActivitiesEntity> build(String vehicleId) async {
    if (vehicleId.isEmpty) {
      return const RecentActivitiesEntity.empty();
    }

    return loadRecentActivities(vehicleId);
  }

  /// Loads recent activities from all categories in parallel
  Future<RecentActivitiesEntity> loadRecentActivities(String vehicleId) async {
    SecureLogger.info('Loading activities for vehicle: $vehicleId');
    final params = GetRecentParams(vehicleId: vehicleId, limit: 3);

    // Load all 4 use cases in parallel
    final results = await Future.wait([
      _getRecentFuelRecords(params),
      _getRecentMaintenanceRecords(params),
      _getRecentExpenses(params),
      _getRecentOdometerRecords(params),
    ]);

    // Graceful degradation: if one fails, show empty but don't break the page
    final entity = RecentActivitiesEntity(
      fuelRecords: results[0].fold(
        (failure) {
          SecureLogger.warning('Failed to load fuel records: ${failure.message}');
          return <FuelRecordEntity>[];
        },
        (records) {
          SecureLogger.info('Loaded ${records.length} fuel records');
          return records.cast<FuelRecordEntity>();
        },
      ),
      maintenanceRecords: results[1].fold(
        (failure) {
          SecureLogger.warning('Failed to load maintenance records: ${failure.message}');
          return <MaintenanceEntity>[];
        },
        (records) {
          SecureLogger.info('Loaded ${records.length} maintenance records');
          return records.cast<MaintenanceEntity>();
        },
      ),
      expenses: results[2].fold(
        (failure) {
          SecureLogger.warning('Failed to load expenses: ${failure.message}');
          return <ExpenseEntity>[];
        },
        (records) {
          SecureLogger.info('Loaded ${records.length} expense records');
          return records.cast<ExpenseEntity>();
        },
      ),
      odometerRecords: results[3].fold(
        (failure) {
          SecureLogger.warning('Failed to load odometer records: ${failure.message}');
          return <OdometerEntity>[];
        },
        (records) {
          SecureLogger.info('Loaded ${records.length} odometer records');
          return records.cast<OdometerEntity>();
        },
      ),
      vehicleId: vehicleId,
    );

    SecureLogger.info('Final entity: fuel=${entity.fuelRecords.length}, maintenance=${entity.maintenanceRecords.length}, expenses=${entity.expenses.length}, odometer=${entity.odometerRecords.length}');
    return entity;
  }

  /// Refresh activities data
  Future<void> refresh() async {
    final currentState = await future;
    if (currentState.vehicleId.isNotEmpty) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => loadRecentActivities(currentState.vehicleId));
    }
  }

  // Private helper methods to call use cases
  Future<Either<Failure, List<FuelRecordEntity>>> _getRecentFuelRecords(GetRecentParams params) async {
    final useCase = ref.read(getRecentFuelRecordsProvider);
    return useCase(params);
  }

  Future<Either<Failure, List<MaintenanceEntity>>> _getRecentMaintenanceRecords(GetRecentParams params) async {
    final useCase = ref.read(getRecentMaintenanceRecordsProvider);
    return useCase(params);
  }

  Future<Either<Failure, List<ExpenseEntity>>> _getRecentExpenses(GetRecentParams params) async {
    final useCase = ref.read(getRecentExpensesProvider);
    return useCase(params);
  }

  Future<Either<Failure, List<OdometerEntity>>> _getRecentOdometerRecords(GetRecentParams params) async {
    final useCase = ref.read(getRecentOdometerRecordsProvider);
    return useCase(params);
  }
}
