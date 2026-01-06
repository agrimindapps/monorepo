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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Create empty state
  static CalculatorState<T> empty<T>() => CalculatorState<T>();
  
  /// Create loading state
  CalculatorState<T> toLoading() => CalculatorState<T>(
    calculation: calculation,
    isLoading: true,
    errorMessage: null,
  );
  
  /// Create success state with calculation
  CalculatorState<T> toSuccess(T calc) => CalculatorState<T>(
    calculation: calc,
    isLoading: false,
  );
  
  /// Create error state
  CalculatorState<T> toError(String msg) => CalculatorState<T>(
    errorMessage: msg,
    isLoading: false,
  );
}
