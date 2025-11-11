import 'dart:developer' as developer;

import '../../domain/repositories/i_favoritos_repository.dart';

/// Implementação do storage local para favoritos usando Drift (Data Layer)
/// Substitui a versão baseada em Hive repositories
///
/// ⚠️ NOTA: Esta classe substitui FavoritosStorageService para usar Drift
class FavoritosStorageServiceDrift implements IFavoritosStorage {
  // TODO: Implementar usando FavoritoRepository do Drift
  // Por enquanto, mantém implementação vazia para compatibilidade

  @override
  Future<List<String>> getFavoriteIds(String tipo) async {
    // TODO: Implementar usando Drift
    developer.log(
      'FavoritosStorageServiceDrift.getFavoriteIds: TODO - implementar',
      name: 'FavoritosStorageServiceDrift',
    );
    return [];
  }

  @override
  Future<bool> addFavoriteId(String tipo, String id) async {
    // TODO: Implementar usando Drift
    developer.log(
      'FavoritosStorageServiceDrift.addFavoriteId: TODO - implementar',
      name: 'FavoritosStorageServiceDrift',
    );
    return false;
  }

  @override
  Future<bool> removeFavoriteId(String tipo, String id) async {
    // TODO: Implementar usando Drift
    developer.log(
      'FavoritosStorageServiceDrift.removeFavoriteId: TODO - implementar',
      name: 'FavoritosStorageServiceDrift',
    );
    return false;
  }

  @override
  Future<bool> isFavoriteId(String tipo, String id) async {
    // TODO: Implementar usando Drift
    developer.log(
      'FavoritosStorageServiceDrift.isFavoriteId: TODO - implementar',
      name: 'FavoritosStorageServiceDrift',
    );
    return false;
  }

  @override
  Future<void> clearFavorites(String tipo) async {
    // TODO: Implementar usando Drift
    developer.log(
      'FavoritosStorageServiceDrift.clearFavorites: TODO - implementar',
      name: 'FavoritosStorageServiceDrift',
    );
  }

  @override
  Future<void> clearAllFavorites() async {
    // TODO: Implementar usando Drift
    developer.log(
      'FavoritosStorageServiceDrift.clearAllFavorites: TODO - implementar',
      name: 'FavoritosStorageServiceDrift',
    );
  }

  @override
  Future<void> syncFavorites() async {
    // TODO: Implementar usando Drift
    developer.log(
      'FavoritosStorageServiceDrift.syncFavorites: TODO - implementar',
      name: 'FavoritosStorageServiceDrift',
    );
  }

  /// Singleton instance
  static FavoritosStorageServiceDrift? _instance;
  static FavoritosStorageServiceDrift get instance {
    _instance ??= FavoritosStorageServiceDrift();
    return _instance!;
  }
}
