import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_defensivos_ui_notifier.g.dart';

/// Estados específicos para UI
enum HomeDefensivosViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// UI state for home defensivos
class HomeDefensivosUIState {
  final bool isRefreshing;
  final String? uiMessage;

  const HomeDefensivosUIState({
    required this.isRefreshing,
    this.uiMessage,
  });

  factory HomeDefensivosUIState.initial() {
    return const HomeDefensivosUIState(
      isRefreshing: false,
      uiMessage: null,
    );
  }

  HomeDefensivosUIState copyWith({
    bool? isRefreshing,
    String? uiMessage,
  }) {
    return HomeDefensivosUIState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      uiMessage: uiMessage ?? this.uiMessage,
    );
  }

  HomeDefensivosUIState clearMessage() {
    return copyWith(uiMessage: null);
  }
}

/// Notifier following Single Responsibility Principle - handles only UI state coordination
/// Coordinates between statistics and history providers for UI display
/// Separated from original HomeDefensivosProvider to improve maintainability
@riverpod
class HomeDefensivosUINotifier extends _$HomeDefensivosUINotifier {
  @override
  HomeDefensivosUIState build() {
    return HomeDefensivosUIState.initial();
  }

  /// Determine overall view state based on statistics and history providers
  HomeDefensivosViewState getViewState({
    required bool statisticsLoading,
    required bool historyLoading,
    required String? statisticsError,
    required String? historyError,
    required bool hasStatisticsData,
  }) {
    if (statisticsLoading || historyLoading) {
      return HomeDefensivosViewState.loading;
    }

    if (statisticsError != null || historyError != null) {
      return HomeDefensivosViewState.error;
    }

    if (!hasStatisticsData) {
      return HomeDefensivosViewState.empty;
    }

    return HomeDefensivosViewState.loaded;
  }

  /// Get combined error message from all providers
  String? getCombinedErrorMessage({
    required String? statisticsError,
    required String? historyError,
  }) {
    if (statisticsError != null && historyError != null) {
      return 'Múltiplos erros detectados:\n• $statisticsError\n• $historyError';
    }
    return statisticsError ?? historyError;
  }

  /// Start refresh operation
  void startRefresh() {
    if (!state.isRefreshing) {
      state = state.copyWith(isRefreshing: true).clearMessage();
    }
  }

  /// Complete refresh operation
  void completeRefresh({String? message}) {
    state = HomeDefensivosUIState(
      isRefreshing: false,
      uiMessage: message,
    );
  }

  /// Set UI message
  void setUIMessage(String message) {
    state = state.copyWith(uiMessage: message);
  }

  /// Clear UI message
  void clearUIMessage() {
    if (state.uiMessage != null) {
      state = state.clearMessage();
    }
  }

  /// Determine if content should be shown
  bool shouldShowContent({
    required bool statisticsLoading,
    required bool historyLoading,
    required bool hasStatisticsData,
  }) {
    return !statisticsLoading || hasStatisticsData;
  }

  /// Get formatted header subtitle
  String getHeaderSubtitle({
    required bool statisticsLoading,
    required bool historyLoading,
    required int totalDefensivos,
  }) {
    if (state.isRefreshing) {
      return 'Atualizando dados...';
    }

    if (statisticsLoading) {
      return 'Carregando defensivos...';
    }

    return '$totalDefensivos Registros Disponíveis';
  }

  /// Check if any loading state is active
  bool isAnyLoading({
    required bool statisticsLoading,
    required bool historyLoading,
  }) {
    return state.isRefreshing || statisticsLoading || historyLoading;
  }

  /// Check if data is ready for display
  bool isDataReady({
    required bool statisticsLoading,
    required bool historyLoading,
    required bool hasStatisticsData,
  }) {
    return !statisticsLoading && !historyLoading && hasStatisticsData;
  }
}
