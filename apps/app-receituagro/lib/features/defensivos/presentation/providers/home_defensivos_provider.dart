import 'package:flutter/foundation.dart';

import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/services/access_history_service.dart';
import '../../../../core/services/random_selection_service.dart';

/// Model for statistics data computed in background
class DefensivosStatistics {
  final int totalDefensivos;
  final int totalFabricantes;
  final int totalModoAcao;
  final int totalIngredienteAtivo;
  final int totalClasseAgronomica;
  final List<FitossanitarioHive> recentDefensivos;
  final List<FitossanitarioHive> newDefensivos;

  const DefensivosStatistics({
    required this.totalDefensivos,
    required this.totalFabricantes,
    required this.totalModoAcao,
    required this.totalIngredienteAtivo,
    required this.totalClasseAgronomica,
    required this.recentDefensivos,
    required this.newDefensivos,
  });
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
  
  // Sort by name to ensure consistent ordering
  defensivos.sort((a, b) => a.displayName.compareTo(b.displayName));
  
  // Retorna listas vazias - a seleção será feita no provider principal
  final recentDefensivos = <FitossanitarioHive>[];
  final newDefensivos = <FitossanitarioHive>[];

  return DefensivosStatistics(
    totalDefensivos: totalDefensivos,
    totalFabricantes: totalFabricantes,
    totalModoAcao: totalModoAcao,
    totalIngredienteAtivo: totalIngredienteAtivo,
    totalClasseAgronomica: totalClasseAgronomica,
    recentDefensivos: recentDefensivos,
    newDefensivos: newDefensivos,
  );
}

/// Provider seguindo padrão Clean Architecture para página Home de Defensivos
/// 
/// Performance optimizations:
/// - Uses compute() to move heavy calculations to background isolate
/// - Consolidates state updates using single notifyListeners() call
/// - Implements proper error handling without multiple setState calls
class HomeDefensivosProvider extends ChangeNotifier {
  final FitossanitarioHiveRepository _repository;
  final AccessHistoryService _historyService = AccessHistoryService();

  // Estados consolidados
  bool _isLoading = false;
  String? _errorMessage;
  
  // Dados calculados em background
  int _totalDefensivos = 0;
  int _totalFabricantes = 0;
  int _totalModoAcao = 0;
  int _totalIngredienteAtivo = 0;
  int _totalClasseAgronomica = 0;
  
  List<FitossanitarioHive> _recentDefensivos = [];
  List<FitossanitarioHive> _newDefensivos = [];

  HomeDefensivosProvider({
    required FitossanitarioHiveRepository repository,
  }) : _repository = repository;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get totalDefensivos => _totalDefensivos;
  int get totalFabricantes => _totalFabricantes;
  int get totalModoAcao => _totalModoAcao;
  int get totalIngredienteAtivo => _totalIngredienteAtivo;
  int get totalClasseAgronomica => _totalClasseAgronomica;
  
  List<FitossanitarioHive> get recentDefensivos => List.unmodifiable(_recentDefensivos);
  List<FitossanitarioHive> get newDefensivos => List.unmodifiable(_newDefensivos);
  
  // Getters de conveniência
  bool get hasData => _totalDefensivos > 0;
  bool get hasRecentDefensivos => _recentDefensivos.isNotEmpty;
  bool get hasNewDefensivos => _newDefensivos.isNotEmpty;
  String get subtitleText => _isLoading ? 'Carregando defensivos...' : '$_totalDefensivos Registros Disponíveis';

  /// Carrega dados reais com otimização de performance
  Future<void> loadData() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Carrega dados do repositório na main thread (necessário para Hive)
      final defensivos = _repository.getActiveDefensivos();
      
      // Performance optimization: Move heavy statistical calculations to background isolate
      final statistics = await compute(_calculateDefensivosStatistics, defensivos);
      
