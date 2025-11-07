import 'app_error.dart';

/// Service para mapear Failures para AppErrors (SRP - Single Responsibility)
/// Reutilizável por todos os Notifiers do app
abstract class ErrorMapper {
  /// Mapeia Failure genérico para AppError específico
  AppError mapFailureToError(dynamic failure);
}

/// Implementação do ErrorMapper
class ErrorMapperImpl implements ErrorMapper {
  @override
  AppError mapFailureToError(dynamic failure) {
    final failureString = failure.toString().toLowerCase();

    if (failureString.contains('network') ||
        failureString.contains('connection')) {
      return NetworkError(
        message: 'Erro de conexão. Verifique sua internet.',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('timeout')) {
      return TimeoutError(
        message: 'Operação demorou muito',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('server')) {
      return ServerError(
        message: 'Erro do servidor. Tente novamente mais tarde.',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('cache')) {
      return CacheError(
        message: 'Erro de cache local.',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('not found')) {
      return NotFoundError(
        message: 'Recurso não encontrado.',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('unauthorized') ||
        failureString.contains('authentication')) {
      return UnauthorizedError(
        message: 'Não autorizado.',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('validation')) {
      return ValidationError(
        message: 'Dados inválidos.',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('conflict')) {
      return ConflictError(
        message: 'Conflito de dados.',
        technicalDetails: failure.toString(),
      );
    } else if (failureString.contains('sync')) {
      return SyncError(
        message: 'Erro de sincronização.',
        technicalDetails: failure.toString(),
      );
    } else {
      return UnexpectedError(
        message: 'Erro inesperado. Tente novamente.',
        technicalDetails: failure.toString(),
      );
    }
  }
}
