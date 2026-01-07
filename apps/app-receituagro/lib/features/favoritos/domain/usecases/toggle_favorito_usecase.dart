import 'package:core/core.dart';

import '../entities/favorito_entity.dart';
import '../repositories/i_favoritos_repository.dart';

/// UseCase genérico para alternar (toggle) qualquer tipo de favorito
///
/// **Responsabilidade:** Trata add/remove de forma atômica
///
/// **Benefício:** Simplifica lógica de UI que precisa adicionar OU remover baseado em estado

class ToggleFavoritoUseCase {
  final IFavoritosRepository _repository;

  const ToggleFavoritoUseCase(this._repository);

  /// Alterna (toggle) um favorito
  ///
  /// Se estiver nos favoritos: Remove
  /// Se não estiver: Adiciona
  ///
  /// **Parâmetros:**
  /// - `tipo`: Tipo de favorito (TipoFavorito.defensivo, .praga, .diagnostico, .cultura)
  /// - `id`: ID do item favorito
  /// - `favorito`: (Opcional) Entidade do favorito para ser adicionada caso não exista
  ///
  /// **Exemplo de uso:**
  /// ```dart
  /// // Modo 1: Apenas toggle by tipo/id (remove se existe)
  /// var result = await toggleFavoritoUseCase(
  ///   tipo: TipoFavorito.defensivo,
  ///   id: '123',
  /// );
  ///
  /// // Modo 2: Toggle com entidade (adiciona a entidade se não existe)
  /// var result = await toggleFavoritoUseCase(
  ///   tipo: TipoFavorito.defensivo,
  ///   id: '123',
  ///   favorito: FavoritoDefensivoEntity(...),
  /// );
  ///
  /// result.fold(
  ///   (failure) => debugPrint('Erro: ${failure.message}'),
  ///   (toggledOn) => debugPrint(toggledOn ? '✓ Adicionado' : '✗ Removido'),
  /// );
  /// ```
  ///
  /// **Retorno:** bool indicando estado final (true = está nos favoritos, false = não está)
  Future<Either<Failure, bool>> call({
    required String tipo,
    required String id,
    FavoritoEntity? favorito,
  }) async {
    // Validação de parâmetros
    if (tipo.isEmpty || id.isEmpty) {
      return const Left<Failure, bool>(
        ValidationFailure('Tipo e ID são obrigatórios'),
      );
    }

    // Verifica estado atual
    final isFavoriteResult = await _repository.isFavorito(tipo, id);

    return isFavoriteResult.fold((failure) => Left<Failure, bool>(failure), (
          isFavorite,
        ) async {
          if (isFavorite) {
            // Já está nos favoritos: Remove
            final removeResult = await _repository.removeFavorito(tipo, id);
            return removeResult.fold(
              (failure) => Left<Failure, bool>(failure),
              (_) => const Right<Failure, bool>(false),
            );
          } else {
            // Não está nos favoritos: Adiciona
            if (favorito != null) {
              return _repository
                  .addFavorito(favorito)
                  .then(
                    (result) => result.fold(
                      (failure) => Left<Failure, bool>(failure),
                      (_) => const Right<Failure, bool>(true),
                    ),
                  );
            } else {
              return const Left<Failure, bool>(
                ValidationFailure(
                  'Entidade do favorito é obrigatória para adicionar',
                ),
              );
            }
          }
        })
        as Future<Either<Failure, bool>>;
  }
}
