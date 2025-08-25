import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/favorito_item_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para gerenciar favoritos usando Hive
/// Substitui o mock repository por armazenamento real
class FavoritosHiveRepository extends BaseHiveRepository<FavoritoItemHive> {
  FavoritosHiveRepository() : super('receituagro_user_favorites');

  @override
  FavoritoItemHive createFromJson(Map<String, dynamic> json) {
    return FavoritoItemHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(FavoritoItemHive entity) {
    return '${entity.tipo}_${entity.itemId}';
  }

  /// Busca favoritos por tipo
  List<FavoritoItemHive> getFavoritosByTipo(String tipo) {
    return findBy((item) => item.tipo == tipo);
  }

  /// Versão async para garantir que o box esteja aberto
  Future<List<FavoritoItemHive>> getAllAsync() async {
    try {
      final box = await Hive.openBox<FavoritoItemHive>('receituagro_user_favorites');
      print('📦 [getAllAsync] Box aberto com ${box.length} itens');
      return box.values.toList();
    } catch (e) {
      print('❌ [getAllAsync] Erro: $e');
      return [];
    }
  }

  /// Versão async para buscar por tipo
  Future<List<FavoritoItemHive>> getFavoritosByTipoAsync(String tipo) async {
    try {
      final all = await getAllAsync();
      final filtered = all.where((item) => item.tipo == tipo).toList();
      print('🔍 [getFavoritosByTipoAsync] Tipo $tipo: ${filtered.length} itens');
      return filtered;
    } catch (e) {
      print('❌ [getFavoritosByTipoAsync] Erro: $e');
      return [];
    }
  }

  /// Verifica se um item é favorito
  bool isFavorito(String tipo, String itemId) {
    final key = '${tipo}_$itemId';
    return getById(key) != null;
  }

  /// Adiciona um item aos favoritos
  Future<bool> addFavorito(String tipo, String itemId, Map<String, dynamic> itemData) async {
    try {
      final favorito = FavoritoItemHive(
        objectId: '${tipo}_$itemId',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        tipo: tipo,
        itemId: itemId,
        itemData: jsonEncode(itemData),
      );
      
      final box = await Hive.openBox<FavoritoItemHive>('receituagro_user_favorites');
      await box.put(getKeyFromEntity(favorito), favorito);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove um item dos favoritos
  Future<bool> removeFavorito(String tipo, String itemId) async {
    try {
      final key = '${tipo}_$itemId';
      final box = await Hive.openBox<FavoritoItemHive>('receituagro_user_favorites');
      await box.delete(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Busca dados de um favorito específico
  Map<String, dynamic>? getFavoritoData(String tipo, String itemId) {
    final key = '${tipo}_$itemId';
    final favorito = getById(key);
    
    if (favorito != null && favorito.itemData.isNotEmpty) {
      try {
        return jsonDecode(favorito.itemData) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  /// Limpa todos os favoritos de um tipo
  Future<void> clearFavoritosByTipo(String tipo) async {
    final favoritos = getFavoritosByTipo(tipo);
    final box = await Hive.openBox<FavoritoItemHive>('receituagro_user_favorites');
    for (final favorito in favoritos) {
      await box.delete(getKeyFromEntity(favorito));
    }
  }

  /// Retorna estatísticas dos favoritos
  Map<String, int> getFavoritosStats() {
    final stats = <String, int>{
      'defensivos': 0,
      'pragas': 0,
      'diagnosticos': 0,
      'culturas': 0,
    };
    
    for (final favorito in getAll()) {
      final tipo = favorito.tipo;
      stats[tipo] = (stats[tipo] ?? 0) + 1;
    }
    
    return stats;
  }
}