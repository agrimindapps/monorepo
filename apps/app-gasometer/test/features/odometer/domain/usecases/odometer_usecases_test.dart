import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/odometer/domain/entities/odometer_entity.dart';
import 'package:gasometer_drift/features/odometer/domain/repositories/odometer_repository.dart';
import 'package:gasometer_drift/features/odometer/domain/usecases/add_odometer_reading.dart';
import 'package:gasometer_drift/features/odometer/domain/usecases/delete_odometer_reading.dart';
import 'package:gasometer_drift/features/odometer/domain/usecases/get_all_odometer_readings.dart';
import 'package:gasometer_drift/features/odometer/domain/usecases/update_odometer_reading.dart';
import 'package:mocktail/mocktail.dart';

class MockOdometerRepository extends Mock implements OdometerRepository {}

class FakeOdometerEntity extends Fake implements OdometerEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOdometerEntity());
  });

  late MockOdometerRepository mockRepository;

  final testOdometer = OdometerEntity(
    id: 'test-id',
    vehicleId: 'vehicle-001',
    value: 15000.0,
    registrationDate: DateTime(2024, 1, 15),
    description: 'Registro de viagem',
    type: OdometerType.trip,
    metadata: {},
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
    userId: 'user-001',
    moduleName: 'gasometer',
  );

  setUp(() {
    mockRepository = MockOdometerRepository();
  });

  group('AddOdometerReadingUseCase', () {
    late AddOdometerReadingUseCase useCase;

    setUp(() {
      useCase = AddOdometerReadingUseCase(mockRepository);
    });

    test('should add odometer reading successfully with valid data', () async {
      // Arrange
      when(() => mockRepository.addOdometerReading(any()))
          .thenAnswer((_) async => Right(testOdometer));

      // Act
      final result = await useCase(testOdometer);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (reading) {
          expect(reading?.id, testOdometer.id);
          expect(reading?.value, testOdometer.value);
        },
      );

      verify(() => mockRepository.addOdometerReading(any())).called(1);
    });

    test('should return ValidationFailure for empty vehicle ID', () async {
      // Arrange
      final invalidReading = testOdometer.copyWith(vehicleId: '');

      // Act
      final result = await useCase(invalidReading);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Veículo'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.addOdometerReading(any()));
    });

    test('should return ValidationFailure for negative value', () async {
      // Arrange
      final invalidReading = testOdometer.copyWith(value: -100.0);

      // Act
      final result = await useCase(invalidReading);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('negativo'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for very high value', () async {
      // Arrange
      final invalidReading = testOdometer.copyWith(value: 10000000.0);

      // Act
      final result = await useCase(invalidReading);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('muito alto'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for future date', () async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final invalidReading = testOdometer.copyWith(registrationDate: futureDate);

      // Act
      final result = await useCase(invalidReading);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('futuro'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for very old date', () async {
      // Arrange
      final oldDate = DateTime(1999, 1, 1);
      final invalidReading = testOdometer.copyWith(registrationDate: oldDate);

      // Act
      final result = await useCase(invalidReading);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('antiga'));
        },
        (_) => fail('Should fail'),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.addOdometerReading(any()))
          .thenAnswer((_) async => Left(ServerFailure('Database error')));

      // Act
      final result = await useCase(testOdometer);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('GetAllOdometerReadingsUseCase', () {
    late GetAllOdometerReadingsUseCase useCase;

    setUp(() {
      useCase = GetAllOdometerReadingsUseCase(mockRepository);
    });

    test('should get all odometer readings successfully', () async {
      // Arrange
      final readings = [testOdometer];
      when(() => mockRepository.getAllOdometerReadings())
          .thenAnswer((_) async => Right(readings));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, testOdometer.id);
        },
      );

      verify(() => mockRepository.getAllOdometerReadings()).called(1);
    });

    test('should return readings sorted by date descending', () async {
      // Arrange
      final reading1 = testOdometer.copyWith(
        registrationDate: DateTime(2024, 1, 10),
      );
      final reading2 = testOdometer.copyWith(
        id: 'test-id-2',
        registrationDate: DateTime(2024, 1, 20),
      );
      final reading3 = testOdometer.copyWith(
        id: 'test-id-3',
        registrationDate: DateTime(2024, 1, 15),
      );

      when(() => mockRepository.getAllOdometerReadings())
          .thenAnswer((_) async => Right([reading1, reading2, reading3]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      result.fold(
        (_) => fail('Should succeed'),
        (list) {
          expect(list[0].registrationDate, DateTime(2024, 1, 20)); // Most recent
          expect(list[1].registrationDate, DateTime(2024, 1, 15));
          expect(list[2].registrationDate, DateTime(2024, 1, 10)); // Oldest
        },
      );
    });

    test('should return empty list when no readings', () async {
      // Arrange
      when(() => mockRepository.getAllOdometerReadings())
          .thenAnswer((_) async => Right([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) => expect(list.isEmpty, true),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getAllOdometerReadings())
          .thenAnswer((_) async => Left(CacheFailure('No data')));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('UpdateOdometerReadingUseCase', () {
    late UpdateOdometerReadingUseCase useCase;

    setUp(() {
      useCase = UpdateOdometerReadingUseCase(mockRepository);
    });

    test('should update odometer reading successfully', () async {
      // Arrange
      final updated = testOdometer.copyWith(value: 20000.0);
      when(() => mockRepository.getOdometerReadingById(any()))
          .thenAnswer((_) async => Right(testOdometer));
      when(() => mockRepository.updateOdometerReading(any()))
          .thenAnswer((_) async => Right(updated));

      // Act
      final result = await useCase(updated);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (reading) => expect(reading?.value, 20000.0),
      );

      verify(() => mockRepository.getOdometerReadingById(any())).called(1);
      verify(() => mockRepository.updateOdometerReading(any())).called(1);
    });

    test('should return ValidationFailure when reading not found', () async {
      // Arrange
      when(() => mockRepository.getOdometerReadingById(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testOdometer);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('não encontrada'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.updateOdometerReading(any()));
    });
  });

  group('DeleteOdometerReadingUseCase', () {
    late DeleteOdometerReadingUseCase useCase;

    setUp(() {
      useCase = DeleteOdometerReadingUseCase(mockRepository);
    });

    test('should delete odometer reading successfully', () async {
      // Arrange
      when(() => mockRepository.getOdometerReadingById(any()))
          .thenAnswer((_) async => Right(testOdometer));
      when(() => mockRepository.deleteOdometerReading(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (success) => expect(success, true),
      );

      verify(() => mockRepository.deleteOdometerReading('test-id')).called(1);
    });

    test('should return ValidationFailure for empty ID', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('obrigatório'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.deleteOdometerReading(any()));
    });

    test('should return ValidationFailure when reading not found', () async {
      // Arrange
      when(() => mockRepository.getOdometerReadingById(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase('invalid-id');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('não encontrada'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.deleteOdometerReading(any()));
    });
  });
}
