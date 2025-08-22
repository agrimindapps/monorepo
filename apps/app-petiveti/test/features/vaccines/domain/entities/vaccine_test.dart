import 'package:flutter_test/flutter_test.dart';
import 'package:app_petiveti/features/vaccines/domain/entities/vaccine.dart';

void main() {
  group('Vaccine Entity Tests', () {
    late Vaccine testVaccine;

    setUp(() {
      testVaccine = Vaccine(
        id: 'test_vaccine_001',
        animalId: 'test_animal_001',
        name: 'V10',
        description: 'Vacina múltipla contra 10 doenças',
        applicationDate: DateTime(2023, 1, 15),
        nextDoseDate: DateTime(2024, 1, 15),
        veterinarianName: 'Dr. João Silva',
        clinicName: 'Clínica Veterinária Central',
        batch: 'ABC123456',
        status: VaccineStatus.applied,
        notes: 'Aplicação sem intercorrências',
        createdAt: DateTime(2023, 1, 15, 10, 30),
        updatedAt: DateTime(2023, 1, 15, 10, 30),
      );
    });

    test('should create vaccine with correct properties', () {
      expect(testVaccine.id, equals('test_vaccine_001'));
      expect(testVaccine.animalId, equals('test_animal_001'));
      expect(testVaccine.name, equals('V10'));
      expect(testVaccine.description, equals('Vacina múltipla contra 10 doenças'));
      expect(testVaccine.veterinarianName, equals('Dr. João Silva'));
      expect(testVaccine.clinicName, equals('Clínica Veterinária Central'));
      expect(testVaccine.batch, equals('ABC123456'));
      expect(testVaccine.status, equals(VaccineStatus.applied));
      expect(testVaccine.notes, equals('Aplicação sem intercorrências'));
    });

    test('should calculate correct days until next dose', () {
      final vaccine = testVaccine.copyWith(
        nextDoseDate: DateTime.now().add(Duration(days: 30)),
      );
      
      expect(vaccine.daysUntilNextDose, equals(30));
    });

    test('should calculate correct days since application', () {
      final vaccine = testVaccine.copyWith(
        applicationDate: DateTime.now().subtract(Duration(days: 60)),
      );
      
      expect(vaccine.daysSinceApplication, equals(60));
    });

    test('should identify vaccine as overdue when next dose date has passed', () {
      final overdueVaccine = testVaccine.copyWith(
        nextDoseDate: DateTime.now().subtract(Duration(days: 10)),
        status: VaccineStatus.scheduled,
      );
      
      expect(overdueVaccine.isOverdue, isTrue);
    });

    test('should identify vaccine as due soon when next dose date is within 7 days', () {
      final dueSoonVaccine = testVaccine.copyWith(
        nextDoseDate: DateTime.now().add(Duration(days: 5)),
        status: VaccineStatus.scheduled,
      );
      
      expect(dueSoonVaccine.isDueSoon, isTrue);
    });

    test('should not identify applied vaccines as overdue', () {
      final appliedVaccine = testVaccine.copyWith(
        nextDoseDate: DateTime.now().subtract(Duration(days: 10)),
        status: VaccineStatus.applied,
      );
      
      expect(appliedVaccine.isOverdue, isFalse);
    });

    test('should format next dose date correctly', () {
      final vaccine = testVaccine.copyWith(
        nextDoseDate: DateTime(2024, 6, 15),
      );
      
      expect(vaccine.formattedNextDoseDate, equals('15/06/2024'));
    });

    test('should format application date correctly', () {
      final vaccine = testVaccine.copyWith(
        applicationDate: DateTime(2023, 3, 10),
      );
      
      expect(vaccine.formattedApplicationDate, equals('10/03/2023'));
    });

    test('should copy vaccine with new values', () {
      final copied = testVaccine.copyWith(
        name: 'Raiva',
        status: VaccineStatus.completed,
        notes: 'Nova observação',
      );

      expect(copied.name, equals('Raiva'));
      expect(copied.status, equals(VaccineStatus.completed));
      expect(copied.notes, equals('Nova observação'));
      expect(copied.id, equals(testVaccine.id)); // unchanged
      expect(copied.animalId, equals(testVaccine.animalId)); // unchanged
    });

    test('should maintain equality based on properties', () {
      final vaccine1 = Vaccine(
        id: 'test_001',
        animalId: 'animal_001',
        name: 'V8',
        description: 'Vacina múltipla',
        applicationDate: DateTime(2023, 1, 1),
        nextDoseDate: DateTime(2024, 1, 1),
        veterinarianName: 'Dr. Silva',
        clinicName: 'Clínica A',
        batch: 'ABC123',
        status: VaccineStatus.applied,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      final vaccine2 = Vaccine(
        id: 'test_001',
        animalId: 'animal_001',
        name: 'V8',
        description: 'Vacina múltipla',
        applicationDate: DateTime(2023, 1, 1),
        nextDoseDate: DateTime(2024, 1, 1),
        veterinarianName: 'Dr. Silva',
        clinicName: 'Clínica A',
        batch: 'ABC123',
        status: VaccineStatus.applied,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      expect(vaccine1, equals(vaccine2));
      expect(vaccine1.hashCode, equals(vaccine2.hashCode));
    });

    test('should handle null values correctly', () {
      final vaccineWithNulls = Vaccine(
        id: 'test_002',
        animalId: 'animal_002',
        name: 'Raiva',
        applicationDate: DateTime(2023, 6, 1),
        veterinarianName: 'Dr. Maria',
        clinicName: 'Clínica B',
        batch: 'XYZ789',
        status: VaccineStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // description, nextDoseDate, notes are null
      );

      expect(vaccineWithNulls.description, isNull);
      expect(vaccineWithNulls.nextDoseDate, isNull);
      expect(vaccineWithNulls.notes, isNull);
      expect(vaccineWithNulls.name, equals('Raiva'));
      expect(vaccineWithNulls.status, equals(VaccineStatus.scheduled));
    });

    test('should handle edge cases for date calculations', () {
      final now = DateTime.now();
      
      // Test vaccine with next dose today
      final todayVaccine = testVaccine.copyWith(nextDoseDate: now);
      expect(todayVaccine.daysUntilNextDose, equals(0));
      expect(todayVaccine.isDueSoon, isTrue);

      // Test vaccine with application today
      final todayApplication = testVaccine.copyWith(applicationDate: now);
      expect(todayApplication.daysSinceApplication, equals(0));
    });

    test('should handle different vaccine statuses correctly', () {
      final statuses = [
        VaccineStatus.scheduled,
        VaccineStatus.applied,
        VaccineStatus.overdue,
        VaccineStatus.completed,
        VaccineStatus.cancelled,
      ];
      
      for (final status in statuses) {
        final vaccine = testVaccine.copyWith(status: status);
        expect(vaccine.status, equals(status));
      }
    });

    test('should provide correct status display text', () {
      expect(VaccineStatus.scheduled.displayText, equals('Agendada'));
      expect(VaccineStatus.applied.displayText, equals('Aplicada'));
      expect(VaccineStatus.overdue.displayText, equals('Atrasada'));
      expect(VaccineStatus.completed.displayText, equals('Completa'));
      expect(VaccineStatus.cancelled.displayText, equals('Cancelada'));
    });

    test('should handle various vaccine names', () {
      final vaccineNames = [
        'V8',
        'V10',
        'Raiva',
        'Giárdia',
        'Leishmaniose',
        'Gripe Canina',
        'FeLV',
        'FIV',
      ];
      
      for (final name in vaccineNames) {
        final vaccine = testVaccine.copyWith(name: name);
        expect(vaccine.name, equals(name));
      }
    });

    test('should maintain immutability', () {
      final original = Vaccine(
        id: 'immutable_test',
        animalId: 'animal_test',
        name: 'Original',
        applicationDate: DateTime(2023, 1, 1),
        veterinarianName: 'Dr. Original',
        clinicName: 'Clínica Original',
        batch: 'ORIG123',
        status: VaccineStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final modified = original.copyWith(name: 'Modified');

      expect(original.name, equals('Original'));
      expect(modified.name, equals('Modified'));
      expect(original.id, equals(modified.id)); // Other fields should be same
    });

    test('should handle timestamp fields correctly', () {
      final createdAt = DateTime(2023, 1, 1, 10, 30);
      final updatedAt = DateTime(2023, 1, 2, 15, 45);
      
      final vaccine = testVaccine.copyWith(
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(vaccine.createdAt, equals(createdAt));
      expect(vaccine.updatedAt, equals(updatedAt));
    });
  });

  group('Vaccine Status Tests', () {
    test('should have correct status values', () {
      expect(VaccineStatus.scheduled.name, equals('scheduled'));
      expect(VaccineStatus.applied.name, equals('applied'));
      expect(VaccineStatus.overdue.name, equals('overdue'));
      expect(VaccineStatus.completed.name, equals('completed'));
      expect(VaccineStatus.cancelled.name, equals('cancelled'));
    });

    test('should have correct priority order', () {
      // Overdue should have highest priority
      expect(VaccineStatus.overdue.priority, equals(0));
      expect(VaccineStatus.scheduled.priority, equals(1));
      expect(VaccineStatus.applied.priority, equals(2));
      expect(VaccineStatus.completed.priority, equals(3));
      expect(VaccineStatus.cancelled.priority, equals(4));
    });

    test('should identify active statuses correctly', () {
      expect(VaccineStatus.scheduled.isActive, isTrue);
      expect(VaccineStatus.applied.isActive, isTrue);
      expect(VaccineStatus.overdue.isActive, isTrue);
      expect(VaccineStatus.completed.isActive, isFalse);
      expect(VaccineStatus.cancelled.isActive, isFalse);
    });
  });

  group('Vaccine Validation Tests', () {
    test('should accept valid vaccine data', () {
      expect(
        () => Vaccine(
          id: 'valid_001',
          animalId: 'animal_001',
          name: 'V10',
          applicationDate: DateTime(2023, 1, 1),
          veterinarianName: 'Dr. Valid',
          clinicName: 'Clínica Valid',
          batch: 'VALID123',
          status: VaccineStatus.applied,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        returnsNormally,
      );
    });

    test('should handle edge case dates', () {
      final now = DateTime.now();
      
      // Test past dates
      expect(
        () => Vaccine(
          id: 'past_test',
          animalId: 'animal_001',
          name: 'V8',
          applicationDate: DateTime(2020, 1, 1),
          nextDoseDate: DateTime(2021, 1, 1),
          veterinarianName: 'Dr. Past',
          clinicName: 'Clínica Past',
          batch: 'PAST123',
          status: VaccineStatus.completed,
          createdAt: now,
          updatedAt: now,
        ),
        returnsNormally,
      );

      // Test future dates
      expect(
        () => Vaccine(
          id: 'future_test',
          animalId: 'animal_001',
          name: 'V8',
          applicationDate: now.add(Duration(days: 30)),
          nextDoseDate: now.add(Duration(days: 365)),
          veterinarianName: 'Dr. Future',
          clinicName: 'Clínica Future',
          batch: 'FUTURE123',
          status: VaccineStatus.scheduled,
          createdAt: now,
          updatedAt: now,
        ),
        returnsNormally,
      );
    });
  });
}