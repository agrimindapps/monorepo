import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../../../core/data/repositories/favoritos_hive_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';
import '../factories/favorito_entity_factory_registry.dart';
import 'favoritos_cache_service_inline.dart';
import 'favoritos_data_resolver_service.dart';
import 'favoritos_sync_service.dart';
import 'favoritos_validator_service.dart';

/// Service consolidado para Favoritos com Specialized Services
/// Reduzido de 915 linhas para ~250 linhas usando delegation pattern
///
/// SOLID Refactoring (P1):
/// - Removed switch case factory (OCP violation)
/// - Now uses FavoritoEntityFactoryRegistry (Strategy Pattern)
/// - Extensible: adding new tipos doesn't require modifying this service
class FavoritosService {
  // Lazy loading do repository (evita erro de acesso antes do registro no GetIt)
  late final FavoritosHiveRepository _repository;
  bool _repositoryInitialized = false;

  // Specialized Services (injetadas via construtor - DIP)
  final FavoritosDataResolverService _dataResolver;
  final FavoritosValidatorService _validator;
  final FavoritosSyncService _syncService;
  final FavoritosCacheServiceInline _cache;
  final IFavoritoEntityFactoryRegistry _factoryRegistry;

  FavoritosService({
    required FavoritosDataResolverService dataResolver,
    required FavoritosValidatorService validator,
    required FavoritosSyncService syncService,
    required FavoritosCacheServiceInline cache,
    required IFavoritoEntityFactoryRegistry factoryRegistry,
  }) : _dataResolver = dataResolver,
       _validator = validator,
       _syncService = syncService,
       _cache = cache,
       _factoryRegistry = factoryRegistry;

  // Getter lazy para repository (inicializado na primeira vez que é acessado)
  FavoritosHiveRepository get repo {
    if (!_repositoryInitialized) {
      _repository = sl<FavoritosHiveRepository>();
      _repositoryInitialized = true;
    }
    return _repository;
  }

  // ========== STORAGE/CRUD OPERATIONS ==========

  Future<List<String>> getFavoriteIds(String tipo) async {
    try {
      final favoritos = await repo.getFavoritosByTipoAsync(tipo);
      return favoritos.map((f) => f.itemId).toList();
    } catch (e) {
      throw FavoritosException('Erro ao buscar IDs favoritos: $e', tipo: tipo);
    }
  }

