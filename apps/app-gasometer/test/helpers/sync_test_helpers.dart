import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/logging/services/logging_service.dart';
import 'package:gasometer/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer/features/maintenance/domain/entities/maintenance_entity.dart';
import 'package:gasometer/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

// ============================================================================
// MOCKS
// ============================================================================

/// Mock do UnifiedSyncManager (core package)
class MockUnifiedSyncManager extends Mock implements UnifiedSyncManager {}

/// Mock do LoggingService
class MockLoggingService extends Mock implements LoggingService {}

// ============================================================================
// FAKE ENTITIES (para fallback values)
// ============================================================================

class FakeVehicleEntity extends Fake implements VehicleEntity {}

class FakeFuelRecordEntity extends Fake implements FuelRecordEntity {}

class FakeMaintenanceEntity extends Fake implements MaintenanceEntity {}

// ============================================================================
// TEST FIXTURES (dados de teste reutilizáveis)
// ============================================================================

class SyncTestFixtures {
  // Vehicle Fixtures
  static VehicleEntity createVehicle({
    String id = 'vehicle_1',
    String name = 'Test Vehicle',
    String brand = 'Test Brand',
    String model = 'Test Model',
    int year = 2020,
    String licensePlate = 'ABC-1234',
    int version = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    String? userId,
    String? moduleName,
    double? currentOdometer,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return VehicleEntity(
      id: id,
      name: name,
      brand: brand,
      model: model,
      year: year,
      color: 'Black',
      licensePlate: licensePlate,
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline],
      currentOdometer: currentOdometer ?? 10000.0,
      tankCapacity: 50.0,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      lastSyncAt: lastSyncAt,
      isDirty: isDirty,
      isDeleted: isDeleted,
      version: version,
      userId: userId ?? 'user_123',
      moduleName: moduleName ?? 'gasometer',
      metadata: metadata ?? const {},
    );
  }

  // Fuel Record Fixtures
  static FuelRecordEntity createFuelRecord({
    String id = 'fuel_1',
    String vehicleId = 'vehicle_1',
    FuelType fuelType = FuelType.gasoline,
    double liters = 30.0,
    double pricePerLiter = 5.0,
    double odometer = 11000.0,
    DateTime? date,
    int version = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    String? userId,
    String? moduleName,
  }) {
    final now = DateTime.now();
    return FuelRecordEntity(
      id: id,
      vehicleId: vehicleId,
      fuelType: fuelType,
      liters: liters,
      pricePerLiter: pricePerLiter,
      totalPrice: liters * pricePerLiter,
      odometer: odometer,
      date: date ?? now,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      lastSyncAt: lastSyncAt,
      isDirty: isDirty,
      isDeleted: isDeleted,
      version: version,
      userId: userId ?? 'user_123',
      moduleName: moduleName ?? 'gasometer',
    );
  }

  // Maintenance Fixtures
  static MaintenanceEntity createMaintenance({
    String id = 'maintenance_1',
    String vehicleId = 'vehicle_1',
    MaintenanceType type = MaintenanceType.preventive,
    MaintenanceStatus status = MaintenanceStatus.completed,
    String title = 'Test Maintenance',
    double cost = 500.0,
    double odometer = 15000.0,
    DateTime? serviceDate,
    int version = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    String? userId,
    String? moduleName,
  }) {
    final now = DateTime.now();
    return MaintenanceEntity(
      id: id,
      vehicleId: vehicleId,
      type: type,
      status: status,
      title: title,
      description: 'Test maintenance description',
      cost: cost,
      serviceDate: serviceDate ?? now,
      odometer: odometer,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      lastSyncAt: lastSyncAt,
      isDirty: isDirty,
      isDeleted: isDeleted,
      version: version,
      userId: userId ?? 'user_123',
      moduleName: moduleName ?? 'gasometer',
    );
  }

  // Batch Creation Helpers
  static List<VehicleEntity> createVehicles(int count) {
    return List.generate(
      count,
      (i) => createVehicle(
        id: 'vehicle_${i + 1}',
        name: 'Vehicle ${i + 1}',
      ),
    );
  }

  static List<FuelRecordEntity> createFuelRecords(int count,
      {String? vehicleId}) {
    return List.generate(
      count,
      (i) => createFuelRecord(
        id: 'fuel_${i + 1}',
        vehicleId: vehicleId ?? 'vehicle_1',
      ),
    );
  }

  static List<MaintenanceEntity> createMaintenances(int count,
      {String? vehicleId}) {
    return List.generate(
      count,
      (i) => createMaintenance(
        id: 'maintenance_${i + 1}',
        vehicleId: vehicleId ?? 'vehicle_1',
      ),
    );
  }
}

// ============================================================================
// CUSTOM MATCHERS
// ============================================================================

/// Matcher para verificar VehicleEntity com ID específico
class IsVehicleWithId extends Matcher {
  IsVehicleWithId(this.expectedId);
  final String expectedId;

  @override
  bool matches(item, Map matchState) {
    return item is VehicleEntity && item.id == expectedId;
  }

  @override
  Description describe(Description description) {
    return description.add('VehicleEntity with id $expectedId');
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! VehicleEntity) {
      return mismatchDescription.add('is not a VehicleEntity');
    }
    return mismatchDescription.add('has id ${item.id}');
  }
}

/// Matcher para verificar FuelRecordEntity com ID específico
class IsFuelRecordWithId extends Matcher {
  IsFuelRecordWithId(this.expectedId);
  final String expectedId;

