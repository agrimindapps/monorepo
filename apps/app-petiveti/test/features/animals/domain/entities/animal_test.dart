import 'package:flutter_test/flutter_test.dart';
import 'package:app_petiveti/features/animals/domain/entities/animal.dart';

void main() {
  group('Animal Entity Tests', () {
    late Animal testAnimal;

    setUp(() {
      testAnimal = Animal(
        id: 'test_001',
        name: 'Rex',
        species: 'Dog',
        breed: 'Labrador',
        birthDate: DateTime(2020, 1, 1), // 3+ years old
        gender: 'Male',
        color: 'Golden',
        currentWeight: 25.5,
        notes: 'Docile animal',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
      );
    });

    test('should create animal with correct properties', () {
      expect(testAnimal.id, equals('test_001'));
      expect(testAnimal.name, equals('Rex'));
      expect(testAnimal.species, equals('Dog'));
      expect(testAnimal.breed, equals('Labrador'));
      expect(testAnimal.gender, equals('Male'));
      expect(testAnimal.currentWeight, equals(25.5));
      expect(testAnimal.color, equals('Golden'));
      expect(testAnimal.notes, equals('Docile animal'));
      expect(testAnimal.isDeleted, isFalse);
    });

    test('should calculate correct age in days', () {
      final now = DateTime.now();
      final expectedDays = now.difference(testAnimal.birthDate).inDays;
      expect(testAnimal.ageInDays, equals(expectedDays));
    });

    test('should calculate correct age in months', () {
      final expectedMonths = (testAnimal.ageInDays / 30.44).floor();
      expect(testAnimal.ageInMonths, equals(expectedMonths));
    });

    test('should calculate correct age in years', () {
      final expectedYears = (testAnimal.ageInMonths / 12).floor();
      expect(testAnimal.ageInYears, equals(expectedYears));
    });

    test('should return correct display age for years', () {
      final youngAnimal = testAnimal.copyWith(
        birthDate: DateTime.now().subtract(Duration(days: 400)), // More than 1 year
      );
      expect(youngAnimal.displayAge, contains('ano'));
    });

    test('should return correct display age for months', () {
      final puppyAnimal = testAnimal.copyWith(
        birthDate: DateTime.now().subtract(Duration(days: 60)), // About 2 months
      );
      expect(puppyAnimal.displayAge, contains('mês'));
    });

    test('should return correct display age for days', () {
      final newBornAnimal = testAnimal.copyWith(
        birthDate: DateTime.now().subtract(Duration(days: 15)), // 15 days old
      );
      expect(newBornAnimal.displayAge, contains('dia'));
    });

    test('should copy animal with new values', () {
      final copied = testAnimal.copyWith(
        name: 'Max',
        currentWeight: 30.0,
      );

      expect(copied.name, equals('Max'));
      expect(copied.currentWeight, equals(30.0));
      expect(copied.id, equals(testAnimal.id)); // unchanged
      expect(copied.species, equals(testAnimal.species)); // unchanged
    });

    test('should maintain equality based on properties', () {
      final animal1 = Animal(
        id: 'test_001',
        name: 'Rex',
        species: 'Dog',
        breed: 'Labrador',
        birthDate: DateTime(2020, 1, 1),
        gender: 'Male',
        color: 'Golden',
        currentWeight: 25.5,
        notes: 'Docile animal',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
      );

      final animal2 = Animal(
        id: 'test_001',
        name: 'Rex',
        species: 'Dog',
        breed: 'Labrador',
        birthDate: DateTime(2020, 1, 1),
        gender: 'Male',
        color: 'Golden',
        currentWeight: 25.5,
        notes: 'Docile animal',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
      );

      expect(animal1, equals(animal2));
      expect(animal1.hashCode, equals(animal2.hashCode));
    });

    test('should handle null values correctly', () {
      final animalWithNulls = Animal(
        id: 'test_002',
        name: 'Miau',
        species: 'Cat',
        breed: 'Persian',
        birthDate: DateTime(2021, 6, 1),
        gender: 'Female',
        color: 'White',
        currentWeight: 4.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // notes is null
      );

      expect(animalWithNulls.notes, isNull);
      expect(animalWithNulls.name, equals('Miau'));
      expect(animalWithNulls.species, equals('Cat'));
    });

    test('should handle optional photo field', () {
      final animalWithPhoto = testAnimal.copyWith(
        photo: 'path/to/photo.jpg',
      );

      expect(animalWithPhoto.photo, equals('path/to/photo.jpg'));
      expect(testAnimal.photo, isNull); // original should still be null
    });

    test('should properly handle copyWith with all fields', () {
      final newDate = DateTime(2019, 5, 15);
      final copied = testAnimal.copyWith(
        id: 'new_id',
        name: 'Buddy',
        species: 'Cat',
        breed: 'Siamese',
        birthDate: newDate,
        gender: 'Female',
        color: 'Black',
        currentWeight: 12.0,
        photo: 'new_photo.jpg',
        notes: 'Updated notes',
        isDeleted: true,
      );

      expect(copied.id, equals('new_id'));
      expect(copied.name, equals('Buddy'));
      expect(copied.species, equals('Cat'));
      expect(copied.breed, equals('Siamese'));
      expect(copied.birthDate, equals(newDate));
      expect(copied.gender, equals('Female'));
      expect(copied.color, equals('Black'));
      expect(copied.currentWeight, equals(12.0));
      expect(copied.photo, equals('new_photo.jpg'));
      expect(copied.notes, equals('Updated notes'));
      expect(copied.isDeleted, isTrue);
    });

    test('should handle different species correctly', () {
      final species = ['Dog', 'Cat', 'Rabbit', 'Hamster', 'Bird'];
      
      for (final animalSpecies in species) {
        final animal = Animal(
          id: 'test_${animalSpecies.toLowerCase()}',
          name: 'Pet',
          species: animalSpecies,
          breed: 'Mixed',
          birthDate: DateTime(2020, 1, 1),
          gender: 'Male',
          color: 'Brown',
          currentWeight: 5.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(animal.species, equals(animalSpecies));
        expect(animal.name, equals('Pet'));
      }
    });

    test('should handle gender variations', () {
      final genders = ['Male', 'Female'];
      
      for (final gender in genders) {
        final animal = Animal(
          id: 'test_${gender.toLowerCase()}',
          name: 'Pet',
          species: 'Dog',
          breed: 'Labrador',
          birthDate: DateTime(2020, 1, 1),
          gender: gender,
          color: 'Golden',
          currentWeight: 25.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(animal.gender, equals(gender));
      }
    });

    test('should handle edge cases for age calculations', () {
      final now = DateTime.now();
      
      // Test animal born today
      final newborn = testAnimal.copyWith(birthDate: now);
      expect(newborn.ageInDays, equals(0));
      expect(newborn.ageInMonths, equals(0));
      expect(newborn.ageInYears, equals(0));
      expect(newborn.displayAge, contains('dia'));

      // Test animal born exactly 1 year ago
      final oneYearOld = testAnimal.copyWith(
        birthDate: DateTime(now.year - 1, now.month, now.day),
      );
      expect(oneYearOld.ageInYears, greaterThanOrEqualTo(0));
      expect(oneYearOld.ageInMonths, greaterThanOrEqualTo(11));
    });

    test('should maintain immutability', () {
      final original = Animal(
        id: 'immutable_test',
        name: 'Original',
        species: 'Dog',
        breed: 'Poodle',
        birthDate: DateTime(2020, 1, 1),
        gender: 'Male',
        color: 'White',
        currentWeight: 15.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final modified = original.copyWith(name: 'Modified');

      expect(original.name, equals('Original'));
      expect(modified.name, equals('Modified'));
      expect(original.id, equals(modified.id)); // Other fields should be same
    });

    test('should handle weight variations', () {
      final weights = [0.5, 1.0, 5.5, 25.0, 50.5, 100.0];
      
      for (final weight in weights) {
        final animal = testAnimal.copyWith(currentWeight: weight);
        expect(animal.currentWeight, equals(weight));
      }
    });

    test('should handle timestamp fields correctly', () {
      final createdAt = DateTime(2023, 1, 1, 10, 30);
      final updatedAt = DateTime(2023, 1, 2, 15, 45);
      
      final animal = testAnimal.copyWith(
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(animal.createdAt, equals(createdAt));
      expect(animal.updatedAt, equals(updatedAt));
    });
  });

  group('Animal Validation Tests', () {
    test('should accept valid animal data', () {
      expect(
        () => Animal(
          id: 'valid_001',
          name: 'Valid Pet',
          species: 'Dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 1, 1),
          gender: 'Male',
          color: 'Golden',
          currentWeight: 30.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        returnsNormally,
      );
    });

    test('should handle various breed names', () {
      final breeds = [
        'Mixed Breed',
        'German Shepherd',
        'Persian Cat',
        'Labrador Retriever',
        'Unknown',
        '',
      ];
      
      for (final breed in breeds) {
        expect(
          () => Animal(
            id: 'breed_test',
            name: 'Pet',
            species: 'Dog',
            breed: breed,
            birthDate: DateTime(2020, 1, 1),
            gender: 'Male',
            color: 'Brown',
            currentWeight: 25.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          returnsNormally,
        );
      }
    });

    test('should handle various color names', () {
      final colors = [
        'Black',
        'White',
        'Brown',
        'Golden',
        'Mixed Colors',
        'Tabby',
        'Spotted',
      ];
      
      for (final color in colors) {
        expect(
          () => Animal(
            id: 'color_test',
            name: 'Pet',
            species: 'Cat',
            breed: 'Persian',
            birthDate: DateTime(2020, 1, 1),
            gender: 'Female',
            color: color,
            currentWeight: 4.5,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          returnsNormally,
        );
      }
    });
  });
}