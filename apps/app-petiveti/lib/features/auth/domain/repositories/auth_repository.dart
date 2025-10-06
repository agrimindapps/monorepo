import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail(String email, String password);
  Future<Either<Failure, User>> signUpWithEmail(String email, String password, String? name);
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> signInWithApple();
  Future<Either<Failure, User>> signInWithFacebook();
  Future<Either<Failure, User>> signInAnonymously();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, User>> updateProfile(String? name, String? photoUrl);
  Future<Either<Failure, void>> deleteAccount();
  Stream<Either<Failure, User?>> watchAuthState();
}
