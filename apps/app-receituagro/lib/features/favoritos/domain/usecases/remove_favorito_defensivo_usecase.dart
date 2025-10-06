import 'package:core/core.dart';

import '../repositories/i_favoritos_repository.dart';

/// Use Case para remover um defensivo dos favoritos
/// Segue padrão `Either<Failure, Success>` do core package
class RemoveFavoritoDefensivoUseCase {
  final IFavoritosDefensivosRepository _repository;
  final IFavoritosValidator _validator;

  const RemoveFavoritoDefensivoUseCase(
    this._repository,
    this._validator,
  );

  /// Executa o caso de uso para remover defensivo dos favoritos
  /// Retorna `Either<Failure, bool>`
  Future<Either<Failure, bool>> call(String defensivoId) async {
    try {
      if (!_validator.isValidId(defensivoId)) {
        return Left(
          ValidationFailure('ID do defensivo é inválido: $defensivoId'),
        );
      }
      final isFavorite = await _repository.isDefensivoFavorito(defensivoId);
      if (!isFavorite) {
        return Left(
          NotFoundFailure('Defensivo não está nos favoritos: $defensivoId'),
        );
      }
      final result = await _repository.removeDefensivo(defensivoId);
      
      if (!result) {
        return Left(
          CacheFailure('Falha ao remover defensivo dos favoritos: $defensivoId'),
        );
      }

      return Right(result);
      
    } catch (e) {
      return Left(
        CacheFailure('Erro ao remover defensivo dos favoritos: ${e.toString()}'),
      );
    }
  }
}