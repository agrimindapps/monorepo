import 'package:core/core.dart';

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
@Deprecated("Deprecated - use alternative")
@injectable
class AddFavoritoDefensivoUseCase {
  final IFavoritosDefensivosRepository _repository;
  final IFavoritosValidator _validator;

  const AddFavoritoDefensivoUseCase(this._repository, this._validator);

  /// Executa o caso de uso para adicionar defensivo aos favoritos
  /// Retorna `Either<Failure, bool>`
  Future<Either<Failure, bool>> call(String defensivoId) async {
    if (!_validator.isValidId(defensivoId)) {
      return Left<Failure, bool>(
        ValidationFailure('ID do defensivo é inválido: $defensivoId'),
      );
    }

    final exists = await _validator.exists('defensivo', defensivoId);
    if (!exists) {
      return Left<Failure, bool>(
        NotFoundFailure('Defensivo não encontrado: $defensivoId'),
      );
    }

    final isAlreadyFavorite = await _repository.isDefensivoFavorito(defensivoId);
    if (isAlreadyFavorite) {
      return Left<Failure, bool>(
        ValidationFailure('Defensivo já está nos favoritos: $defensivoId'),
      );
    }

    try {
      final result = await _repository.addDefensivo(defensivoId);
      return Right<Failure, bool>(result);
    } catch (e) {
      return Left<Failure, bool>(
        CacheFailure('Erro ao adicionar defensivo aos favoritos: ${e.toString()}'),
      );
    }
  }
}
