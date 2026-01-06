import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/odometer/domain/entities/odometer_entity.dart';

void main() {
  group('OdometerEntity', () {
    final testOdometer = OdometerEntity(
      id: 'test-id',
      vehicleId: 'vehicle-001',
      value: 15000.0,
      registrationDate: DateTime(2024, 1, 15),
      description: 'Registro inicial',
      type: OdometerType.trip,
      metadata: const {'source': 'manual'},
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
      userId: 'user-001',
      moduleName: 'gasometer',
    );

    test('should create odometer entity with all fields', () {
      expect(testOdometer.id, 'test-id');
      expect(testOdometer.vehicleId, 'vehicle-001');
      expect(testOdometer.value, 15000.0);
      expect(testOdometer.registrationDate, DateTime(2024, 1, 15));
      expect(testOdometer.description, 'Registro inicial');
      expect(testOdometer.type, OdometerType.trip);
      expect(testOdometer.metadata['source'], 'manual');
    });

    test('should copy with new values', () {
      final updated = testOdometer.copyWith(
        value: 20000.0,
        description: 'Registro atualizado',
      );

      expect(updated.value, 20000.0);
      expect(updated.description, 'Registro atualizado');
      expect(updated.vehicleId, 'vehicle-001'); // unchanged
    });

    test('should mark as dirty', () {
      final dirty = testOdometer.markAsDirty();
      
      expect(dirty.isDirty, true);
      expect(dirty.version, testOdometer.version + 1);
    });

    test('should mark as synced', () {
      final synced = testOdometer.markAsSynced();
      
      expect(synced.isDirty, false);
      expect(synced.lastSyncAt, isNotNull);
    });

    test('should mark as deleted', () {
      final deleted = testOdometer.markAsDeleted();
      
      expect(deleted.isDeleted, true);
      expect(deleted.version, testOdometer.version + 1);
    });

    test('should increment version', () {
      final incremented = testOdometer.incrementVersion();
      
      expect(incremented.version, testOdometer.version + 1);
    });

    test('should convert to map', () {
      final map = testOdometer.toMap();
      
      expect(map['id'], 'test-id');
      expect(map['vehicleId'], 'vehicle-001');
      expect(map['value'], 15000.0);
      expect(map['type'], 'trip');
      expect(map['description'], 'Registro inicial');
    });

    test('should create from map', () {
      final map = {
        'id': 'test-id',
        'vehicleId': 'vehicle-001',
        'value': 15000.0,
        'registrationDate': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'description': 'Test',
        'type': 'trip',
        'metadata': {'key': 'value'},
        'createdAt': DateTime(2024, 1, 1).millisecondsSinceEpoch,
        'updatedAt': DateTime(2024, 1, 1).millisecondsSinceEpoch,
        'isDirty': false,
        'isDeleted': false,
        'version': 1,
        'userId': 'user-001',
      };

      final odometer = OdometerEntity.fromMap(map);
      
      expect(odometer.id, 'test-id');
      expect(odometer.vehicleId, 'vehicle-001');
      expect(odometer.value, 15000.0);
      expect(odometer.type, OdometerType.trip);
    });

    test('should convert to Firebase map', () {
      final map = testOdometer.toFirebaseMap();
      
      expect(map['vehicleId'], 'vehicle-001');
      expect(map['value'], 15000.0);
      expect(map['type'], 'trip');
      expect(map['description'], 'Registro inicial');
      expect(map['metadata'], {'source': 'manual'});
    });

    test('should create from Firebase map', () {
      final map = {
        'id': 'test-id',
        'vehicleId': 'vehicle-001',
        'value': 15000.0,
        'registrationDate': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'description': 'Test',
        'type': 'trip',
        'metadata': {'key': 'value'},
        'user_id': 'user-001',
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
        'updated_at': DateTime(2024, 1, 1).toIso8601String(),
      };

      final odometer = OdometerEntity.fromFirebaseMap(map);
      
      expect(odometer.id, 'test-id');
      expect(odometer.vehicleId, 'vehicle-001');
      expect(odometer.value, 15000.0);
    });

    test('should handle snake_case fields in Firebase map', () {
      final map = {
        'id': 'test-id',
        'vehicle_id': 'vehicle-001',
        'value': 15000.0,
        'date': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'notes': 'Test notes',
        'type': 'fueling',
        'user_id': 'user-001',
      };

      final odometer = OdometerEntity.fromFirebaseMap(map);
      
      expect(odometer.vehicleId, 'vehicle-001');
      expect(odometer.description, 'Test notes');
      expect(odometer.type, OdometerType.fueling);
    });

    test('should handle alternative reading field in Firebase map', () {
      final map = {
        'id': 'test-id',
        'vehicleId': 'vehicle-001',
        'reading': 18000.0, // alternative field name
        'registrationDate': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'type': 'trip',
        'user_id': 'user-001',
      };

      final odometer = OdometerEntity.fromFirebaseMap(map);
      
      expect(odometer.value, 18000.0);
    });

    test('should handle string value in Firebase map', () {
      final map = {
        'id': 'test-id',
        'vehicleId': 'vehicle-001',
        'value': '20000.5',
        'registrationDate': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'type': 'trip',
        'user_id': 'user-001',
      };

      final odometer = OdometerEntity.fromFirebaseMap(map);
      
      expect(odometer.value, 20000.5);
    });

    test('should handle missing optional fields', () {
      final map = {
        'id': 'test-id',
        'vehicleId': 'vehicle-001',
        'value': 10000.0,
        'registrationDate': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'type': 'other',
        'user_id': 'user-001',
      };

      final odometer = OdometerEntity.fromFirebaseMap(map);
      
      expect(odometer.description, '');
      expect(odometer.metadata, isEmpty);
    });

    test('should use equality correctly', () {
      final odometer1 = testOdometer;
      final odometer2 = testOdometer.copyWith();
      final odometer3 = testOdometer.copyWith(value: 20000.0);

      expect(odometer1, equals(odometer2));
      expect(odometer1, isNot(equals(odometer3)));
    });

    test('should have correct toString representation', () {
      final str = testOdometer.toString();
      
      expect(str, contains('OdometerEntity'));
      expect(str, contains('test-id'));
      expect(str, contains('vehicle-001'));
      expect(str, contains('15000.0'));
    });
  });

  group('OdometerType', () {
    test('should have correct display names', () {
      expect(OdometerType.trip.displayName, 'Viagem');
      expect(OdometerType.leisure.displayName, 'Passeio');
      expect(OdometerType.maintenance.displayName, 'Manutenção');
      expect(OdometerType.fueling.displayName, 'Abastecimento');
      expect(OdometerType.other.displayName, 'Outros');
    });

    test('should have descriptions', () {
      expect(OdometerType.trip.description, isNotEmpty);
      expect(OdometerType.leisure.description, isNotEmpty);
      expect(OdometerType.maintenance.description, isNotEmpty);
    });

    test('should convert from string', () {
      expect(OdometerType.fromString('trip'), OdometerType.trip);
      expect(OdometerType.fromString('fueling'), OdometerType.fueling);
      expect(OdometerType.fromString('invalid'), OdometerType.other);
    });

    test('should return all types', () {
      final types = OdometerType.allTypes;
      expect(types.length, 5);
      expect(types, contains(OdometerType.trip));
      expect(types, contains(OdometerType.other));
    });

    test('should return all display names', () {
      final names = OdometerType.displayNames;
      expect(names.length, 5);
      expect(names, contains('Viagem'));
      expect(names, contains('Abastecimento'));
    });
  });
}
