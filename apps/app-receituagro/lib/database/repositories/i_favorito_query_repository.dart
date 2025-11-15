import 'package:core/core.dart';

import 'favorito_repository.dart';

/// Interface Segregation Pattern: Query & Search operations for favoritos
/// 
/// Focused responsibility: Search, filter, count, and complex queries
/// Does NOT include mutation operations (add, update, delete)
/// 
/// This follows ISP principle - clients only depend on methods they use
abstract class IFavoritoQueryRepository {
  /// Busca favoritos do usuário por tipo (multi-result)
  Future<List<FavoritoData>> findByUserAndType(String userId, String tipo);

  /// Verifica se um item está favoritado
  Future<bool> isFavorited(String userId, String tipo, String itemId);

  /// Busca favoritos recentes (últimos N)
  Future<List<FavoritoData>> findRecent(String userId, {int limit = 10});

  /// Conta total de favoritos do usuário
  Future<int> countByUserId(String userId);

  /// Conta favoritos do usuário por tipo
  Future<Map<String, int>> countByType(String userId);
}
