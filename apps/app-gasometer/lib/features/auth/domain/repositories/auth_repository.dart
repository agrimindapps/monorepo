import 'package:core/core.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<Either<Failure, UserEntity?>> watchAuthState();
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithApple();
  Future<Either<Failure, UserEntity>> signInWithFacebook();
  Future<Either<Failure, UserEntity>> signInAnonymously();
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });
  Future<Either<Failure, Unit>> updateEmail(String newEmail);
  Future<Either<Failure, Unit>> updatePassword(String newPassword);
  Future<Either<Failure, Unit>> sendEmailVerification();
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);
  Future<Either<Failure, Unit>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });
  Future<Either<Failure, UserEntity>> linkAnonymousWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> linkAnonymousWithGoogle();
  Future<Either<Failure, UserEntity>> linkAnonymousWithApple();
  Future<Either<Failure, UserEntity>> linkAnonymousWithFacebook();
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, Unit>> deleteAccount();
  Either<Failure, Unit> validateEmail(String email);
  Either<Failure, Unit> validatePassword(String password);
}