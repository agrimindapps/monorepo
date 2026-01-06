import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../database/repositories/favorito_repository.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';
import '../factories/favorito_entity_factory_registry.dart';
import 'favoritos_cache_service_inline.dart';
import 'favoritos_data_resolver_service.dart';
import 'favoritos_validator_service.dart';

/// Service consolidado para Favoritos com Specialized Services
/// Reduzido de 915 linhas para ~250 linhas usando delegation pattern
///
/// SOLID Refactoring (P1):
/// - Removed switch case factory (OCP violation)
/// - Now uses FavoritoEntityFactoryRegistry (Strategy Pattern)
/// - Extensible: adding new tipos doesn't require modifying this service
class FavoritosService {
  // Lazy loading do repository
  late final FavoritoRepository _repository;

  // Specialized Services (injetadas via construtor - DIP)
  final FavoritosDataResolverService _dataResolver;
  final FavoritosValidatorService _validator;
  final FavoritosCacheServiceInline _cache;
  final IFavoritoEntityFactoryRegistry _factoryRegistry;

  FavoritosService({
    required FavoritosDataResolverService dataResolver,
    required FavoritosValidatorService validator,
    required FavoritosCacheServiceInline cache,
    required IFavoritoEntityFactoryRegistry factoryRegistry,
    required FavoritoRepository repository,
  }) : _dataResolver = dataResolver,
       _validator = validator,
       _cache = cache,
       _factoryRegistry = factoryRegistry,
       _repository = repository;

  // Getter lazy para repository (inicializado na primeira vez que é acessado)
  FavoritoRepository get repo => _repository;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ========== STORAGE/CRUD OPERATIONS ==========

  Future<List<String>> getFavoriteIds(String tipo) async {
    try {
      if (_userId.isEmpty) return [];
      final favoritos = await repo.findByUserAndType(_userId, tipo);
      return favoritos.map((f) => f.itemId).toList();
    } catch (e) {
      throw FavoritosException('Erro ao buscar IDs favoritos: $e', tipo: tipo);
    }
  }

  Future<bool> addFavoriteId(String tipo, String id) async {
    developer.log(
      '🔖 [FAVORITOS] Adicionando favorito: tipo=$tipo, id=$id',
      name: 'FavoritosService',
    );

    try {
      if (!_validator.isValidTipo(tipo)) {
        developer.log(
          '🔖 [FAVORITOS] ❌ Tipo inválido: $tipo',
          name: 'FavoritosService',
        );
        return false;
      }

      final canAdd = await _validator.canAddToFavorites(tipo, id);
      if (!canAdd) {
        developer.log(
          '🔖 [FAVORITOS] ❌ Validação canAddToFavorites falhou para tipo=$tipo, id=$id',
          name: 'FavoritosService',
        );
        return false;
      }

      final itemDataString =
          '{"id":"$id","tipo":"$tipo","adicionadoEm":"${DateTime.now().toIso8601String()}"}';

      if (_userId.isEmpty) {
        developer.log(
          '🔖 [FAVORITOS] ❌ Usuário não autenticado ao adicionar favorito',
          name: 'FavoritosService',
        );
        // Se não tiver usuário, não salva no banco local pois a tabela exige userId
        return false;
      }

      developer.log(
        '🔖 [FAVORITOS] Inserindo no banco: userId=$_userId, tipo=$tipo, id=$id',
        name: 'FavoritosService',
      );

      final insertedId = await repo.addFavorito(
        _userId,
        tipo,
        id,
        itemDataString,
      );
      final result = insertedId > 0;

      developer.log(
        '🔖 [FAVORITOS] Resultado da inserção: insertedId=$insertedId, success=$result',
        name: 'FavoritosService',
      );

      if (result) {
        await _cache.clearForTipo(tipo);
        // Sync agora é feito via DriftSyncAdapter (offline-first)
      }

      return result;
    } catch (e, stack) {
      developer.log(
        '🔖 [FAVORITOS] ❌ Exception ao adicionar favorito: $e',
        name: 'FavoritosService',
        error: e,
        stackTrace: stack,
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
        if (kDebugMode) {
          developer.log('Tipo inválido: $tipo', name: 'FavoritosService');
        }
        return false;
      }

      if (_userId.isEmpty) return false;
      final result = await repo.removeFavorito(_userId, tipo, id);

      if (result) {
        await _cache.clearForTipo(tipo);
        // Sync agora é feito via DriftSyncAdapter (offline-first)
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
      if (_userId.isEmpty) return false;
      return await repo.isFavorited(_userId, tipo, id);
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
      if (_userId.isEmpty) return;
      await repo.clearFavoritosByTipo(_userId, tipo);
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
      if (_userId.isEmpty) return FavoritosStats.empty();
      final stats = await repo.countByType(_userId);
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
