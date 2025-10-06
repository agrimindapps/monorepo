import 'package:core/core.dart';

import '../entities/favorito_entity.dart';
import '../repositories/i_favoritos_repository.dart';

/// Use Case para obter lista de defensivos favoritos
/// Segue padrão `Either<Failure, Success>` do core package
class GetFavoritoDefensivosUseCase {
  final IFavoritosDefensivosRepository _repository;

  const GetFavoritoDefensivosUseCase(this._repository);

  /// Executa o caso de uso para obter defensivos favoritos
  /// Retorna `Either<Failure, List<FavoritoDefensivoEntity>>`
  Future<Either<Failure, List<FavoritoDefensivoEntity>>> call() async {
    try {
      final defensivosFavoritos = await _repository.getDefensivos();
      
      return Right(defensivosFavoritos);
      
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter defensivos favoritos: ${e.toString()}'),
      );
    }
  }
}