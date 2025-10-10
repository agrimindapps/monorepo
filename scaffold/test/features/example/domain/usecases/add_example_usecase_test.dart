import 'package:core/core.dart' hide test; // Avoid namespace conflicts
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{APP_NAME}}/features/example/domain/entities/example_entity.dart';
import 'package:{{APP_NAME}}/features/example/domain/repositories/example_repository.dart';
import 'package:{{APP_NAME}}/features/example/domain/usecases/add_example_usecase.dart';

// Mock repository
class MockExampleRepository extends Mock implements ExampleRepository {}

// Fake entity for fallback registration
class _FakeExampleEntity extends Fake implements ExampleEntity {}

void main() {
  late AddExampleUseCase useCase;
  late MockExampleRepository mockRepository;

  setUp(() {
    mockRepository = MockExampleRepository();
    useCase = AddExampleUseCase(mockRepository);

    // Register fallback values for any() matchers
    registerFallbackValue(_FakeExampleEntity());
  });

  group('AddExampleUseCase', () {
    const validParams = AddExampleParams(
      name: 'Test Example',
      description: 'Test description',
      userId: 'user-123',
    );

    test('should add example successfully with valid data', () async {
      // Arrange
      when(() => mockRepository.addExample(any()))
          .thenAnswer((_) async => Right(ExampleEntity.empty()));

      // Act
      final result = await useCase(validParams);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (entity) {
          expect(entity.name, 'Test Example');
          expect(entity.description, 'Test description');
          expect(entity.userId, 'user-123');
          expect(entity.isDirty, true);
        },
      );

      verify(() => mockRepository.addExample(any())).called(1);
    });

    test('should return ValidationFailure when name is empty', () async {
      // Arrange
      const params = AddExampleParams(name: '');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome é obrigatório');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.addExample(any()));
    });

    test('should return ValidationFailure when name is only whitespace',
        () async {
      // Arrange
      const params = AddExampleParams(name: '   ');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome é obrigatório');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.addExample(any()));
    });

    test('should return ValidationFailure when name is too short', () async {
      // Arrange
      const params = AddExampleParams(name: 'A');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome deve ter pelo menos 2 caracteres');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.addExample(any()));
    });

    test('should return ValidationFailure when name is too long', () async {
      // Arrange
      final longName = 'A' * 101; // 101 characters
      final params = AddExampleParams(name: longName);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome deve ter no máximo 100 caracteres');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.addExample(any()));
    });

    test('should return ValidationFailure when description is too long',
        () async {
      // Arrange
      final longDescription = 'A' * 501; // 501 characters
      final params = AddExampleParams(
        name: 'Valid Name',
        description: longDescription,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Descrição deve ter no máximo 500 caracteres',
          );
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.addExample(any()));
    });

    test('should trim whitespace from name and description', () async {
      // Arrange
      const params = AddExampleParams(
        name: '  Test Example  ',
        description: '  Test description  ',
      );

      final capturedEntities = <ExampleEntity>[];
      when(() => mockRepository.addExample(any())).thenAnswer((invocation) {
        final entity = invocation.positionalArguments[0] as ExampleEntity;
        capturedEntities.add(entity);
        return Future.value(Right(entity));
      });

      // Act
      await useCase(params);

      // Assert
      expect(capturedEntities.length, 1);
      expect(capturedEntities.first.name, 'Test Example');
      expect(capturedEntities.first.description, 'Test description');
    });

    test('should set timestamps correctly', () async {
      // Arrange
      final beforeCall = DateTime.now();

      final capturedEntities = <ExampleEntity>[];
      when(() => mockRepository.addExample(any())).thenAnswer((invocation) {
        final entity = invocation.positionalArguments[0] as ExampleEntity;
        capturedEntities.add(entity);
        return Future.value(Right(entity));
      });

      // Act
      await useCase(validParams);

      final afterCall = DateTime.now();

      // Assert
      expect(capturedEntities.length, 1);
      final entity = capturedEntities.first;

      expect(entity.createdAt, isNotNull);
      expect(entity.updatedAt, isNotNull);
      expect(entity.createdAt!.isAfter(beforeCall), true);
      expect(entity.createdAt!.isBefore(afterCall), true);
      expect(entity.createdAt, equals(entity.updatedAt));
    });

    test('should set isDirty flag to true', () async {
      // Arrange
      final capturedEntities = <ExampleEntity>[];
      when(() => mockRepository.addExample(any())).thenAnswer((invocation) {
        final entity = invocation.positionalArguments[0] as ExampleEntity;
        capturedEntities.add(entity);
        return Future.value(Right(entity));
      });

      // Act
      await useCase(validParams);

      // Assert
      expect(capturedEntities.length, 1);
      expect(capturedEntities.first.isDirty, true);
    });

    test('should generate unique ID', () async {
      // Arrange
      final capturedIds = <String>[];
      when(() => mockRepository.addExample(any())).thenAnswer((invocation) {
        final entity = invocation.positionalArguments[0] as ExampleEntity;
        capturedIds.add(entity.id);
        return Future.value(Right(entity));
      });

      // Act
      await useCase(validParams);
      await useCase(validParams);
      await useCase(validParams);

      // Assert
      expect(capturedIds.length, 3);
      expect(capturedIds.toSet().length, 3); // All IDs are unique
      expect(capturedIds.every((id) => id.isNotEmpty), true);
    });

    test('should propagate repository failure', () async {
      // Arrange
      const failure = ServerFailure('Network error');
      when(() => mockRepository.addExample(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(validParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<ServerFailure>());
          expect(f.message, 'Network error');
        },
        (_) => fail('Should not return success'),
      );

      verify(() => mockRepository.addExample(any())).called(1);
    });

    test('should work with null description', () async {
      // Arrange
      const params = AddExampleParams(name: 'Test Name');

      when(() => mockRepository.addExample(any()))
          .thenAnswer((_) async => Right(ExampleEntity.empty()));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (entity) {
          expect(entity.name, 'Test Name');
          expect(entity.description, null);
        },
      );
    });

    test('should work with null userId', () async {
      // Arrange
      const params = AddExampleParams(name: 'Test Name');

      when(() => mockRepository.addExample(any()))
          .thenAnswer((_) async => Right(ExampleEntity.empty()));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (entity) {
          expect(entity.userId, null);
        },
      );
    });
  });
}
