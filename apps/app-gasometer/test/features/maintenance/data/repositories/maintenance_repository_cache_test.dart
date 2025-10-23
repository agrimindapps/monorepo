import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';

// Relative imports
import '../../../../../lib/features/maintenance/data/models/maintenance_model.dart';
import '../../../../../lib/features/maintenance/data/repositories/maintenance_repository.dart';
import '../../../../../lib/features/maintenance/domain/entities/maintenance_entity.dart';

void main() {
  late MaintenanceRepository repository;
  late Box<MaintenanceModel> mockBox;

  setUpAll(() async {
    // Initialize Hive for testing
    Hive.init('./test_hive');
    Hive.registerAdapter(MaintenanceModelAdapter());
  });

  setUp(() async {
    // Clean up before each test
    if (Hive.isBoxOpen('maintenance')) {
      await Hive.box<MaintenanceModel>('maintenance').clear();
      await Hive.box<MaintenanceModel>('maintenance').close();
    }

    repository = MaintenanceRepository();
    await repository.initialize();
    mockBox = Hive.box<MaintenanceModel>('maintenance');
  });

  tearDown(() async {
    await mockBox.clear();
    await mockBox.close();
  });

  group('Cache behavior', () {
    test('should load cache on first read', () async {
      // Arrange
      final maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      await repository.saveMaintenance(maintenance);

      // Clear in-memory cache to force re-read
      repository.clearAllCache();

      // Act
      final result = await repository.getMaintenanceById('maintenance-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'maintenance-1');
      expect(result.title, 'Troca de óleo');
    });

    test('should use cache on subsequent reads (no HiveBox hit)', () async {
      // Arrange
      final maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      await repository.saveMaintenance(maintenance);

      // Act - primeira leitura (carrega cache)
      final firstRead = await repository.getMaintenanceById('maintenance-1');

      // Delete from Hive to verify cache is being used
      await mockBox.delete('maintenance-1');

      // Act - segunda leitura (deve usar cache, não Hive)
      final secondRead = await repository.getMaintenanceById('maintenance-1');

      // Assert
      expect(firstRead, isNotNull);
      expect(secondRead, isNotNull);
      expect(secondRead!.id, 'maintenance-1');
      expect(secondRead.title, 'Troca de óleo');
    });

    test('should invalidate cache after save', () async {
      // Arrange
      final maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Act
      await repository.getAllMaintenances(); // carrega cache vazio
      await repository.saveMaintenance(maintenance); // invalida cache
      final maintenances = await repository.getAllMaintenances(); // recarrega cache

      // Assert
      expect(maintenances.length, 1);
      expect(maintenances.first.id, 'maintenance-1');
    });

    test('should invalidate cache after update', () async {
      // Arrange
      final maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      await repository.saveMaintenance(maintenance);

      // Act - Load to cache
      await repository.getAllMaintenances();

      // Update
      final updated = maintenance.copyWith(cost: 200.0);
      await repository.updateMaintenance(updated);

      // Read again (should get updated from cache)
      final result = await repository.getMaintenanceById('maintenance-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.cost, 200.0);
    });

    test('should invalidate cache after delete', () async {
      // Arrange
      final maintenance1 = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      final maintenance2 = MaintenanceEntity(
        id: 'maintenance-2',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.corrective,
        status: MaintenanceStatus.completed,
        title: 'Alinhamento',
        description: 'Alinhamento e balanceamento',
        cost: 100.0,
        serviceDate: DateTime(2024, 2, 1),
        odometer: 11000.0,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      );

      await repository.saveMaintenance(maintenance1);
      await repository.saveMaintenance(maintenance2);

      // Act
      await repository.getAllMaintenances(); // carrega cache
      await repository.deleteMaintenance('maintenance-1'); // invalida cache
      final maintenances = await repository.getAllMaintenances(); // recarrega cache

      // Assert
      expect(maintenances.length, 1);
      expect(maintenances.first.id, 'maintenance-2');
    });

    test('should cache filtered lists separately', () async {
      // Arrange
      final preventive = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      final corrective = MaintenanceEntity(
        id: 'maintenance-2',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.corrective,
        status: MaintenanceStatus.completed,
        title: 'Alinhamento',
        description: 'Alinhamento e balanceamento',
        cost: 100.0,
        serviceDate: DateTime(2024, 2, 1),
        odometer: 11000.0,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      );

      await repository.saveMaintenance(preventive);
      await repository.saveMaintenance(corrective);

      // Act
      final allMaintenances = await repository.getAllMaintenances();
      final preventiveMaintenances = await repository.getMaintenancesByType(
        MaintenanceType.preventive,
      );
      final correctiveMaintenances = await repository.getMaintenancesByType(
        MaintenanceType.corrective,
      );

      // Assert
      expect(allMaintenances.length, 2);
      expect(preventiveMaintenances.length, 1);
      expect(correctiveMaintenances.length, 1);
      expect(preventiveMaintenances.first.type, MaintenanceType.preventive);
      expect(correctiveMaintenances.first.type, MaintenanceType.corrective);
    });

    test('should cache vehicle-specific queries separately', () async {
      // Arrange
      final vehicle1Maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      final vehicle2Maintenance = MaintenanceEntity(
        id: 'maintenance-2',
        userId: 'user-123',
        vehicleId: 'vehicle-2',
        type: MaintenanceType.corrective,
        status: MaintenanceStatus.completed,
        title: 'Alinhamento',
        description: 'Alinhamento e balanceamento',
        cost: 100.0,
        serviceDate: DateTime(2024, 2, 1),
        odometer: 11000.0,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      );

      await repository.saveMaintenance(vehicle1Maintenance);
      await repository.saveMaintenance(vehicle2Maintenance);

      // Act
      final vehicle1Maintenances = await repository.getMaintenancesByVehicle(
        'vehicle-1',
      );
      final vehicle2Maintenances = await repository.getMaintenancesByVehicle(
        'vehicle-2',
      );

      // Assert
      expect(vehicle1Maintenances.length, 1);
      expect(vehicle2Maintenances.length, 1);
      expect(vehicle1Maintenances.first.vehicleId, 'vehicle-1');
      expect(vehicle2Maintenances.first.vehicleId, 'vehicle-2');
    });

    test('should cache period queries with TTL', () async {
      // Arrange
      final maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      await repository.saveMaintenance(maintenance);

      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);

      // Act
      final firstRead = await repository.getMaintenancesByPeriod(start, end);

      // Delete from Hive to verify cache is being used
      await mockBox.clear();

      // Act - should use cache
      final secondRead = await repository.getMaintenancesByPeriod(start, end);

      // Assert
      expect(firstRead.length, 1);
      expect(secondRead.length, 1);
      expect(secondRead.first.id, 'maintenance-1');
    });

    test('should cache search results with TTL', () async {
      // Arrange
      final maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      await repository.saveMaintenance(maintenance);

      // Act
      final firstSearch = await repository.searchMaintenances('óleo');

      // Delete from Hive to verify cache is being used
      await mockBox.clear();

      // Act - should use cache
      final secondSearch = await repository.searchMaintenances('óleo');

      // Assert
      expect(firstSearch.length, 1);
      expect(secondSearch.length, 1);
      expect(secondSearch.first.title, 'Troca de óleo');
    });
  });

  group('Cache statistics', () {
    test('should return cache statistics', () async {
      // Arrange
      final maintenance = MaintenanceEntity(
        id: 'maintenance-1',
        userId: 'user-123',
        vehicleId: 'vehicle-1',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        title: 'Troca de óleo',
        description: 'Troca de óleo sintético',
        cost: 150.0,
        serviceDate: DateTime(2024, 1, 15),
        odometer: 10000.0,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      await repository.saveMaintenance(maintenance);
      await repository.getMaintenanceById('maintenance-1');
      await repository.getAllMaintenances();

      // Act
      final stats = repository.getCacheStats();

      // Assert
      expect(stats, isNotNull);
      expect(stats['isInitialized'], true);
      expect(stats['entityCache'], isNotNull);
      expect(stats['listCache'], isNotNull);
    });
  });
}
