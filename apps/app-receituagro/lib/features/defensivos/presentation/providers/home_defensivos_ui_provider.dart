import 'package:flutter/foundation.dart';

/// Estados específicos para UI
enum HomeDefensivosViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Provider following Single Responsibility Principle - handles only UI state coordination
/// Coordinates between statistics and history providers for UI display
/// Separated from original HomeDefensivosProvider to improve maintainability
class HomeDefensivosUIProvider extends ChangeNotifier {
  bool _isRefreshing = false;
  String? _uiMessage;

  // Getters
  bool get isRefreshing => _isRefreshing;
  String? get uiMessage => _uiMessage;

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
    if (!_isRefreshing) {
      _isRefreshing = true;
      _clearUIMessage();
      notifyListeners();
    }
  }

  /// Complete refresh operation
  void completeRefresh({String? message}) {
    _isRefreshing = false;
    _uiMessage = message;
    notifyListeners();
  }

  /// Set UI message
  void setUIMessage(String message) {
    _uiMessage = message;
    notifyListeners();
  }

  /// Clear UI message
  void clearUIMessage() {
    if (_uiMessage != null) {
      _uiMessage = null;
      notifyListeners();
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
    if (_isRefreshing) {
      return 'Atualizando dados...';
    }
    
    if (statisticsLoading) {
      return 'Carregando defensivos...';
    }
    
    return '$totalDefensivos Registros Disponíveis';
  }

  // Private methods
  void _clearUIMessage() {
    if (_uiMessage != null) {
      _uiMessage = null;
    }
  }
}

/// Extension for UI convenience methods
extension HomeDefensivosUIProviderExt on HomeDefensivosUIProvider {
  /// Check if any loading state is active
  bool isAnyLoading({
    required bool statisticsLoading,
    required bool historyLoading,
  }) {
    return _isRefreshing || statisticsLoading || historyLoading;
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