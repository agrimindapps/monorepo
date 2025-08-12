/// Exceções customizadas para o módulo lembretes_cadastro
/// 
/// Permite tratamento específico de diferentes tipos de erro
library;

/// Exceção base para erros de lembrete
abstract class LembreteException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const LembreteException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'LembreteException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exceção para erros de validação
class ValidationException extends LembreteException {
  final String fieldName;

  const ValidationException(
    super.message, {
    required this.fieldName,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ValidationException [$fieldName]: $message';
}

/// Exceção para erros de rede/conectividade
class NetworkException extends LembreteException {
  final int? statusCode;
  final String? endpoint;

  const NetworkException(
    super.message, {
    this.statusCode,
    this.endpoint,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exceção para erros de permissão
class PermissionException extends LembreteException {
  final String? permission;

  const PermissionException(
    super.message, {
    this.permission,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'PermissionException: $message${permission != null ? ' (Permission: $permission)' : ''}';
}

/// Exceção para erros de armazenamento
class StorageException extends LembreteException {
  final String? path;

  const StorageException(
    super.message, {
    this.path,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'StorageException: $message${path != null ? ' (Path: $path)' : ''}';
}

/// Exceção para erros de notificação
class NotificationException extends LembreteException {
  final String? notificationId;

  const NotificationException(
    super.message, {
    this.notificationId,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NotificationException: $message${notificationId != null ? ' (ID: $notificationId)' : ''}';
}

/// Exceção para operações de time-out
class TimeoutException extends LembreteException {
  final Duration timeout;

  const TimeoutException(
    super.message, {
    required this.timeout,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}

/// Exceção para recursos não encontrados
class NotFoundException extends LembreteException {
  final String? resourceId;
  final String? resourceType;

  const NotFoundException(
    super.message, {
    this.resourceId,
    this.resourceType,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NotFoundException: $message${resourceType != null ? ' ($resourceType)' : ''}';
}

/// Exceção para conflitos de dados
class ConflictException extends LembreteException {
  final String? conflictingField;

  const ConflictException(
    super.message, {
    this.conflictingField,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ConflictException: $message${conflictingField != null ? ' (Field: $conflictingField)' : ''}';
}

/// Factory para criação de exceções baseadas em contexto
class LembreteExceptionFactory {
  static LembreteException fromError(dynamic error, {String? context}) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return NetworkException(
        'Erro de conexão: ${_getCleanMessage(error)}',
        originalError: error,
      );
    }

    if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return PermissionException(
        'Sem permissão: ${_getCleanMessage(error)}',
        originalError: error,
      );
    }

    if (errorString.contains('storage') || errorString.contains('disk')) {
      return StorageException(
        'Erro de armazenamento: ${_getCleanMessage(error)}',
        originalError: error,
      );
    }

    if (errorString.contains('timeout')) {
      return TimeoutException(
        'Operação expirou: ${_getCleanMessage(error)}',
        timeout: const Duration(seconds: 30),
        originalError: error,
      );
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return NotFoundException(
        'Recurso não encontrado: ${_getCleanMessage(error)}',
        originalError: error,
      );
    }

    if (errorString.contains('conflict') || errorString.contains('409')) {
      return ConflictException(
        'Conflito de dados: ${_getCleanMessage(error)}',
        originalError: error,
      );
    }

    if (errorString.contains('notification')) {
      return NotificationException(
        'Erro de notificação: ${_getCleanMessage(error)}',
        originalError: error,
      );
    }

    // Fallback para erro genérico
    return _GenericLembreteException(
      context != null ? '$context: ${_getCleanMessage(error)}' : _getCleanMessage(error),
      originalError: error,
    );
  }

  static String _getCleanMessage(dynamic error) {
    if (error == null) return 'Erro desconhecido';
    
    String message = error.toString();
    
    // Remove stack traces e informações técnicas desnecessárias
    if (message.contains('\n')) {
      message = message.split('\n').first;
    }
    
    // Remove prefixos técnicos comuns
    final prefixesToRemove = [
      'Exception: ',
      'Error: ',
      'FormatException: ',
      'StateError: ',
      'ArgumentError: ',
    ];
    
    for (final prefix in prefixesToRemove) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length);
        break;
      }
    }
    
    return message.trim();
  }
}

/// Implementação genérica para exceções não categorizadas
class _GenericLembreteException extends LembreteException {
  const _GenericLembreteException(super.message, {super.originalError});
}