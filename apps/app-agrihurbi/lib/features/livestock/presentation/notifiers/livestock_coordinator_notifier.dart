import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';
import 'bovines_filter_notifier.dart';
import 'bovines_management_notifier.dart';
import 'equines_management_notifier.dart';
import 'livestock_coordinator_state.dart';
import 'livestock_search_notifier.dart';
import 'livestock_statistics_notifier.dart';
import 'livestock_sync_notifier.dart';

part 'livestock_coordinator_notifier.g.dart';

/// Riverpod coordinator notifier that composes specialized notifiers
///
/// Single Responsibility: Coordinate specialized providers following SRP
/// Replaces the monolithic LivestockProvider (475 lines)
@riverpod
class LivestockCoordinatorNotifier extends _$LivestockCoordinatorNotifier {
  @override
  LivestockCoordinatorState build() {
    return const LivestockCoordinatorState();
  }

  /// Access to specialized notifiers via ref.read/ref.watch
  BovinesManagementNotifier get bovinesNotifier =>
      ref.read(bovinesManagementProvider.notifier);

  EquinesManagementNotifier get equinesNotifier =>
      ref.read(equinesManagementProvider.notifier);

  BovinesFilterNotifier get filtersNotifier =>
      ref.read(bovinesFilterProvider.notifier);

  LivestockSearchNotifier get searchNotifier =>
      ref.read(livestockSearchProvider.notifier);

  LivestockStatisticsNotifier get statisticsNotifier =>
      ref.read(livestockStatisticsProvider.notifier);

  LivestockSyncNotifier get syncNotifier =>
      ref.read(livestockSyncProvider.notifier);

  /// Aggregated states from specialized notifiers
  bool get isAnyOperationInProgress {
    final bovinesState = ref.watch(bovinesManagementProvider);
    final equinesState = ref.watch(equinesManagementProvider);
    final searchState = ref.watch(livestockSearchProvider);
    final statsState = ref.watch(livestockStatisticsProvider);
    final syncState = ref.watch(livestockSyncProvider);

    return (bovinesState.isLoadingBovines ||
        bovinesState.isCreating ||
        bovinesState.isUpdating ||
        bovinesState.isDeleting) ||
        (equinesState.isLoadingEquines ||
            equinesState.isCreating ||
            equinesState.isUpdating ||
            equinesState.isDeleting) ||
        searchState.isSearching ||
        statsState.isLoading ||
        syncState.isSyncing;
  }

  /// Consolidated error message from all providers
  String? get consolidatedErrorMessage {
    final errors = <String>[];

    final bovinesState = ref.watch(bovinesManagementProvider);
    final equinesState = ref.watch(equinesManagementProvider);
    final searchState = ref.watch(livestockSearchProvider);
    final statsState = ref.watch(livestockStatisticsProvider);
    final syncState = ref.watch(livestockSyncProvider);

    if (bovinesState.errorMessage != null) {
      errors.add('Bovinos: ${bovinesState.errorMessage}');
    }
    if (equinesState.errorMessage != null) {
      errors.add('Equinos: ${equinesState.errorMessage}');
    }
    if (searchState.errorMessage != null) {
      errors.add('Busca: ${searchState.errorMessage}');
    }
    if (statsState.errorMessage != null) {
      errors.add('Estatísticas: ${statsState.errorMessage}');
    }
    if (syncState.errorMessage != null) {
      errors.add('Sincronização: ${syncState.errorMessage}');
    }

    return errors.isEmpty ? null : errors.join('\n');
  }

  /// Filtered bovines list
  List<BovineEntity> get filteredBovines {
    final bovinesState = ref.watch(bovinesManagementProvider);
    return filtersNotifier.applyFilters(bovinesState.bovines);
  }

  /// Total animals across all types
  int get totalAnimals {
    final bovinesState = ref.watch(bovinesManagementProvider);
    final equinesState = ref.watch(equinesManagementProvider);
    return bovinesState.bovines.length + equinesState.equines.length;
  }

  /// Complete system initialization
  Future<void> initializeSystem() async {
    debugPrint(
      'LivestockCoordinatorNotifier: Inicializando sistema livestock',
    );

    state = state.copyWith(isInitializing: true);

    await Future.wait([
      bovinesNotifier.loadBovines(),
      equinesNotifier.loadEquines(),
      statisticsNotifier.loadStatistics(),
    ]);

    final bovinesState = ref.read(bovinesManagementProvider);
    filtersNotifier.updateAvailableValues(bovinesState.bovines);

    state = state.copyWith(isInitializing: false);

    debugPrint(
      'LivestockCoordinatorNotifier: Sistema livestock inicializado',
    );
  }

  /// Complete refresh of all data
  Future<void> refreshAllData() async {
    debugPrint('LivestockCoordinatorNotifier: Atualizando todos os dados');

    await Future.wait([
      bovinesNotifier.refreshBovines(),
      equinesNotifier.refreshEquines(),
      statisticsNotifier.refreshStatistics(),
    ]);

    final bovinesState = ref.read(bovinesManagementProvider);
    filtersNotifier.updateAvailableValues(bovinesState.bovines);

    debugPrint('LivestockCoordinatorNotifier: Todos os dados atualizados');
  }

  /// Complete synchronization with progress callback
  Future<bool> performCompleteSync({void Function(double)? onProgress}) async {
    debugPrint(
      'LivestockCoordinatorNotifier: Iniciando sincronização completa',
    );

    final syncSuccess = await syncNotifier.forceSyncNow(
      onProgress: onProgress,
    );

    if (syncSuccess) {
      await refreshAllData();
      debugPrint(
        'LivestockCoordinatorNotifier: Sincronização completa realizada com sucesso',
      );
    }

    return syncSuccess;
  }

  /// Clears all errors from specialized providers
  void clearAllErrors() {
    bovinesNotifier.clearError();
    equinesNotifier.clearError();
    searchNotifier.clearError();
    statisticsNotifier.clearError();
    syncNotifier.clearError();

    debugPrint('LivestockCoordinatorNotifier: Todos os erros limpos');
  }

  /// Complete system reset
  void resetSystem() {
    bovinesNotifier.resetState();
    equinesNotifier.resetState();
    filtersNotifier.clearAllFilters();
    searchNotifier.clearSearchResults();
    statisticsNotifier.clearStatistics();
    syncNotifier.resetSyncState();

    debugPrint('LivestockCoordinatorNotifier: Sistema resetado');
  }

  /// Shortcut methods for common operations

  /// Shortcut for searching animals
  Future<void> searchAnimals(String query) {
    return searchNotifier.searchAllAnimals(query);
  }

  /// Shortcut for quick sync
  Future<bool> quickSync() {
    return syncNotifier.backgroundSync();
  }

  /// Shortcut for applying bovine filters
  void applyBovineFilters() {
    final bovinesState = ref.read(bovinesManagementProvider);
    filtersNotifier.updateAvailableValues(bovinesState.bovines);
  }
}
