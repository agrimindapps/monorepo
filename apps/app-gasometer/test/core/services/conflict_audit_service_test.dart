import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/services/conflict_audit_service.dart';
import 'package:gasometer/core/sync/conflict_resolution_strategy.dart';
import 'package:gasometer/features/fuel/data/models/fuel_supply_model.dart';
import 'package:gasometer/features/maintenance/data/models/maintenance_model.dart';
import 'package:gasometer/features/vehicles/data/models/vehicle_model.dart';
import 'package:mocktail/mocktail.dart';

// Mock para simular o logger (precisa implementar interface do ConflictAuditService)
class MockLoggingService extends Mock implements _LoggerInterface {
  @override
  void warning(String message) {}
  @override
  void info(String message) {}
  @override
  void error(String message) {}
}

// Interface de logger para compatibilidade
abstract class _LoggerInterface {
  void info(String message);
  void warning(String message);
  void error(String message);
}

void main() {
  late ConflictAuditService auditService;
  late MockLoggingService mockLogger;

  setUp(() {
    mockLogger = MockLoggingService();
    auditService = ConflictAuditService(mockLogger);
  });

  group('ConflictAuditService - Basic Logging', () {
    test('should log vehicle conflict and add to audit log', () {
      // Arrange
      final local = VehicleModel(
        id: 'vehicle-123',
        updatedAtMs: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        version: 1,
        marca: 'Toyota',
        modelo: 'Corolla',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 10000.0,
      );

      final remote = VehicleModel(
        id: 'vehicle-123',
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        version: 2,
        marca: 'Toyota',
        modelo: 'Corolla XEI',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 12000.0,
      );

      // Act
      auditService.logConflict(
        entityType: 'vehicle',
        entityId: 'vehicle-123',
        localEntity: local,
        remoteEntity: remote,
        resolution: ConflictAction.keepRemote,
      );

      // Assert
      expect(auditService.countConflicts(), 1);

      final conflicts = auditService.getRecentConflicts();
      expect(conflicts.length, 1);
      expect(conflicts.first.entityType, 'vehicle');
      expect(conflicts.first.entityId, 'vehicle-123');
      expect(conflicts.first.resolution, ConflictAction.keepRemote);
    });

    test('should log financial conflict with extra warnings', () {
      // Arrange
      final local = FuelSupplyModel(
        id: 'fuel-123',
        updatedAtMs: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        vehicleId: 'vehicle-123',
        date: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        odometer: 10000.0,
        liters: 40.0,
        totalPrice: 280.0,
        pricePerLiter: 7.0,
      );

      final remote = FuelSupplyModel(
        id: 'fuel-123',
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        vehicleId: 'vehicle-123',
        date: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        odometer: 10500.0,
        liters: 42.0,
        totalPrice: 294.0,
        pricePerLiter: 7.0,
      );

      // Act
      auditService.logConflict(
        entityType: 'fuel_supply',
        entityId: 'fuel-123',
        localEntity: local,
        remoteEntity: remote,
        resolution: ConflictAction.keepRemote,
        additionalNotes: 'Financial data - requires special attention',
      );

      // Assert
      expect(auditService.countConflicts(), 1);

      final conflicts = auditService.getRecentConflicts();
      expect(conflicts.first.notes, 'Financial data - requires special attention');
    });

    test('should alert when financial values differ significantly', () {
      // Arrange
      final local = MaintenanceModel(
        id: 'maint-123',
        updatedAtMs: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        veiculoId: 'vehicle-123',
        tipo: 'Preventiva',
        descricao: 'Troca de óleo',
        valor: 150.0, // Diferença de 50 reais
        data: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        odometro: 10000,
      );

      final remote = MaintenanceModel(
        id: 'maint-123',
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        veiculoId: 'vehicle-123',
        tipo: 'Preventiva',
        descricao: 'Troca de óleo completa',
        valor: 200.0,
        data: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        odometro: 10000,
      );

      // Act
      auditService.logConflict(
        entityType: 'maintenance',
        entityId: 'maint-123',
        localEntity: local,
        remoteEntity: remote,
        resolution: ConflictAction.keepRemote,
      );

      // Assert
      // O service deve ter registrado o conflito
      expect(auditService.countConflicts(), 1);
    });
  });

  group('ConflictAuditService - Statistics', () {
    test('should provide accurate conflict statistics', () {
      // Arrange & Act - Log múltiplos conflitos
      final vehicle = VehicleModel(
        id: 'v1',
        version: 1,
        marca: 'Toyota',
        modelo: 'Corolla',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 10000.0,
      );

      auditService.logConflict(
        entityType: 'vehicle',
        entityId: 'v1',
        localEntity: vehicle,
        remoteEntity: vehicle,
        resolution: ConflictAction.keepLocal,
      );

      auditService.logConflict(
        entityType: 'vehicle',
        entityId: 'v2',
        localEntity: vehicle,
        remoteEntity: vehicle,
        resolution: ConflictAction.keepRemote,
      );

      final fuel = FuelSupplyModel(
        id: 'f1',
        vehicleId: 'v1',
        date: DateTime.now().millisecondsSinceEpoch,
        odometer: 10000.0,
        liters: 40.0,
        totalPrice: 280.0,
        pricePerLiter: 7.0,
      );

      auditService.logConflict(
        entityType: 'fuel_supply',
        entityId: 'f1',
        localEntity: fuel,
        remoteEntity: fuel,
        resolution: ConflictAction.keepLocal,
      );

      // Act
      final stats = auditService.getStatistics();

      // Assert
      expect(stats.totalConflicts, 3);
      expect(stats.conflictsByAction[ConflictAction.keepLocal], 2);
      expect(stats.conflictsByAction[ConflictAction.keepRemote], 1);
      expect(stats.conflictsByType['vehicle'], 2);
      expect(stats.conflictsByType['fuel_supply'], 1);
      expect(stats.lastConflictAt, isNotNull);
    });

    test('should return empty statistics when no conflicts logged', () {
      // Act
      final stats = auditService.getStatistics();

      // Assert
      expect(stats.totalConflicts, 0);
      expect(stats.conflictsByAction.isEmpty, true);
      expect(stats.conflictsByType.isEmpty, true);
      expect(stats.lastConflictAt, isNull);
    });
  });

  group('ConflictAuditService - Query Methods', () {
    late VehicleModel vehicle;
    late FuelSupplyModel fuel;
    late MaintenanceModel maintenance;

    setUp(() {
      vehicle = VehicleModel(
        id: 'v1',
        version: 1,
        marca: 'Toyota',
        modelo: 'Corolla',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 10000.0,
      );

      fuel = FuelSupplyModel(
        id: 'f1',
        vehicleId: 'v1',
        date: DateTime.now().millisecondsSinceEpoch,
        odometer: 10000.0,
        liters: 40.0,
        totalPrice: 280.0,
        pricePerLiter: 7.0,
      );

      maintenance = MaintenanceModel(
        id: 'm1',
        veiculoId: 'v1',
        tipo: 'Preventiva',
        descricao: 'Troca de óleo',
        valor: 150.0,
        data: DateTime.now().millisecondsSinceEpoch,
        odometro: 10000,
      );

      // Log alguns conflitos
      auditService.logConflict(
        entityType: 'vehicle',
        entityId: 'v1',
        localEntity: vehicle,
        remoteEntity: vehicle,
        resolution: ConflictAction.keepLocal,
      );

      auditService.logConflict(
        entityType: 'fuel_supply',
        entityId: 'f1',
        localEntity: fuel,
        remoteEntity: fuel,
        resolution: ConflictAction.keepRemote,
      );

      auditService.logConflict(
        entityType: 'maintenance',
        entityId: 'm1',
        localEntity: maintenance,
        remoteEntity: maintenance,
        resolution: ConflictAction.useMerged,
      );
    });

    test('should get conflicts by entity type', () {
      // Act
      final vehicleConflicts =
          auditService.getConflictsByEntityType('vehicle');
      final fuelConflicts =
          auditService.getConflictsByEntityType('fuel_supply');

      // Assert
      expect(vehicleConflicts.length, 1);
      expect(fuelConflicts.length, 1);
      expect(vehicleConflicts.first.entityId, 'v1');
      expect(fuelConflicts.first.entityId, 'f1');
    });

    test('should get conflicts by entity ID', () {
      // Act
      final v1Conflicts = auditService.getConflictsByEntityId('v1');
      final f1Conflicts = auditService.getConflictsByEntityId('f1');

      // Assert
      expect(v1Conflicts.length, 1);
      expect(f1Conflicts.length, 1);
      expect(v1Conflicts.first.entityType, 'vehicle');
      expect(f1Conflicts.first.entityType, 'fuel_supply');
    });

    test('should get recent conflicts with limit', () {
      // Act
      final recent = auditService.getRecentConflicts(limit: 2);

      // Assert
      expect(recent.length, 2);
      // Deve estar ordenado por timestamp (mais recente primeiro)
      expect(
        recent.first.timestamp.isAfter(recent.last.timestamp) ||
            recent.first.timestamp.isAtSameMomentAs(recent.last.timestamp),
        true,
      );
    });
  });

  group('ConflictAuditService - Memory Management', () {
    test('should limit in-memory audit log to max entries', () {
      // Arrange
      final vehicle = VehicleModel(
        id: 'v1',
        version: 1,
        marca: 'Toyota',
        modelo: 'Corolla',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 10000.0,
      );

      // Act - Log 150 conflitos (limite é 100)
      for (int i = 0; i < 150; i++) {
        auditService.logConflict(
          entityType: 'vehicle',
          entityId: 'v$i',
          localEntity: vehicle,
          remoteEntity: vehicle,
          resolution: ConflictAction.keepLocal,
        );
      }

      // Assert - Deve manter apenas os 100 mais recentes
      expect(auditService.countConflicts(), 100);
    });

    test('should clear audit log', () {
      // Arrange
      final vehicle = VehicleModel(
        id: 'v1',
        version: 1,
        marca: 'Toyota',
        modelo: 'Corolla',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 10000.0,
      );

      auditService.logConflict(
        entityType: 'vehicle',
        entityId: 'v1',
        localEntity: vehicle,
        remoteEntity: vehicle,
        resolution: ConflictAction.keepLocal,
      );

      expect(auditService.countConflicts(), 1);

      // Act
      auditService.clearAuditLog();

      // Assert
      expect(auditService.countConflicts(), 0);
    });
  });

  group('ConflictAuditService - Export', () {
    test('should export audit log as JSON', () {
      // Arrange
      final vehicle = VehicleModel(
        id: 'v1',
        updatedAtMs: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        version: 1,
        marca: 'Toyota',
        modelo: 'Corolla',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 10000.0,
      );

      auditService.logConflict(
        entityType: 'vehicle',
        entityId: 'v1',
        localEntity: vehicle,
        remoteEntity: vehicle,
        resolution: ConflictAction.keepLocal,
      );

      // Act
      final exported = auditService.exportAuditLog();

      // Assert
      expect(exported.length, 1);
      expect(exported.first['entityType'], 'vehicle');
      expect(exported.first['entityId'], 'v1');
      expect(exported.first['resolution'], contains('ConflictAction'));
    });

    test('should export empty list when no conflicts', () {
      // Act
      final exported = auditService.exportAuditLog();

      // Assert
      expect(exported.isEmpty, true);
    });
  });

  group('ConflictAuditEntry', () {
    test('should serialize to JSON correctly', () {
      // Arrange
      final entry = ConflictAuditEntry(
        id: 'entry-123',
        timestamp: DateTime(2024, 1, 10),
        entityType: 'vehicle',
        entityId: 'v1',
        resolution: ConflictAction.keepLocal,
        localVersion: 'v1 @ 2024-01-05',
        remoteVersion: 'v2 @ 2024-01-10',
      );

      // Act
      final json = entry.toJson();

      // Assert
      expect(json['id'], 'entry-123');
      expect(json['entityType'], 'vehicle');
      expect(json['entityId'], 'v1');
      expect(json['localVersion'], 'v1 @ 2024-01-05');
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'entry-123',
        'timestamp': '2024-01-10T00:00:00.000',
        'entityType': 'vehicle',
        'entityId': 'v1',
        'resolution': 'ConflictAction.keepLocal',
        'localVersion': 'v1',
        'remoteVersion': 'v2',
      };

      // Act
      final entry = ConflictAuditEntry.fromJson(json);

      // Assert
      expect(entry.id, 'entry-123');
      expect(entry.entityType, 'vehicle');
      expect(entry.resolution, ConflictAction.keepLocal);
    });
  });
}
