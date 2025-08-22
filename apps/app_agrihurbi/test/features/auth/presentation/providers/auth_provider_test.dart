import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/usecases/refresh_user_usecase.dart';
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:core/core.dart' as core_lib;

import 'auth_provider_test.mocks.dart';
import '../../../../helpers/test_helpers.dart';

@GenerateMocks([LoginUseCase, RegisterUseCase, LogoutUseCase, GetCurrentUserUseCase, RefreshUserUseCase])
void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockRegisterUseCase mockRegisterUseCase;
    late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

    setUp(() {
      mockRegisterUseCase = MockRegisterUseCase();
      mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
      
      authProvider = AuthProvider(
        loginUseCase: MockLoginUseCase(),
        registerUseCase: mockRegisterUseCase,
        logoutUseCase: MockLogoutUseCase(),
        getCurrentUserUseCase: mockGetCurrentUserUseCase,
        refreshUserUseCase: MockRefreshUserUseCase(),
      );
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isLoggedIn, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('Login', () {
      test('should login successfully with correct credentials', () async {
        // Arrange
        const email = 'test@test.com';
        const password = '123456';
        
        // Act
        final result = await authProvider.login(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isRight(), isTrue);
        expect(authProvider.isLoggedIn, isTrue);
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.currentUser!.email, equals(email));
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);
      });

      test('should fail login with incorrect credentials', () async {
        // Arrange
        const email = 'wrong@email.com';
        const password = 'wrongpassword';

        // Act
        final result = await authProvider.login(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isLeft(), isTrue);
        expect(authProvider.isLoggedIn, isFalse);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNotNull);
      });

      test('should show loading state during login', () async {
        // Arrange
        const email = 'test@test.com';
        const password = '123456';
        bool loadingStateChecked = false;

        // Act
        final loginFuture = authProvider.login(
          email: email,
          password: password,
        );

        // Check loading state immediately after calling login
        if (authProvider.isLoading) {
          loadingStateChecked = true;
        }

        await loginFuture;

        // Assert
        expect(loadingStateChecked, isTrue);
        expect(authProvider.isLoading, isFalse);
      });
    });

    group('Register', () {
      final mockUser = UserEntity(
        id: '123',
        name: 'Test User',
        email: 'test@test.com',
        phone: null,
        profileImageUrl: null,
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
      );

      test('should register user successfully', () async {
        // Arrange
        when(mockRegisterUsecase.call(any))
            .thenAnswer((_) async => Right(mockUser));

        // Act
        final result = await authProvider.register(
          name: 'Test User',
          email: 'test@test.com',
          password: '123456',
        );

        // Assert
        expect(result.isRight(), isTrue);
        expect(authProvider.isLoggedIn, isTrue);
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);
      });

      test('should handle registration failure', () async {
        // Arrange
        const failure = ValidationFailure('Email já está em uso');
        when(mockRegisterUsecase.call(any))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await authProvider.register(
          name: 'Test User',
          email: 'test@test.com',
          password: '123456',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        expect(authProvider.isLoggedIn, isFalse);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, equals('Email já está em uso'));
      });
    });

    group('Logout', () {
      test('should logout successfully', () async {
        // Arrange - first login user
        await authProvider.login(
          email: 'test@test.com',
          password: '123456',
        );
        
        expect(authProvider.isLoggedIn, isTrue);

        // Act
        final result = await authProvider.logout();

        // Assert
        expect(result.isRight(), isTrue);
        expect(authProvider.isLoggedIn, isFalse);
        expect(authProvider.currentUser, isNull);
        expect(authProvider.errorMessage, isNull);
        expect(authProvider.isLoading, isFalse);
      });
    });

    group('Error Handling', () {
      test('should clear error message', () async {
        // Arrange - trigger an error first
        await authProvider.login(
          email: 'wrong@email.com',
          password: 'wrongpassword',
        );
        
        expect(authProvider.errorMessage, isNotNull);

        // Act
        authProvider.clearError();

        // Assert
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('Refresh User', () {
      test('should refresh user data', () async {
        // Arrange
        when(mockGetCurrentUserUsecase.call())
            .thenAnswer((_) async => const Right(null));

        // Act
        await authProvider.refreshUser();

        // Assert
        verify(mockGetCurrentUserUsecase.call()).called(1);
        expect(authProvider.isLoading, isFalse);
      });
    });
  });
}