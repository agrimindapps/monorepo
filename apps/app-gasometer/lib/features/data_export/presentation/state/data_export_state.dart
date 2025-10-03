import '../../domain/entities/export_progress.dart';
import '../../domain/entities/export_result.dart';

/// Estado da exportação de dados LGPD
class DataExportState {
  const DataExportState({
    this.isExporting = false,
    this.canExport = true,
    this.currentProgress,
    this.lastResult,
    this.errorMessage,
    this.exportHistory = const [],
    this.exportEstimate,
  });

  /// Cria um estado inicial
  factory DataExportState.initial() {
    return const DataExportState();
  }

  final bool isExporting;
  final bool canExport;
  final ExportProgress? currentProgress;
  final ExportResult? lastResult;
  final String? errorMessage;
  final List<ExportResult> exportHistory;
  final Map<String, dynamic>? exportEstimate;

  // Getters auxiliares
  bool get hasError => errorMessage != null;
  bool get canStartExport => canExport && !isExporting;

  DataExportState copyWith({
    bool? isExporting,
    bool? canExport,
    ExportProgress? currentProgress,
    ExportResult? lastResult,
    String? errorMessage,
    List<ExportResult>? exportHistory,
    Map<String, dynamic>? exportEstimate,
  }) {
    return DataExportState(
      isExporting: isExporting ?? this.isExporting,
      canExport: canExport ?? this.canExport,
      currentProgress: currentProgress ?? this.currentProgress,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage ?? this.errorMessage,
      exportHistory: exportHistory ?? this.exportHistory,
      exportEstimate: exportEstimate ?? this.exportEstimate,
    );
  }

  /// Cria um estado com erro
  DataExportState withError(String error) {
    return copyWith(
      errorMessage: error,
      isExporting: false,
    );
  }

  /// Limpa o erro
  DataExportState clearError() {
    return copyWith(errorMessage: '');
  }

  /// Limpa o progresso
  DataExportState clearProgress() {
    return copyWith(currentProgress: null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataExportState &&
          isExporting == other.isExporting &&
          canExport == other.canExport &&
          currentProgress == other.currentProgress &&
          lastResult == other.lastResult &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        isExporting,
        canExport,
        currentProgress,
        lastResult,
        errorMessage,
      );

  @override
  String toString() {
    return 'DataExportState(isExporting: $isExporting, canExport: $canExport, hasError: $hasError)';
  }
}
