import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Utility class responsible for mapping Failures to user-friendly messages
/// Moved from PlantsCrudService to follow proper layer separation
/// Domain services should not contain UI strings
class FailureMessageMapper {
  /// Map a Failure to a user-friendly message
  static String map(Failure failure) {
    if (kDebugMode) {
      debugPrint('FailureMessageMapper - Mapping failure:');
      debugPrint('- Type: ${failure.runtimeType}');
      debugPrint('- Message: ${failure.message}');
    }

    switch (failure.runtimeType) {
      case const (ValidationFailure):
        return _mapValidationFailure(failure);

      case const (CacheFailure):
        return _mapCacheFailure(failure);

      case const (NetworkFailure):
        return _mapNetworkFailure(failure);

      case const (ServerFailure):
        return _mapServerFailure(failure);

      case const (NotFoundFailure):
        return _mapNotFoundFailure(failure);

      default:
        return _mapUnknownFailure(failure);
    }
  }

  static String _mapValidationFailure(Failure failure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'Dados inválidos fornecidos';
  }

  static String _mapCacheFailure(Failure failure) {
    // Handle specific database/adapter errors
    if (failure.message.contains('PlantaModelAdapter') ||
        failure.message.contains('TypeAdapter')) {
      return 'Erro ao acessar dados locais. O app será reiniciado para corrigir o problema.';
    }

    if (failure.message.contains('DatabaseError') ||
        failure.message.contains('corrupted')) {
      return 'Dados locais corrompidos. Sincronizando com servidor...';
    }

    return failure.message.isNotEmpty
        ? 'Cache: ${failure.message}'
        : 'Erro ao acessar dados locais';
  }

  static String _mapNetworkFailure(Failure failure) {
    return 'Sem conexão com a internet. Verifique sua conectividade.';
  }

  static String _mapServerFailure(Failure failure) {
    // Handle authentication errors
    if (failure.message.contains('não autenticado') ||
        failure.message.contains('unauthorized') ||
        failure.message.contains('Usuário não autenticado')) {
      return 'Sessão expirada. Tente fazer login novamente.';
    }

    // Handle permission errors
    if (failure.message.contains('403') ||
        failure.message.contains('Forbidden')) {
      return 'Acesso negado. Verifique suas permissões.';
    }

    // Handle server errors
    if (failure.message.contains('500') ||
        failure.message.contains('Internal')) {
      return 'Erro no servidor. Tente novamente em alguns instantes.';
    }

    return failure.message.isNotEmpty
        ? 'Servidor: ${failure.message}'
        : 'Erro no servidor';
  }

  static String _mapNotFoundFailure(Failure failure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'Dados não encontrados';
  }

  static String _mapUnknownFailure(Failure failure) {
    final errorContext = kDebugMode
        ? ' (${failure.runtimeType}: ${failure.message})'
        : '';
    return 'Ops! Algo deu errado$errorContext';
  }

  /// Get a short error message suitable for snackbars
  static String mapToShortMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ValidationFailure):
        return 'Dados inválidos';

      case const (CacheFailure):
        return 'Erro local';

      case const (NetworkFailure):
        return 'Sem internet';

      case const (ServerFailure):
        if (failure.message.contains('não autenticado')) {
          return 'Sessão expirada';
        }
        return 'Erro no servidor';

      case const (NotFoundFailure):
        return 'Não encontrado';

      default:
        return 'Erro';
    }
  }

  /// Check if the failure requires user action
  static bool requiresUserAction(Failure failure) {
    return failure is NetworkFailure ||
        (failure is ServerFailure &&
            failure.message.contains('não autenticado'));
  }

  /// Get suggested action for the failure
  static String? getSuggestedAction(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Verifique sua conexão e tente novamente';
    }

    if (failure is ServerFailure &&
        failure.message.contains('não autenticado')) {
      return 'Faça login novamente';
    }

    if (failure is CacheFailure &&
        (failure.message.contains('corrupted') ||
            failure.message.contains('TypeAdapter'))) {
      return 'Reinicie o aplicativo';
    }

    return null;
  }
}
