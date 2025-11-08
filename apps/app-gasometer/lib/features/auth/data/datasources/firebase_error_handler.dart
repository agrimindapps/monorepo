import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';

/// Handler especializado para tratar erros do Firebase Auth
///
/// Responsabilidade: Mapear FirebaseAuthException para exceções da aplicação
/// Aplica SRP (Single Responsibility Principle)
@injectable
class FirebaseErrorHandler {
  /// Trata erros de autenticação do Firebase
  ///
  /// Lança [AuthenticationException] ou [ServerException] apropriadas
  void handleAuthError(Object error, String operation) {
    if (error is FirebaseAuthException) {
      _handleFirebaseAuthException(error, operation);
    } else {
      throw ServerException('Unexpected $operation error: $error');
    }
  }

  void _handleFirebaseAuthException(FirebaseAuthException e, String operation) {
    if (kDebugMode) {
      debugPrint(
        '🔥 Firebase Auth Error [$operation] - Code: ${e.code}, Message: ${e.message}',
      );
    }

    switch (e.code) {
      // Rate limiting
      case 'too-many-requests':
        if (kDebugMode) {
          debugPrint('🔥 Firebase rate limiting detected - too-many-requests');
        }
        throw const AuthenticationException(
          'FIREBASE BLOQUEIO: Muitas tentativas. Tente novamente mais tarde.',
        );

      // Account issues
      case 'user-disabled':
        throw const AuthenticationException('Esta conta foi desabilitada.');
      case 'user-not-found':
        throw const AuthenticationException('Email não encontrado.');

      // Credential issues
      case 'wrong-password':
        throw const AuthenticationException('Senha incorreta.');
      case 'invalid-email':
        throw const AuthenticationException('Email inválido.');
      case 'email-already-in-use':
        throw const AuthenticationException('Este email já está em uso.');
      case 'weak-password':
        throw const AuthenticationException('Senha muito fraca.');

      // Operation issues
      case 'operation-not-allowed':
        throw const AuthenticationException('Operação não permitida.');
      case 'invalid-credential':
        throw const AuthenticationException('Credenciais inválidas.');
      case 'credential-already-in-use':
        throw const AuthenticationException('Credencial já está em uso.');

      // Network issues
      case 'network-request-failed':
        throw const ServerException('Erro de conexão. Verifique sua internet.');

      // Default
      default:
        throw AuthenticationException(
          'Erro de autenticação: ${e.message ?? e.code}',
        );
    }
  }

  /// Verifica se há usuário autenticado
  ///
  /// Lança [AuthenticationException] se não houver usuário
  void ensureUserAuthenticated(User? user, [String? operation]) {
    if (user == null) {
      final message = operation != null
          ? 'No user signed in for operation: $operation'
          : 'No user signed in';
      throw AuthenticationException(message);
    }
  }

  /// Valida resultado de autenticação
  ///
  /// Lança [AuthenticationException] se o usuário for nulo
  User validateAuthResult(UserCredential credential, String operation) {
    if (credential.user == null) {
      throw AuthenticationException('No user returned from $operation');
    }
    return credential.user!;
  }
}
