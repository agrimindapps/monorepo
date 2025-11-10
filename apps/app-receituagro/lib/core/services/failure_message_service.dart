import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';

/// Service specialized in mapping Failure types to user-friendly messages
/// Principle: Single Responsibility - Only handles Failure to message mapping
@lazySingleton
class FailureMessageService {
  /// Maps a Failure to a user-friendly error message
  String mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Erro do servidor. Tente novamente.';

      case CacheFailure:
        return 'Erro ao acessar dados locais.';

      case NetworkFailure:
        return 'Erro de conexão. Verifique sua internet.';

      case ValidationFailure:
        final validationFailure = failure as ValidationFailure;
        return validationFailure.message;

      case NotFoundFailure:
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
      case ServerFailure:
      case NetworkFailure:
      case CacheFailure:
        return true;

      case ValidationFailure:
      case NotFoundFailure:
        return false;

      default:
        return true;
    }
  }

  /// Gets suggestions based on failure type
  List<String> getSuggestions(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return [
          'Tente novamente em alguns instantes',
          'Verifique se o serviço está disponível',
        ];

      case NetworkFailure:
        return [
          'Verifique sua conexão com a internet',
          'Tente mudar de rede Wi-Fi',
          'Ative os dados móveis',
        ];

      case CacheFailure:
        return ['Limpe o cache do aplicativo', 'Reinstale o aplicativo'];

      case ValidationFailure:
        return ['Verifique os dados inseridos', 'Corrija os campos destacados'];

      case NotFoundFailure:
        return ['Recarregue os dados', 'Verifique se o item ainda existe'];

      default:
        return [
          'Tente novamente',
          'Entre em contato com o suporte se o problema persistir',
        ];
    }
  }
}
