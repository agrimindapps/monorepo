import 'package:gasometer_drift/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer_drift/features/fuel/domain/repositories/fuel_repository.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/add_fuel_record.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/delete_fuel_record.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/get_all_fuel_records.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/update_fuel_record.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

/// Mock repositories
class MockFuelRepository extends Mock implements FuelRepository {}

/// Mock use cases
class MockAddFuelRecord extends Mock implements AddFuelRecord {}

class MockUpdateFuelRecord extends Mock implements UpdateFuelRecord {}

class MockDeleteFuelRecord extends Mock implements DeleteFuelRecord {}

class MockGetAllFuelRecords extends Mock implements GetAllFuelRecords {}

class MockGetFuelRecordsByVehicle extends Mock
    implements GetFuelRecordsByVehicle {}

/// Fake entities for fallback values
class FakeFuelRecordEntity extends Fake implements FuelRecordEntity {}

class FakeVehicleEntity extends Fake implements VehicleEntity {}

/// Fake params for fallback values
class FakeAddFuelRecordParams extends Fake implements AddFuelRecordParams {}

class FakeUpdateFuelRecordParams extends Fake
    implements UpdateFuelRecordParams {}

class FakeDeleteFuelRecordParams extends Fake
    implements DeleteFuelRecordParams {}

class FakeGetFuelRecordsByVehicleParams extends Fake
    implements GetFuelRecordsByVehicleParams {}

/// Factory for registering all fallback values
class MockFactories {
  /// Register all fallback values needed for mocktail
  static void registerFallbackValues() {
    registerFallbackValue(FakeFuelRecordEntity());
    registerFallbackValue(FakeVehicleEntity());
    registerFallbackValue(FakeAddFuelRecordParams());
    registerFallbackValue(FakeUpdateFuelRecordParams());
    registerFallbackValue(FakeDeleteFuelRecordParams());
    registerFallbackValue(FakeGetFuelRecordsByVehicleParams());
  }
}
