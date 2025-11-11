import 'dart:convert';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../models/favorito_item_legacy.dart';
import 'base/typed_box_adapter.dart';

/// Repositório para gerenciar favoritos usando Hive com type-safe boxes.
/// ✅ FIXED (P0.3): Using `TypedBoxAdapter<FavoritoItemHive>` para compatibilidade
/// com boxes abertas como `Box<dynamic>` pelo BoxRegistryService
/// BENEFIT: Não tenta reabrir a box com tipo diferente - usa adapter type-safe
class FavoritosLegacyRepository {
  final IHiveManager _hiveManager;
  final String boxName = 'favoritos';
  TypedBoxAdapter<FavoritoItemHive>? _adapter;

  FavoritosLegacyRepository()
    : _hiveManager = GetIt.instance<IHiveManager>();

  /// Obtém o adapter type-safe para `Box<dynamic>` já aberta pelo BoxRegistryService
  /// Retorna TypedBoxAdapter<FavoritoItemHive> para operações type-safe
  Future<TypedBoxAdapter<FavoritoItemHive>> get adapter async {
    if (_adapter != null && _adapter!.isOpen) return _adapter!;

    final result = await _hiveManager.getBox<dynamic>(boxName);
    return result.fold(
      (failure) => throw Exception('Failed to open Hive box: ${failure.message}'),
      (dynamicBox) {
        _adapter = TypedBoxAdapter<FavoritoItemHive>(dynamicBox);
        return _adapter!;
      },
    );
  }

  /// Busca favoritos por tipo
  Future<List<FavoritoItemHive>> getFavoritosByTipo(String tipo) async {
    try {
      final typedAdapter = await adapter;
      final items = <FavoritoItemHive>[];

      // ✅ adapter.values já é Iterable<FavoritoItemHive> (type-safe)
      items.addAll(typedAdapter.values.where((item) => item.tipo == tipo));

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
      final typedAdapter = await adapter;
      final items = <FavoritoItemHive>[];

      // ✅ adapter.values já é Iterable<FavoritoItemHive> (type-safe)
      items.addAll(typedAdapter.values);

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
      final typedAdapter = await adapter;
      return typedAdapter.containsKey(key);
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
      final typedAdapter = await adapter;
      await typedAdapter.put(key, favorito);
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
      final typedAdapter = await adapter;
      await typedAdapter.delete(key);
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
      final typedAdapter = await adapter;
      final value = typedAdapter.get(key);

      // ✅ adapter.get() já retorna FavoritoItemHive? (type-safe)
      if (value != null && value.itemData.isNotEmpty) {
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
      final typedAdapter = await adapter;
      for (final favorito in favoritos) {
        final key = '${favorito.tipo}_${favorito.itemId}';
        await typedAdapter.delete(key);
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

  /// Fecha o adapter (liberando recursos se necessário)
  Future<void> close() async {
    try {
      if (_adapter != null && _adapter!.isOpen) {
        await _adapter!.close();
        _adapter = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [close] Erro ao fechar adapter: $e');
      }
    }
  }
}
