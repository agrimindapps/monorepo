import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/livestock_repository.dart';

/// Provider especializado para estatísticas de livestock
/// 
/// Responsabilidade única: Gerenciar estatísticas e métricas do rebanho
/// Seguindo Single Responsibility Principle
@singleton
class LivestockStatisticsProvider extends ChangeNotifier {
  final LivestockRepository _repository;

  LivestockStatisticsProvider({
    required LivestockRepository repository,
  }) : _repository = repository;
  
  bool _isLoading = false;
  Map<String, dynamic>? _statistics;
  String? _errorMessage;
  DateTime? _lastUpdate;
  
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get statistics => _statistics;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdate => _lastUpdate;
  
  bool get hasStatistics => _statistics != null;
  bool get needsUpdate => 
    _lastUpdate == null || 
    DateTime.now().difference(_lastUpdate!).inMinutes > 30;
  int get totalAnimals => (_statistics?['totalAnimals'] as int?) ?? 0;
  int get totalBovines => (_statistics?['totalBovines'] as int?) ?? 0;
  int get totalEquines => (_statistics?['totalEquines'] as int?) ?? 0;
  int get activeBovines => (_statistics?['activeBovines'] as int?) ?? 0;
  int get activeEquines => (_statistics?['activeEquines'] as int?) ?? 0;
  
  double get bovinesPercentage => totalAnimals > 0 
    ? (totalBovines / totalAnimals * 100) 
    : 0.0;
    
  double get equinesPercentage => totalAnimals > 0 
    ? (totalEquines / totalAnimals * 100) 
    : 0.0;

  /// Carrega estatísticas do rebanho
  Future<void> loadStatistics({bool forceRefresh = false}) async {
    if (!forceRefresh && hasStatistics && !needsUpdate) {
      debugPrint('LivestockStatisticsProvider: Usando estatísticas em cache');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getLivestockStatistics();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('LivestockStatisticsProvider: Erro ao carregar estatísticas - ${failure.message}');
      },
      (stats) {
        _statistics = stats;
        _lastUpdate = DateTime.now();
        debugPrint('LivestockStatisticsProvider: Estatísticas carregadas - $stats');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Invalida cache e força recarga
  Future<void> refreshStatistics() async {
    _lastUpdate = null;
    await loadStatistics(forceRefresh: true);
  }

  /// Limpa estatísticas
  void clearStatistics() {
    _statistics = null;
    _lastUpdate = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtém estatística específica por chave
  T? getStatistic<T>(String key) {
    return _statistics?[key] as T?;
  }

  /// Verifica se uma estatística existe
  bool hasStatistic(String key) {
    return _statistics?.containsKey(key) == true;
  }

  /// Obtém mapa de distribuição por categoria
  Map<String, int> get distributionByType {
    return {
      'Bovinos': totalBovines,
      'Equinos': totalEquines,
    };
  }

  /// Obtém mapa de distribuição de ativos
  Map<String, int> get activeDistribution {
    return {
      'Bovinos Ativos': activeBovines,
      'Equinos Ativos': activeEquines,
    };
  }

  @override
  void dispose() {
    debugPrint('LivestockStatisticsProvider: Disposed');
    super.dispose();
  }
}
