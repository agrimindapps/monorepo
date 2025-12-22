import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/expenses/domain/entities/expense_entity.dart';

void main() {
  group('ExpenseEntity', () {
    final testExpense = ExpenseEntity(
      id: 'test-id',
      vehicleId: 'vehicle-001',
      type: ExpenseType.maintenance,
      description: 'Troca de óleo',
      amount: 150.50,
      date: DateTime(2024, 1, 15),
      odometer: 15000.0,
      receiptImagePath: '/path/to/receipt.jpg',
      location: 'Auto Center XYZ',
      notes: 'Óleo sintético 5W30',
      metadata: {'mechanic': 'João Silva'},
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
      userId: 'user-001',
      moduleName: 'gasometer',
    );

    test('should create expense entity with all fields', () {
      expect(testExpense.id, 'test-id');
      expect(testExpense.vehicleId, 'vehicle-001');
      expect(testExpense.type, ExpenseType.maintenance);
      expect(testExpense.description, 'Troca de óleo');
      expect(testExpense.amount, 150.50);
      expect(testExpense.odometer, 15000.0);
      expect(testExpense.receiptImagePath, '/path/to/receipt.jpg');
      expect(testExpense.location, 'Auto Center XYZ');
      expect(testExpense.notes, 'Óleo sintético 5W30');
    });

    test('should detect receipt presence', () {
      expect(testExpense.hasReceipt, true);
      
      final withoutReceipt = testExpense.copyWith(receiptImagePath: '');
      expect(withoutReceipt.hasReceipt, false);
    });

    test('should detect location presence', () {
      expect(testExpense.hasLocation, true);
      
      final withoutLocation = testExpense.copyWith(location: '');
      expect(withoutLocation.hasLocation, false);
    });

    test('should detect notes presence', () {
      expect(testExpense.hasNotes, true);
      
      final withoutNotes = testExpense.copyWith(notes: '');
      expect(withoutNotes.hasNotes, false);
    });

    test('should format amount as Brazilian currency', () {
      expect(testExpense.formattedAmount, 'R\$ 150,50');
    });

    test('should format odometer with km', () {
      expect(testExpense.formattedOdometer, '15000 km');
    });

    test('should identify high value expenses', () {
      final highValue = testExpense.copyWith(amount: 600.0);
      expect(highValue.isHighValue, true);
      expect(testExpense.isHighValue, false);
    });

    test('should identify recent expenses', () {
      final recent = testExpense.copyWith(date: DateTime.now());
      expect(recent.isRecent, true);
      expect(testExpense.isRecent, false);
    });

    test('should identify recurring expenses', () {
      final insurance = testExpense.copyWith(type: ExpenseType.insurance);
      expect(insurance.isRecurring, true);
      expect(testExpense.isRecurring, false);
    });

    test('should return title from description', () {
      expect(testExpense.title, 'Troca de óleo');
    });

    test('should return establishment name from location', () {
      expect(testExpense.establishmentName, 'Auto Center XYZ');
    });

    test('should copy with new values', () {
      final updated = testExpense.copyWith(
        description: 'Revisão completa',
        amount: 300.0,
      );

      expect(updated.description, 'Revisão completa');
      expect(updated.amount, 300.0);
      expect(updated.vehicleId, 'vehicle-001'); // unchanged
    });

    test('should mark as dirty', () {
      final dirty = testExpense.markAsDirty();
      
      expect(dirty.isDirty, true);
      expect(dirty.updatedAt!.isAfter(testExpense.updatedAt!), true);
    });

    test('should mark as synced', () {
      final synced = testExpense.markAsSynced();
      
      expect(synced.isDirty, false);
      expect(synced.lastSyncAt, isNotNull);
    });

    test('should mark as deleted', () {
      final deleted = testExpense.markAsDeleted();
      
      expect(deleted.isDeleted, true);
      expect(deleted.isDirty, true);
    });

    test('should increment version', () {
      final incremented = testExpense.incrementVersion();
      
      expect(incremented.version, testExpense.version + 1);
    });

    test('should convert to Firebase map', () {
      final map = testExpense.toFirebaseMap();
      
      expect(map['vehicle_id'], 'vehicle-001');
      expect(map['type'], 'maintenance');
      expect(map['description'], 'Troca de óleo');
      expect(map['amount'], 150.50);
      expect(map['odometer'], 15000.0);
      expect(map['receipt_image_path'], '/path/to/receipt.jpg');
      expect(map['location'], 'Auto Center XYZ');
      expect(map['notes'], 'Óleo sintético 5W30');
    });

    test('should create from Firebase map', () {
      final map = {
        'id': 'test-id',
        'vehicle_id': 'vehicle-001',
        'type': 'maintenance',
        'description': 'Troca de óleo',
        'amount': 150.50,
        'date': DateTime(2024, 1, 15).toIso8601String(),
        'odometer': 15000.0,
        'receipt_image_path': '/path/to/receipt.jpg',
        'location': 'Auto Center XYZ',
        'notes': 'Test notes',
        'metadata': {'key': 'value'},
        'user_id': 'user-001',
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
        'updated_at': DateTime(2024, 1, 1).toIso8601String(),
      };

      final expense = ExpenseEntity.fromFirebaseMap(map);
      
      expect(expense.id, 'test-id');
      expect(expense.vehicleId, 'vehicle-001');
      expect(expense.type, ExpenseType.maintenance);
      expect(expense.description, 'Troca de óleo');
      expect(expense.amount, 150.50);
    });

    test('should handle missing optional fields in Firebase map', () {
      final map = {
        'id': 'test-id',
        'vehicle_id': 'vehicle-001',
        'type': 'parking',
        'description': 'Estacionamento',
        'amount': 20.0,
        'date': DateTime(2024, 1, 15).toIso8601String(),
        'odometer': 5000.0,
        'user_id': 'user-001',
      };

      final expense = ExpenseEntity.fromFirebaseMap(map);
      
      expect(expense.receiptImagePath, isNull);
      expect(expense.location, isNull);
      expect(expense.notes, isNull);
      expect(expense.metadata, isEmpty);
    });

    test('should use equality correctly', () {
      final expense1 = testExpense;
      final expense2 = testExpense.copyWith();
      final expense3 = testExpense.copyWith(description: 'Different');

      expect(expense1, equals(expense2));
      expect(expense1, isNot(equals(expense3)));
    });
  });

  group('ExpenseType', () {
    test('should have correct display names', () {
      expect(ExpenseType.fuel.displayName, 'Combustível');
      expect(ExpenseType.maintenance.displayName, 'Manutenção');
      expect(ExpenseType.insurance.displayName, 'Seguro');
      expect(ExpenseType.ipva.displayName, 'IPVA');
      expect(ExpenseType.parking.displayName, 'Estacionamento');
      expect(ExpenseType.carWash.displayName, 'Lavagem');
      expect(ExpenseType.fine.displayName, 'Multa');
      expect(ExpenseType.toll.displayName, 'Pedágio');
    });

    test('should identify recurring types', () {
      expect(ExpenseType.insurance.isRecurring, true);
      expect(ExpenseType.ipva.isRecurring, true);
      expect(ExpenseType.licensing.isRecurring, true);
      expect(ExpenseType.parking.isRecurring, false);
      expect(ExpenseType.fuel.isRecurring, false);
    });

    test('should convert from string', () {
      expect(ExpenseType.fromString('maintenance'), ExpenseType.maintenance);
      expect(ExpenseType.fromString('Seguro'), ExpenseType.insurance);
      expect(ExpenseType.fromString('invalid'), ExpenseType.other);
    });

    test('should have icon data', () {
      expect(ExpenseType.fuel.icon, isNotNull);
      expect(ExpenseType.maintenance.icon, isNotNull);
      expect(ExpenseType.insurance.icon, isNotNull);
    });

    test('should have color data', () {
      expect(ExpenseType.fuel.color, isNotNull);
      expect(ExpenseType.maintenance.color, isNotNull);
      expect(ExpenseType.insurance.color, isNotNull);
    });
  });
}
