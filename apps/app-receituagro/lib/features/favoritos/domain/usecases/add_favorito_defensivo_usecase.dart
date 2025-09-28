import 'package:core/core.dart';
import 'package:core/core.dart';

import '../repositories/i_favoritos_repository.dart';

/// Use Case para adicionar um defensivo aos favoritos
/// Segue padrão `Either<Failure, Success>` do core package
class AddFavoritoDefensivoUseCase {
  final IFavoritosDefensivosRepository _repository;
  final IFavoritosValidator _validator;

  const AddFavoritoDefensivoUseCase(
    this._repository,
    this._validator,
  );

  /// Executa o caso de uso para adicionar defensivo aos favoritos
  /// Retorna `Either<Failure, bool>`
  Future<Either<Failure, bool>> call(String defensivoId) async {
    try {
      // Validação de entrada
      if (!_validator.isValidId(defensivoId)) {
        return Left(
          ValidationFailure('ID do defensivo é inválido: $defensivoId'),
        );
      }

      // Verifica se o defensivo existe no sistema
      final exists = await _validator.exists('defensivo', defensivoId);
      if (!exists) {
        return Left(
          NotFoundFailure('Defensivo não encontrado: $defensivoId'),
        );
      }

      // Verifica se já está nos favoritos
      final isAlreadyFavorite = await _repository.isDefensivoFavorito(defensivoId);
      if (isAlreadyFavorite) {
        return Left(
          ValidationFailure('Defensivo já está nos favoritos: $defensivoId'),
        );
      }

      // Adiciona aos favoritos
      final result = await _repository.addDefensivo(defensivoId);
      
      if (!result) {
        return Left(
          CacheFailure('Falha ao adicionar defensivo aos favoritos: $defensivoId'),
        );
      }

      return Right(result);
      
    } catch (e) {
      return Left(
        CacheFailure('Erro ao adicionar defensivo aos favoritos: ${e.toString()}'),
      );
    }
  }
}