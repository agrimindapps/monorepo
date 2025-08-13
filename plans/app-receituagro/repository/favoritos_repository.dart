// Flutter imports:
// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../../core/services/localstorage_service.dart';
import '../core/cache/i_cache_service.dart';
import '../models/favorito_model.dart';
import 'database_repository.dart';
import 'defensivos_repository.dart';
import 'diagnostico_repository.dart';

/// Refactored FavoritosRepository using unified cache service
class FavoritosRepository {
  final LocalStorageService _localStorageService =
      Get.find<LocalStorageService>();
  final DefensivosRepository _defensivosRepository =
      Get.find<DefensivosRepository>();
  final DiagnosticoRepository _diagnosticoRepository =
      Get.find<DiagnosticoRepository>();
  final ICacheService _cacheService = Get.find<ICacheService>();

  // Cache prefixes for different data types
  static const String _defensivosCachePrefix = 'favoritos_defensivos_';
  static const String _pragasCachePrefix = 'favoritos_pragas_';
  static const String _diagnosticosCachePrefix = 'favoritos_diagnosticos_';
  static const Duration _favoritesCacheTtl = Duration(minutes: 5);

  // =========================================================================
  // Generic Batch Processing System - Using Unified Cache Service
  // =========================================================================

  /// Generic batch fetcher with unified cache service
  Future<List<T>> _fetchBatchGeneric<T>({
    required String favoritesKey,
    required Future<Map<String, dynamic>?> Function(String) dataFetcher,
    required T Function(String id, Map<String, dynamic> data) modelBuilder,
    required String entityType,
  }) async {
    try {
      // Get favorite IDs from localStorage
      final favoritosIds =
          await _localStorageService.getFavorites(favoritesKey);

      if (favoritosIds.isEmpty) {
        return [];
      }

      final List<T> favoritos = [];
      final List<String> idsToFetch = [];

      // Check unified cache first
      for (String idString in favoritosIds) {
        if (idString.isEmpty) {
          continue;
        }

        final cacheKey = '${_getCachePrefix<T>()}$idString';
        final cachedData = await _cacheService.get<Map<String, dynamic>>(cacheKey);
        
        if (cachedData != null) {
          // Use cached data
          favoritos.add(modelBuilder(idString, cachedData));
        } else {
          // Add to fetch list
          idsToFetch.add(idString);
        }
      }

      // Fetch non-cached data in parallel
      if (idsToFetch.isNotEmpty) {
        await _executeBatchFetch<T>(
          idsToFetch: idsToFetch,
          dataFetcher: dataFetcher,
          modelBuilder: modelBuilder,
          favoritos: favoritos,
          entityType: entityType,
        );
      }

      return favoritos;
    } catch (e) {
      debugPrint('Erro ao buscar favoritos de $entityType: $e');
      return [];
    }
  }

  /// Generic batch execution with unified cache service
  Future<void> _executeBatchFetch<T>({
    required List<String> idsToFetch,
    required Future<Map<String, dynamic>?> Function(String) dataFetcher,
    required T Function(String id, Map<String, dynamic> data) modelBuilder,
    required List<T> favoritos,
    required String entityType,
  }) async {
    try {
      // Execute queries in parallel instead of sequential
      final futures = idsToFetch.map((idString) async {
        try {
          final data = await dataFetcher(idString);
          return {
            'id': idString,
            'data': data,
          };
        } catch (e) {
          debugPrint('Erro ao buscar $entityType $idString: $e');
          return null;
        }
      });

      final results = await Future.wait(futures);

      // Process results
      for (final result in results) {
        if (result != null && result['data'] != null) {
          final idString = result['id'] as String;
          final data = result['data'] as Map<String, dynamic>;

          if (data.isNotEmpty) {
            // Add to unified cache
            final cacheKey = '${_getCachePrefix<T>()}$idString';
            await _cacheService.put(cacheKey, data, ttl: _favoritesCacheTtl);

            // Add to favorites
            favoritos.add(modelBuilder(idString, data));
          }
        }
      }
    } catch (e) {
      debugPrint('Erro no batch de $entityType: $e');
    }
  }

  /// Gets cache prefix for different data types
  String _getCachePrefix<T>() {
    if (T == FavoritoDefensivoModel) {
      return _defensivosCachePrefix;
    } else if (T == FavoritoPragaModel) {
      return _pragasCachePrefix;
    } else if (T == FavoritoDiagnosticoModel) {
      return _diagnosticosCachePrefix;
    }
    return 'favoritos_unknown_';
  }

