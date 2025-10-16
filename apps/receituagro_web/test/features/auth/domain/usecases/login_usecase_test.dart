import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receituagro_web/core/error/failures.dart';
import 'package:receituagro_web/features/auth/domain/entities/user.dart';
import 'package:receituagro_web/features/auth/domain/entities/user_role.dart';
import 'package:receituagro_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:receituagro_web/features/auth/domain/usecases/login_usecase.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class FakeUser extends Fake implements User {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  // Test data
  final tUser = User(
    id: '123',
    email: 'admin@receituagro.com',
    name: 'Admin User',
    role: UserRole.admin,
    createdAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(FakeUser());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('should login successfully with valid credentials', () async {
      // Arrange
      const params = LoginParams(
        email: 'admin@receituagro.com',
        password: '123456',
      );
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (user) {
          expect(user, isA<User>());
          expect(user.email, 'admin@receituagro.com');
          expect(user.role, UserRole.admin);
        },
      );
      verify(() => mockRepository.login(
            email: 'admin@receituagro.com',
            password: '123456',
          )).called(1);
    });

    test('should return ValidationFailure when email is invalid', () async {
      // Arrange
      const params = LoginParams(
        email: 'invalid-email',
        password: '123456',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Email inválido'));
        },
        (_) => fail('Should not succeed'),
      );
      verifyNever(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('should return ValidationFailure when email is empty', () async {
      // Arrange
      const params = LoginParams(
        email: '',
        password: '123456',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Email'));
        },
        (_) => fail('Should not succeed'),
      );
      verifyNever(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('should return ValidationFailure when password is empty', () async {
      // Arrange
      const params = LoginParams(
        email: 'admin@receituagro.com',
        password: '',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Senha'));
        },
        (_) => fail('Should not succeed'),
      );
      verifyNever(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('should return ValidationFailure when password is too short', () async {
      // Arrange
      const params = LoginParams(
        email: 'admin@receituagro.com',
        password: '123',
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('6 caracteres'));
        },
        (_) => fail('Should not succeed'),
      );
      verifyNever(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('should return PermissionFailure when credentials are invalid',
        () async {
      // Arrange
      const params = LoginParams(
        email: 'admin@receituagro.com',
        password: 'wrongpassword',
      );
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
        (_) async => const Left(PermissionFailure('Credenciais inválidas')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<PermissionFailure>());
          expect(failure.message, contains('Credenciais inválidas'));
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('should trim email whitespace before validation', () async {
      // Arrange
      const params = LoginParams(
        email: '  admin@receituagro.com  ',
        password: '123456',
      );
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.login(
            email: 'admin@receituagro.com',
            password: '123456',
          )).called(1);
    });

    test('should handle repository exceptions', () async {
      // Arrange
      const params = LoginParams(
        email: 'admin@receituagro.com',
        password: '123456',
      );
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<UnexpectedFailure>());
        },
        (_) => fail('Should not succeed'),
      );
    });
  });
}
