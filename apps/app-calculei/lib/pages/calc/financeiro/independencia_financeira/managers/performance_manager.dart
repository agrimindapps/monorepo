// Dart imports:
import 'dart:async';

class PerformanceManager {
  static const Duration _validationDebounceDelay = Duration(milliseconds: 300);
  static const Duration _calculationDebounceDelay = Duration(milliseconds: 800);
  
  Timer? _validationTimer;
  Timer? _calculationTimer;
  
  // Cache para resultados de validação
  final Map<String, dynamic> _validationCache = {};
  final Map<String, dynamic> _calculationCache = {};
  
  // Controle de operações pendentes
  bool _hasValidationPending = false;
  bool _hasCalculationPending = false;
  
  void scheduleValidation(void Function() validationAction) {
    _validationTimer?.cancel();
    _hasValidationPending = true;
    
    _validationTimer = Timer(_validationDebounceDelay, () {
      if (_hasValidationPending) {
        validationAction();
        _hasValidationPending = false;
      }
    });
  }
  
  void scheduleCalculation(void Function() calculationAction) {
    _calculationTimer?.cancel();
    _hasCalculationPending = true;
    
    _calculationTimer = Timer(_calculationDebounceDelay, () {
      if (_hasCalculationPending) {
        calculationAction();
        _hasCalculationPending = false;
      }
    });
  }
  
  void cancelValidation() {
    _validationTimer?.cancel();
    _hasValidationPending = false;
  }
  
  void cancelCalculation() {
    _calculationTimer?.cancel();
    _hasCalculationPending = false;
  }
  
  void cancelAll() {
    cancelValidation();
    cancelCalculation();
  }
  
  // Cache para validações
  T? getCachedValidation<T>(String key) {
    return _validationCache[key] as T?;
  }
  
  void setCachedValidation<T>(String key, T value) {
    _validationCache[key] = value;
  }
  
  void clearValidationCache() {
    _validationCache.clear();
  }
  
  // Cache para cálculos
  T? getCachedCalculation<T>(String key) {
    return _calculationCache[key] as T?;
  }
  
  void setCachedCalculation<T>(String key, T value) {
    _calculationCache[key] = value;
  }
  
  void clearCalculationCache() {
    _calculationCache.clear();
  }
  
  void clearAllCaches() {
    clearValidationCache();
    clearCalculationCache();
  }
  
  // Getters para estado
  bool get hasValidationPending => _hasValidationPending;
  bool get hasCalculationPending => _hasCalculationPending;
  bool get isValidationRunning => _validationTimer?.isActive ?? false;
  bool get isCalculationRunning => _calculationTimer?.isActive ?? false;
  
  void dispose() {
    _validationTimer?.cancel();
    _calculationTimer?.cancel();
    clearAllCaches();
  }
}
