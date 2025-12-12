import 'package:core/core.dart' hide Column;

import '../../domain/repositories/auth_repository.dart';

/// Implementação do AuthRepository usando FirebaseAuthService do Core
///
/// Esta implementação delega para o FirebaseAuthService do core package,
/// mantendo a separação de responsabilidades e permitindo substituição
/// futura se necessário.
class AuthRepositoryImpl implements AuthRepository {
  final IAuthRepository _coreAuthService;

  const AuthRepositoryImpl(this._coreAuthService);

  @override
  Stream<UserEntity?> get currentUser => _coreAuthService.currentUser;

  @override
  Future<bool> get isLoggedIn => _coreAuthService.isLoggedIn;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _coreAuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _coreAuthService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    return await _coreAuthService.signInWithGoogle();
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return await _coreAuthService.signOut();
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    return await _coreAuthService.sendPasswordResetEmail(email: email);
  }
}
