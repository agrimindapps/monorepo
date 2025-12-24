/// Generic state wrapper for calculator features
/// 
/// Provides consistent state management across all calculators
/// without persistence logic
class CalculatorState<T> {
  final T? calculation;
  final bool isLoading;
  final String? errorMessage;

  const CalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  CalculatorState<T> copyWith({
    T? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CalculatorState<T>(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Create empty state
  static CalculatorState<T> empty<T>() => const CalculatorState();
  
  /// Create loading state
  CalculatorState<T> toLoading() => copyWith(
    isLoading: true, 
    errorMessage: null,
  );
  
  /// Create success state with calculation
  CalculatorState<T> toSuccess(T calc) => CalculatorState(
    calculation: calc,
    isLoading: false,
  );
  
  /// Create error state
  CalculatorState<T> toError(String msg) => CalculatorState(
    errorMessage: msg,
    isLoading: false,
  );
}
