import 'package:core/core.dart' hide Column;

import '../repositories/i_favoritos_repository.dart';

/// Use Case para adicionar um defensivo aos favoritos
/// Segue padrão `Either<Failure, Success>` do core package
///
/// @Deprecated Substituído por `AddFavoritoUseCase` genérico (mais reutilizável)
///
/// **Migração:** Use `AddFavoritoUseCase` em vez deste:
/// ```dart
/// // Antes (específico):
/// final result = await addFavoritoDefensivoUseCase('defensivoId');
///
/// // Depois (genérico):
/// final defensivo = FavoritoDefensivoEntity(...);
/// final result = await addFavoritoUseCase(defensivo);
/// ```
///
/// **Benefício:** Um único usecase para todos os tipos (Defensivos, Pragas, Diagnósticos, Culturas)
@deprecated
@injectable
class AddFavoritoDefensivoUseCase {
  final IFavoritosDefensivosRepository _repository;
  final IFavoritosValidator _validator;

  const AddFavoritoDefensivoUseCase(this._repository, this._validator);

  /// Executa o caso de uso para adicionar defensivo aos favoritos
  /// Retorna `Either<Failure, bool>`
  Future<Either<Failure, bool>> call(String defensivoId) async {
    try {
      if (!_validator.isValidId(defensivoId)) {
        return Left(
          ValidationFailure('ID do defensivo é inválido: $defensivoId'),
        );
      }
      final exists = await _validator.exists('defensivo', defensivoId);
      if (!exists) {
        return Left(NotFoundFailure('Defensivo não encontrado: $defensivoId'));
      }
      final isAlreadyFavorite = await _repository.isDefensivoFavorito(
        defensivoId,
      );
      if (isAlreadyFavorite) {
        return Left(
          ValidationFailure('Defensivo já está nos favoritos: $defensivoId'),
        );
      }
      final result = await _repository.addDefensivo(defensivoId);

      if (!result) {
        return Left(
          CacheFailure(
            'Falha ao adicionar defensivo aos favoritos: $defensivoId',
          ),
        );
      }

      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao adicionar defensivo aos favoritos: ${e.toString()}',
        ),
      );
    }
  }
}
