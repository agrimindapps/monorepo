import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/logging/services/logging_service.dart';
import 'package:gasometer/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:gasometer/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:gasometer/features/maintenance/domain/entities/maintenance_entity.dart';
import 'package:gasometer/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:gasometer/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/sync_test_helpers.dart';

void main() {
  late VehicleRepositoryImpl vehicleRepository;
  late FuelRepositoryImpl fuelRepository;
  late MaintenanceRepositoryImpl maintenanceRepository;
  late MockUnifiedSyncManager mockSyncManager;
  late MockLoggingService mockLogger;

  setUp(() {
    mockSyncManager = MockUnifiedSyncManager();
    mockLogger = MockLoggingService();

    vehicleRepository = VehicleRepositoryImpl(loggingService: mockLogger);
    fuelRepository = FuelRepositoryImpl(loggingService: mockLogger);
    maintenanceRepository =
        MaintenanceRepositoryImpl(loggingService: mockLogger);

    SyncTestSetup.registerFallbackValues();
    SyncTestSetup.setupLoggingService(mockLogger);
  });

  group('Orphaned Record Edge Cases', () {
    test('should handle fuel record with deleted vehicle', () async {
      // Scenario: FuelRecord aponta para Vehicle que foi deletado
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        vehicleId: 'deleted_vehicle',
      );

      // UnifiedSyncManager permite criação (integrity check detecta depois)
      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act
      final result = await fuelRepository.addFuelRecord(fuelRecord);

      // Assert - Criado, mas será marcado como orphan
      expect(result.isRight(), true);
    });

    test('should handle maintenance record with deleted vehicle', () async {
      // Scenario: Maintenance aponta para Vehicle que não existe mais
      final maintenance = SyncTestFixtures.createMaintenance(
        vehicleId: 'nonexistent_vehicle',
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      final result = await maintenanceRepository.addMaintenanceRecord(maintenance);

      // Assert - Criado localmente
      expect(result.isRight(), true);
      // Data integrity service detectaria posteriormente
    });

    test('should clean up orphaned records after vehicle deletion', () async {
      // Arrange - Vehicle com registros dependentes
      const vehicleId = 'vehicle_1';

      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act - Delete vehicle
      final deleteResult = await vehicleRepository.deleteVehicle(vehicleId);
      expect(deleteResult.isRight(), true);

      // Arrange - Tentar buscar fuel records do veículo deletado
      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right([]));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final fuelResult = await fuelRepository.getFuelRecordsByVehicle(vehicleId);

      // Assert - Lista vazia (registros foram limpos ou marcados como orphan)
      expect(fuelResult.isRight(), true);
      fuelResult.fold(
        (_) => fail('Should not fail'),
        (records) => expect(records.isEmpty, true),
      );
    });
  });

  group('Deleted Entity Edge Cases', () {
    test('should handle sync of entity that was deleted elsewhere', () async {
      // Scenario: Device A deleta, Device B tenta atualizar
      const vehicleId = 'vehicle_1';

      // Device B tenta update
      final vehicle = SyncTestFixtures.createVehicle(id: vehicleId);

      // Servidor retorna "not found" (já foi deletado)
      const failure = CacheFailure('Entity not found: deleted');

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await vehicleRepository.updateVehicle(vehicle);

      // Assert - Falha (entity foi deletado)
      expect(result.isLeft(), true);
    });

    test('should handle delete of entity modified elsewhere', () async {
      // Scenario: Device A modifica, Device B deleta simultaneamente
      const vehicleId = 'vehicle_1';

      // Device B deleta
      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      final deleteResult = await vehicleRepository.deleteVehicle(vehicleId);
      expect(deleteResult.isRight(), true);

      // Device A tenta update (mas já foi deletado)
      final vehicle = SyncTestFixtures.createVehicle(id: vehicleId);
      const failure = CacheFailure('Cannot update deleted entity');

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Left(failure));

      final updateResult = await vehicleRepository.updateVehicle(vehicle);

      // Assert - Update falha (entity foi deletado)
      expect(updateResult.isLeft(), true);
    });

    test('should handle soft delete vs hard delete', () async {
      // Arrange - Soft delete (marcado como deleted, não removido)
      final vehicle = SyncTestFixtures.createVehicle(isDeleted: false);
      final deletedVehicle = vehicle.markAsDeleted();

      expect(deletedVehicle.isDeleted, true);
      expect(deletedVehicle.isDirty, true);

      // Hard delete remove completamente
      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      final result = await vehicleRepository.deleteVehicle(vehicle.id);
      expect(result.isRight(), true);
    });
  });

  group('Timestamp Edge Cases', () {
    test('should handle entities with same timestamp', () async {
      // Arrange - 2 devices editam no mesmo segundo
      final now = DateTime(2024, 1, 1, 12, 0, 0);

      final vehicleA = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        version: 2,
        name: 'Device A',
        updatedAt: now,
      );

      final vehicleB = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        version: 2,
        name: 'Device B',
        updatedAt: now, // Mesmo timestamp!
      );

      // UnifiedSyncManager resolve por version ou outro critério
      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act - Ambos sincronizam
      await vehicleRepository.updateVehicle(vehicleA);
      await vehicleRepository.updateVehicle(vehicleB);

      // Assert - Conflict resolution handled by USM
      verify(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .called(2);
    });

    test('should handle future timestamps (clock skew)', () async {
      // Arrange - Device com relógio adiantado
      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final vehicle = SyncTestFixtures.createVehicle(
        createdAt: futureDate,
        updatedAt: futureDate,
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act - Aceita timestamp futuro (será corrigido pelo servidor)
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle very old timestamps', () async {
      // Arrange - Registro muito antigo sendo sincronizado
      final veryOld = DateTime(2000, 1, 1);
      final vehicle = SyncTestFixtures.createVehicle(
        createdAt: veryOld,
        updatedAt: veryOld,
        isDirty: true,
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert - Aceita mesmo timestamp antigo
      expect(result.isRight(), true);
    });
  });

  group('Empty/Null Data Edge Cases', () {
    test('should handle empty lists in batch operations', () async {
      // Arrange - Lista vazia
      final emptyList = <VehicleEntity>[];

      // Act - Batch com lista vazia
      final results = await Future.wait(
        emptyList.map((v) => vehicleRepository.addVehicle(v)),
      );

      // Assert - Nenhuma operação executada
      expect(results.isEmpty, true);
      verifyNever(() => mockSyncManager.create<VehicleEntity>(any(), any()));
    });

    test('should handle null optional fields', () async {
      // Arrange - Entity com campos opcionais nulos
      final vehicle = SyncTestFixtures.createVehicle().copyWith(
        tankCapacity: null,
        engineSize: null,
        photoUrl: null,
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert - Aceita nulls em campos opcionais
      expect(result.isRight(), true);
    });

    test('should handle empty metadata maps', () async {
      // Arrange - Metadata vazio
      final vehicle = SyncTestFixtures.createVehicle().copyWith(
        metadata: {},
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle maintenance without next service date', () async {
      // Arrange - Manutenção sem agendamento futuro
      final maintenance = SyncTestFixtures.createMaintenance().copyWith(
        nextServiceDate: null,
        nextServiceOdometer: null,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      final result = await maintenanceRepository.addMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (created) {
          expect(created.hasNextService, false);
        },
      );
    });
  });

  group('Boundary Value Edge Cases', () {
    test('should handle zero odometer value', () async {
      // Arrange - Veículo novo com odômetro zerado
      final vehicle = SyncTestFixtures.createVehicle().copyWith(
        currentOdometer: 0.0,
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert - Aceita odômetro zero
      expect(result.isRight(), true);
    });

    test('should handle very large odometer values', () async {
      // Arrange - Veículo com muita quilometragem
      final vehicle = SyncTestFixtures.createVehicle().copyWith(
        currentOdometer: 999999.0,
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle very small fuel amounts', () async {
      // Arrange - Abastecimento pequeno (ex: moto)
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        liters: 0.5, // Meio litro
        pricePerLiter: 6.0,
      );

      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act
      final result = await fuelRepository.addFuelRecord(fuelRecord);

      // Assert - Aceita valores pequenos válidos
      expect(result.isRight(), true);
    });

    test('should handle very large fuel costs', () async {
      // Arrange - Abastecimento de caminhão (tanque grande)
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        liters: 500.0,
        pricePerLiter: 6.0,
      ); // R$ 3000

      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act
      final result = await fuelRepository.addFuelRecord(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (created) {
          expect(created.totalPrice, 3000.0);
        },
      );
    });

    test('should handle zero cost maintenance (warranty)', () async {
      // Arrange - Manutenção gratuita (garantia)
      final maintenance = SyncTestFixtures.createMaintenance().copyWith(
        cost: 0.0,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      final result = await maintenanceRepository.addMaintenanceRecord(maintenance);

      // Assert - Aceita custo zero
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (created) {
          expect(created.cost, 0.0);
          expect(created.isHighCost, false);
        },
      );
    });
  });

  group('Special Character Edge Cases', () {
    test('should handle special characters in vehicle name', () async {
      // Arrange - Nome com caracteres especiais
      final vehicle = SyncTestFixtures.createVehicle().copyWith(
        name: 'Meu Carro™ & Moto® (2024) 🚗',
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert - Aceita caracteres especiais
      expect(result.isRight(), true);
    });

    test('should handle unicode characters in maintenance notes', () async {
      // Arrange - Notas com emoji e outros idiomas
      final maintenance = SyncTestFixtures.createMaintenance().copyWith(
        notes: 'Troca de óleo ✓ • 日本語 • Français • Español 🔧',
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      final result = await maintenanceRepository.addMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle long text in notes field', () async {
      // Arrange - Texto muito longo
      final longText = 'A' * 10000; // 10k caracteres
      final maintenance = SyncTestFixtures.createMaintenance().copyWith(
        notes: longText,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      final result = await maintenanceRepository.addMaintenanceRecord(maintenance);

      // Assert - Aceita texto longo
      expect(result.isRight(), true);
    });
  });

  group('Rapid Sequential Operations', () {
    test('should handle rapid create-update-delete sequence', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle(id: 'vehicle_1');

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right('vehicle_1'));
      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));
      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act - Sequência rápida
      final createResult = await vehicleRepository.addVehicle(vehicle);
      expect(createResult.isRight(), true);

      final updateResult = await vehicleRepository.updateVehicle(
        vehicle.copyWith(name: 'Updated'),
      );
      expect(updateResult.isRight(), true);

      final deleteResult = await vehicleRepository.deleteVehicle(vehicle.id);
      expect(deleteResult.isRight(), true);

      // Assert - Todas operações completaram
      verify(() => mockSyncManager.create<VehicleEntity>(any(), any())).called(1);
      verify(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .called(1);
      verify(() => mockSyncManager.delete<VehicleEntity>(any(), any())).called(1);
    });

    test('should handle multiple updates in quick succession', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle(id: 'vehicle_1');

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act - 10 updates rápidos
      final results = await Future.wait(
        List.generate(
          10,
          (i) => vehicleRepository.updateVehicle(
            vehicle.copyWith(name: 'Update $i'),
          ),
        ),
      );

      // Assert - Todos processados
      expect(results.every((r) => r.isRight()), true);
      expect(results.length, 10);
    });
  });

  group('Version Rollover Edge Cases', () {
    test('should handle very large version numbers', () async {
      // Arrange - Entity com versão muito alta
      final vehicle = SyncTestFixtures.createVehicle().copyWith(
        version: 999999,
      );

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await vehicleRepository.updateVehicle(vehicle);

      // Assert - Incrementa normalmente
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.version, 1000000);
        },
      );
    });

    test('should handle version reset after re-creation', () async {
      // Arrange - Delete e recria mesma entidade
      const vehicleId = 'vehicle_1';

      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Delete
      await vehicleRepository.deleteVehicle(vehicleId);

      // Recria com version 1
      final newVehicle = SyncTestFixtures.createVehicle(
        id: vehicleId,
        version: 1,
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(vehicleId));

      // Act
      final result = await vehicleRepository.addVehicle(newVehicle);

      // Assert - Version resetada
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (created) {
          expect(created.version, 1);
        },
      );
    });
  });
}
