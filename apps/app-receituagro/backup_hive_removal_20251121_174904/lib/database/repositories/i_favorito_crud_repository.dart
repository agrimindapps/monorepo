
import 'favorito_repository.dart';

/// Interface Segregation Pattern: CRUD operations for favoritos
///
/// Focused responsibility: Create, Read, Update, Delete operations
/// Does NOT include search, filter, or query operations
///
/// This follows ISP principle - clients only depend on methods they use
abstract class IFavoritoCrudRepository {
  /// Adds a new favorito
  Future<int> addFavorito(
    String userId,
    String tipo,
    String itemId,
    String? itemData,
  );

  /// Busca favoritos do usuário
  Future<List<FavoritoData>> findByUserId(String userId);

  /// Busca um favorito específico
  Future<FavoritoData?> findByUserTypeAndItem(
    String userId,
    String tipo,
    String itemId,
  );

  /// Remove favorito (soft delete)
  Future<bool> removeFavorito(String userId, String tipo, String itemId);
}
