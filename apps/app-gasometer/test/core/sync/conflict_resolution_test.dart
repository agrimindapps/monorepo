import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/sync/conflict_resolution_strategy.dart';
import 'package:gasometer/features/fuel/data/models/fuel_supply_model.dart';
import 'package:gasometer/features/maintenance/data/models/maintenance_model.dart';
import 'package:gasometer/features/vehicles/data/models/vehicle_model.dart';

void main() {
  group('VehicleConflictResolver', () {
    late VehicleConflictResolver resolver;

    setUp(() {
      resolver = VehicleConflictResolver();
    });

    test('should keep remote when remote version is higher', () {
      // Arrange
      final local = VehicleModel(
        id: 'vehicle-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
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
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        version: 2, // Versão maior
        marca: 'Toyota',
        modelo: 'Corolla XEI',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 12000.0,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.keepRemote);
      expect(resolution.remoteEntity, remote);
      expect(resolution.resolvedEntity.modelo, 'Corolla XEI');
      expect(resolution.resolvedEntity.version, 2);
    });

    test('should keep local when local version is higher', () {
      // Arrange
      final local = VehicleModel(
        id: 'vehicle-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        version: 3, // Versão maior
        marca: 'Toyota',
        modelo: 'Corolla Cross',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 15000.0,
      );

      final remote = VehicleModel(
        id: 'vehicle-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        version: 2,
        marca: 'Toyota',
        modelo: 'Corolla',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 12000.0,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.keepLocal);
      expect(resolution.localEntity, local);
      expect(resolution.resolvedEntity.modelo, 'Corolla Cross');
      expect(resolution.resolvedEntity.version, 3);
    });

    test('should merge when versions are equal but data differs', () {
      // Arrange
      final local = VehicleModel(
        id: 'vehicle-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        version: 2,
        marca: 'Toyota',
        modelo: 'Corolla Local',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 10000.0, // Menor
        valorVenda: 50000.0,
      );

      final remote = VehicleModel(
        id: 'vehicle-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch, // Mais recente
        version: 2,
        marca: 'Toyota',
        modelo: 'Corolla Remote',
        ano: 2020,
        placa: 'ABC-1234',
        odometroInicial: 5000.0,
        odometroAtual: 12000.0, // Maior
        valorVenda: 48000.0,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.useMerged);
      expect(resolution.mergedEntity, isNotNull);

      final merged = resolution.mergedEntity!;
      expect(merged.id, 'vehicle-123');
      // Modelo deve ser do remote (mais recente por updatedAt)
      expect(merged.modelo, 'Corolla Remote');
      // Odômetro deve ser o maior valor (nunca regride)
      expect(merged.odometroAtual, 12000.0);
      // Valor de venda deve ser o maior
      expect(merged.valorVenda, 50000.0);
      // Versão deve ser incrementada
      expect(merged.version, 3);
      // Deve estar marcado como dirty
      expect(merged.isDirty, true);
    });

    test('should use max odometer values in merge', () {
      // Arrange
      final local = VehicleModel(
        id: 'vehicle-123',
        version: 1,
        marca: 'Honda',
        modelo: 'Civic',
        ano: 2021,
        placa: 'XYZ-5678',
        odometroInicial: 8000.0, // Maior
        odometroAtual: 15000.0,
      );

      final remote = VehicleModel(
        id: 'vehicle-123',
        version: 1,
        marca: 'Honda',
        modelo: 'Civic',
        ano: 2021,
        placa: 'XYZ-5678',
        odometroInicial: 5000.0,
        odometroAtual: 20000.0, // Maior
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.useMerged);
      final merged = resolution.mergedEntity!;

      // Deve usar maior valor de odômetro inicial
      expect(merged.odometroInicial, 8000.0);
      // Deve usar maior valor de odômetro atual
      expect(merged.odometroAtual, 20000.0);
    });

    test('should mark vehicle as sold if either is sold', () {
      // Arrange
      final local = VehicleModel(
        id: 'vehicle-123',
        version: 1,
        marca: 'Ford',
        modelo: 'Ka',
        ano: 2019,
        placa: 'DEF-9012',
        odometroInicial: 10000.0,
        odometroAtual: 50000.0,
        vendido: false, // Não vendido
        valorVenda: 0.0,
      );

      final remote = VehicleModel(
        id: 'vehicle-123',
        version: 1,
        marca: 'Ford',
        modelo: 'Ka',
        ano: 2019,
        placa: 'DEF-9012',
        odometroInicial: 10000.0,
        odometroAtual: 50000.0,
        vendido: true, // Vendido
        valorVenda: 25000.0,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.useMerged);
      final merged = resolution.mergedEntity!;

      // Se um dispositivo marcou como vendido, considera vendido
      expect(merged.vendido, true);
      // Usa maior valor de venda
      expect(merged.valorVenda, 25000.0);
    });
  });

  group('FuelSupplyConflictResolver', () {
    late FuelSupplyConflictResolver resolver;

    setUp(() {
      resolver = FuelSupplyConflictResolver();
    });

    test('should keep remote when remote is more recent (last write wins)', () {
      // Arrange
      final local = FuelSupplyModel(
        id: 'fuel-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
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
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch, // Mais recente
        vehicleId: 'vehicle-123',
        date: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        odometer: 10500.0,
        liters: 42.0,
        totalPrice: 294.0,
        pricePerLiter: 7.0,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.keepRemote);
      expect(resolution.remoteEntity, remote);
      expect(resolution.resolvedEntity.totalPrice, 294.0);
      expect(resolution.resolvedEntity.liters, 42.0);
    });

    test('should keep local when local is more recent', () {
      // Arrange
      final local = FuelSupplyModel(
        id: 'fuel-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 15).millisecondsSinceEpoch, // Mais recente
        vehicleId: 'vehicle-123',
        date: DateTime(2024, 1, 15).millisecondsSinceEpoch,
        odometer: 11000.0,
        liters: 45.0,
        totalPrice: 315.0,
        pricePerLiter: 7.0,
      );

      final remote = FuelSupplyModel(
        id: 'fuel-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        vehicleId: 'vehicle-123',
        date: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        odometer: 10500.0,
        liters: 42.0,
        totalPrice: 294.0,
        pricePerLiter: 7.0,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.keepLocal);
      expect(resolution.localEntity, local);
      expect(resolution.resolvedEntity.totalPrice, 315.0);
      expect(resolution.resolvedEntity.liters, 45.0);
    });

    test('should handle equal timestamps (edge case)', () {
      // Arrange
      final timestamp = DateTime(2024, 1, 10).millisecondsSinceEpoch;

      final local = FuelSupplyModel(
        id: 'fuel-123',
        updatedAtMs: timestamp,
        vehicleId: 'vehicle-123',
        date: timestamp,
        odometer: 10000.0,
        liters: 40.0,
        totalPrice: 280.0,
        pricePerLiter: 7.0,
      );

      final remote = FuelSupplyModel(
        id: 'fuel-123',
        updatedAtMs: timestamp,
        vehicleId: 'vehicle-123',
        date: timestamp,
        odometer: 10000.0,
        liters: 40.0,
        totalPrice: 280.0,
        pricePerLiter: 7.0,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert - Deve manter local quando timestamps são iguais
      expect(resolution.action, ConflictAction.keepLocal);
    });
  });

  group('MaintenanceConflictResolver', () {
    late MaintenanceConflictResolver resolver;

    setUp(() {
      resolver = MaintenanceConflictResolver();
    });

    test('should keep remote when remote is more recent (last write wins)', () {
      // Arrange
      final local = MaintenanceModel(
        id: 'maint-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        veiculoId: 'vehicle-123',
        tipo: 'Preventiva',
        descricao: 'Troca de óleo',
        valor: 150.0,
        data: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        odometro: 10000,
      );

      final remote = MaintenanceModel(
        id: 'maint-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch, // Mais recente
        veiculoId: 'vehicle-123',
        tipo: 'Preventiva',
        descricao: 'Troca de óleo e filtro',
        valor: 200.0,
        data: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        odometro: 10000,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.keepRemote);
      expect(resolution.remoteEntity, remote);
      expect(resolution.resolvedEntity.valor, 200.0);
      expect(resolution.resolvedEntity.descricao, 'Troca de óleo e filtro');
    });

    test('should keep local when local is more recent', () {
      // Arrange
      final local = MaintenanceModel(
        id: 'maint-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 15).millisecondsSinceEpoch, // Mais recente
        veiculoId: 'vehicle-123',
        tipo: 'Corretiva',
        descricao: 'Troca de pneus',
        valor: 800.0,
        data: DateTime(2024, 1, 15).millisecondsSinceEpoch,
        odometro: 12000,
      );

      final remote = MaintenanceModel(
        id: 'maint-123',
        createdAtMs: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAtMs: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        veiculoId: 'vehicle-123',
        tipo: 'Preventiva',
        descricao: 'Troca de óleo',
        valor: 150.0,
        data: DateTime(2024, 1, 10).millisecondsSinceEpoch,
        odometro: 10000,
      );

      // Act
      final resolution = resolver.resolve(local, remote);

      // Assert
      expect(resolution.action, ConflictAction.keepLocal);
      expect(resolution.localEntity, local);
      expect(resolution.resolvedEntity.valor, 800.0);
      expect(resolution.resolvedEntity.descricao, 'Troca de pneus');
    });

    test('should handle missing timestamps (null safety)', () {
      // Arrange
      final local = MaintenanceModel(
        id: 'maint-123',
        updatedAtMs: null, // Sem timestamp
        veiculoId: 'vehicle-123',
        tipo: 'Preventiva',
        descricao: 'Troca de óleo',
        valor: 150.0,
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
      final resolution = resolver.resolve(local, remote);

      // Assert - Remoto deve ganhar pois tem timestamp válido
      expect(resolution.action, ConflictAction.keepRemote);
    });
  });

  group('ConflictResolverFactory', () {
    test('should return VehicleConflictResolver for VehicleModel type', () {
      // Act
      final resolver = ConflictResolverFactory.getResolver<VehicleModel>();

      // Assert
      expect(resolver, isA<VehicleConflictResolver>());
    });

    test('should return FuelSupplyConflictResolver for FuelSupplyModel type',
        () {
      // Act
      final resolver = ConflictResolverFactory.getResolver<FuelSupplyModel>();

      // Assert
      expect(resolver, isA<FuelSupplyConflictResolver>());
    });

    test(
        'should return MaintenanceConflictResolver for MaintenanceModel type',
        () {
      // Act
      final resolver = ConflictResolverFactory.getResolver<MaintenanceModel>();

      // Assert
      expect(resolver, isA<MaintenanceConflictResolver>());
    });

    test('should return null for unknown type', () {
      // Act - Testa com tipo que não tem resolver implementado
      // Não podemos usar String pois não extends BaseSyncModel
      // Este teste valida que getResolverByType retorna null para tipo desconhecido
      final resolver =
          ConflictResolverFactory.getResolverByType('unknown_entity');

      // Assert
      expect(resolver, isNull);
    });

    test('should return resolver by entity type string', () {
      // Act
      final vehicleResolver =
          ConflictResolverFactory.getResolverByType('vehicle');
      final fuelResolver =
          ConflictResolverFactory.getResolverByType('fuel_supply');
      final maintenanceResolver =
          ConflictResolverFactory.getResolverByType('maintenance');

      // Assert
      expect(vehicleResolver, isA<VehicleConflictResolver>());
      expect(fuelResolver, isA<FuelSupplyConflictResolver>());
      expect(maintenanceResolver, isA<MaintenanceConflictResolver>());
    });

    test('should return null for unknown entity type string', () {
      // Act
      final resolver =
          ConflictResolverFactory.getResolverByType('unknown_type');

      // Assert
      expect(resolver, isNull);
    });
  });
}