  /// Obtém os favoritos de defensivos usando sistema genérico
  Future<List<FavoritoDefensivoModel>> getFavoritosDefensivos() async {
    // Verificar se o DatabaseRepository está carregado
    try {
      final dbRepo = _defensivosRepository.getDatabaseRepository();
      if (!dbRepo.isLoaded.value) {
        return [];
      }
    } catch (e) {
      debugPrint('Erro ao verificar DatabaseRepository: $e');
      return [];
    }

    return await _fetchBatchGeneric<FavoritoDefensivoModel>(
      favoritesKey: 'favDefensivos',
      dataFetcher: (id) => _defensivosRepository.getDefensivoById(id),
      modelBuilder: (id, data) => FavoritoDefensivoModel(
        id: id,
        nomeComum: data['nomeComum'] ?? '',
        ingredienteAtivo: data['ingredienteAtivo'] ?? '',
      ),
      entityType: 'defensivos',
    );
  }

  /// Obtém os favoritos de pragas usando sistema genérico
  Future<List<FavoritoPragaModel>> getFavoritosPragas() async {
    return await _fetchBatchGeneric<FavoritoPragaModel>(
      favoritesKey: 'favPragas',
      dataFetcher: (id) async {
        try {
          // Buscar diretamente no banco sem usar pragaUnica para evitar concorrência
          final dbRepo = Get.find<DatabaseRepository>();
          if (!dbRepo.isLoaded.value) {
            return null;
          }

          final data = dbRepo.gPragas.map((p) => p.toJson()).firstWhereOrNull(
                (row) => row['idReg'] == id,
              );

          if (data != null) {
            return {
              'nomeComum': data['nomeComum'] ?? '',
              'nomeCientifico': data['nomeCientifico'] ?? '',
              'nomeImagem': data['nomeCientifico'] ?? '',
            };
          }
        } catch (e) {
          debugPrint('Erro ao buscar praga $id: $e');
        }
        return null;
      },
      modelBuilder: (id, data) => FavoritoPragaModel(
        id: id,
        nomeComum: data['nomeComum'] ?? '',
        nomeCientifico: data['nomeCientifico'] ?? '',
      ),
      entityType: 'pragas',
    );
  }

  /// Obtém os favoritos de diagnósticos usando sistema genérico
  /// Requer conta premium
  Future<List<FavoritoDiagnosticoModel>> getFavoritosDiagnosticos() async {
    return await _fetchBatchGeneric<FavoritoDiagnosticoModel>(
      favoritesKey: 'favDiagnosticos',
      dataFetcher: (id) async {
        try {
          final data = _diagnosticoRepository.getDiagnosticoDetalhes(id);
          if (data != null && data.isNotEmpty) {
            return data;
          }
        } catch (e) {
          debugPrint('Erro ao buscar diagnóstico $id: $e');
        }
        return null;
      },
      modelBuilder: (id, data) => FavoritoDiagnosticoModel(
        id: id,
        priNome: data['nomePraga'] ?? '',
        nomeCientifico: data['nomeCientifico'] ?? '',
        nomeComum: data['nomeDefensivo'] ?? '',
        cultura: data['cultura'] ?? '',
      ),
      entityType: 'diagnosticos',
    );
  }

  /// Adiciona um defensivo aos favoritos
  Future<bool> adicionarDefensivoFavorito(
      FavoritoDefensivoModel defensivo) async {
    try {
      final result = await _localStorageService.setFavorite(
          'favDefensivos', defensivo.id);
      
      // Invalidate cache for this item to ensure fresh data on next load
      if (result) {
        final cacheKey = '$_defensivosCachePrefix${defensivo.id}';
        await _cacheService.remove(cacheKey);
      }
      
      return result;
    } catch (e) {
      debugPrint('Erro ao adicionar defensivo aos favoritos: $e');
      return false;
    }
  }

