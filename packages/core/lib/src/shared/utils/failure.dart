import 'package:equatable/equatable.dart';

/// Classe base para representar falhas na aplicação
/// Usado com Either<Failure, Success> para programação funcional
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  /// Mensagem de erro para o usuário
  final String message;

  /// Código do erro (opcional)
  final String? code;

  /// Detalhes técnicos do erro (opcional)
  final dynamic details;

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Falha de servidor/rede
class ServerFailure extends Failure {
  const ServerFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de cache/storage local
class CacheFailure extends Failure {
  const CacheFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de validação de dados
class ValidationFailure extends Failure {
  const ValidationFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de autenticação
class AuthFailure extends Failure {
  const AuthFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de permissão/autorização
class PermissionFailure extends Failure {
  const PermissionFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de conexão de rede
class NetworkFailure extends Failure {
  const NetworkFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de parsing/conversão de dados
class ParseFailure extends Failure {
  const ParseFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha genérica/desconhecida
class UnknownFailure extends Failure {
  const UnknownFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha específica do Firebase
class FirebaseFailure extends Failure {
  const FirebaseFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha específica do RevenueCat
class RevenueCatFailure extends Failure {
  const RevenueCatFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de sincronização
class SyncFailure extends Failure {
  const SyncFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Falha de recurso não encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Extensions para facilitar o uso
extension FailureExtension on Failure {
  /// Retorna true se é uma falha de rede
  bool get isNetworkFailure =>
      this is NetworkFailure || this is ServerFailure;

  /// Retorna true se é uma falha de autenticação
  bool get isAuthFailure => this is AuthFailure;

  /// Retorna true se é uma falha de validação
  bool get isValidationFailure => this is ValidationFailure;

  /// Retorna uma mensagem user-friendly
  String get userMessage {
    if (this is NetworkFailure || this is ServerFailure) {
      return 'Problema de conexão. Verifique sua internet e tente novamente.';
    }
    if (this is AuthFailure) {
      return 'Erro de autenticação. Faça login novamente.';
    }
    if (this is ValidationFailure) {
      return message; // Mensagens de validação já são user-friendly
    }
    if (this is PermissionFailure) {
      return 'Você não tem permissão para esta ação.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}