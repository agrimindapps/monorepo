import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:app_petiveti/core/error/failures.dart';
import 'package:app_petiveti/features/appointments/domain/entities/appointment.dart';
import 'package:app_petiveti/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:app_petiveti/features/appointments/domain/usecases/add_appointment.dart';

import 'add_appointment_test.mocks.dart';

@GenerateMocks([AppointmentRepository])
void main() {
  late AddAppointment usecase;
  late MockAppointmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    usecase = AddAppointment(mockRepository);
  });

  final tAppointment = Appointment(
    id: '1',
    animalId: 'animal1',
    veterinarianName: 'Dr. Test',
    date: DateTime(2024, 1, 1),
    reason: 'Test reason',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('AddAppointment', () {
    test('should add appointment successfully when data is valid', () async {
      // arrange
      when(mockRepository.addAppointment(any))
          .thenAnswer((_) async => Right(tAppointment));

      // act
      final result = await usecase(AddAppointmentParams(appointment: tAppointment));

      // assert
      expect(result, Right(tAppointment));
      verify(mockRepository.addAppointment(tAppointment));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when veterinarian name is empty', () async {
      // arrange
      final invalidAppointment = tAppointment.copyWith(veterinarianName: '');

      // act
      final result = await usecase(AddAppointmentParams(appointment: invalidAppointment));

      // assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (r) => fail('Expected failure'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when reason is empty', () async {
      // arrange
      final invalidAppointment = tAppointment.copyWith(reason: '');

      // act
      final result = await usecase(AddAppointmentParams(appointment: invalidAppointment));

      // assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (r) => fail('Expected failure'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when animal ID is empty', () async {
      // arrange
      final invalidAppointment = tAppointment.copyWith(animalId: '');

      // act
      final result = await usecase(AddAppointmentParams(appointment: invalidAppointment));

      // assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (r) => fail('Expected failure'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure(message: 'Server error');
      when(mockRepository.addAppointment(any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(AddAppointmentParams(appointment: tAppointment));

      // assert
      expect(result, const Left(tFailure));
      verify(mockRepository.addAppointment(tAppointment));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}