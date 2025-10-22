import 'dart:convert';
import 'package:core/core.dart';
import '../models/favorito_item_hive.dart';

/// Repositório para gerenciar favoritos usando Hive
/// Substitui o mock repository por armazenamento real
class FavoritosHiveRepository extends BaseHiveRepository<FavoritoItemHive> {
  FavoritosHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'favoritos',  // ✅ CORRIGIDO: Match com ReceitaAgroBoxes e sync config
  );


  /// Busca favoritos por tipo
  Future<List<FavoritoItemHive>> getFavoritosByTipo(String tipo) async {
    final result = await findBy((item) => item.tipo == tipo);
    return result.isSuccess ? result.data! : [];
  }

  /// Versão async para garantir que o box esteja aberto
  Future<List<FavoritoItemHive>> getAllAsync() async {
    final result = await getAll();
    return result.isSuccess ? result.data! : [];
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
  Future<bool> isFavorito(String tipo, String itemId) async {
    final key = '${tipo}_$itemId';
    final result = await getByKey(key);
    return result.isSuccess && result.data != null;
  }

  /// Verifica se um item é favorito (versão assíncrona)
  Future<bool> isFavoritoAsync(String tipo, String itemId) async {
    return await isFavorito(tipo, itemId);
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
      
      final key = '${tipo}_$itemId';
      final result = await save(favorito, key: key);
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Remove um item dos favoritos
  Future<bool> removeFavorito(String tipo, String itemId) async {
    try {
      final key = '${tipo}_$itemId';
      final result = await deleteByKey(key);
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Busca dados de um favorito específico
  Future<Map<String, dynamic>?> getFavoritoData(String tipo, String itemId) async {
    final key = '${tipo}_$itemId';
    final result = await getByKey(key);
    
    if (result.isSuccess && result.data != null && result.data!.itemData.isNotEmpty) {
      try {
        return jsonDecode(result.data!.itemData) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  /// Busca dados de um favorito específico (versão assíncrona)
  Future<Map<String, dynamic>?> getFavoritoDataAsync(String tipo, String itemId) async {
    return await getFavoritoData(tipo, itemId);
  }

  /// Limpa todos os favoritos de um tipo
  Future<void> clearFavoritosByTipo(String tipo) async {
    final favoritos = await getFavoritosByTipo(tipo);
    for (final favorito in favoritos) {
      final key = '${favorito.tipo}_${favorito.itemId}';
      await deleteByKey(key);
    }
  }

  /// Retorna estatísticas dos favoritos
  Future<Map<String, int>> getFavoritosStats() async {
    final stats = <String, int>{
      'defensivos': 0,
      'pragas': 0,
      'diagnosticos': 0,
      'culturas': 0,
    };
    
    final result = await getAll();
    if (result.isSuccess) {
      for (final favorito in result.data!) {
        final tipo = favorito.tipo;
        stats[tipo] = (stats[tipo] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  /// Busca favoritos por lista de IDs
  Future<List<FavoritoItemHive>> findByIds(List<String> ids) async {
    final results = <FavoritoItemHive>[];
    
    for (final id in ids) {
      final result = await findBy((favorito) => favorito.itemId == id);
      if (result.isSuccess && result.data!.isNotEmpty) {
        results.add(result.data!.first);
      }
    }
    
    return results;
  }
}
