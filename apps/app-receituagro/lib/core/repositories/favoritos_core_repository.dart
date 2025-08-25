import 'dart:convert';
import 'package:core/core.dart';

import '../models/favorito_item_hive.dart';
import 'core_base_hive_repository.dart';

/// Repositório para gerenciar favoritos usando core package
/// Substitui FavoritosHiveRepository que usava Hive diretamente
class FavoritosCoreRepository extends CoreBaseHiveRepository<FavoritoItemHive> {
  final ILocalStorageRepository _localStorageService;
  final String _localBoxName;
  
  FavoritosCoreRepository(ILocalStorageRepository storageService)
      : _localStorageService = storageService,
        _localBoxName = 'receituagro_user_favorites',
        super(storageService, 'receituagro_user_favorites');

  @override
  FavoritoItemHive createFromJson(Map<String, dynamic> json) {
    return FavoritoItemHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(FavoritoItemHive entity) {
    return '${entity.tipo}_${entity.itemId}';
  }

  /// Busca favoritos por tipo
  Future<List<FavoritoItemHive>> getFavoritosByTipo(String tipo) async {
    return findBy((item) => item.tipo == tipo);
  }

  /// Verifica se um item é favorito
  Future<bool> isFavorito(String tipo, String itemId) async {
    final key = '${tipo}_$itemId';
    final favorito = getById(key);
    return favorito != null;
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
      
      final key = getKeyFromEntity(favorito);
      final result = await _localStorageService.save<Map<String, dynamic>>(
        key: '${_localBoxName}_$key',
        data: favorito.toJson(),
        box: HiveBoxes.receituagro,
      );
      
      return result.isRight();
    } catch (e) {
      return false;
    }
  }

  /// Remove um item dos favoritos
  Future<bool> removeFavorito(String tipo, String itemId) async {
    try {
      final key = '${tipo}_$itemId';
      final result = await _localStorageService.remove(
        key: '${_localBoxName}_$key',
        box: HiveBoxes.receituagro,
      );
      
      return result.isRight();
    } catch (e) {
      return false;
    }
  }

  /// Busca dados de um favorito específico
  Future<Map<String, dynamic>?> getFavoritoData(String tipo, String itemId) async {
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
    final favoritos = await getFavoritosByTipo(tipo);
    for (final favorito in favoritos) {
      final key = getKeyFromEntity(favorito);
      await _localStorageService.remove(
        key: '${_localBoxName}_$key',
        box: HiveBoxes.receituagro,
      );
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
    
    final favoritos = getAll();
    for (final favorito in favoritos) {
      final tipo = favorito.tipo;
      stats[tipo] = (stats[tipo] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Toggle favorito - adiciona se não existe, remove se existe
  Future<bool> toggleFavorito(String tipo, String itemId, Map<String, dynamic> itemData) async {
    final isFav = await isFavorito(tipo, itemId);
    
    if (isFav) {
      return await removeFavorito(tipo, itemId);
    } else {
      return await addFavorito(tipo, itemId, itemData);
    }
  }

  /// Lista todos os favoritos de forma paginada
  Future<List<FavoritoItemHive>> getFavoritosPaginated({
    required int page,
    required int limit,
    String? tipo,
  }) async {
    List<FavoritoItemHive> favoritos;
    
    if (tipo != null) {
      favoritos = await getFavoritosByTipo(tipo);
    } else {
      favoritos = getAll();
    }
    
    // Ordena por data de criação (mais recentes primeiro)
    favoritos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= favoritos.length) return [];
    
    return favoritos.sublist(
      startIndex,
      endIndex > favoritos.length ? favoritos.length : endIndex,
    );
  }

  /// Busca favoritos com texto no itemData
  Future<List<FavoritoItemHive>> searchFavoritos(String searchTerm) async {
    final lowerSearchTerm = searchTerm.toLowerCase();
    
    return findBy((favorito) {
      if (favorito.itemData.isEmpty) return false;
      
      try {
        final data = jsonDecode(favorito.itemData) as Map<String, dynamic>;
        
        // Busca em campos comuns
        final searchableFields = [
          data['nomeComum']?.toString(),
          data['nomeCientifico']?.toString(),
          data['fabricante']?.toString(),
          data['ingredienteAtivo']?.toString(),
          data['classeAgronomica']?.toString(),
        ];
        
        for (final field in searchableFields) {
          if (field != null && field.toLowerCase().contains(lowerSearchTerm)) {
            return true;
          }
        }
        
        return false;
      } catch (e) {
        return false;
      }
    });
  }

  /// Getter para acessar o storageService protegido da classe base
}