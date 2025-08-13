/// Interface para gerenciamento de favoritos
abstract class IFavoriteService {
  /// Verifica se um item está marcado como favorito
  Future<bool> isFavorite(String category, String itemId);
  
  /// Alterna o status de favorito de um item
  Future<bool> toggleFavorite(String category, String itemId);
  
  /// Remove um item dos favoritos
  Future<void> removeFavorite(String category, String itemId);
  
  /// Adiciona um item aos favoritos
  Future<void> addFavorite(String category, String itemId);
}