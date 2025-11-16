import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:core/core.dart';
import 'failures.dart';

/// Mapeia exceptions para failures específicos
/// Centraliza a lógica de conversão de erros de bibliotecas externas
class ExceptionMapper {
  /// Mapeia qualquer exception para um Failure apropriado
  static Failure mapException(dynamic exception, [StackTrace? stackTrace]) {
    // ⚠️ IMPORTANTE: Ordem de verificação importa!
    // Verificar tipos específicos ANTES de tipos genéricos

    // Firebase Auth exceptions (FirebaseAuthException extends FirebaseException)
    if (exception is auth.FirebaseAuthException) {
      return _mapFirebaseAuthException(exception, stackTrace);
    }

    // Firebase exceptions (Firestore ou Storage - diferenciar por plugin)
    if (exception is FirebaseException) {
      // Distinguir por plugin name
      if (exception.plugin.contains('storage') ||
          exception.plugin.contains('firebase_storage')) {
        return _mapFirebaseStorageException(exception, stackTrace);
      }
      // Default: Firestore
      return _mapFirebaseException(exception, stackTrace);
    }

    // Network/connectivity exceptions
    if (_isNetworkException(exception)) {
      return ConnectivityFailure(
        message: 'Sem conexão com a internet',
        code: 'NO_CONNECTION',
        details: exception.toString(),
      );
    }

    // Format exceptions (parsing)
    if (exception is FormatException) {
      return ParseFailure(
        'Erro ao processar dados: ${exception.message}',
        code: 'PARSE_ERROR',
        details: exception.toString(),
      );
    }

    // State errors
    if (exception is StateError) {
      return ValidationFailure(
        exception.message,
        code: 'STATE_ERROR',
        details: exception.toString(),
      );
    }

    // Argument errors
    if (exception is ArgumentError) {
      return ValidationFailure(
        exception.message?.toString() ?? 'Argumento inválido',
        code: 'ARGUMENT_ERROR',
        details: exception.toString(),
      );
    }

    // Fallback: unknown error
    return UnknownFailure(
      'Erro inesperado: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
      details: {
        'exception_type': exception.runtimeType.toString(),
        'exception': exception.toString(),
        if (stackTrace != null) 'stack_trace': stackTrace.toString(),
      },
    );
  }

  /// Mapeia Firebase Firestore exceptions
  static Failure _mapFirebaseException(
    FirebaseException exception,
    StackTrace? stackTrace,
  ) {
    final code = exception.code;
    final message = exception.message ?? 'Erro no Firebase';

    switch (code) {
      // Permission/Auth errors
      case 'permission-denied':
      case 'unauthenticated':
        return PermissionFailure(
          'Você não tem permissão para acessar estes dados',
          code: code,
          details: message,
        );

      // Network errors
      case 'unavailable':
      case 'deadline-exceeded':
        return ConnectivityFailure(
          message: 'Servidor temporariamente indisponível',
          code: code,
          details: message,
        );

      // Data errors
      case 'not-found':
        return NotFoundFailure(
          'Dados não encontrados',
          code: code,
          details: message,
        );

      case 'already-exists':
        return ValidationFailure(
          'Registro já existe',
          code: code,
          details: message,
        );

      case 'failed-precondition':
      case 'aborted':
        return FinancialConflictFailure(
          message:
              'Conflito ao salvar dados. Os dados foram modificados por outro dispositivo.',
          entityType: 'unknown',
          entityId: 'unknown',
          code: code,
          details: message,
        );

      // Storage/resource errors
      case 'resource-exhausted':
        return StorageFailure(
          message: 'Limite de recursos atingido',
          code: code,
          storageType: 'firebase',
          operation: 'write',
          details: message,
        );

      // Generic Firebase error
      default:
        return FirebaseFailure(
          message,
          code: code,
          details: exception.toString(),
        );
    }
  }