      // Aplica resultados consolidadamente
      await _applyStatistics(statistics);
      
    } catch (e) {
      _setError('Erro ao carregar dados: ${e.toString()}');
      _resetToDefaultValues();
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza dados sem mostrar loading (para refresh silencioso)
  Future<void> refreshData() async {
    try {
      _clearError();
      
      final defensivos = _repository.getActiveDefensivos();
      final statistics = await compute(_calculateDefensivosStatistics, defensivos);
      
      await _applyStatistics(statistics);
      
    } catch (e) {
      _setError('Erro ao atualizar dados: ${e.toString()}');
    }
  }

  /// Limpa erro atual
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Registra acesso a um defensivo
  Future<void> recordDefensivoAccess(FitossanitarioHive defensivo) async {
    await _historyService.recordDefensivoAccess(
      id: defensivo.idReg,
      name: defensivo.displayName,
      fabricante: defensivo.displayFabricante,
      ingrediente: defensivo.displayIngredient,
      classe: defensivo.displayClass,
    );
  }

  // Métodos privados para gerenciar estado consolidado

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

  Future<void> _applyStatistics(DefensivosStatistics statistics) async {
    _totalDefensivos = statistics.totalDefensivos;
    _totalFabricantes = statistics.totalFabricantes;
    _totalModoAcao = statistics.totalModoAcao;
    _totalIngredienteAtivo = statistics.totalIngredienteAtivo;
    _totalClasseAgronomica = statistics.totalClasseAgronomica;
    
    // Carrega histórico real para recent e new
    await _loadHistoryData(statistics);
    
    // Single notification consolidates all state changes
    notifyListeners();
  }

  /// Carrega dados do histórico e combina com seleção aleatória
  Future<void> _loadHistoryData(DefensivosStatistics statistics) async {
    try {
      // Carrega histórico de acessos
      final historyItems = await _historyService.getDefensivosHistory();
      
      // Converte histórico para FitossanitarioHive
      final allDefensivos = _repository.getActiveDefensivos();
      
      // Se não há defensivos, retorna listas vazias
      if (allDefensivos.isEmpty) {
        _recentDefensivos = [];
        _newDefensivos = [];
        return;
      }
      
      final historicDefensivos = <FitossanitarioHive>[];
      
      for (final historyItem in historyItems.take(10)) {
        final defensivo = allDefensivos.firstWhere(
          (d) => d.idReg == historyItem.id,
          orElse: () => allDefensivos.firstWhere(
            (d) => d.displayName == historyItem.name,
            orElse: () => FitossanitarioHive(
              idReg: '',
              status: false,
              nomeComum: '',
              nomeTecnico: '',
              comercializado: 0,
              elegivel: false,
            ),
          ),
        );
        
        if (defensivo.idReg.isNotEmpty) {
          historicDefensivos.add(defensivo);
        }
      }
      
      // Combina histórico com seleção aleatória
      _recentDefensivos = RandomSelectionService.combineHistoryWithRandom(
        historicDefensivos,
        allDefensivos,
        10,
        RandomSelectionService.selectRandomDefensivos,
      );
      
      // Para "novos", usa seleção aleatória com lógica de "mais recentes"
      _newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 10);
      
    } catch (e) {
      // Em caso de erro, usa seleção aleatória como fallback
      final allDefensivos = _repository.getActiveDefensivos();
      if (allDefensivos.isNotEmpty) {
        _recentDefensivos = RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 3);
        _newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 4);
      } else {
        _recentDefensivos = [];
        _newDefensivos = [];
      }
    }
  }

  void _resetToDefaultValues() {
    _totalDefensivos = 0;
    _totalFabricantes = 0;
    _totalModoAcao = 0;
    _totalIngredienteAtivo = 0;
    _totalClasseAgronomica = 0;
    _recentDefensivos = [];
    _newDefensivos = [];
  }
}

/// Estados específicos para UI
enum HomeDefensivosViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Extension para facilitar uso na UI
extension HomeDefensivosProviderUI on HomeDefensivosProvider {
  HomeDefensivosViewState get viewState {
    if (isLoading) return HomeDefensivosViewState.loading;
    if (errorMessage != null) return HomeDefensivosViewState.error;
    if (!hasData) return HomeDefensivosViewState.empty;
    return HomeDefensivosViewState.loaded;
  }

  /// Retorna texto formatado para contadores
  String getFormattedCount(int count) {
    return isLoading ? '...' : '$count';
  }

  /// Verifica se deve mostrar seção de dados
  bool get shouldShowContent => !isLoading || hasData;

  /// Texto para header da página
  String get headerSubtitle => subtitleText;
}