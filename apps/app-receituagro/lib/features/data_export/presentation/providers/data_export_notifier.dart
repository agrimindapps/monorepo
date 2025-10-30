import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/export_request.dart';
import '../../services/export_progress_service.dart';
import '../../services/export_validation_service.dart';

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
  late final ExportProgressService _progressService;
  late final ExportValidationService _validationService;

  @override
  Future<DataExportState> build() async {
    _progressService = di.sl<ExportProgressService>();
    _validationService = di.sl<ExportValidationService>();
    return DataExportState.initial();
  }

  /// Check availability of data export for the current user
  Future<void> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(seconds: 2));

      // Use validation service to check availability
      final isAvailable = _validationService.areDataTypesAvailable(
        requestedDataTypes,
      );

      if (!isAvailable) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            availabilityResult: const ExportAvailabilityResult.unavailable(
              reason: 'Diagnósticos não estão disponíveis para exportação',
            ),
          ),
        );
        return;
      }

      final availableTypes = <DataType, bool>{};
      for (final dataType in requestedDataTypes) {
        availableTypes[dataType] = dataType != DataType.diagnostics;
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

    // Validate export request
    final validationError = _validationService.validateExportRequest(
      userId: userId,
      dataTypes: dataTypes,
      format: format,
    );

    if (validationError != null) {
      state = AsyncValue.data(currentState.copyWith(error: validationError));
      return null;
    }

    // Check if user can request more exports
    if (!_validationService.canRequestExport(
      history: currentState.exportHistory,
    )) {
      state = AsyncValue.data(
        currentState.copyWith(
          error:
              'Você atingiu o limite de exportações pendentes. Aguarde a conclusão das exportações em andamento.',
        ),
      );
      return null;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      final request = ExportRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        dataTypes: dataTypes,
        format: format,
        requestDate: DateTime.now(),
        status: ExportRequestStatus.pending,
      );
      final updatedHistory = [...currentState.exportHistory, request];
      state = AsyncValue.data(
        currentState.copyWith(exportHistory: updatedHistory),
      );
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
      _updateExportRequest(
        request.copyWith(status: ExportRequestStatus.processing),
      );

      const totalSteps = 5;
      const averageStepDuration = 3; // seconds

      for (int i = 0; i < totalSteps; i++) {
        // Use progress service to calculate and update progress
        final updatedProgress = _progressService.updateProgress(
          currentStep: i,
          totalSteps: totalSteps,
          format: request.format,
          averageStepDurationSeconds: averageStepDuration,
        );

        state = AsyncValue.data(
          currentState.copyWith(currentProgress: updatedProgress),
        );
        await Future<void>.delayed(
          const Duration(seconds: averageStepDuration),
        );
      }

      // Use progress service for completion
      final completedProgress = _progressService.createCompletedProgress();
      state = AsyncValue.data(
        currentState.copyWith(currentProgress: completedProgress),
      );

      _updateExportRequest(
        request.copyWith(
          status: ExportRequestStatus.completed,
          completionDate: DateTime.now(),
          downloadUrl: 'https://example.com/download/${request.id}',
        ),
      );
    } catch (e) {
      // Use progress service for error
      final errorProgress = _progressService.createErrorProgress(
        'Erro durante processamento: ${e.toString()}',
      );
      state = AsyncValue.data(
        currentState.copyWith(currentProgress: errorProgress),
      );

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

    final index = currentState.exportHistory.indexWhere(
      (req) => req.id == updatedRequest.id,
    );
    if (index != -1) {
      final updatedHistory = List<ExportRequest>.from(
        currentState.exportHistory,
      );
      updatedHistory[index] = updatedRequest;
      state = AsyncValue.data(
        currentState.copyWith(exportHistory: updatedHistory),
      );
    }
  }

  /// Load export history for user
  Future<void> loadExportHistory(String userId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final history = [
        ExportRequest(
          id: '1',
          userId: userId,
          dataTypes: const {DataType.userProfile, DataType.favorites},
          format: ExportFormat.json,
          requestDate: DateTime.now().subtract(const Duration(days: 2)),
          completionDate: DateTime.now().subtract(
            const Duration(days: 2, hours: 1),
          ),
          status: ExportRequestStatus.completed,
          downloadUrl: 'https://example.com/download/1',
        ),
      ];

      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, exportHistory: history),
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
      final request = currentState.exportHistory.firstWhere(
        (req) => req.id == exportId,
        orElse: () => throw Exception('Exportação não encontrada'),
      );

      // Validate if export is downloadable
      if (!_validationService.isDownloadable(request)) {
        String errorMessage;
        if (request.status != ExportRequestStatus.completed) {
          errorMessage = 'Exportação ainda não foi concluída';
        } else if (request.downloadUrl == null) {
          errorMessage = 'URL de download não disponível';
        } else if (_validationService.isExportExpired(request)) {
          errorMessage = 'Exportação expirada. Solicite uma nova exportação.';
        } else {
          errorMessage = 'Exportação não está disponível para download';
        }

        state = AsyncValue.data(currentState.copyWith(error: errorMessage));
        return false;
      }

      // Simulate download
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
      final updatedHistory = currentState.exportHistory
          .where((req) => req.id != exportId)
          .toList();
      state = AsyncValue.data(
        currentState.copyWith(exportHistory: updatedHistory),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Erro ao deletar exportação: ${e.toString()}',
        ),
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
