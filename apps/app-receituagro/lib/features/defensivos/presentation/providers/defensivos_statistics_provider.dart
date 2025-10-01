import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/services/fitossanitarios_data_loader.dart';

/// Model for statistics data computed in background
class DefensivosStatistics {
  final int totalDefensivos;
  final int totalFabricantes;
  final int totalModoAcao;
  final int totalIngredienteAtivo;
  final int totalClasseAgronomica;

  const DefensivosStatistics({
    required this.totalDefensivos,
    required this.totalFabricantes,
    required this.totalModoAcao,
    required this.totalIngredienteAtivo,
    required this.totalClasseAgronomica,
  });

  DefensivosStatistics.empty()
      : totalDefensivos = 0,
        totalFabricantes = 0,
        totalModoAcao = 0,
        totalIngredienteAtivo = 0,
        totalClasseAgronomica = 0;
}

/// Static function for compute() - calculates statistics in background isolate
/// Performance optimization: Prevents UI thread blocking during heavy statistical calculations
DefensivosStatistics _calculateDefensivosStatistics(List<FitossanitarioHive> defensivos) {
  // Calculate real statistics - moved to background thread to prevent UI blocking
  final totalDefensivos = defensivos.length;
  final totalFabricantes = defensivos.map((d) => d.displayFabricante).toSet().length;
  final totalModoAcao = defensivos.map((d) => d.displayModoAcao).where((m) => m.isNotEmpty).toSet().length;
  final totalIngredienteAtivo = defensivos.map((d) => d.displayIngredient).where((i) => i.isNotEmpty).toSet().length;
  final totalClasseAgronomica = defensivos.map((d) => d.displayClass).where((c) => c.isNotEmpty).toSet().length;

  return DefensivosStatistics(
    totalDefensivos: totalDefensivos,
    totalFabricantes: totalFabricantes,
    totalModoAcao: totalModoAcao,
    totalIngredienteAtivo: totalIngredienteAtivo,
    totalClasseAgronomica: totalClasseAgronomica,
  );
}

/// Provider following Single Responsibility Principle - handles only statistics calculation
/// Separated from HomeDefensivosProvider to improve maintainability and testability
class DefensivosStatisticsProvider extends ChangeNotifier {
  final FitossanitarioHiveRepository _repository;

  DefensivosStatistics _statistics = DefensivosStatistics.empty();
  bool _isLoading = false;
  String? _errorMessage;

  DefensivosStatisticsProvider({
    required FitossanitarioHiveRepository repository,
  }) : _repository = repository;

  // Getters
  DefensivosStatistics get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Convenience getters
  int get totalDefensivos => _statistics.totalDefensivos;
  int get totalFabricantes => _statistics.totalFabricantes;
  int get totalModoAcao => _statistics.totalModoAcao;
  int get totalIngredienteAtivo => _statistics.totalIngredienteAtivo;
  int get totalClasseAgronomica => _statistics.totalClasseAgronomica;
  
  bool get hasData => _statistics.totalDefensivos > 0;
  String get subtitleText => _isLoading ? 'Calculando estatísticas...' : '${_statistics.totalDefensivos} Registros Disponíveis';

  /// Load and calculate statistics
  Future<void> loadStatistics() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Load data from repository on main thread (required for Hive)
      var defensivos = await _repository.getActiveDefensivos();
      
      // Se não há dados, verifica se precisa aguardar o carregamento
      if (defensivos.isEmpty) {
        // Verifica se dados estão sendo carregados
        final isDataLoaded = await FitossanitariosDataLoader.isDataLoaded();
        
        if (!isDataLoaded) {
          // Aguarda um pouco e tenta novamente (dados podem estar sendo carregados)
          await Future<void>.delayed(const Duration(milliseconds: 500));
          defensivos = await _repository.getActiveDefensivos();
          
          // Se ainda estiver vazio após aguardar
          if (defensivos.isEmpty) {
            _setError('Dados não disponíveis no momento.\n\nPor favor, reinicie o aplicativo se o problema persistir.');
            _statistics = DefensivosStatistics.empty();
            return;
          }
        }
      }
      
      // Calculate statistics directly (Hive objects are not serializable for compute)
      _statistics = _calculateDefensivosStatistics(defensivos);
      
    } catch (e) {
      _setError('Erro ao calcular estatísticas: ${e.toString()}');
      _statistics = DefensivosStatistics.empty();
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh statistics without showing loading indicator
  Future<void> refreshStatistics() async {
    try {
      _clearError();
      
      var defensivos = await _repository.getActiveDefensivos();
      
      // Se não há dados, não mostra erro - apenas calcula com dados vazios
      // (durante refresh, não queremos mostrar mensagens de erro)
      _statistics = _calculateDefensivosStatistics(defensivos);
      
      notifyListeners();
      
    } catch (e) {
      _setError('Erro ao atualizar estatísticas: ${e.toString()}');
    }
  }

  /// Clear current error
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Private state management methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }
}

/// Extension for UI convenience methods
extension DefensivosStatisticsProviderUI on DefensivosStatisticsProvider {
  /// Returns formatted count text
  String getFormattedCount(int count) {
    return isLoading ? '...' : '$count';
  }

  /// Whether to show content sections
  bool get shouldShowContent => !isLoading || hasData;
}