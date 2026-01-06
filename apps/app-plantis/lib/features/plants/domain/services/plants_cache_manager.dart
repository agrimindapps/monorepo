import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/usecases/get_plants_usecase.dart';

/// Gerencia cache local e estratégia de loading para Plants
///
/// Responsabilidades (SRP):
/// - Load local-first strategy (cache → network)
/// - Background sync coordination
/// - Cache invalidation
/// - Data freshness tracking
class PlantsCacheManager {
  PlantsCacheManager({required GetPlantsUseCase getPlantsUseCase})
    : _getPlantsUseCase = getPlantsUseCase;

  final GetPlantsUseCase _getPlantsUseCase;

  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  /// Check if cache is fresh (less than 5 minutes old)
  bool get isCacheFresh {
    if (_lastSyncTime == null) return false;
    final age = DateTime.now().difference(_lastSyncTime!);
    return age.inMinutes < 5;
  }

  /// Load plants with local-first strategy
  ///
  /// Strategy:
  /// 1. Try loading from local cache first
  /// 2. Return cached data immediately if available
  /// 3. Sync with server in background if cache is stale
  Future<PlantsLoadResult> loadLocalFirst() async {
    try {
      debugPrint('🔄 PlantsCacheManager: Loading plants (local-first)...');

      final result = await _getPlantsUseCase.call(const NoParams());

      return await result.fold(
        (failure) async {
          debugPrint('❌ PlantsCacheManager: Load failed - ${failure.message}');
          return PlantsLoadResult.failure(failure.message);
        },
        (plants) async {
          debugPrint('✅ PlantsCacheManager: Loaded ${plants.length} plants');
          _lastSyncTime = DateTime.now();
          return PlantsLoadResult.success(plants);
        },
      );
    } catch (e) {
      debugPrint('❌ PlantsCacheManager: Exception - $e');
      return PlantsLoadResult.failure('Erro ao carregar plantas: $e');
    }
  }

  /// Sync with server in background (fire and forget)
  ///
  /// This method:
  /// - Doesn't block UI
  /// - Updates cache timestamp on success
  /// - Ignores errors silently (we already have local data)
  Future<List<Plant>?> syncInBackground() async {
    if (_isSyncing) {
      debugPrint('⏭️ PlantsCacheManager: Sync already in progress, skipping');
      return null;
    }

    try {
      _isSyncing = true;
      debugPrint('🔄 PlantsCacheManager: Background sync started...');

      final result = await _getPlantsUseCase.call(const NoParams());

      return result.fold(
        (failure) {
          debugPrint('⚠️ PlantsCacheManager: Background sync failed (silent)');
          return null;
        },
        (plants) {
          debugPrint(
            '✅ PlantsCacheManager: Background sync completed - ${plants.length} plants',
          );
          _lastSyncTime = DateTime.now();
          return plants;
        },
      );
    } catch (e) {
      debugPrint('⚠️ PlantsCacheManager: Background sync exception (silent)');
      return null;
    } finally {
      _isSyncing = false;
    }
  }

  /// Force refresh from server (explicit user action)
  Future<PlantsLoadResult> forceRefresh() async {
    debugPrint('🔄 PlantsCacheManager: Force refresh requested...');
    _lastSyncTime = null; // Invalidate cache
    return loadLocalFirst();
  }

  /// Clear all cached data
  void clearCache() {
    _lastSyncTime = null;
    debugPrint('🗑️ PlantsCacheManager: Cache cleared');
  }

  /// Dispose resources
  void dispose() {
    _isSyncing = false;
    _lastSyncTime = null;
  }
}

/// Result type for plant loading operations
class PlantsLoadResult {
  const PlantsLoadResult._({
    required this.isSuccess,
    this.plants,
    this.errorMessage,
  });

  final bool isSuccess;
  final List<Plant>? plants;
  final String? errorMessage;

  factory PlantsLoadResult.success(List<Plant> plants) {
    return PlantsLoadResult._(isSuccess: true, plants: plants);
  }

  factory PlantsLoadResult.failure(String message) {
    return PlantsLoadResult._(isSuccess: false, errorMessage: message);
  }

  T fold<T>({
    required T Function(List<Plant> plants) onSuccess,
    required T Function(String message) onFailure,
  }) {
    if (isSuccess && plants != null) {
      return onSuccess(plants!);
    } else {
      return onFailure(errorMessage ?? 'Unknown error');
    }
  }
}
