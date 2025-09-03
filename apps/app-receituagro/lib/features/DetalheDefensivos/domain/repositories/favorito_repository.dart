import '../../../../core/utils/typedef.dart';
import '../entities/favorito_entity.dart';

/// Contrato do repositório de favoritos
/// 
/// Define as operações disponíveis para favoritos,
/// seguindo os princípios de Clean Architecture
abstract class FavoritoRepository {
  /// Adiciona um item aos favoritos
  ResultFuture<String> addFavorito(FavoritoEntity favorito);
  
  /// Remove um item dos favoritos
  ResultFuture<void> removeFavorito(String itemId, String tipo);
  
  /// Verifica se um item está nos favoritos
  ResultFuture<bool> isFavorito(String itemId, String tipo);
  
  /// Busca favoritos por tipo
  ResultFuture<List<FavoritoEntity>> getFavoritosByTipo(String tipo);
  
  /// Lista todos os favoritos do usuário
  ResultFuture<List<FavoritoEntity>> getAllFavoritos();
  
  /// Busca favoritos por query de texto
  ResultFuture<List<FavoritoEntity>> searchFavoritos(String query);
  
  /// Stream de favoritos em tempo real
  Stream<List<FavoritoEntity>> watchFavoritos();
  
  /// Conta o número de favoritos por tipo
  ResultFuture<int> countFavoritosByTipo(String tipo);
  
  /// Remove todos os favoritos (limpar cache)
  ResultFuture<void> clearAllFavoritos();
}