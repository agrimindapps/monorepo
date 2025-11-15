import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

/// Interface abstrata para autenticação
/// 
/// Segregada conforme ISP - apenas responsável por operações de autenticação
/// Abstrai Firebase para facilitar testes e mudanças futuras
abstract class IAuthProvider {
  /// Obtém usuário autenticado atual
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Faz login com email/senha
  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password);

  /// Faz logout
  Future<Either<Failure, void>> logout();

  /// Verifica se usuário está autenticado
  Future<bool> isAuthenticated();

  /// Obtém ID do usuário atual
  Future<Either<Failure, String>> getCurrentUserId();
}
