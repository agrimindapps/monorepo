import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';
import 'bovines_filter_provider.dart';
import 'bovines_management_provider.dart';
import 'equines_management_provider.dart';
import 'livestock_search_provider.dart';
import 'livestock_statistics_provider.dart';
import 'livestock_sync_provider.dart';

part 'livestock_coordinator_provider.g.dart';

/// State class for LivestockCoordinator
class LivestockCoordinatorState {
  final bool isInitialized;

  const LivestockCoordinatorState({this.isInitialized = false});

  LivestockCoordinatorState copyWith({bool? isInitialized}) {
    return LivestockCoordinatorState(
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Provider coordenador que compõe funcionalidades especializadas
///
/// Responsabilidade única: Coordenar providers especializados seguindo SRP
/// Substitui o LivestockProvider monolítico original de 475 linhas
@riverpod
class LivestockCoordinatorNotifier extends _$LivestockCoordinatorNotifier {
  @override
  LivestockCoordinatorState build() {
    return const LivestockCoordinatorState();
  }

  // Provider accessors
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

  // Convenience getters for state access
  BovinesManagementState get bovinesState =>
      ref.read(bovinesManagementProvider);
  EquinesManagementState get equinesState =>
      ref.read(equinesManagementProvider);
  BovinesFilterState get filtersState => ref.read(bovinesFilterProvider);
  LivestockSearchState get searchState => ref.read(livestockSearchProvider);
  LivestockStatisticsState get statisticsState =>
      ref.read(livestockStatisticsProvider);
  LivestockSyncState get syncState => ref.read(livestockSyncProvider);

  /// Verifica se alguma operação está em andamento
  bool get isAnyOperationInProgress =>
      bovinesState.isAnyOperationInProgress ||
      equinesState.isAnyOperationInProgress ||
      searchState.isSearching ||
      statisticsState.isLoading ||
      syncState.isSyncing;

  /// Obtém mensagem de erro consolidada
  String? get consolidatedErrorMessage {
    final errors = <String>[];

    if (bovinesState.errorMessage != null) {
      errors.add('Bovinos: ${bovinesState.errorMessage}');
    }
    if (equinesState.errorMessage != null) {
      errors.add('Equinos: ${equinesState.errorMessage}');
    }
    if (searchState.errorMessage != null) {
      errors.add('Busca: ${searchState.errorMessage}');
    }
    if (statisticsState.errorMessage != null) {
      errors.add('Estatísticas: ${statisticsState.errorMessage}');
    }
    if (syncState.errorMessage != null) {
      errors.add('Sincronização: ${syncState.errorMessage}');
    }

    return errors.isEmpty ? null : errors.join('\n');
  }

  /// Lista filtrada de bovinos
  List<BovineEntity> get filteredBovines {
    return filtersNotifier.applyFilters(bovinesState.bovines);
  }

  /// Total de animais
  int get totalAnimals => bovinesState.totalBovines + equinesState.totalEquines;

  /// Inicialização completa do sistema livestock
  Future<void> initializeSystem() async {
    debugPrint('LivestockCoordinatorNotifier: Inicializando sistema livestock');

    await Future.wait([
      bovinesNotifier.loadBovines(),
      equinesNotifier.loadEquines(),
      statisticsNotifier.loadStatistics(),
    ]);
    filtersNotifier.updateAvailableValues(bovinesState.bovines);

    state = state.copyWith(isInitialized: true);
    debugPrint('LivestockCoordinatorNotifier: Sistema livestock inicializado');
  }

  /// Refresh completo de todos os dados
  Future<void> refreshAllData() async {
    debugPrint('LivestockCoordinatorNotifier: Atualizando todos os dados');

    await Future.wait([
      bovinesNotifier.refreshBovines(),
      equinesNotifier.refreshEquines(),
      statisticsNotifier.refreshStatistics(),
    ]);
    filtersNotifier.updateAvailableValues(bovinesState.bovines);

    debugPrint('LivestockCoordinatorNotifier: Todos os dados atualizados');
  }

  /// Sincronização completa com callback de progresso
  Future<bool> performCompleteSync({void Function(double)? onProgress}) async {
    debugPrint(
      'LivestockCoordinatorNotifier: Iniciando sincronização completa',
    );
    final syncSuccess = await syncNotifier.forceSyncNow(onProgress: onProgress);

    if (syncSuccess) {
      await refreshAllData();
      debugPrint(
        'LivestockCoordinatorNotifier: Sincronização completa realizada com sucesso',
      );
    }

    return syncSuccess;
  }

  /// Limpa todos os erros dos providers especializados
  void clearAllErrors() {
    bovinesNotifier.clearError();
    equinesNotifier.clearError();
    searchNotifier.clearError();
    statisticsNotifier.clearError();
    syncNotifier.clearError();

    debugPrint('LivestockCoordinatorNotifier: Todos os erros limpos');
  }

  /// Reset completo do sistema
  void resetSystem() {
    bovinesNotifier.resetState();
    equinesNotifier.resetState();
    filtersNotifier.clearAllFilters();
    searchNotifier.clearSearchResults();
    statisticsNotifier.clearStatistics();
    syncNotifier.resetSyncState();

    state = state.copyWith(isInitialized: false);
    debugPrint('LivestockCoordinatorNotifier: Sistema resetado');
  }

  /// Atalho para buscar animais
  Future<void> searchAnimals(String query) =>
      searchNotifier.searchAllAnimals(query);

  /// Atalho para sincronização rápida
  Future<bool> quickSync() => syncNotifier.backgroundSync();

  /// Atalho para aplicar filtros
  void applyBovineFilters() {
    filtersNotifier.updateAvailableValues(bovinesState.bovines);
  }
}