  /// Mapeia Firebase Auth exceptions
  static Failure _mapFirebaseAuthException(
    auth.FirebaseAuthException exception,
    StackTrace? stackTrace,
  ) {
    final code = exception.code;
    final message = exception.message ?? 'Erro de autenticação';

    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
        return AuthFailure(
          'Email ou senha incorretos',
          code: code,
          details: message,
        );

      case 'user-disabled':
        return AuthFailure(
          'Conta desabilitada. Entre em contato com o suporte',
          code: code,
          details: message,
        );

      case 'email-already-in-use':
        return ValidationFailure(
          'Este email já está em uso',
          code: code,
          details: message,
        );

      case 'weak-password':
        return ValidationFailure(
          'Senha muito fraca. Use pelo menos 6 caracteres',
          code: code,
          details: message,
        );

      case 'invalid-email':
        return ValidationFailure(
          'Email inválido',
          code: code,
          details: message,
        );

      case 'network-request-failed':
        return ConnectivityFailure(
          message: 'Erro de conexão ao autenticar',
          code: code,
          details: message,
        );

      case 'too-many-requests':
        return ValidationFailure(
          'Muitas tentativas. Aguarde alguns minutos e tente novamente',
          code: code,
          details: message,
        );

      default:
        return AuthFailure(message, code: code, details: exception.toString());
    }
  }

  /// Mapeia Firebase Storage exceptions
  static Failure _mapFirebaseStorageException(
    storage.FirebaseException exception,
    StackTrace? stackTrace,
  ) {
    final code = exception.code;
    final message = exception.message ?? 'Erro ao processar imagem';

    switch (code) {
      case 'object-not-found':
        return NotFoundFailure(
          'Imagem não encontrada',
          code: code,
          details: message,
        );

      case 'unauthorized':
      case 'unauthenticated':
        return PermissionFailure(
          'Sem permissão para acessar imagem',
          code: code,
          details: message,
        );

      case 'retry-limit-exceeded':
        return ConnectivityFailure(
          message: 'Falha ao processar imagem após várias tentativas',
          code: code,
          details: message,
        );

      case 'invalid-checksum':
        return ImageOperationFailure(
          message: 'Imagem corrompida durante upload',
          operation: 'upload',
          code: code,
          details: message,
        );

      case 'canceled':
        return ValidationFailure(
          'Operação cancelada',
          code: code,
          details: message,
        );

      default:
        return ImageOperationFailure(
          message: message,
          operation: 'unknown',
          code: code,
          details: exception.toString(),
        );
    }
  }

  /// Verifica se é uma exception de rede
  static bool _isNetworkException(dynamic exception) {
    final exceptionString = exception.toString().toLowerCase();
    return exceptionString.contains('socketexception') ||
        exceptionString.contains('networkexception') ||
        exceptionString.contains('connection refused') ||
        exceptionString.contains('failed host lookup') ||
        exceptionString.contains('network is unreachable') ||
        exceptionString.contains('timeout');
  }

  /// Cria FinancialIntegrityFailure para validações financeiras
  static FinancialIntegrityFailure createFinancialIntegrityFailure({
    required String message,
    String? fieldName,
    dynamic invalidValue,
    String? constraint,
  }) {
    return FinancialIntegrityFailure(
      message: message,
      fieldName: fieldName,
      invalidValue: invalidValue,
      constraint: constraint,
    );
  }

  /// Cria FinancialConflictFailure para conflitos de sincronização
  static FinancialConflictFailure createFinancialConflictFailure({
    required String message,
    required String entityType,
    required String entityId,
    dynamic localData,
    dynamic remoteData,
  }) {
    return FinancialConflictFailure(
      message: message,
      entityType: entityType,
      entityId: entityId,
      localData: localData,
      remoteData: remoteData,
    );
  }

  /// Cria IdReconciliationFailure para erros de ID mapping
  static IdReconciliationFailure createIdReconciliationFailure({
    required String message,
    required String localId,
    required String entityType,
    String? remoteId,
  }) {
    return IdReconciliationFailure(
      message: message,
      localId: localId,
      entityType: entityType,
      remoteId: remoteId,
    );
  }
}
