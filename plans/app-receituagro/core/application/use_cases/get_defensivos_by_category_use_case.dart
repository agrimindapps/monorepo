// Project imports:
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../error/result.dart';
import '../dtos/defensivo_dto.dart';
import '../mappers/defensivos_mapper.dart';

/// UseCase responsável por obter defensivos por categoria
/// 
/// Implementa lógica de negócio para filtros e validações de categoria
class GetDefensivosByCategoryUseCase {
  final IDefensivosRepository _repository;
  final DefensivosMapper _mapper;

  const GetDefensivosByCategoryUseCase(
    this._repository,
    this._mapper,
  );

  /// Executa a busca por defensivos de uma categoria específica
  /// 
  /// [category] - Categoria a ser buscada (fabricante, classe agronômica, etc.)
  /// 
  /// Retorna [Result] com lista de [DefensivoDto]
  Future<Result<List<DefensivoDto>>> execute(String category) async {
    try {
      // Validação de entrada
      if (category.trim().isEmpty) {
        return Result.failure(ValidationError(
          field: 'category',
          value: category,
          message: 'Categoria não pode ser vazia',
        ));
      }

      // Verifica se os dados estão carregados
      if (!_repository.isDataLoaded) {
        final initResult = await _repository.initialize();
        if (initResult.isFailure) {
          return Result.failure(initResult.errorOrNull!);
        }
      }

      // Busca defensivos por categoria
      final result = await _repository.getDefensivosByCategory(category);
      
      if (result.isFailure) {
        return Result.failure(result.errorOrNull!);
      }

      // Converte entities para DTOs
      final entities = result.valueOrNull!;
      final dtos = _mapper.defensivoEntitiesToDtos(entities);

      // Aplica ordenação padrão (alfabética por nome comercial)
      dtos.sort((a, b) => a.nomeComercial.compareTo(b.nomeComercial));

      return Result.success(dtos);

    } catch (e) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getDefensivosByCategory',
        message: 'Erro ao buscar defensivos por categoria: ${e.toString()}',
      ));
    }
  }
}