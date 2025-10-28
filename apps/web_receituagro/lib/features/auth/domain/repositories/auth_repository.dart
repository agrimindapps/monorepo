import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Authentication repository contract (interface)
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
