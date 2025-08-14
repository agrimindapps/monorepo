import 'package:flutter/foundation.dart';
import '../models/atualizacao_state.dart';
import '../models/atualizacao_model.dart';
import '../services/atualizacao_data_service.dart';
import '../services/theme_service.dart';

/// Controller for managing updates page state following SOLID principles
class AtualizacaoController extends ChangeNotifier {
  final IAtualizacaoDataService _dataService;
  final IThemeService _themeService;
  
  AtualizacaoState _state = const AtualizacaoState();
  
  AtualizacaoController({
    required IAtualizacaoDataService dataService,
    required IThemeService themeService,
  }) : _dataService = dataService,
       _themeService = themeService {
    _initializeController();
  }

  /// Current state (read-only)
  AtualizacaoState get state => _state;

  /// Computed properties for convenience
  bool get hasData => _state.hasData;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  int get totalAtualizacoes => _state.totalAtualizacoes;
  List<AtualizacaoModel> get atualizacoes => _state.atualizacoesList;

  /// Initialize controller with theme listener and load data
  void _initializeController() {
    _initializeTheme();
    carregarAtualizacoes();
  }

  /// Initialize theme monitoring
  void _initializeTheme() {
    // Set initial theme state
    _updateState(_state.copyWith(isDark: _themeService.isDark));
    
    // Listen to theme changes
    _themeService.addThemeListener(_onThemeChanged);
  }

  /// Handle theme changes
  void _onThemeChanged() {
    _updateState(_state.copyWith(isDark: _themeService.isDark));
  }

  /// Load updates from data service
  Future<void> carregarAtualizacoes() async {
    try {
      _updateState(_state.withLoading(true).clearError());
      
      final atualizacoes = await _dataService.loadAtualizacoes();
      
      _updateState(_state.copyWith(
        atualizacoesList: atualizacoes,
        isLoading: false,
      ));
    } catch (e) {
      _updateState(_state.withError('Falha ao carregar atualizações: $e'));
    }
  }

  /// Refresh updates data
  Future<void> recarregarAtualizacoes() async {
    try {
      await _dataService.refresh();
      await carregarAtualizacoes();
    } catch (e) {
      _updateState(_state.withError('Falha ao recarregar atualizações: $e'));
    }
  }

  /// Check if a version is the latest
  bool isLatestVersion(AtualizacaoModel atualizacao) {
    return _state.isLatestVersion(atualizacao);
  }

  /// Get latest version model
  AtualizacaoModel? get latestVersion => _state.latestVersion;

  /// Clear any error state
  void clearError() {
    _updateState(_state.clearError());
  }

  /// Update state and notify listeners
  void _updateState(AtualizacaoState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _themeService.removeThemeListener(_onThemeChanged);
    super.dispose();
  }

  /// Debug information
  @override
  String toString() {
    return 'AtualizacaoController('
        'hasData: $hasData, '
        'isLoading: $isLoading, '
        'hasError: $hasError, '
        'totalItems: $totalAtualizacoes'
        ')';
  }
}