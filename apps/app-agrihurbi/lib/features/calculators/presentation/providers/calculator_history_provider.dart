import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/manage_calculation_history.dart';
import '../../domain/usecases/save_calculation_to_history.dart';

/// Provider especializado para histórico de cálculos
/// 
/// Responsabilidade única: Gerenciar histórico de cálculos
/// Seguindo Single Responsibility Principle
@singleton
class CalculatorHistoryProvider extends ChangeNotifier {
  final GetCalculationHistory _getCalculationHistory;
  final SaveCalculationToHistory _saveCalculationToHistory;

  CalculatorHistoryProvider({
    required GetCalculationHistory getCalculationHistory,
    required SaveCalculationToHistory saveCalculationToHistory,
  })  : _getCalculationHistory = getCalculationHistory,
        _saveCalculationToHistory = saveCalculationToHistory;

  // === STATE MANAGEMENT ===

  List<CalculationHistory> _calculationHistory = [];
  bool _isLoadingHistory = false;
  bool _isSavingToHistory = false;
  String? _errorMessage;

  // === GETTERS ===

  List<CalculationHistory> get calculationHistory => _calculationHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isSavingToHistory => _isSavingToHistory;
  String? get errorMessage => _errorMessage;
  
  int get totalHistoryItems => _calculationHistory.length;
  bool get hasHistory => _calculationHistory.isNotEmpty;
  
  /// Obtém os últimos N itens do histórico
  List<CalculationHistory> getRecentHistory(int count) {
    return _calculationHistory.take(count).toList();
  }

  /// Obtém histórico por calculadora
  List<CalculationHistory> getHistoryByCalculator(String calculatorId) {
    return _calculationHistory
        .where((item) => item.calculatorId == calculatorId)
        .toList();
  }

  /// Obtém histórico por data
  List<CalculationHistory> getHistoryByDateRange(DateTime start, DateTime end) {
    return _calculationHistory
        .where((item) => 
          item.createdAt.isAfter(start) && 
          item.createdAt.isBefore(end))
        .toList();
  }

  // === HISTORY OPERATIONS ===