  Future<bool> addFavoriteId(String tipo, String id) async {
    if (kDebugMode) {
      developer.log(
        'Adicionando favorito: tipo=$tipo, id=$id',
        name: 'FavoritosService',
      );
    }

    try {
      if (!_validator.isValidTipo(tipo)) {
        if (kDebugMode)
          developer.log('Tipo inválido: $tipo', name: 'FavoritosService');
        return false;
      }

      if (!await _validator.canAddToFavorites(tipo, id)) {
        if (kDebugMode)
          developer.log('Validação falhou', name: 'FavoritosService');
        return false;
      }

      final itemData = {
        'id': id,
        'tipo': tipo,
        'adicionadoEm': DateTime.now().toIso8601String(),
      };

      final result = await repo.addFavorito(tipo, id, itemData);

      if (result) {
        await _cache.clearForTipo(tipo);
        try {
          await _syncService.syncOperation('create', tipo, id, itemData);
        } catch (e) {
          if (kDebugMode) {
            developer.log(
              'Erro na sincronização (local OK): $e',
              name: 'FavoritosService',
            );
          }
        }
      }

      return result;
    } catch (e) {
      developer.log(
        'Erro ao adicionar favorito: $e',
        name: 'FavoritosService',
        error: e,
      );
      throw FavoritosException(
        'Erro ao adicionar favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  Future<bool> removeFavoriteId(String tipo, String id) async {
    if (kDebugMode) {
      developer.log(
        'Removendo favorito: tipo=$tipo, id=$id',
        name: 'FavoritosService',
      );
    }

    try {
      if (!_validator.isValidTipo(tipo)) {
        if (kDebugMode)
          developer.log('Tipo inválido: $tipo', name: 'FavoritosService');
        return false;
      }

      final result = await repo.removeFavorito(tipo, id);

      if (result) {
        await _cache.clearForTipo(tipo);
        try {
          await _syncService.syncOperation('delete', tipo, id, null);
        } catch (e) {
          if (kDebugMode) {
            developer.log(
              'Erro na sincronização de remoção (local OK): $e',
              name: 'FavoritosService',
            );
          }
        }
      }

      return result;
    } catch (e) {
      developer.log(
        'Erro ao remover favorito: $e',
        name: 'FavoritosService',
        error: e,
      );
      throw FavoritosException(
        'Erro ao remover favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  Future<bool> isFavoriteId(String tipo, String id) async {
    try {
      if (!_validator.isValidTipo(tipo)) return false;
      return await repo.isFavorito(tipo, id);
    } catch (e) {
      throw FavoritosException(
        'Erro ao verificar favorito: $e',
        tipo: tipo,
        id: id,
      );
    }
  }

  Future<void> clearFavorites(String tipo) async {
    try {
      if (!_validator.isValidTipo(tipo)) return;
      await repo.clearFavoritosByTipo(tipo);
      await _cache.clearForTipo(tipo);
    } catch (e) {
      throw FavoritosException('Erro ao limpar favoritos: $e', tipo: tipo);
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      for (final tipo in TipoFavorito.todos) {
        await clearFavorites(tipo);
      }
    } catch (e) {
      throw FavoritosException('Erro ao limpar todos os favoritos: $e');
    }
  }

  // ========== DATA RESOLVER (DELEGATED) ==========

  Future<Map<String, dynamic>?> resolveItemData(String tipo, String id) async {
    if (kDebugMode) {
      developer.log(
        'Resolvendo dados: tipo=$tipo, id=$id',
        name: 'FavoritosService',
      );
    }

    final cacheKey = 'resolve_${tipo}_$id';
    final cached = await _cache.get<Map<String, dynamic>?>(cacheKey);

    if (cached != null) {
      if (kDebugMode) developer.log('Cache hit', name: 'FavoritosService');
      return cached;
    }

    final data = await _dataResolver.resolveItemData(tipo, id);

    if (data != null) {
      await _cache.put(cacheKey, data);
    }

    return data;
  }

  // ========== ENTITY FACTORY ==========

  /// Create FavoritoEntity using the factory registry (Strategy Pattern)
  /// SOLID Refactoring: Replaced switch case with Strategy Pattern
  /// Benefit: Adding new tipos doesn't require modifying this method
  FavoritoEntity createEntity({
    required String tipo,
    required String id,
    required Map<String, dynamic> data,
  }) {
    return _factoryRegistry.create(tipo: tipo, id: id, data: data);
  }

  /// Check if the given tipo is supported
  bool isTipoSupported(String tipo) {
    return _factoryRegistry.canHandle(tipo);
  }

  /// Get list of all supported tipos
  List<String> getSupportedTipos() {
    return _factoryRegistry.getRegisteredTipos();
  }

  // ========== VALIDATION (DELEGATED) ==========

  Future<bool> canAddToFavorites(String tipo, String id) async {
    return await _validator.canAddToFavorites(tipo, id);
  }

  Future<bool> existsInData(String tipo, String id) async {
    return await _validator.existsInData(tipo, id);
  }

  bool isValidTipo(String tipo) => _validator.isValidTipo(tipo);

  bool isValidId(String id) => _validator.isValidId(id);

  // ========== STATS ==========

  Future<FavoritosStats> getStats() async {
    try {
      final stats = await repo.getFavoritosStats();
      return FavoritosStats(
        totalDefensivos: stats['defensivos'] ?? 0,
        totalPragas: stats['pragas'] ?? 0,
        totalDiagnosticos: stats['diagnosticos'] ?? 0,
        totalCulturas: stats['culturas'] ?? 0,
      );
    } catch (e) {
      return FavoritosStats.empty();
    }
  }

  // ========== CACHE ==========

  Future<void> clearAllCache() async {
    await _cache.clearAll();
  }

  Future<void> syncFavorites() async {
    try {
      await clearAllCache();
      final stats = await getStats();
      if (kDebugMode) {
        developer.log(
          'Favoritos sincronizados - Stats: $stats',
          name: 'FavoritosService',
        );
      }
    } catch (e) {
      throw FavoritosException('Erro ao sincronizar favoritos: $e');
    }
  }
}
