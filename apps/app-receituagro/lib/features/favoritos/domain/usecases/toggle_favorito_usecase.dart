import 'package:core/core.dart' hide Column;

import '../entities/favorito_entity.dart';
import '../repositories/i_favoritos_repository.dart';

/// UseCase genérico para alternar (toggle) qualquer tipo de favorito
///
/// **Responsabilidade:** Trata add/remove de forma atômica
///
/// **Benefício:** Simplifica lógica de UI que precisa adicionar OU remover baseado em estado
@injectable
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
  ///   (failure) => print('Erro: ${failure.message}'),
  ///   (toggledOn) => print(toggledOn ? '✓ Adicionado' : '✗ Removido'),
  /// );
  /// ```
  ///
  /// **Retorno:** bool indicando estado final (true = está nos favoritos, false = não está)
  Future<Either<Failure, bool>> call({
    required String tipo,
    required String id,
    FavoritoEntity? favorito,
  }) async {
    try {
      // Validação de parâmetros
      if (tipo.isEmpty || id.isEmpty) {
        return Left(ValidationFailure('Tipo e ID são obrigatórios'));
      }

      // Verifica estado atual
      final isFavorite = await _repository.isFavorito(tipo, id);

      if (isFavorite) {
        // Já está nos favoritos: Remove
        final removeResult = await _repository.removeFavorito(tipo, id);

        if (!removeResult) {
          return Left(CacheFailure('Falha ao remover dos favoritos'));
        }

        // Retorna false (não está mais nos favoritos)
        return const Right(false);
      } else {
        // Não está nos favoritos: Adiciona

        // Se temos a entidade, usamos ela
        if (favorito != null) {
          final addResult = await _repository.addFavorito(favorito);

          if (!addResult) {
            return Left(CacheFailure('Falha ao adicionar aos favoritos'));
          }

          // Retorna true (está nos favoritos agora)
          return const Right(true);
        } else {
          // Sem entidade completa, apenas marcamos como favorito
          // (comportamento simplificado para compatibilidade)
          return Left(
            ValidationFailure(
              'Entidade do favorito é obrigatória para adicionar',
            ),
          );
        }
      }
    } catch (e) {
      return Left(CacheFailure('Erro ao alternar favorito: ${e.toString()}'));
    }
  }
}
