import 'package:flutter/foundation.dart';
import 'atualizacao_model.dart';

/// Immutable state for the updates page
@immutable
class AtualizacaoState {
  /// List of available updates
  final List<AtualizacaoModel> atualizacoesList;
  
  /// Whether data is currently loading
  final bool isLoading;
  
  /// Current theme mode (dark/light)
  final bool isDark;
  
  /// Error message if any occurred
  final String? error;

  const AtualizacaoState({
    this.atualizacoesList = const [],
    this.isLoading = true,
    this.isDark = false,
    this.error,
  });

  /// Create a copy with modified fields
  AtualizacaoState copyWith({
    List<AtualizacaoModel>? atualizacoesList,
    bool? isLoading,
    bool? isDark,
    String? error,
  }) {
    return AtualizacaoState(
      atualizacoesList: atualizacoesList ?? this.atualizacoesList,
      isLoading: isLoading ?? this.isLoading,
      isDark: isDark ?? this.isDark,
      error: error,
    );
  }

  /// Clear error state
  AtualizacaoState clearError() {
    return copyWith(error: null);
  }

  /// Set error state
  AtualizacaoState withError(String errorMessage) {
    return copyWith(
      error: errorMessage,
      isLoading: false,
    );
  }

  /// Set loading state
  AtualizacaoState withLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Computed properties
  bool get hasData => atualizacoesList.isNotEmpty;
  bool get hasError => error != null;
  int get totalAtualizacoes => atualizacoesList.length;
  
  /// Get the latest version (first in list)
  AtualizacaoModel? get latestVersion {
    return hasData ? atualizacoesList.first : null;
  }

  /// Check if a specific version is the latest
  bool isLatestVersion(AtualizacaoModel atualizacao) {
    final latest = latestVersion;
    return latest != null && latest.versao == atualizacao.versao;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AtualizacaoState &&
        listEquals(other.atualizacoesList, atualizacoesList) &&
        other.isLoading == isLoading &&
        other.isDark == isDark &&
        other.error == error;
  }

  @override
  int get hashCode {
    return atualizacoesList.hashCode ^
        isLoading.hashCode ^
        isDark.hashCode ^
        error.hashCode;
  }

  @override
  String toString() {
    return 'AtualizacaoState('
        'hasData: $hasData, '
        'isLoading: $isLoading, '
        'isDark: $isDark, '
        'hasError: $hasError, '
        'totalItems: $totalAtualizacoes'
        ')';
  }
}