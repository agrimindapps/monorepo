import 'package:core/core.dart' hide Failure;

import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  // Auth State
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<Either<Failure, UserEntity?>> watchAuthState();
  
  // Sign In Methods
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email, 
    required String password,
  });
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInAnonymously();
  
  // Sign Up
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });
  
  // Profile Management
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });
  Future<Either<Failure, Unit>> updateEmail(String newEmail);
  Future<Either<Failure, Unit>> updatePassword(String newPassword);
  Future<Either<Failure, Unit>> sendEmailVerification();
  
  // Password Reset
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);
  Future<Either<Failure, Unit>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
  
  // Account Conversion
  Future<Either<Failure, UserEntity>> linkAnonymousWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> linkAnonymousWithGoogle();
  
  // Sign Out
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, Unit>> deleteAccount();
  
  // Validation
  Either<Failure, Unit> validateEmail(String email);
  Either<Failure, Unit> validatePassword(String password);
}