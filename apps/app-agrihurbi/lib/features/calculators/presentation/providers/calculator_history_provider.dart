import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/manage_calculation_history.dart';
import '../../domain/usecases/save_calculation_to_history.dart';
import 'calculators_di_providers.dart';

part 'calculator_history_provider.g.dart';

/// HistoryStatistics class
class HistoryStatistics {
  final int totalCalculations;
  final int uniqueCalculators;
  final String? mostUsedCalculator;
  final int mostUsedCalculatorCount;
  final DateTime? oldestCalculation;
  final DateTime? newestCalculation;

  const HistoryStatistics({
    required this.totalCalculations,
    required this.uniqueCalculators,
    required this.mostUsedCalculator,
    required this.mostUsedCalculatorCount,
    required this.oldestCalculation,
    required this.newestCalculation,
  });
}

/// State class for CalculatorHistory
class CalculatorHistoryState {
  final List<CalculationHistory> calculationHistory;
  final bool isLoadingHistory;
  final bool isSavingToHistory;
  final String? errorMessage;

  const CalculatorHistoryState({
    this.calculationHistory = const [],
    this.isLoadingHistory = false,
    this.isSavingToHistory = false,
    this.errorMessage,
  });

  CalculatorHistoryState copyWith({
    List<CalculationHistory>? calculationHistory,
    bool? isLoadingHistory,
    bool? isSavingToHistory,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalculatorHistoryState(
      calculationHistory: calculationHistory ?? this.calculationHistory,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isSavingToHistory: isSavingToHistory ?? this.isSavingToHistory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get totalHistoryItems => calculationHistory.length;
  bool get hasHistory => calculationHistory.isNotEmpty;

  List<CalculationHistory> getRecentHistory(int count) {
    return calculationHistory.take(count).toList();
  }

  List<CalculationHistory> getHistoryByCalculator(String calculatorId) {
    return calculationHistory
        .where((item) => item.calculatorId == calculatorId)
        .toList();
  }

  List<CalculationHistory> getHistoryByDateRange(DateTime start, DateTime end) {
    return calculationHistory
        .where(
          (item) =>
              item.createdAt.isAfter(start) && item.createdAt.isBefore(end),
        )
        .toList();
  }
}

/// Provider especializado para histórico de cálculos
///
/// Responsabilidade única: Gerenciar histórico de cálculos
/// Seguindo Single Responsibility Principle
@riverpod
class CalculatorHistoryNotifier extends _$CalculatorHistoryNotifier {
  GetCalculationHistory get _getCalculationHistory => ref.read(getCalculationHistoryUseCaseProvider);
  SaveCalculationToHistory get _saveCalculationToHistory => ref.read(saveCalculationToHistoryUseCaseProvider);

  @override
  CalculatorHistoryState build() {
    return const CalculatorHistoryState();
  }

  // Convenience getters for backward compatibility
  List<CalculationHistory> get calculationHistory => state.calculationHistory;
  bool get isLoadingHistory => state.isLoadingHistory;
  bool get isSavingToHistory => state.isSavingToHistory;
  String? get errorMessage => state.errorMessage;
  int get totalHistoryItems => state.totalHistoryItems;
  bool get hasHistory => state.hasHistory;

  List<CalculationHistory> getRecentHistory(int count) {
    return state.getRecentHistory(count);
  }

  List<CalculationHistory> getHistoryByCalculator(String calculatorId) {
    return state.getHistoryByCalculator(calculatorId);
  }

  List<CalculationHistory> getHistoryByDateRange(DateTime start, DateTime end) {
    return state.getHistoryByDateRange(start, end);
  }

  /// Carrega histórico de cálculos
  Future<void> loadCalculationHistory() async {
    state = state.copyWith(isLoadingHistory: true, clearError: true);

    final result = await _getCalculationHistory.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoadingHistory: false,
        );
        debugPrint(
          'CalculatorHistoryNotifier: Erro ao carregar histórico - ${failure.message}',
        );
      },
      (history) {
        state = state.copyWith(
          calculationHistory: history,
          isLoadingHistory: false,
        );
        debugPrint(
          'CalculatorHistoryNotifier: Histórico carregado - ${history.length} itens',
        );
      },
    );
  }

