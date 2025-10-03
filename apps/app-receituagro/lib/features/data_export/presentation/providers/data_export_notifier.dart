import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/export_request.dart';

part 'data_export_notifier.g.dart';

/// Data Export state
class DataExportState {
  final ExportProgress currentProgress;
  final ExportAvailabilityResult? availabilityResult;
  final List<ExportRequest> exportHistory;
  final bool isLoading;
  final String? error;

  const DataExportState({
    required this.currentProgress,
    this.availabilityResult,
    required this.exportHistory,
    required this.isLoading,
    this.error,
  });

  factory DataExportState.initial() {
    return const DataExportState(
      currentProgress: ExportProgress.initial(),
      availabilityResult: null,
      exportHistory: [],
      isLoading: false,
      error: null,
    );
  }

  DataExportState copyWith({
    ExportProgress? currentProgress,
    ExportAvailabilityResult? availabilityResult,
    List<ExportRequest>? exportHistory,
    bool? isLoading,
    String? error,
  }) {
    return DataExportState(
      currentProgress: currentProgress ?? this.currentProgress,
      availabilityResult: availabilityResult ?? this.availabilityResult,
      exportHistory: exportHistory ?? this.exportHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  DataExportState clearError() {
    return copyWith(error: null);
  }

  DataExportState clearAvailability() {
    return copyWith(availabilityResult: null);
  }
}

/// Provider for managing LGPD data export functionality (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class DataExportNotifier extends _$DataExportNotifier {
  @override
  Future<DataExportState> build() async {
    return DataExportState.initial();
  }

  /// Check availability of data export for the current user
  Future<void> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      // Simulate availability check
      await Future<void>.delayed(const Duration(seconds: 2));

      // Mock availability result - in real implementation, this would call repository
      final availableTypes = <DataType, bool>{};
      for (final dataType in requestedDataTypes) {
        // Simulate that some data types might not be available
        availableTypes[dataType] = dataType != DataType.diagnostics; // Example: diagnostics not available
      }

      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          availabilityResult: ExportAvailabilityResult.available(
            availableDataTypes: availableTypes,
            estimatedSizeInBytes: 1024 * 1024, // 1MB estimated
          ),
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao verificar disponibilidade: ${e.toString()}',
          availabilityResult: const ExportAvailabilityResult.unavailable(
            reason: 'Erro interno do sistema',
          ),
        ),
      );
    }
  }

  /// Request data export
  Future<ExportRequest?> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    final currentState = state.value;
    if (currentState == null) return null;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final request = ExportRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        dataTypes: dataTypes,
        format: format,
        requestDate: DateTime.now(),
        status: ExportRequestStatus.pending,
      );

      // Add to history
      final updatedHistory = [...currentState.exportHistory, request];
      state = AsyncValue.data(currentState.copyWith(exportHistory: updatedHistory));

      // Start processing
      await _processExportRequest(request);

      return request;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao solicitar exportação: ${e.toString()}',
        ),
      );
      return null;
    }
  }

  /// Process export request with progress updates
  Future<void> _processExportRequest(ExportRequest request) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Update request status to processing
      _updateExportRequest(request.copyWith(status: ExportRequestStatus.processing));

      // Simulate export process with progress updates
      const totalSteps = 5;
      final steps = [
        'Coletando dados do perfil...',
        'Processando favoritos...',
        'Compilando comentários...',
        'Gerando arquivo ${request.format.displayName}...',
        'Finalizando exportação...',
      ];

      for (int i = 0; i < totalSteps; i++) {
        final updatedProgress = currentState.currentProgress.copyWith(
          percentage: ((i + 1) / totalSteps) * 100,
          currentTask: steps[i],
          estimatedTimeRemaining: i < totalSteps - 1 ? '${(totalSteps - i - 1) * 3} segundos restantes' : null,
        );

        state = AsyncValue.data(currentState.copyWith(currentProgress: updatedProgress));

        // Simulate processing time
        await Future<void>.delayed(const Duration(seconds: 3));
      }

      // Mark as completed
      final completedProgress = const ExportProgress.completed();
      state = AsyncValue.data(currentState.copyWith(currentProgress: completedProgress));

      _updateExportRequest(
        request.copyWith(
          status: ExportRequestStatus.completed,
          completionDate: DateTime.now(),
          downloadUrl: 'https://example.com/download/${request.id}',
        ),
      );
    } catch (e) {
      final errorProgress = ExportProgress.error('Erro durante processamento: ${e.toString()}');
      state = AsyncValue.data(currentState.copyWith(currentProgress: errorProgress));

      _updateExportRequest(
        request.copyWith(
          status: ExportRequestStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Update an export request in the history
  void _updateExportRequest(ExportRequest updatedRequest) {
    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.exportHistory.indexWhere((req) => req.id == updatedRequest.id);
    if (index != -1) {
      final updatedHistory = List<ExportRequest>.from(currentState.exportHistory);
      updatedHistory[index] = updatedRequest;
      state = AsyncValue.data(currentState.copyWith(exportHistory: updatedHistory));
    }
  }

  /// Load export history for user
  Future<void> loadExportHistory(String userId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      // Simulate loading from repository
      await Future<void>.delayed(const Duration(seconds: 1));

      // Mock history data - in real implementation, this would call repository
      final history = [
        ExportRequest(
          id: '1',
          userId: userId,
          dataTypes: const {DataType.userProfile, DataType.favorites},
          format: ExportFormat.json,
          requestDate: DateTime.now().subtract(const Duration(days: 2)),
          completionDate: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
          status: ExportRequestStatus.completed,
          downloadUrl: 'https://example.com/download/1',
        ),
      ];

      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          exportHistory: history,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao carregar histórico: ${e.toString()}',
        ),
      );
    }
  }

  /// Download export file
  Future<bool> downloadExport(String exportId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      final request = currentState.exportHistory.firstWhere((req) => req.id == exportId);
      if (request.downloadUrl == null) {
        throw Exception('URL de download não disponível');
      }

      // In real implementation, this would handle file download
      await Future<void>.delayed(const Duration(seconds: 2));

      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Erro ao baixar arquivo: ${e.toString()}'),
      );
      return false;
    }
  }

  /// Delete export request and associated file
  Future<bool> deleteExport(String exportId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      final updatedHistory = currentState.exportHistory.where((req) => req.id != exportId).toList();
      state = AsyncValue.data(currentState.copyWith(exportHistory: updatedHistory));

      // In real implementation, this would delete the file from storage
      await Future<void>.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(error: 'Erro ao deletar exportação: ${e.toString()}'),
      );
      return false;
    }
  }

  /// Reset current progress
  void resetProgress() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(currentProgress: const ExportProgress.initial()),
    );
  }

  /// Clear availability result
  void clearAvailability() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearAvailability());
  }

  /// Clear error
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }
}