  /// Remove um defensivo dos favoritos
  Future<bool> removerDefensivoFavorito(String id) async {
    try {
      final isCurrentlyFavorite =
          await _localStorageService.isFavorite('favDefensivos', id);
      if (isCurrentlyFavorite) {
        await _localStorageService.setFavorite('favDefensivos', id);
        
        // Remove from cache
        final cacheKey = '$_defensivosCachePrefix$id';
        await _cacheService.remove(cacheKey);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao remover defensivo dos favoritos: $e');
      return false;
    }
  }

  /// Adiciona uma praga aos favoritos
  Future<bool> adicionarPragaFavorito(FavoritoPragaModel praga) async {
    try {
      final result = await _localStorageService.setFavorite('favPragas', praga.id);
      
      if (result) {
        final cacheKey = '$_pragasCachePrefix${praga.id}';
        await _cacheService.remove(cacheKey);
      }
      
      return result;
    } catch (e) {
      debugPrint('Erro ao adicionar praga aos favoritos: $e');
      return false;
    }
  }

  /// Remove uma praga dos favoritos
  Future<bool> removerPragaFavorito(String id) async {
    try {
      final isCurrentlyFavorite =
          await _localStorageService.isFavorite('favPragas', id);
      if (isCurrentlyFavorite) {
        await _localStorageService.setFavorite('favPragas', id);
        
        final cacheKey = '$_pragasCachePrefix$id';
        await _cacheService.remove(cacheKey);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao remover praga dos favoritos: $e');
      return false;
    }
  }

  /// Adiciona um diagnóstico aos favoritos
  Future<bool> adicionarDiagnosticoFavorito(
      FavoritoDiagnosticoModel diagnostico) async {
    try {
      final result = await _localStorageService.setFavorite(
          'favDiagnosticos', diagnostico.id);
          
      if (result) {
        final cacheKey = '$_diagnosticosCachePrefix${diagnostico.id}';
        await _cacheService.remove(cacheKey);
      }
      
      return result;
    } catch (e) {
      debugPrint('Erro ao adicionar diagnóstico aos favoritos: $e');
      return false;
    }
  }

  /// Remove um diagnóstico dos favoritos
  Future<bool> removerDiagnosticoFavorito(String id) async {
    try {
      final isCurrentlyFavorite =
          await _localStorageService.isFavorite('favDiagnosticos', id);
      if (isCurrentlyFavorite) {
        await _localStorageService.setFavorite('favDiagnosticos', id);
        
        final cacheKey = '$_diagnosticosCachePrefix$id';
        await _cacheService.remove(cacheKey);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao remover diagnóstico dos favoritos: $e');
      return false;
    }
  }

  /// Verifica se um item é favorito
  Future<bool> isFavorito(String tipo, String id) async {
    try {
      final tipoKey = _getTipoKey(tipo);
      return await _localStorageService.isFavorite(tipoKey, id);
    } catch (e) {
      debugPrint('Erro ao verificar se item é favorito: $e');
      return false;
    }
  }

  /// Converte tipo para chave do localStorage
  String _getTipoKey(String tipo) {
    switch (tipo) {
      case 'defensivos':
        return 'favDefensivos';
      case 'pragas':
        return 'favPragas';
      case 'diagnosticos':
        return 'favDiagnosticos';
      default:
        return 'favDefensivos';
    }
  }

  // =========================================================================
  // Unified Cache Management Methods
  // =========================================================================

  /// Limpa todo o cache de favoritos usando cache centralizado
  Future<void> clearCache() async {
    await _cacheService.clearByPrefix('favoritos_');
    debugPrint('🧹 Cache de favoritos limpo através do serviço centralizado');
  }

  /// Limpa cache específico por tipo usando cache centralizado
  Future<void> clearCacheByType(String tipo) async {
    String prefix;
    switch (tipo) {
      case 'defensivos':
        prefix = _defensivosCachePrefix;
        break;
      case 'pragas':
        prefix = _pragasCachePrefix;
        break;
      case 'diagnosticos':
        prefix = _diagnosticosCachePrefix;
        break;
      default:
        prefix = 'favoritos_unknown_';
    }
    await _cacheService.clearByPrefix(prefix);
    debugPrint('🧹 Cache de $tipo limpo através do serviço centralizado');
  }

  /// Estatísticas do cache usando serviço centralizado
  Future<Map<String, dynamic>> getCacheStats() async {
    final stats = await _cacheService.getStats();
    final keys = await _cacheService.getKeys();
    
    final defensivosKeys = keys.where((k) => k.startsWith(_defensivosCachePrefix)).length;
    final pragasKeys = keys.where((k) => k.startsWith(_pragasCachePrefix)).length;
    final diagnosticosKeys = keys.where((k) => k.startsWith(_diagnosticosCachePrefix)).length;
    
    return {
      'strategy': 'unified_cache_service',
      'defensivos': defensivosKeys,
      'pragas': pragasKeys,
      'diagnosticos': diagnosticosKeys,
      'totalItems': defensivosKeys + pragasKeys + diagnosticosKeys,
      'cacheService': stats,
    };
  }
}