import 'package:core/core.dart';

import '../repositories/i_favoritos_repository.dart';

/// Use Case para remover um defensivo dos favoritos
/// Segue padrão `Either<Failure, Success>` do core package
///
/// @Deprecated Substituído por `RemoveFavoritoUseCase` genérico (mais reutilizável)
///
/// **Migração:** Use `RemoveFavoritoUseCase` em vez deste:
/// ```dart
/// // Antes (específico):
/// final result = await removeFavoritoDefensivoUseCase('defensivoId');
///
/// // Depois (genérico):
/// final result = await removeFavoritoUseCase(
///   tipo: TipoFavorito.defensivo,
///   id: 'defensivoId',
/// );
/// ```
///
/// **Benefício:** Um único usecase para todos os tipos (Defensivos, Pragas, Diagnósticos, Culturas)
@Deprecated("Deprecated - use alternative")
class RemoveFavoritoDefensivoUseCase {
  final IFavoritosDefensivosRepository _repository;
  final IFavoritosValidator _validator;

  const RemoveFavoritoDefensivoUseCase(this._repository, this._validator);

  /// Executa o caso de uso para remover defensivo dos favoritos
  /// Retorna `Either<Failure, bool>`
  Future<Either<Failure, bool>> call(String defensivoId) async {
    if (!_validator.isValidId(defensivoId)) {
      return Left<Failure, bool>(
        ValidationFailure('ID do defensivo é inválido: $defensivoId'),
      );
    }

    final isFavorite = await _repository.isDefensivoFavorito(defensivoId);
    if (!isFavorite) {
      return Left<Failure, bool>(
        NotFoundFailure('Defensivo não está nos favoritos: $defensivoId'),
      );
    }

    try {
      final result = await _repository.removeDefensivo(defensivoId);
      return Right<Failure, bool>(result);
    } catch (e) {
      return Left<Failure, bool>(
        CacheFailure('Erro ao remover defensivo dos favoritos: ${e.toString()}'),
      );
    }
  }
}
