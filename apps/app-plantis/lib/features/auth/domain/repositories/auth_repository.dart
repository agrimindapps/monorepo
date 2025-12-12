import 'package:core/core.dart' hide Column;

/// Repository abstrato para autenticação - camada domain
///
/// Define o contrato para operações de autenticação da feature Auth.
/// A implementação concreta ficará na camada data.
abstract class AuthRepository {
  /// Stream do usuário atual
  Stream<UserEntity?> get currentUser;

  /// Verifica se há usuário logado
  Future<bool> get isLoggedIn;

  /// Login com email e senha
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registro com email e senha
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login com Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Logout
  Future<Either<Failure, void>> signOut();

  /// Enviar email de reset de senha
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});
}
