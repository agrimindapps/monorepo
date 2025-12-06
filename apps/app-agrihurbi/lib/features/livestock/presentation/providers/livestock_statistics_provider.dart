import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/livestock_repository.dart';
import 'livestock_di_providers.dart';

part 'livestock_statistics_provider.g.dart';

/// State class for LivestockStatistics
class LivestockStatisticsState {
  final bool isLoading;
  final Map<String, dynamic>? statistics;
  final String? errorMessage;
  final DateTime? lastUpdate;

  const LivestockStatisticsState({
    this.isLoading = false,
    this.statistics,
    this.errorMessage,
    this.lastUpdate,
  });

  LivestockStatisticsState copyWith({
    bool? isLoading,
    Map<String, dynamic>? statistics,
    String? errorMessage,
    DateTime? lastUpdate,
    bool clearError = false,
    bool clearStatistics = false,
  }) {
    return LivestockStatisticsState(
      isLoading: isLoading ?? this.isLoading,
      statistics: clearStatistics ? null : (statistics ?? this.statistics),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdate: clearStatistics ? null : (lastUpdate ?? this.lastUpdate),
    );
  }

  bool get hasStatistics => statistics != null;
  bool get needsUpdate =>
      lastUpdate == null ||
      DateTime.now().difference(lastUpdate!).inMinutes > 30;
  int get totalAnimals => (statistics?['totalAnimals'] as int?) ?? 0;
  int get totalBovines => (statistics?['totalBovines'] as int?) ?? 0;
  int get totalEquines => (statistics?['totalEquines'] as int?) ?? 0;
  int get activeBovines => (statistics?['activeBovines'] as int?) ?? 0;
  int get activeEquines => (statistics?['activeEquines'] as int?) ?? 0;

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
}

/// Provider especializado para estatísticas de livestock
///
/// Responsabilidade única: Gerenciar estatísticas e métricas do rebanho
/// Seguindo Single Responsibility Principle
@riverpod
class LivestockStatisticsNotifier extends _$LivestockStatisticsNotifier {
  LivestockRepository get _repository => ref.read(livestockRepositoryProvider);

  @override
  LivestockStatisticsState build() {
    return const LivestockStatisticsState();
  }

  // Convenience getters for backward compatibility
  bool get isLoading => state.isLoading;
  Map<String, dynamic>? get statistics => state.statistics;
  String? get errorMessage => state.errorMessage;
  DateTime? get lastUpdate => state.lastUpdate;
  bool get hasStatistics => state.hasStatistics;
  bool get needsUpdate => state.needsUpdate;
  int get totalAnimals => state.totalAnimals;
  int get totalBovines => state.totalBovines;
  int get totalEquines => state.totalEquines;
  int get activeBovines => state.activeBovines;
  int get activeEquines => state.activeEquines;
  double get bovinesPercentage => state.bovinesPercentage;
  double get equinesPercentage => state.equinesPercentage;
  Map<String, int> get distributionByType => state.distributionByType;
  Map<String, int> get activeDistribution => state.activeDistribution;

  /// Carrega estatísticas do rebanho
  Future<void> loadStatistics({bool forceRefresh = false}) async {
    if (!forceRefresh && state.hasStatistics && !state.needsUpdate) {
      debugPrint('LivestockStatisticsNotifier: Usando estatísticas em cache');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getLivestockStatistics();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        debugPrint(
            'LivestockStatisticsNotifier: Erro ao carregar estatísticas - ${failure.message}');
      },
      (stats) {
        state = state.copyWith(
          statistics: stats,
          lastUpdate: DateTime.now(),
          isLoading: false,
        );
        debugPrint(
            'LivestockStatisticsNotifier: Estatísticas carregadas - $stats');
      },
    );
  }

  /// Invalida cache e força recarga
  Future<void> refreshStatistics() async {
    state = state.copyWith(clearStatistics: true);
    await loadStatistics(forceRefresh: true);
  }

  /// Limpa estatísticas
  void clearStatistics() {
    state = state.copyWith(clearStatistics: true);
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Obtém estatística específica por chave
  T? getStatistic<T>(String key) {
    return state.statistics?[key] as T?;
  }

  /// Verifica se uma estatística existe
  bool hasStatistic(String key) {
    return state.statistics?.containsKey(key) == true;
  }
}
