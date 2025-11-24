import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';


import '../../../../database/repositories/favorito_repository.dart';
import '../../domain/repositories/i_favoritos_repository.dart';

/// Implementação do storage local para favoritos usando Drift (Data Layer)
///
/// ⚠️ NOTA: Esta classe substitui FavoritosStorageService para usar Drift

class FavoritosStorageServiceDrift implements IFavoritosStorage {
  final FavoritoRepository _repository;

  FavoritosStorageServiceDrift(this._repository);

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Future<List<String>> getFavoriteIds(String tipo) async {
    if (_userId.isEmpty) return [];
    try {
      final favoritos = await _repository.findByUserAndType(_userId, tipo);
      return favoritos.map((f) => f.itemId).toList();
    } catch (e) {
      developer.log(
        'Erro ao buscar IDs favoritos: $e',
        name: 'FavoritosStorageServiceDrift',
      );
      return [];
    }
  }

  @override
  Future<bool> addFavoriteId(String tipo, String id) async {
    if (_userId.isEmpty) return false;
    try {
      if (await isFavoriteId(tipo, id)) return true;
      // Nota: IFavoritosStorage não fornece itemData, passamos vazio.
      // O ideal é que quem chama use FavoritosService que trata isso.
      await _repository.addFavorito(_userId, tipo, id, '');
      return true;
    } catch (e) {
      developer.log(
        'Erro ao adicionar favorito: $e',
        name: 'FavoritosStorageServiceDrift',
      );
      return false;
    }
  }

  @override
  Future<bool> removeFavoriteId(String tipo, String id) async {
    if (_userId.isEmpty) return false;
    try {
      return await _repository.removeFavorito(_userId, tipo, id);
    } catch (e) {
      developer.log(
        'Erro ao remover favorito: $e',
        name: 'FavoritosStorageServiceDrift',
      );
      return false;
    }
  }

  @override
  Future<bool> isFavoriteId(String tipo, String id) async {
    if (_userId.isEmpty) return false;
    try {
      return await _repository.isFavorited(_userId, tipo, id);
    } catch (e) {
      developer.log(
        'Erro ao verificar favorito: $e',
        name: 'FavoritosStorageServiceDrift',
      );
      return false;
    }
  }

  @override
  Future<void> clearFavorites(String tipo) async {
    if (_userId.isEmpty) return;
    try {
      final ids = await getFavoriteIds(tipo);
      for (final id in ids) {
        await removeFavoriteId(tipo, id);
      }
    } catch (e) {
      developer.log(
        'Erro ao limpar favoritos: $e',
        name: 'FavoritosStorageServiceDrift',
      );
    }
  }

  @override
  Future<void> clearAllFavorites() async {
    if (_userId.isEmpty) return;
    try {
      final all = await _repository.findByUserId(_userId);
      for (final fav in all) {
        await _repository.removeFavorito(_userId, fav.tipo, fav.itemId);
      }
    } catch (e) {
      developer.log(
        'Erro ao limpar todos favoritos: $e',
        name: 'FavoritosStorageServiceDrift',
      );
    }
  }

  @override
  Future<void> syncFavorites() async {
    // Drift já gerencia sync via isDirty e SyncManager
    developer.log(
      'Sync solicitado (gerenciado pelo Drift/SyncManager)',
      name: 'FavoritosStorageServiceDrift',
    );
  }
}
