import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/defensivo_entity.dart';
import '../repositories/i_defensivos_repository.dart';

/// Use Case para busca de defensivos (LEGADO)
/// Mantido para compatibilidade com código existente
/// Recomenda-se usar os Use Cases específicos em get_defensivos_usecase.dart
class SearchDefensivosUseCase {
  final IDefensivosRepository _repository;

  const SearchDefensivosUseCase(this._repository);

  /// Executa busca de defensivos
  /// Retorna `Either<Failure, List<DefensivoEntity>>`
  Future<Either<Failure, List<DefensivoEntity>>> call({
    String? nomeComum,
    String? ingredienteAtivo,
    String? fabricante,
    String? classeAgron,
    int? limit,
    int? offset,
  }) async {
    try {
      Either<Failure, List<DefensivoEntity>> result;

      // Busca por nome comum
      if (nomeComum != null && nomeComum.trim().isNotEmpty) {
        result = await _repository.searchByNomeComum(nomeComum.trim());
      }
      // Busca por ingrediente ativo
      else if (ingredienteAtivo != null && ingredienteAtivo.trim().isNotEmpty) {
        result = await _repository.searchByIngredienteAtivo(ingredienteAtivo.trim());
      }
      // Busca por fabricante
      else if (fabricante != null && fabricante.trim().isNotEmpty) {
        result = await _repository.searchByFabricante(fabricante.trim());
      }
      // Busca por classe agronômica
      else if (classeAgron != null && classeAgron.trim().isNotEmpty) {
        result = await _repository.searchByClasseAgronomica(classeAgron.trim());
      }
      // Busca geral (todos os defensivos)
      else {
        result = await _repository.getAll(limit: limit, offset: offset);
      }

      return result;
      
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar defensivos: ${e.toString()}'),
      );
    }
  }
}

// Interface e Entity movidas para arquivos dedicados:
// - ../repositories/i_defensivos_repository.dart  
// - ../entities/defensivo_entity.dart