import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';

part 'calculator_state.freezed.dart';

/// Immutable state for calculator management
@freezed
abstract class CalculatorState with _$CalculatorState {
  const CalculatorState._();
  const factory CalculatorState({
    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isCalculating,
    @Default(false) bool isLoadingHistory,
    @Default(false) bool isLoadingFavorites,
    // Data
    @Default([]) List<CalculatorEntity> calculators,
    @Default([]) List<CalculatorEntity> filteredCalculators,
    @Default(null) CalculatorEntity? selectedCalculator,
    // Filters and search
    @Default('') String searchQuery,
    @Default(null) CalculatorCategory? selectedCategory,
    // Results and history
    @Default(null) CalculationResult? currentResult,
    @Default([]) List<CalculationHistory> calculationHistory,
    @Default([]) List<String> favoriteCalculatorIds,
    // Current inputs
    @Default({}) Map<String, dynamic> currentInputs,
    // Error handling
    @Default(null) String? errorMessage,
  }) = _CalculatorState;
}
