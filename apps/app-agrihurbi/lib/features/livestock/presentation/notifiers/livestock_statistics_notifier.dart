import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/livestock_repository.dart';
import 'livestock_statistics_state.dart';

part 'livestock_statistics_notifier.g.dart';

/// Riverpod notifier for livestock statistics
///
/// Single Responsibility: Manage statistics and metrics of the herd
@riverpod
class LivestockStatisticsNotifier extends _$LivestockStatisticsNotifier {
  late final LivestockRepository _repository;

  @override
  LivestockStatisticsState build() {
    _repository = getIt<LivestockRepository>();
    return const LivestockStatisticsState();
  }

  /// Computed properties
  bool get hasStatistics => state.statistics != null;
  bool get needsUpdate =>
      state.lastUpdate == null ||
      DateTime.now().difference(state.lastUpdate!).inMinutes > 30;

  int get totalAnimals => (state.statistics?['totalAnimals'] as int?) ?? 0;
  int get totalBovines => (state.statistics?['totalBovines'] as int?) ?? 0;
  int get totalEquines => (state.statistics?['totalEquines'] as int?) ?? 0;
  int get activeBovines => (state.statistics?['activeBovines'] as int?) ?? 0;
  int get activeEquines => (state.statistics?['activeEquines'] as int?) ?? 0;

  double get bovinesPercentage =>
      totalAnimals > 0 ? (totalBovines / totalAnimals * 100) : 0.0;

  double get equinesPercentage =>
      totalAnimals > 0 ? (totalEquines / totalAnimals * 100) : 0.0;

  Map<String, int> get distributionByType {
    return {
      'Bovinos': totalBovines,
      'Equinos': totalEquines,
    };
  }

  Map<String, int> get activeDistribution {
    return {
      'Bovinos Ativos': activeBovines,
      'Equinos Ativos': activeEquines,
    };
  }

  /// Loads livestock statistics
  Future<void> loadStatistics({bool forceRefresh = false}) async {
    if (!forceRefresh && hasStatistics && !needsUpdate) {
      debugPrint('LivestockStatisticsNotifier: Usando estatísticas em cache');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final result = await _repository.getLivestockStatistics();

    result.fold(
      (failure) {
        debugPrint(
          'LivestockStatisticsNotifier: Erro ao carregar estatísticas - ${failure.message}',
        );
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (stats) {
        debugPrint(
          'LivestockStatisticsNotifier: Estatísticas carregadas - $stats',
        );
        state = state.copyWith(
          statistics: stats,
          lastUpdate: DateTime.now(),
          isLoading: false,
        );
      },
    );
  }

  /// Invalidates cache and forces reload
  Future<void> refreshStatistics() async {
    state = state.copyWith(lastUpdate: null);
    await loadStatistics(forceRefresh: true);
  }

  /// Clears statistics
  void clearStatistics() {
    state = const LivestockStatisticsState();
  }

  /// Clears error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Gets specific statistic by key
  T? getStatistic<T>(String key) {
    return state.statistics?[key] as T?;
  }

  /// Checks if a statistic exists
  bool hasStatistic(String key) {
    return state.statistics?.containsKey(key) == true;
  }
}
