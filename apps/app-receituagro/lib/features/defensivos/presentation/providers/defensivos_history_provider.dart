import 'package:flutter/foundation.dart';

import '../../../../core/extensions/fitossanitario_hive_extension.dart';
import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/services/access_history_service.dart';
import '../../../../core/services/random_selection_service.dart';

/// Provider following Single Responsibility Principle - handles only history and random selections
/// Separated from HomeDefensivosProvider to improve maintainability and testability
class DefensivosHistoryProvider extends ChangeNotifier {
  final FitossanitarioHiveRepository _repository;
  final AccessHistoryService _historyService = AccessHistoryService();

  List<FitossanitarioHive> _recentDefensivos = [];
  List<FitossanitarioHive> _newDefensivos = [];
  bool _isLoading = false;
  String? _errorMessage;

  DefensivosHistoryProvider({
    required FitossanitarioHiveRepository repository,
  }) : _repository = repository;

  // Getters
  List<FitossanitarioHive> get recentDefensivos => List.unmodifiable(_recentDefensivos);
  List<FitossanitarioHive> get newDefensivos => List.unmodifiable(_newDefensivos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Convenience getters
  bool get hasRecentDefensivos => _recentDefensivos.isNotEmpty;
  bool get hasNewDefensivos => _newDefensivos.isNotEmpty;

  /// Load history and generate recommendations
  Future<void> loadHistory() async {
    try {
      _setLoading(true);
      _clearError();
      
      final allDefensivos = _repository.getActiveDefensivos();
      
      // If no data, return empty lists
      if (allDefensivos.isEmpty) {
        _recentDefensivos = [];
        _newDefensivos = [];
        return;
      }
      
      await _loadHistoryData(allDefensivos);
      
    } catch (e) {
      _setError('Erro ao carregar histórico: ${e.toString()}');
      // Use random selection as fallback
      final allDefensivos = _repository.getActiveDefensivos();
      if (allDefensivos.isNotEmpty) {
        _recentDefensivos = RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 3);
        _newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 4);
      } else {
        _recentDefensivos = [];
        _newDefensivos = [];
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh history data without showing loading indicator
  Future<void> refreshHistory() async {
    try {
      _clearError();
      
      final allDefensivos = _repository.getActiveDefensivos();
      await _loadHistoryData(allDefensivos);
      
      notifyListeners();
      
    } catch (e) {
      _setError('Erro ao atualizar histórico: ${e.toString()}');
    }
  }

  /// Record access to a defensivo
  Future<void> recordDefensivoAccess(FitossanitarioHive defensivo) async {
    await _historyService.recordDefensivoAccess(
      id: defensivo.idReg,
      name: defensivo.displayName,
      fabricante: defensivo.displayFabricante,
      ingrediente: defensivo.displayIngredient,
      classe: defensivo.displayClass,
    );
  }

  /// Clear current error
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Load history data and combine with random selection
  Future<void> _loadHistoryData(List<FitossanitarioHive> allDefensivos) async {
    try {
      // Load access history
      final historyItems = await _historyService.getDefensivosHistory();
      
      // If no defensivos, return empty lists
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
      
      // Combine history with random selection
      _recentDefensivos = RandomSelectionService.combineHistoryWithRandom(
        historicDefensivos,
        allDefensivos,
        10,
        RandomSelectionService.selectRandomDefensivos,
      );
      
      // For "new", use random selection with "latest" logic
      _newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 10);
      
    } catch (e) {
      // In case of error, use random selection as fallback
      if (allDefensivos.isNotEmpty) {
        _recentDefensivos = RandomSelectionService.selectRandomDefensivos(allDefensivos, count: 3);
        _newDefensivos = RandomSelectionService.selectNewDefensivos(allDefensivos, count: 4);
      } else {
        _recentDefensivos = [];
        _newDefensivos = [];
      }
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