  /// Salva resultado no histórico
  Future<bool> saveToHistory({
    required String calculatorId,
    required String calculatorName,
    required CalculationResult result,
    String? userId,
    String? notes,
  }) async {
    state = state.copyWith(isSavingToHistory: true, clearError: true);

    final historyItem = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId ?? 'current_user',
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
        state = state.copyWith(
          errorMessage: failure.message,
          isSavingToHistory: false,
        );
        debugPrint(
          'CalculatorHistoryNotifier: Erro ao salvar no histórico - ${failure.message}',
        );
      },
      (_) {
        final updatedHistory = [historyItem, ...state.calculationHistory];
        state = state.copyWith(
          calculationHistory: updatedHistory,
          isSavingToHistory: false,
        );
        success = true;
        debugPrint(
          'CalculatorHistoryNotifier: Resultado salvo no histórico - ${historyItem.id}',
        );
      },
    );

    return success;
  }

  /// Remove item do histórico por ID
  Future<bool> removeFromHistory(String historyId) async {
    final updatedHistory = state.calculationHistory
        .where((item) => item.id != historyId)
        .toList();
    final removed = state.calculationHistory.length - updatedHistory.length;

    if (removed > 0) {
      state = state.copyWith(calculationHistory: updatedHistory);
      debugPrint(
        'CalculatorHistoryNotifier: Item removido do histórico - $historyId',
      );
      return true;
    }

    return false;
  }

  /// Remove múltiplos itens do histórico
  Future<bool> removeMultipleFromHistory(List<String> historyIds) async {
    final updatedHistory = state.calculationHistory
        .where((item) => !historyIds.contains(item.id))
        .toList();
    final removedCount = state.calculationHistory.length - updatedHistory.length;

    if (removedCount > 0) {
      state = state.copyWith(calculationHistory: updatedHistory);
      debugPrint(
        'CalculatorHistoryNotifier: $removedCount itens removidos do histórico',
      );
      return true;
    }

    return false;
  }

  Future<bool> clearAllHistory() async {
    state = state.copyWith(calculationHistory: []);
    debugPrint('CalculatorHistoryNotifier: Todo histórico limpo');
    return true;
  }

  /// Limpa histórico de uma calculadora específica
  Future<bool> clearCalculatorHistory(String calculatorId) async {
    final updatedHistory = state.calculationHistory
        .where((item) => item.calculatorId != calculatorId)
        .toList();
    final removedCount = state.calculationHistory.length - updatedHistory.length;

    if (removedCount > 0) {
      state = state.copyWith(calculationHistory: updatedHistory);
      debugPrint(
        'CalculatorHistoryNotifier: Histórico da calculadora $calculatorId limpo - $removedCount itens removidos',
      );
      return true;
    }

    return false;
  }

  /// Busca no histórico por termo
  List<CalculationHistory> searchHistory(String searchTerm) {
    if (searchTerm.trim().isEmpty) return state.calculationHistory;

    final term = searchTerm.toLowerCase();
    return state.calculationHistory
        .where(
          (item) =>
              item.calculatorName.toLowerCase().contains(term) ||
              (item.notes?.toLowerCase().contains(term) ?? false),
        )
        .toList();
  }

  /// Filtra histórico por calculadora
  List<CalculationHistory> filterByCalculator(String calculatorId) {
    return state.calculationHistory
        .where((item) => item.calculatorId == calculatorId)
        .toList();
  }

  /// Filtra histórico por período
  List<CalculationHistory> filterByPeriod(DateTime start, DateTime end) {
    return state.calculationHistory
        .where(
          (item) =>
              item.createdAt.isAfter(start) && item.createdAt.isBefore(end),
        )
        .toList();
  }

  /// Obtém estatísticas do histórico
  HistoryStatistics getHistoryStatistics() {
    if (state.calculationHistory.isEmpty) {
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

    for (final item in state.calculationHistory) {
      calculatorCounts[item.calculatorId] =
          (calculatorCounts[item.calculatorId] ?? 0) + 1;
      if (oldest == null || item.createdAt.isBefore(oldest)) {
        oldest = item.createdAt;
      }
      if (newest == null || item.createdAt.isAfter(newest)) {
        newest = item.createdAt;
      }
    }
    String? mostUsedCalculator;
    int mostUsedCount = 0;
    calculatorCounts.forEach((calculatorId, count) {
      if (count > mostUsedCount) {
        mostUsedCount = count;
        mostUsedCalculator = calculatorId;
      }
    });

    return HistoryStatistics(
      totalCalculations: state.calculationHistory.length,
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

    for (final item in state.calculationHistory) {
      final dateKey =
          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';
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
    state = state.copyWith(clearError: true);
  }

  /// Reset completo do estado
  void resetState() {
    state = const CalculatorHistoryState();
  }
}
