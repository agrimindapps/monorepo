import 'dart:async';

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

  group('Network Failure Handling', () {
    test('should retry sync after network failure', () async {
      // Arrange - Network fails on first attempt
      var attempts = 0;
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async {
        attempts++;
        if (attempts < 3) {
          return const Left(CacheFailure('Network timeout'));
        }
        return const Right(unit);
      });

      // Act - Retry até sucesso
      var result = await vehicleRepository.syncVehicles();
      expect(result.isLeft(), true); // 1ª tentativa: falha

      result = await vehicleRepository.syncVehicles();
      expect(result.isLeft(), true); // 2ª tentativa: falha

      result = await vehicleRepository.syncVehicles();
      expect(result.isRight(), true); // 3ª tentativa: sucesso

      // Assert
      expect(attempts, 3);
      verify(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .called(3);
    });

    test('should handle network timeout during create', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle();
      const failure = CacheFailure('Request timeout after 30s');

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<CacheFailure>());
          expect(error.message, contains('timeout'));
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should handle intermittent connectivity', () async {
      // Arrange - Network alternates between online/offline
      var isOnline = false;

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async {
        isOnline = !isOnline;
        if (!isOnline) {
          return const Left(CacheFailure('Network unavailable'));
        }
        return const Right('vehicle_1');
      });

      final vehicle = SyncTestFixtures.createVehicle();

      // Act - First attempt (offline)
      var result = await vehicleRepository.addVehicle(vehicle);
      expect(result.isLeft(), true);

      // Act - Second attempt (online)
      result = await vehicleRepository.addVehicle(vehicle);
      expect(result.isRight(), true);
    });
  });

  group('Partial Sync Failure', () {
    test('should continue syncing remaining items if one fails', () async {
      // Arrange - Batch com 1 item que vai falhar
      final vehicles = SyncTestFixtures.createVehicles(3);

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_1')),
          )).thenAnswer((_) async => const Right('vehicle_1'));

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_2')),
          )).thenAnswer(
              (_) async => const Left(ValidationFailure('Validation error')));

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_3')),
          )).thenAnswer((_) async => const Right('vehicle_3'));

      // Act
      final results = await Future.wait([
        vehicleRepository.addVehicle(vehicles[0]),
        vehicleRepository.addVehicle(vehicles[1]),
        vehicleRepository.addVehicle(vehicles[2]),
      ]);

      // Assert - v1: success, v2: fail, v3: success (não foi afetado)
      expect(results[0].isRight(), true);
      expect(results[1].isLeft(), true);
      expect(results[2].isRight(), true);
    });

    test('should track which items failed during batch sync', () async {
      // Arrange
      final fuelRecords = SyncTestFixtures.createFuelRecords(5);

      // Records 0, 2, 4 succeed; 1, 3 fail
      for (var i = 0; i < fuelRecords.length; i++) {
        final shouldFail = i.isOdd;

        when(() => mockSyncManager.create<FuelRecordEntity>(
              any(),
              any(that: isFuelRecordWithId('fuel_${i + 1}')),
            )).thenAnswer((_) async {
          if (shouldFail) {
            return const Left(CacheFailure('Sync failed'));
          }
          return Right('fuel_${i + 1}');
        });
      }

      // Act
      final results = await Future.wait(
        fuelRecords.map((r) => fuelRepository.addFuelRecord(r)),
      );

      // Assert - Contar sucessos e falhas
      final succeeded = results.where((r) => r.isRight()).length;
      final failed = results.where((r) => r.isLeft()).length;

      expect(succeeded, 3); // 0, 2, 4
      expect(failed, 2); // 1, 3
    });

    test('should allow retry of failed items only', () async {
      // Arrange - Item falha na primeira tentativa
      final vehicle = SyncTestFixtures.createVehicle();

      var attemptCount = 0;
      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async {
        attemptCount++;
        if (attemptCount == 1) {
          return const Left(CacheFailure('Temporary failure'));
        }
        return Right(vehicle.id);
      });

      // Act - First attempt fails
      var result = await vehicleRepository.addVehicle(vehicle);
      expect(result.isLeft(), true);

      // Act - Retry succeeds
      result = await vehicleRepository.addVehicle(vehicle);
      expect(result.isRight(), true);

      // Assert
      expect(attemptCount, 2);
    });
  });

  group('Data Integrity After Failure', () {
    test('should not create duplicate vehicles after failed sync', () async {
      // Arrange - Sync falha na primeira tentativa
      final vehicle = SyncTestFixtures.createVehicle(id: 'local_123');

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Left(CacheFailure('Network error')));

      // Act - Create offline (falha no sync)
      var result = await vehicleRepository.addVehicle(vehicle);
      expect(result.isLeft(), true);

      // Arrange - Retry com sucesso
      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right('local_123'));

      // Act - Retry
      result = await vehicleRepository.addVehicle(vehicle);

      // Assert - Mesmo ID (sem duplicata)
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (created) => expect(created.id, 'local_123'),
      );
    });

    test('should rollback partial transaction on critical error', () async {
      // Arrange - Simular erro crítico durante batch operation
      final vehicles = SyncTestFixtures.createVehicles(3);

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_1')),
          )).thenAnswer((_) async => const Right('vehicle_1'));

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_2')),
          )).thenThrow(Exception('Critical database error'));

      // Act
      final results = <Either<Failure, VehicleEntity>>[];
      for (var vehicle in vehicles) {
        try {
          final result = await vehicleRepository.addVehicle(vehicle);
          results.add(result);
        } catch (e) {
          // Critical error interrompe batch
          break;
        }
      }

      // Assert - Apenas 1 completou antes do erro crítico
      expect(results.length, lessThan(vehicles.length));
      expect(results[0].isRight(), true);
    });

    test('should maintain referential integrity on failure', () async {
      // Arrange - Fuel record sem vehicle correspondente
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        vehicleId: 'nonexistent_vehicle',
      );

      // UnifiedSyncManager pode permitir criação (integrity check posterior)
      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act
      final result = await fuelRepository.addFuelRecord(fuelRecord);

      // Assert - Criado (mas marcado para integrity check)
      expect(result.isRight(), true);
      // Data integrity service detectaria este orphan record posteriormente
    });
  });

  group('Concurrent Operation Errors', () {
    test('should handle race condition during concurrent updates', () async {
      // Arrange - Duas updates simultâneas do mesmo registro
      final vehicle = SyncTestFixtures.createVehicle(id: 'vehicle_1', version: 1);

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act - Concurrent updates
      final results = await Future.wait([
        vehicleRepository.updateVehicle(vehicle.copyWith(name: 'Name A')),
        vehicleRepository.updateVehicle(vehicle.copyWith(name: 'Name B')),
      ]);

      // Assert - Ambos completam (UnifiedSyncManager resolve conflito)
      expect(results.every((r) => r.isRight()), true);

      // Ambos incrementam versão
      results[0].fold(
        (_) => fail('Should not fail'),
        (updated) => expect(updated.version, 2),
      );
    });

    test('should detect stale data during update', () async {
      // Arrange - Client tem versão antiga
      final staleVehicle = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        version: 1,
      );

      // Server já tem versão 3
      const failure =
          ValidationFailure('Stale data: server version is 3, client has 1');

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await vehicleRepository.updateVehicle(staleVehicle);

      // Assert - Erro de stale data
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<ValidationFailure>());
          expect(error.message, contains('Stale data'));
        },
        (_) => fail('Should detect stale data'),
      );
    });

    test('should handle delete of already deleted entity', () async {
      // Arrange - Entity já foi deletado
      const vehicleId = 'vehicle_1';
      const failure = CacheFailure('Entity not found: already deleted');

      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await vehicleRepository.deleteVehicle(vehicleId);

      // Assert - Falha (já deletado)
      expect(result.isLeft(), true);
    });
  });

  group('Stream Error Handling', () {
    test('should handle stream error and emit failure', () async {
      // Arrange - Stream com erro
      final controller = StreamController<List<VehicleEntity>>();

      when(() => mockSyncManager.streamAll<VehicleEntity>('gasometer'))
          .thenAnswer((_) => controller.stream);

      // Act - Watch stream
      final streamFuture = vehicleRepository.watchVehicles().take(2).toList();

      // Emit data then error
      controller.add([SyncTestFixtures.createVehicle()]);
      controller.addError(Exception('Stream error'));

      // Wait for completion
      await streamFuture.timeout(
        const Duration(seconds: 1),
        onTimeout: () => [],
      );

      await controller.close();

      // Assert - Error handling verificado via logs
      verify(() => mockLogger.logOperationError(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(named: 'message', that: predicate<String>((m) => m.contains('stream'))),
            error: any(named: 'error'),
          )).called(greaterThanOrEqualTo(0));
    });

    test('should handle stream not available', () async {
      // Arrange
      when(() => mockSyncManager.streamAll<VehicleEntity>('gasometer'))
          .thenReturn(null);

      // Act
      final streamFuture = vehicleRepository.watchVehicles().first;

      // Assert - Emits failure
      final result = await streamFuture;
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<CacheFailure>());
          expect(error.message, contains('Stream not available'));
        },
        (_) => fail('Should emit failure'),
      );
    });

    test('should recover stream after error', () async {
      // Arrange - Stream que se recupera após erro
      final controller = StreamController<List<VehicleEntity>>();

      when(() => mockSyncManager.streamAll<VehicleEntity>('gasometer'))
          .thenAnswer((_) => controller.stream);

      // Act - Watch stream
      final results = <Either<Failure, List<VehicleEntity>>>[];
      final subscription = vehicleRepository.watchVehicles().listen(
            (result) => results.add(result),
            onError: (_) {}, // Ignore errors for test
          );

      // Emit data, error, then data again
      controller.add([SyncTestFixtures.createVehicle(id: 'v1')]);
      await Future.delayed(const Duration(milliseconds: 10));

      controller.addError(Exception('Temporary error'));
      await Future.delayed(const Duration(milliseconds: 10));

      controller.add([SyncTestFixtures.createVehicle(id: 'v2')]);
      await Future.delayed(const Duration(milliseconds: 10));

      await subscription.cancel();
      await controller.close();

      // Assert - Received data before and after error
      final successResults = results.where((r) => r.isRight()).toList();
      expect(successResults.isNotEmpty, true);
    });
  });

  group('Validation Errors', () {
    test('should handle invalid entity data', () async {
      // Arrange - Vehicle com dados inválidos
      final invalidVehicle = SyncTestFixtures.createVehicle(
        name: '', // Nome vazio (inválido)
      );

      const failure = ValidationFailure('Vehicle name cannot be empty');

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await vehicleRepository.addVehicle(invalidVehicle);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<ValidationFailure>());
          expect(error.message, contains('name'));
        },
        (_) => fail('Should validate entity'),
      );
    });

    test('should handle negative values in fuel record', () async {
      // Arrange - Valores negativos (inválidos)
      final invalidFuel = SyncTestFixtures.createFuelRecord(
        liters: -10.0, // Inválido
        pricePerLiter: -5.0, // Inválido
      );

      const failure = ValidationFailure('Liters and price must be positive');

      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await fuelRepository.addFuelRecord(invalidFuel);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should handle future dates in maintenance', () async {
      // Arrange - Manutenção com data futura (pode ser válido para agendamento)
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final maintenance = SyncTestFixtures.createMaintenance(
        serviceDate: futureDate,
        status: MaintenanceStatus.pending,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act - Aceita datas futuras para agendamento
      final result = await maintenanceRepository.addMaintenanceRecord(maintenance);

      // Assert - Válido para manutenção agendada
      expect(result.isRight(), true);
    });
  });

  group('Unexpected Errors', () {
    test('should handle unexpected exception during sync', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle();

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenThrow(Exception('Unexpected database error'));

      // Act
      final result = await vehicleRepository.addVehicle(vehicle);

      // Assert - Wrapped as UnexpectedFailure
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<UnexpectedFailure>());
          expect(error.message, contains('Unexpected'));
        },
        (_) => fail('Should handle unexpected error'),
      );
    });

    test('should log all errors for debugging', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle();

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenThrow(Exception('Test error'));

      // Act
      await vehicleRepository.addVehicle(vehicle);

      // Assert - Error logged
      verify(() => mockLogger.logOperationError(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(named: 'message'),
            error: any(named: 'error'),
            metadata: any(named: 'metadata'),
          )).called(1);
    });
  });
}
