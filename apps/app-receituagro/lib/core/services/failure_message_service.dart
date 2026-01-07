import 'package:core/core.dart' hide Column, Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'failure_message_service.g.dart';

/// Service specialized in mapping Failure types to user-friendly messages
/// Principle: Single Responsibility - Only handles Failure to message mapping
@riverpod
FailureMessageService failureMessageService(Ref ref) {
  return FailureMessageService();
}

class FailureMessageService {
  /// Maps a Failure to a user-friendly error message
  String mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Erro do servidor. Tente novamente.';

      case CacheFailure _:
        return 'Erro ao acessar dados locais.';

      case NetworkFailure _:
        return 'Erro de conexão. Verifique sua internet.';

      case ValidationFailure _:
        final validationFailure = failure as ValidationFailure;
        return validationFailure.message;

      case NotFoundFailure _:
        return 'Dados não encontrados.';

      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }

  /// Gets detailed technical message from Failure
  String getTechnicalMessage(Failure failure) {
    return failure.toString();
  }

  /// Checks if the failure is retryable
  bool canRetry(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
      case NetworkFailure _:
      case CacheFailure _:
        return true;

      case ValidationFailure _:
      case NotFoundFailure _:
        return false;

      default:
        return true;
    }
  }

  /// Gets suggestions based on failure type
  List<String> getSuggestions(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return [
          'Tente novamente em alguns instantes',
          'Verifique se o serviço está disponível',
        ];

      case NetworkFailure _:
        return [
          'Verifique sua conexão com a internet',
          'Tente mudar de rede Wi-Fi',
          'Ative os dados móveis',
        ];

      case CacheFailure _:
        return ['Limpe o cache do aplicativo', 'Reinstale o aplicativo'];

      case ValidationFailure _:
        return ['Verifique os dados inseridos', 'Corrija os campos destacados'];

      case NotFoundFailure _:
        return ['Recarregue os dados', 'Verifique se o item ainda existe'];

      default:
        return [
          'Tente novamente',
          'Entre em contato com o suporte se o problema persistir',
        ];
    }
  }
}
