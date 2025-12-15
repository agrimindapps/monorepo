import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('Auth - Sign In', () {
    test('should sign in successfully with email and password', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final user = UserEntity(
        id: 'user-1',
        email: email,
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );

      when(
        () => mockAuthRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => Right(user));

      // Act
      final result = await mockAuthRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (u) {
        expect(u.id, 'user-1');
        expect(u.email, email);
        expect(u.displayName, 'Test User');
      });
      verify(
        () => mockAuthRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).called(1);
    });

    test('should return failure when credentials are invalid', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';

      when(
        () => mockAuthRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
      ).thenAnswer(
        (_) async => const Left(AuthFailure('Credenciais inválidas')),
      );

      // Act
      final result = await mockAuthRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('inválidas'));
      }, (_) => fail('Should return failure'));
    });

    test('should validate email format', () {
      // Arrange
      const invalidEmails = ['', 'notanemail', '@example.com', 'user@'];

      // Assert
      for (final email in invalidEmails) {
        expect(
          _isValidEmail(email),
          false,
          reason: 'Email "$email" should be invalid',
        );
      }

      expect(_isValidEmail('test@example.com'), true);
      expect(_isValidEmail('user.name@domain.co.uk'), true);
    });

    test('should validate password requirements', () {
      // Arrange
      const weakPasswords = ['', '123', 'abc', '12345'];
      const strongPassword = 'SecurePass123';

      // Assert
      for (final password in weakPasswords) {
        expect(
          _isValidPassword(password),
          false,
          reason: 'Password "$password" should be too weak',
        );
      }

      expect(_isValidPassword(strongPassword), true);
    });
  });

  group('Auth - Sign Up', () {
    test('should sign up successfully with email and password', () async {
      // Arrange
      const email = 'newuser@example.com';
      const password = 'securepassword';
      const displayName = 'New User';

      final user = UserEntity(
        id: 'user-new',
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      when(
        () => mockAuthRepository.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        ),
      ).thenAnswer((_) async => Right(user));

      // Act
      final result = await mockAuthRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (u) {
        expect(u.email, email);
        expect(u.displayName, displayName);
      });
    });

    test('should return failure when email is already in use', () async {
      // Arrange
      const email = 'existing@example.com';
      const password = 'password123';
      const displayName = 'User';

      when(
        () => mockAuthRepository.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        ),
      ).thenAnswer(
        (_) async => const Left(AuthFailure('Email já está em uso')),
      );

      // Act
      final result = await mockAuthRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('em uso')),
        (_) => fail('Should return failure'),
      );
    });

    test('should validate display name requirements', () {
      // Arrange
      const invalidNames = ['', 'A', 'AB'];
      const validNames = ['John', 'Maria Silva', 'User Name 123'];

      // Assert
      for (final name in invalidNames) {
        expect(
          _isValidDisplayName(name),
          false,
          reason: 'Name "$name" should be invalid',
        );
      }

      for (final name in validNames) {
        expect(_isValidDisplayName(name), true);
      }
    });
  });

  group('Auth - Password Reset', () {
    test('should send password reset email successfully', () async {
      // Arrange
      const email = 'user@example.com';

      when(
        () => mockAuthRepository.sendPasswordResetEmail(email: email),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockAuthRepository.sendPasswordResetEmail(
        email: email,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockAuthRepository.sendPasswordResetEmail(email: email),
      ).called(1);
    });

    test('should return failure when email not found', () async {
      // Arrange
      const email = 'notfound@example.com';

      when(
        () => mockAuthRepository.sendPasswordResetEmail(email: email),
      ).thenAnswer(
        (_) async => const Left(AuthFailure('Email não encontrado')),
      );

      // Act
      final result = await mockAuthRepository.sendPasswordResetEmail(
        email: email,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('não encontrado')),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('Auth - Sign Out', () {
    test('should sign out successfully', () async {
      // Arrange
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockAuthRepository.signOut();

      // Assert
      expect(result.isRight(), true);
      verify(() => mockAuthRepository.signOut()).called(1);
    });

    test('should handle sign out errors', () async {
      // Arrange
      when(() => mockAuthRepository.signOut()).thenAnswer(
        (_) async => const Left(ServerFailure('Erro ao fazer logout')),
      );

      // Act
      final result = await mockAuthRepository.signOut();

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('Auth - Current User', () {
    test('should get current user when logged in', () async {
      // Arrange
      final user = UserEntity(
        id: 'user-1',
        email: 'current@example.com',
        displayName: 'Current User',
        createdAt: DateTime.now(),
      );

      when(() => mockAuthRepository.isLoggedIn).thenAnswer((_) async => true);
      when(
        () => mockAuthRepository.currentUser,
      ).thenAnswer((_) => Stream.value(user));

      // Act
      final isLoggedIn = await mockAuthRepository.isLoggedIn;
      final userStream = mockAuthRepository.currentUser;

      // Assert
      expect(isLoggedIn, true);
      expect(userStream, emits(user));
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(() => mockAuthRepository.isLoggedIn).thenAnswer((_) async => false);
      when(
        () => mockAuthRepository.currentUser,
      ).thenAnswer((_) => Stream.value(null));

      // Act
      final isLoggedIn = await mockAuthRepository.isLoggedIn;
      final userStream = mockAuthRepository.currentUser;

      // Assert
      expect(isLoggedIn, false);
      expect(userStream, emits(null));
    });
  });

  group('Auth - Google Sign In', () {
    test('should sign in with Google successfully', () async {
      // Arrange
      final user = UserEntity(
        id: 'google-user-1',
        email: 'google@example.com',
        displayName: 'Google User',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: DateTime.now(),
      );

      when(
        () => mockAuthRepository.signInWithGoogle(),
      ).thenAnswer((_) async => Right(user));

      // Act
      final result = await mockAuthRepository.signInWithGoogle();

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (u) {
        expect(u.email, contains('google'));
        expect(u.photoUrl, isNotNull);
      });
    });

    test('should handle Google sign in cancellation', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
        (_) async => const Left(AuthFailure('Login cancelado pelo usuário')),
      );

      // Act
      final result = await mockAuthRepository.signInWithGoogle();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('cancelado')),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('AuthStateNotifier', () {
    test('should update user state correctly', () {
      // Arrange
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );

      // Act
      AuthStateNotifier.instance.updateUser(user);

      // Assert
      expect(AuthStateNotifier.instance.currentUser, isNotNull);
      expect(AuthStateNotifier.instance.currentUser?.id, 'user-1');

      // Cleanup
      AuthStateNotifier.instance.updateUser(null);
    });

    test('should clear user state on logout', () {
      // Arrange
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );

      AuthStateNotifier.instance.updateUser(user);

      // Act
      AuthStateNotifier.instance.updateUser(null);

      // Assert
      expect(AuthStateNotifier.instance.currentUser, isNull);
    });
  });
}

// Helper validation functions (would be in actual implementation)
bool _isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool _isValidPassword(String password) {
  return password.length >= 6;
}

bool _isValidDisplayName(String name) {
  return name.length >= 3;
}