  @override
  bool matches(item, Map matchState) {
    return item is FuelRecordEntity && item.id == expectedId;
  }

  @override
  Description describe(Description description) {
    return description.add('FuelRecordEntity with id $expectedId');
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! FuelRecordEntity) {
      return mismatchDescription.add('is not a FuelRecordEntity');
    }
    return mismatchDescription.add('has id ${item.id}');
  }
}

/// Matcher para verificar MaintenanceEntity com ID específico
class IsMaintenanceWithId extends Matcher {
  IsMaintenanceWithId(this.expectedId);
  final String expectedId;

  @override
  bool matches(item, Map matchState) {
    return item is MaintenanceEntity && item.id == expectedId;
  }

  @override
  Description describe(Description description) {
    return description.add('MaintenanceEntity with id $expectedId');
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! MaintenanceEntity) {
      return mismatchDescription.add('is not a MaintenanceEntity');
    }
    return mismatchDescription.add('has id ${item.id}');
  }
}

/// Matcher para verificar BaseSyncEntity marcado como dirty
class IsDirtyEntity extends Matcher {
  @override
  bool matches(item, Map matchState) {
    return item is BaseSyncEntity && item.isDirty;
  }

  @override
  Description describe(Description description) {
    return description.add('BaseSyncEntity marked as dirty');
  }
}

/// Matcher para verificar BaseSyncEntity NÃO marcado como dirty
class IsNotDirtyEntity extends Matcher {
  @override
  bool matches(item, Map matchState) {
    return item is BaseSyncEntity && !item.isDirty;
  }

  @override
  Description describe(Description description) {
    return description.add('BaseSyncEntity not marked as dirty');
  }
}

/// Matcher para verificar BaseSyncEntity com versão específica
class IsEntityWithVersion extends Matcher {
  IsEntityWithVersion(this.expectedVersion);
  final int expectedVersion;

  @override
  bool matches(item, Map matchState) {
    return item is BaseSyncEntity && item.version == expectedVersion;
  }

  @override
  Description describe(Description description) {
    return description.add('BaseSyncEntity with version $expectedVersion');
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! BaseSyncEntity) {
      return mismatchDescription.add('is not a BaseSyncEntity');
    }
    return mismatchDescription.add('has version ${item.version}');
  }
}

// ============================================================================
// MATCHER FACTORY FUNCTIONS
// ============================================================================

Matcher isVehicleWithId(String id) => IsVehicleWithId(id);
Matcher isFuelRecordWithId(String id) => IsFuelRecordWithId(id);
Matcher isMaintenanceWithId(String id) => IsMaintenanceWithId(id);
Matcher isDirtyEntity() => IsDirtyEntity();
Matcher isNotDirtyEntity() => IsNotDirtyEntity();
Matcher isEntityWithVersion(int version) => IsEntityWithVersion(version);

// ============================================================================
// SETUP HELPERS
// ============================================================================

/// Setup comum para testes de sync
class SyncTestSetup {
  static void registerFallbackValues() {
    registerFallbackValue(FakeVehicleEntity());
    registerFallbackValue(FakeFuelRecordEntity());
    registerFallbackValue(FakeMaintenanceEntity());
  }

  /// Configura comportamento padrão de sucesso para UnifiedSyncManager
  static void setupSuccessfulSync(MockUnifiedSyncManager mockSyncManager) {
    // Create
    when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
        .thenAnswer((_) async => const Right('created_id'));
    when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
        .thenAnswer((_) async => const Right('created_id'));
    when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
        .thenAnswer((_) async => const Right('created_id'));

    // Update
    when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockSyncManager.update<FuelRecordEntity>(any(), any(), any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockSyncManager.update<MaintenanceEntity>(any(), any(), any()))
        .thenAnswer((_) async => const Right(unit));

    // Delete
    when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockSyncManager.delete<FuelRecordEntity>(any(), any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockSyncManager.delete<MaintenanceEntity>(any(), any()))
        .thenAnswer((_) async => const Right(unit));

    // FindAll
    when(() => mockSyncManager.findAll<VehicleEntity>(any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockSyncManager.findAll<FuelRecordEntity>(any()))
        .thenAnswer((_) async => const Right([]));
    when(() => mockSyncManager.findAll<MaintenanceEntity>(any()))
        .thenAnswer((_) async => const Right([]));

    // FindById
    when(() => mockSyncManager.findById<VehicleEntity>(any(), any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockSyncManager.findById<FuelRecordEntity>(any(), any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockSyncManager.findById<MaintenanceEntity>(any(), any()))
        .thenAnswer((_) async => const Right(null));

    // ForceSyncEntity
    when(() => mockSyncManager.forceSyncEntity<VehicleEntity>(any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>(any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => mockSyncManager.forceSyncEntity<MaintenanceEntity>(any()))
        .thenAnswer((_) async => const Right(unit));
  }

  /// Configura comportamento padrão de sucesso para LoggingService
  static void setupLoggingService(MockLoggingService mockLogger) {
    when(() => mockLogger.logOperationStart(
          category: any(named: 'category'),
          operation: any(named: 'operation'),
          message: any(named: 'message'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});

    when(() => mockLogger.logOperationSuccess(
          category: any(named: 'category'),
          operation: any(named: 'operation'),
          message: any(named: 'message'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});

    when(() => mockLogger.logOperationError(
          category: any(named: 'category'),
          operation: any(named: 'operation'),
          message: any(named: 'message'),
          error: any(named: 'error'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});
  }
}