  /// Carrega histórico de cálculos
  Future<void> loadCalculationHistory() async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCalculationHistory.call();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorHistoryProvider: Erro ao carregar histórico - ${failure.message}');
      },
      (history) {
        _calculationHistory = history;
        debugPrint('CalculatorHistoryProvider: Histórico carregado - ${history.length} itens');
      },
    );

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Salva resultado no histórico
  Future<bool> saveToHistory({
    required String calculatorId,
    required String calculatorName,
    required CalculationResult result,
    String? userId,
    String? notes,
  }) async {
    _isSavingToHistory = true;
    _errorMessage = null;
    notifyListeners();

    final historyItem = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId ?? 'current_user', // TODO: Obter do contexto de autenticação
      calculatorId: calculatorId,
      calculatorName: calculatorName,
      result: result,
      createdAt: DateTime.now(),
      notes: notes,
    );

    final saveResult = await _saveCalculationToHistory.call(historyItem);
    
    bool success = false;
    saveResult.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorHistoryProvider: Erro ao salvar no histórico - ${failure.message}');
      },
      (_) {
        // Adiciona ao início da lista (mais recente primeiro)
        _calculationHistory.insert(0, historyItem);
        success = true;
        debugPrint('CalculatorHistoryProvider: Resultado salvo no histórico - ${historyItem.id}');
      },
    );

    _isSavingToHistory = false;
    notifyListeners();
    return success;
  }

  /// Remove item do histórico por ID
  Future<bool> removeFromHistory(String historyId) async {
    final initialCount = _calculationHistory.length;
    _calculationHistory.removeWhere((item) => item.id == historyId);
    final removed = initialCount - _calculationHistory.length;
    
    if (removed > 0) {
      notifyListeners();
      debugPrint('CalculatorHistoryProvider: Item removido do histórico - $historyId');
      return true;
    }
    
    return false;
  }

  /// Remove múltiplos itens do histórico
  Future<bool> removeMultipleFromHistory(List<String> historyIds) async {
    final initialCount = _calculationHistory.length;
    _calculationHistory.removeWhere((item) => historyIds.contains(item.id));
    
    final removedCount = initialCount - _calculationHistory.length;
    if (removedCount > 0) {
      notifyListeners();
      debugPrint('CalculatorHistoryProvider: $removedCount itens removidos do histórico');
      return true;
    }
    
    return false;
  }

  /// Limpa todo o histórico
  Future<bool> clearAllHistory() async {
    _calculationHistory.clear();
    notifyListeners();
    debugPrint('CalculatorHistoryProvider: Todo histórico limpo');
    return true;
  }

  /// Limpa histórico de uma calculadora específica
  Future<bool> clearCalculatorHistory(String calculatorId) async {
    final initialCount = _calculationHistory.length;
    _calculationHistory.removeWhere((item) => item.calculatorId == calculatorId);
    
    final removedCount = initialCount - _calculationHistory.length;
    if (removedCount > 0) {
      notifyListeners();
      debugPrint('CalculatorHistoryProvider: Histórico da calculadora $calculatorId limpo - $removedCount itens removidos');
      return true;
    }
    
    return false;
  }

  // === HISTORY SEARCH AND FILTER ===

  /// Busca no histórico por termo
  List<CalculationHistory> searchHistory(String searchTerm) {
    if (searchTerm.trim().isEmpty) return _calculationHistory;
    
    final term = searchTerm.toLowerCase();
    return _calculationHistory.where((item) =>
      item.calculatorName.toLowerCase().contains(term) ||
      (item.notes?.toLowerCase().contains(term) ?? false)
    ).toList();
  }

  /// Filtra histórico por calculadora
  List<CalculationHistory> filterByCalculator(String calculatorId) {
    return _calculationHistory
        .where((item) => item.calculatorId == calculatorId)
        .toList();
  }

  /// Filtra histórico por período
  List<CalculationHistory> filterByPeriod(DateTime start, DateTime end) {
    return _calculationHistory.where((item) =>
      item.createdAt.isAfter(start) && 
      item.createdAt.isBefore(end)
    ).toList();
  }

  // === HISTORY STATISTICS ===

  /// Obtém estatísticas do histórico
  HistoryStatistics getHistoryStatistics() {
    if (_calculationHistory.isEmpty) {
      return const HistoryStatistics(
        totalCalculations: 0,
        uniqueCalculators: 0,
        mostUsedCalculator: null,
        mostUsedCalculatorCount: 0,
        oldestCalculation: null,
        newestCalculation: null,
      );
    }

    final calculatorCounts = <String, int>{};
    DateTime? oldest;
    DateTime? newest;

    for (final item in _calculationHistory) {
      // Conta uso por calculadora
      calculatorCounts[item.calculatorId] = 
          (calculatorCounts[item.calculatorId] ?? 0) + 1;
      
      // Encontra datas extremas
      if (oldest == null || item.createdAt.isBefore(oldest)) {
        oldest = item.createdAt;
      }
      if (newest == null || item.createdAt.isAfter(newest)) {
        newest = item.createdAt;
      }
    }

    // Encontra calculadora mais usada
    String? mostUsedCalculator;
    int mostUsedCount = 0;
    calculatorCounts.forEach((calculatorId, count) {
      if (count > mostUsedCount) {
        mostUsedCount = count;
        mostUsedCalculator = calculatorId;
      }
    });

    return HistoryStatistics(
      totalCalculations: _calculationHistory.length,
      uniqueCalculators: calculatorCounts.keys.length,
      mostUsedCalculator: mostUsedCalculator,
      mostUsedCalculatorCount: mostUsedCount,
      oldestCalculation: oldest,
      newestCalculation: newest,
    );
  }

  /// Obtém histórico agrupado por data
  Map<String, List<CalculationHistory>> getHistoryGroupedByDate() {
    final grouped = <String, List<CalculationHistory>>{};
    
    for (final item in _calculationHistory) {
      final dateKey = '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';
      grouped[dateKey] ??= [];
      grouped[dateKey]!.add(item);
    }
    
    return grouped;
  }

  /// Refresh completo do histórico
  Future<void> refreshHistory() async {
    await loadCalculationHistory();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset completo do estado
  void resetState() {
    _calculationHistory.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('CalculatorHistoryProvider: Disposed');
    super.dispose();
  }
}

// === HISTORY STATISTICS CLASS ===

class HistoryStatistics {
  final int totalCalculations;
  final int uniqueCalculators;
  final String? mostUsedCalculator;
  final int mostUsedCalculatorCount;
  final DateTime? oldestCalculation;
  final DateTime? newestCalculation;

  const HistoryStatistics({
    required totalCalculations,
    required uniqueCalculators,
    required mostUsedCalculator,
    required mostUsedCalculatorCount,
    required oldestCalculation,
    required newestCalculation,
  });
}