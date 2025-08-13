// Project imports:
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../error/result.dart';

/// UseCase responsável por registrar o acesso a um defensivo
/// 
/// Implementa as regras de negócio para tracking de acessos,
/// incluindo validações e lógica de timestamp
class RegisterDefensivoAccessUseCase {
  final IDefensivosRepository _repository;

  const RegisterDefensivoAccessUseCase(this._repository);

  /// Executa o registro de acesso ao defensivo
  /// 
  /// [defensivoId] - ID do defensivo acessado
  /// 
  /// Retorna [Result<void>] indicando sucesso ou erro
  Future<Result<void>> execute(String defensivoId) async {
    try {
      // Validação de entrada
      if (defensivoId.trim().isEmpty) {
        return Result.failure(ValidationError(
          field: 'defensivoId',
          value: defensivoId,
          message: 'ID do defensivo não pode ser vazio',
        ));
      }

      // Verifica se o defensivo existe antes de registrar acesso
      final defensivoResult = await _repository.getDefensivoById(defensivoId);
      if (defensivoResult.isFailure) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'registerAccess',
          message: 'Defensivo não encontrado: $defensivoId',
        ));
      }

      // Registra o acesso
      final registerResult = await _repository.registerDefensivoAccess(defensivoId);
      
      if (registerResult.isFailure) {
        return Result.failure(registerResult.errorOrNull!);
      }

      return Result.success(null);

    } catch (e) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'registerDefensivoAccess',
        message: 'Erro ao registrar acesso ao defensivo: ${e.toString()}',
      ));
    }
  }
}