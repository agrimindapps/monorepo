import 'package:flutter/foundation.dart';

import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import 'defensivos_history_provider.dart';
import 'defensivos_statistics_provider.dart';
import 'home_defensivos_ui_provider.dart';

/// Refactored Home Defensivos Provider following SOLID principles
/// 
/// SOLID Improvements:
/// - Single Responsibility: Coordinates between specialized providers
/// - Dependency Inversion: Injects repository and specialized providers
/// - Open/Closed: Easy to extend with new functionality without modification
/// - Interface Segregation: Delegates specific responsibilities to appropriate providers
class HomeDefensivosProvider extends ChangeNotifier {
  final DefensivosStatisticsProvider _statisticsProvider;
  final DefensivosHistoryProvider _historyProvider;
  final HomeDefensivosUIProvider _uiProvider;

  HomeDefensivosProvider({
    required FitossanitarioHiveRepository repository,
  }) : _statisticsProvider = DefensivosStatisticsProvider(repository: repository),
       _historyProvider = DefensivosHistoryProvider(repository: repository),
       _uiProvider = HomeDefensivosUIProvider() {
    
    // Listen to specialized providers and coordinate updates
    _statisticsProvider.addListener(_onProviderUpdate);
    _historyProvider.addListener(_onProviderUpdate);
    _uiProvider.addListener(_onProviderUpdate);
  }

  // Delegated getters to specialized providers
  bool get isLoading => _statisticsProvider.isLoading || _historyProvider.isLoading;
  String? get errorMessage => _uiProvider.getCombinedErrorMessage(
    statisticsError: _statisticsProvider.errorMessage,
    historyError: _historyProvider.errorMessage,
  );
  
  int get totalDefensivos => _statisticsProvider.totalDefensivos;
  int get totalFabricantes => _statisticsProvider.totalFabricantes;
  int get totalModoAcao => _statisticsProvider.totalModoAcao;
  int get totalIngredienteAtivo => _statisticsProvider.totalIngredienteAtivo;
  int get totalClasseAgronomica => _statisticsProvider.totalClasseAgronomica;
  
  List<FitossanitarioHive> get recentDefensivos => _historyProvider.recentDefensivos;
  List<FitossanitarioHive> get newDefensivos => _historyProvider.newDefensivos;
  
  // Convenience getters
  bool get hasData => _statisticsProvider.hasData;
  bool get hasRecentDefensivos => _historyProvider.hasRecentDefensivos;
  bool get hasNewDefensivos => _historyProvider.hasNewDefensivos;
  String get subtitleText => _uiProvider.getHeaderSubtitle(
    statisticsLoading: _statisticsProvider.isLoading,
    historyLoading: _historyProvider.isLoading,
    totalDefensivos: totalDefensivos,
  );

  /// Load data by coordinating specialized providers
  Future<void> loadData() async {
    try {
      // Load statistics and history concurrently for better performance
      await Future.wait([
        _statisticsProvider.loadStatistics(),
        _historyProvider.loadHistory(),
      ]);
    } catch (e) {
      _uiProvider.setUIMessage('Erro ao carregar dados: ${e.toString()}');
    }
  }

  /// Refresh data without showing loading indicators
  Future<void> refreshData() async {
    try {
      _uiProvider.startRefresh();
      
      await Future.wait([
        _statisticsProvider.refreshStatistics(),
        _historyProvider.refreshHistory(),
      ]);
      
      _uiProvider.completeRefresh(message: 'Dados atualizados com sucesso');
    } catch (e) {
      _uiProvider.completeRefresh(message: 'Erro ao atualizar dados: ${e.toString()}');
    }
  }

  /// Clear current error from all providers
  void clearError() {
    _statisticsProvider.clearError();
    _historyProvider.clearError();
    _uiProvider.clearUIMessage();
  }

  /// Record access to a defensivo
  Future<void> recordDefensivoAccess(FitossanitarioHive defensivo) async {
    await _historyProvider.recordDefensivoAccess(defensivo);
  }

  @override
  void dispose() {
    // Clean up specialized providers
    _statisticsProvider.removeListener(_onProviderUpdate);
    _historyProvider.removeListener(_onProviderUpdate);
    _uiProvider.removeListener(_onProviderUpdate);
    
    _statisticsProvider.dispose();
    _historyProvider.dispose();
    _uiProvider.dispose();
    
    super.dispose();
  }

  // Private methods
  void _onProviderUpdate() {
    // Coordinate updates from specialized providers
    notifyListeners();
  }
}

/// Extension for UI convenience methods
extension HomeDefensivosProviderUI on HomeDefensivosProvider {
  HomeDefensivosViewState get viewState {
    return _uiProvider.getViewState(
      statisticsLoading: _statisticsProvider.isLoading,
      historyLoading: _historyProvider.isLoading,
      statisticsError: _statisticsProvider.errorMessage,
      historyError: _historyProvider.errorMessage,
      hasStatisticsData: _statisticsProvider.hasData,
    );
  }

  /// Returns formatted count text
  String getFormattedCount(int count) {
    return isLoading ? '...' : '$count';
  }

  /// Whether to show content sections
  bool get shouldShowContent => _uiProvider.shouldShowContent(
    statisticsLoading: _statisticsProvider.isLoading,
    historyLoading: _historyProvider.isLoading,
    hasStatisticsData: _statisticsProvider.hasData,
  );

  /// Header subtitle text
  String get headerSubtitle => subtitleText;

  /// Access to specialized providers for advanced use cases
  DefensivosStatisticsProvider get statisticsProvider => _statisticsProvider;
  DefensivosHistoryProvider get historyProvider => _historyProvider;
  HomeDefensivosUIProvider get uiProvider => _uiProvider;
}