// Flutter imports:
import 'package:flutter/material.dart';

/// Loading state enum for clear state management in home_defensivos
enum LoadingState {
  /// Initial state before any operations
  initial,
  
  /// Currently loading data or initializing
  loading,
  
  /// Successfully loaded and ready to use
  success,
  
  /// Error occurred during loading or initialization
  error,
}

/// Extension to provide additional functionality to LoadingState
extension LoadingStateExtension on LoadingState {
  /// Returns true if the state indicates loading is in progress
  bool get isLoading => this == LoadingState.loading;
  
  /// Returns true if the state indicates successful completion
  bool get isSuccess => this == LoadingState.success;
  
  /// Returns true if the state indicates an error occurred
  bool get hasError => this == LoadingState.error;
  
  /// Returns true if the state indicates initialization is complete
  bool get isInitialized => this == LoadingState.success;
  
  /// Returns true if operations can be performed safely
  bool get canPerformOperations => this == LoadingState.success;
  
  /// Returns true if the state is in a valid operational state
  bool get isValidState => this != LoadingState.initial;
  
  /// Returns a human-readable description of the current state
  String get description {
    switch (this) {
      case LoadingState.initial:
        return 'Aguardando inicialização';
      case LoadingState.loading:
        return 'Carregando dados...';
      case LoadingState.success:
        return 'Dados carregados com sucesso';
      case LoadingState.error:
        return 'Erro durante operação';
    }
  }
  
  /// Returns an appropriate icon for the current state
  IconData get icon {
    switch (this) {
      case LoadingState.initial:
        return Icons.hourglass_empty;
      case LoadingState.loading:
        return Icons.refresh;
      case LoadingState.success:
        return Icons.check_circle;
      case LoadingState.error:
        return Icons.error;
    }
  }
  
  /// Returns an appropriate color for the current state
  Color get color {
    switch (this) {
      case LoadingState.initial:
        return Colors.grey;
      case LoadingState.loading:
        return Colors.blue;
      case LoadingState.success:
        return Colors.green;
      case LoadingState.error:
        return Colors.red;
    }
  }
}
