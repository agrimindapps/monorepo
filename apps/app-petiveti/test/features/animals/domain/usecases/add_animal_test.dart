import 'package:app_petiveti/core/error/failures.dart';
import 'package:app_petiveti/features/animals/domain/entities/animal.dart';
import 'package:app_petiveti/features/animals/domain/entities/animal_enums.dart';
import 'package:app_petiveti/features/animals/domain/repositories/animal_repository.dart';
import 'package:app_petiveti/features/animals/domain/usecases/add_animal.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAnimalRepository extends Mock implements AnimalRepository {}

void main() {
  late AddAnimal usecase;
  late MockAnimalRepository mockRepository;

  setUp(() {
    mockRepository = MockAnimalRepository();
    usecase = AddAnimal(mockRepository);
  });

  final testAnimal = Animal(
    id: '1',
    userId: 'user1',
    name: 'Rex',
    species: AnimalSpecies.dog,
    breed: 'Labrador',
    birthDate: DateTime(2020, 1, 1),
    gender: AnimalGender.male,
    color: 'Marrom',
    weight: 25.5,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('AddAnimal', () {
    test('should add animal when data is valid', () async {
      // arrange
      when(mockRepository.addAnimal(testAnimal))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(testAnimal);

      // assert
      expect(result, const Right(null));
      verify(mockRepository.addAnimal(testAnimal));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when name is empty', () async {
      // arrange
      final invalidAnimal = Animal(
        id: '1',
        userId: 'user1',
        name: '',
        species: AnimalSpecies.dog,
        breed: 'Labrador',
        birthDate: DateTime(2020, 1, 1),
        gender: AnimalGender.male,
        color: 'Marrom',
        weight: 25.5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // act
      final result = await usecase(invalidAnimal);

      // assert
      expect(result, const Left(ValidationFailure(message: 'Nome do animal é obrigatório')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when species is empty', () async {
      // arrange
      final invalidAnimal = Animal(
        id: '1',
        userId: 'user1',
        name: 'Rex',
        species: AnimalSpecies.dog,
        breed: 'Labrador',
        birthDate: DateTime(2020, 1, 1),
        gender: AnimalGender.male,
        color: 'Marrom',
        weight: 25.5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // act
      final result = await usecase(invalidAnimal);

      // assert
      expect(result, const Left(ValidationFailure(message: 'Espécie é obrigatória')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when weight is zero or negative', () async {
      // arrange
      final invalidAnimal = Animal(
        id: '1',
        userId: 'user1',
        name: 'Rex',
        species: AnimalSpecies.dog,
        breed: 'Labrador',
        birthDate: DateTime(2020, 1, 1),
        gender: AnimalGender.male,
        color: 'Marrom',
        weight: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // act
      final result = await usecase(invalidAnimal);

      // assert
      expect(result, const Left(ValidationFailure(message: 'Peso deve ser maior que zero')));
      verifyZeroInteractions(mockRepository);
    });

    test('should return CacheFailure when repository fails', () async {
      // arrange
      when(mockRepository.addAnimal(testAnimal))
          .thenAnswer((_) async => const Left(CacheFailure(message: 'Cache error')));

      // act
      final result = await usecase(testAnimal);

      // assert
      expect(result, const Left(CacheFailure(message: 'Cache error')));
      verify(mockRepository.addAnimal(testAnimal));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}