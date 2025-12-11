import 'package:core/core.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Adapter to adapt the app's AuthRepository to core.IAuthRepository
/// This is needed because PremiumSyncService expects core.IAuthRepository
class AuthRepositoryAdapter implements IAuthRepository {
  AuthRepositoryAdapter(this._appAuthRepository);

  final AuthRepository _appAuthRepository;

  @override
  Stream<UserEntity?> get currentUser {
    return _appAuthRepository.watchAuthState().map((either) {
      return either.fold((failure) => null, (user) => user);
    });
  }

  @override
  Future<bool> get isLoggedIn async {
    final result = await _appAuthRepository.getCurrentUser();
    return result.fold((_) => false, (user) => user != null);
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _appAuthRepository.signInWithEmail(email: email, password: password);
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _appAuthRepository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() {
    return _appAuthRepository.signInWithGoogle();
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() {
    return _appAuthRepository.signInWithApple();
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() {
    return _appAuthRepository.signInWithFacebook();
  }

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() {
    return _appAuthRepository.signInAnonymously();
  }

  @override
  Future<Either<Failure, void>> signOut() {
    return _appAuthRepository.signOut();
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email}) {
    return _appAuthRepository.sendPasswordResetEmail(email);
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) {
    return _appAuthRepository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> updateEmail({required String newEmail}) async {
    final result = await _appAuthRepository.updateEmail(newEmail);
    
    return result.fold(
      (failure) => Left(failure),
      (_) async {
        final userResult = await _appAuthRepository.getCurrentUser();
        return userResult.fold(
          (l) => Left(l),
          (r) => r != null ? Right(r) : const Left(UnexpectedFailure('User not found')),
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _appAuthRepository.updatePassword(newPassword);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() {
    return _appAuthRepository.deleteAccount();
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() {
    return _appAuthRepository.sendEmailVerification();
  }

  @override
  Future<Either<Failure, void>> reauthenticate({required String password}) async {
    // Not implemented in app AuthRepository directly exposed
    return const Left(UnknownFailure('Reauthentication not implemented in adapter'));
  }

  @override
  Future<Either<Failure, UserEntity>> linkWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _appAuthRepository.linkAnonymousWithEmail(email: email, password: password);
  }

  @override
  Future<Either<Failure, UserEntity>> linkWithGoogle() {
    return _appAuthRepository.linkAnonymousWithGoogle();
  }

  @override
  Future<Either<Failure, UserEntity>> linkWithApple() {
    return _appAuthRepository.linkAnonymousWithApple();
  }

  @override
  Future<Either<Failure, UserEntity>> linkWithFacebook() {
    return _appAuthRepository.linkAnonymousWithFacebook();
  }
}
