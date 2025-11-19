import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../../database/repositories/plants_drift_repository.dart';
import '../../../domain/entities/plant.dart';
import '../../models/plant_model.dart';
import 'plants_search_service.dart';

/// ============================================================================
/// PLANTS LOCAL DATASOURCE - MIGRADO PARA DRIFT
/// ============================================================================
///
/// **MIGRAÇÃO PARA DRIFT (Fase 2):**
/// - Removido código legado (Box, JSON serialization)
/// - Usa PlantsDriftRepository para persistência
/// - Mantém cache em memória para performance (5 minutos)
/// - Integração com PlantsSearchService
/// - Interface pública idêntica (0 breaking changes)
/// ============================================================================

abstract class PlantsLocalDatasource {
  Future<List<Plant>> getPlants();
  Future<Plant?> getPlantById(String id);
  Future<void> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String id);
  Future<void> hardDeletePlant(String id);
  Future<List<Plant>> searchPlants(String query);
  Future<List<Plant>> getPlantsBySpace(String spaceId);
  Future<void> clearCache();
}

@LazySingleton(as: PlantsLocalDatasource)
class PlantsLocalDatasourceImpl implements PlantsLocalDatasource {
  final PlantsDriftRepository _driftRepo;
  final PlantsSearchService _searchService = PlantsSearchService.instance;

  // Cache em memória (5 minutos de validade)
  List<Plant>? _cachedPlants;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  PlantsLocalDatasourceImpl(this._driftRepo);

  @override
  Future<List<Plant>> getPlants() async {
    try {
      // Verifica cache em memória
      if (_cachedPlants != null && _cacheTimestamp != null) {
        final now = DateTime.now();
        if (now.difference(_cacheTimestamp!).compareTo(_cacheValidity) < 0) {
          return _cachedPlants!;
        }
      }

      // Busca do Drift
      final plants = await _driftRepo.getAllPlants();

      // Atualiza cache
      _cachedPlants = plants;
      _cacheTimestamp = DateTime.now();

      // Atualiza índice de busca
      await _searchService.updateSearchIndexFromPlants(plants);

      return plants;
    } catch (e) {
      throw CacheFailure('Erro ao buscar plantas do cache local: ${e.toString()}');
    }
  }

  @override
  Future<Plant?> getPlantById(String id) async {
    try {
      return await _driftRepo.getPlantById(id);
    } catch (e) {
      throw CacheFailure('Erro ao buscar planta do cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> addPlant(Plant plant) async {
    try {
      if (kDebugMode) {
        debugPrint('🌱 PlantsLocalDatasourceImpl.addPlant() - Iniciando');
        debugPrint('🌱 PlantsLocalDatasourceImpl.addPlant() - plant.id: ${plant.id}');
        debugPrint('🌱 PlantsLocalDatasourceImpl.addPlant() - plant.name: ${plant.name}');
      }

      final plantModel = PlantModel.fromEntity(plant);
      await _driftRepo.insertPlant(plantModel);

      if (kDebugMode) {
        debugPrint('✅ PlantsLocalDatasourceImpl.addPlant() - Gravado com sucesso');
      }

      _invalidateCache();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsLocalDatasourceImpl.addPlant() - Erro: $e');
      }
      throw CacheFailure('Erro ao salvar planta no cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    try {
      final plantModel = PlantModel.fromEntity(plant);
      await _driftRepo.updatePlant(plantModel);
      _invalidateCache();
    } catch (e) {
      throw CacheFailure('Erro ao atualizar planta no cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    try {
      await _driftRepo.deletePlant(id);
      _invalidateCache();
    } catch (e) {
      throw CacheFailure('Erro ao deletar planta do cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> hardDeletePlant(String id) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Iniciando');
        debugPrint('🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - id: $id');
      }

      await _driftRepo.hardDeletePlant(id);

      if (kDebugMode) {
        debugPrint('✅ PlantsLocalDatasourceImpl.hardDeletePlant() - Removido fisicamente');
      }

      _invalidateCache();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsLocalDatasourceImpl.hardDeletePlant() - Erro: $e');
      }
      throw CacheFailure('Erro ao remover fisicamente planta do cache local: ${e.toString()}');
    }
  }

  @override
  Future<List<Plant>> searchPlants(String query) async {
    try {
      // Primeiro tenta o search service (cache + debounce)
      final results = await _searchService.searchWithDebounce(
        query,
        const Duration(milliseconds: 300),
      );
      return results;
    } catch (e) {
      // Fallback: busca direto no Drift
      try {
        return await _driftRepo.searchPlants(query);
      } catch (fallbackError) {
        throw CacheFailure('Erro ao buscar plantas no cache local: ${fallbackError.toString()}');
      }
    }
  }

  @override
  Future<List<Plant>> getPlantsBySpace(String spaceId) async {
    try {
      return await _driftRepo.getPlantsBySpace(spaceId);
    } catch (e) {
      throw CacheFailure('Erro ao buscar plantas por espaço no cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _driftRepo.clearAll();
      _invalidateCache();
      _searchService.clearCache();
    } catch (e) {
      throw CacheFailure('Erro ao limpar cache local: ${e.toString()}');
    }
  }

  /// Invalidate memory cache and search cache
  void _invalidateCache() {
    _cachedPlants = null;
    _cacheTimestamp = null;
    _searchService.clearCache();
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'plantsCache': {
        'cached': _cachedPlants != null,
        'cacheSize': _cachedPlants?.length ?? 0,
        'cacheAge': _cacheTimestamp != null
            ? DateTime.now().difference(_cacheTimestamp!).inMinutes
            : null,
      },
      'searchCache': _searchService.getCacheStats(),
    };
  }
}
