import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import '../models/favorito_item_hive.dart';

/// Repositório para gerenciar favoritos usando Hive com dynamic boxes.
/// ✅ FIXED: Changed from BaseHiveRepository<T> typed to direct dynamic box access.
/// REASON: Box 'favoritos' is opened as dynamic by BoxRegistryService (persistent:true)
/// and cannot be reopened with specific types (would cause type mismatch error).
class FavoritosHiveRepository {
  final IHiveManager _hiveManager;
  final String boxName = 'favoritos';
  Box<dynamic>? _box;

  FavoritosHiveRepository() : _hiveManager = GetIt.instance<IHiveManager>();

  /// Obtém a box como dynamic (já aberta pelo BoxRegistryService)
  Future<Box<dynamic>> get box async {
    if (_box != null && _box!.isOpen) return _box!;

    final result = await _hiveManager.getBox<dynamic>(boxName);
    if (result.isFailure) {
      throw Exception('Failed to open Hive box: ${result.error?.message}');
    }
    _box = result.data;
    return _box!;
  }

  /// Busca favoritos por tipo
  Future<List<FavoritoItemHive>> getFavoritosByTipo(String tipo) async {
    try {
      final hiveBox = await box;
      final items = <FavoritoItemHive>[];

      for (final value in hiveBox.values) {
        if (value is FavoritoItemHive && value.tipo == tipo) {
          items.add(value);
        }
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [getFavoritosByTipo] Erro: $e');
      }
      return [];
    }
  }

  /// Versão async para garantir que o box esteja aberto
  Future<List<FavoritoItemHive>> getAllAsync() async {
    try {
      final hiveBox = await box;
      final items = <FavoritoItemHive>[];

      for (final value in hiveBox.values) {
        if (value is FavoritoItemHive) {
          items.add(value);
        }
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [getAllAsync] Erro: $e');
      }
      return [];
    }
  }

  /// Versão async para buscar por tipo
  Future<List<FavoritoItemHive>> getFavoritosByTipoAsync(String tipo) async {
    try {
      final all = await getAllAsync();
      final filtered = all.where((item) => item.tipo == tipo).toList();
      print(
        '🔍 [getFavoritosByTipoAsync] Tipo $tipo: ${filtered.length} itens',
      );
      return filtered;
    } catch (e) {
      print('❌ [getFavoritosByTipoAsync] Erro: $e');
      return [];
    }
  }

  /// Verifica se um item é favorito
  Future<bool> isFavorito(String tipo, String itemId) async {
    try {
      final key = '${tipo}_$itemId';
      final hiveBox = await box;
      return hiveBox.containsKey(key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [isFavorito] Erro: $e');
      }
      return false;
    }
  }

  /// Verifica se um item é favorito (versão assíncrona)
  Future<bool> isFavoritoAsync(String tipo, String itemId) async {
    return await isFavorito(tipo, itemId);
  }

  /// Adiciona um item aos favoritos
  Future<bool> addFavorito(
    String tipo,
    String itemId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      final favorito = FavoritoItemHive(
        sync_objectId: '${tipo}_$itemId',
        sync_createdAt: DateTime.now().millisecondsSinceEpoch,
        sync_updatedAt: DateTime.now().millisecondsSinceEpoch,
        tipo: tipo,
        itemId: itemId,
        itemData: jsonEncode(itemData),
      );

      final key = '${tipo}_$itemId';
      final hiveBox = await box;
      await hiveBox.put(key, favorito);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [addFavorito] Erro: $e');
      }
      return false;
    }
  }

  /// Remove um item dos favoritos
  Future<bool> removeFavorito(String tipo, String itemId) async {
    try {
      final key = '${tipo}_$itemId';
      final hiveBox = await box;
      await hiveBox.delete(key);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [removeFavorito] Erro: $e');
      }
      return false;
    }
  }

  /// Busca dados de um favorito específico
  Future<Map<String, dynamic>?> getFavoritoData(
    String tipo,
    String itemId,
  ) async {
    try {
      final key = '${tipo}_$itemId';
      final hiveBox = await box;
      final value = hiveBox.get(key);

      if (value is FavoritoItemHive && value.itemData.isNotEmpty) {
        return jsonDecode(value.itemData) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [getFavoritoData] Erro: $e');
      }
    }

    return null;
  }

  /// Busca dados de um favorito específico (versão assíncrona)
  Future<Map<String, dynamic>?> getFavoritoDataAsync(
    String tipo,
    String itemId,
  ) async {
    return await getFavoritoData(tipo, itemId);
  }

  /// Limpa todos os favoritos de um tipo
  Future<void> clearFavoritosByTipo(String tipo) async {
    try {
      final favoritos = await getFavoritosByTipo(tipo);
      final hiveBox = await box;
      for (final favorito in favoritos) {
        final key = '${favorito.tipo}_${favorito.itemId}';
        await hiveBox.delete(key);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [clearFavoritosByTipo] Erro: $e');
      }
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

    try {
      final all = await getAllAsync();
      for (final favorito in all) {
        final tipo = favorito.tipo;
        stats[tipo] = (stats[tipo] ?? 0) + 1;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [getFavoritosStats] Erro: $e');
      }
    }

    return stats;
  }

  /// Busca favoritos por lista de IDs
  Future<List<FavoritoItemHive>> findByIds(List<String> ids) async {
    final results = <FavoritoItemHive>[];

    try {
      final all = await getAllAsync();
      for (final id in ids) {
        final items = all.where((favorito) => favorito.itemId == id);
        results.addAll(items);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [findByIds] Erro: $e');
      }
    }

    return results;
  }
}
