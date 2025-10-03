import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide getIt;

import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/get_export_history_usecase.dart';
import '../../domain/usecases/request_export_usecase.dart';

part 'data_export_notifier.g.dart';

/// State para gerenciamento de exportação de dados LGPD
class DataExportState {
  final ExportProgress currentProgress;
  final ExportAvailabilityResult? availabilityResult;
  final List<ExportRequest> exportHistory;
  final bool isLoading;
  final String? error;

  const DataExportState({
    this.currentProgress = const ExportProgress.initial(),
    this.availabilityResult,
    this.exportHistory = const [],
    this.isLoading = false,
    this.error,
  });

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
      error: error,
    );
  }
}

/// Notifier para gerenciamento de exportação de dados LGPD do Plantis
@riverpod
class DataExportNotifier extends _$DataExportNotifier {
  late final CheckExportAvailabilityUseCase _checkAvailabilityUseCase;
  late final RequestExportUseCase _requestExportUseCase;
  late final GetExportHistoryUseCase _getHistoryUseCase;
  late final DataExportRepository _repository;

  /// Mock user ID - em produção, pegar do auth service
  String get _currentUserId => 'mock_user_123';

  @override
  Future<DataExportState> build() async {
    _checkAvailabilityUseCase = ref.read(checkExportAvailabilityUseCaseProvider);
    _requestExportUseCase = ref.read(requestExportUseCaseProvider);
    _getHistoryUseCase = ref.read(getExportHistoryUseCaseProvider);
    _repository = ref.read(dataExportRepositoryProvider);

    // Load initial history
    try {
      final history = await _getHistoryUseCase(_currentUserId);
      return DataExportState(exportHistory: history);
    } catch (e) {
      return DataExportState(error: 'Erro ao inicializar: ${e.toString()}');
    }
  }

  /// Check availability of data export for the current user
  Future<void> checkExportAvailability({
    Set<DataType>? requestedDataTypes,
  }) async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const DataExportState()).copyWith(
        isLoading: true,
        error: null,
      ),
    );

    try {
      final dataTypes = requestedDataTypes ??
          {
            DataType.plants,
            DataType.plantTasks,
            DataType.spaces,
            DataType.plantPhotos,
            DataType.plantComments,
            DataType.settings,
          };

      final result = await _checkAvailabilityUseCase(
        userId: _currentUserId,
        requestedDataTypes: dataTypes,
      );

      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          availabilityResult: result,
          isLoading: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          error: 'Erro ao verificar disponibilidade: ${e.toString()}',
          availabilityResult: const ExportAvailabilityResult.unavailable(
            reason: 'Erro interno do sistema',
          ),
          isLoading: false,
        ),
      );
    }
  }

  /// Request data export
  Future<ExportRequest?> requestExport({
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const DataExportState()).copyWith(
        isLoading: true,
        error: null,
      ),
    );

    try {
      final request = await _requestExportUseCase(
        userId: _currentUserId,
        dataTypes: dataTypes,
        format: format,
      );

      // Add to history
      final currentState = state.valueOrNull ?? const DataExportState();
      final updatedHistory = [request, ...currentState.exportHistory];

      state = AsyncValue.data(
        currentState.copyWith(
          exportHistory: updatedHistory,
          isLoading: false,
        ),
      );

      // Start monitoring progress
      await _monitorExportProgress(request);

      return request;
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          error: 'Erro ao solicitar exportação: ${e.toString()}',
          isLoading: false,
        ),
      );
      return null;
    }
  }

  /// Monitor export progress
  Future<void> _monitorExportProgress(ExportRequest request) async {
    try {
      final progressSteps = [
        (0.1, 'Coletando dados das plantas...'),
        (0.25, 'Processando tarefas e lembretes...'),
        (0.4, 'Compilando fotos das plantas...'),
        (0.55, 'Coletando comentários das plantas...'),
        (0.7, 'Organizando configurações...'),
        (0.85, 'Gerando arquivo ${request.format.displayName}...'),
        (1.0, 'Finalizando exportação...'),
      ];

      for (int i = 0; i < progressSteps.length; i++) {
        final (percentage, task) = progressSteps[i];
        final currentState = state.valueOrNull ?? const DataExportState();

        state = AsyncValue.data(
          currentState.copyWith(
            currentProgress: currentState.currentProgress.copyWith(
              percentage: percentage * 100,
              currentTask: task,
              estimatedTimeRemaining: i < progressSteps.length - 1
                  ? '${(progressSteps.length - i - 1) * 3} segundos restantes'
                  : null,
            ),
          ),
        );

        // Simulate processing time
        await Future<void>.delayed(const Duration(seconds: 3));

        // Check if request was completed or failed
        final updatedHistory = await _getHistoryUseCase(_currentUserId);
        final updatedRequest = updatedHistory.firstWhere(
          (r) => r.id == request.id,
          orElse: () => request,
        );

        if (updatedRequest.status == ExportRequestStatus.failed) {
          state = AsyncValue.data(
            currentState.copyWith(
              currentProgress: ExportProgress.error(
                updatedRequest.errorMessage ?? 'Erro desconhecido',
              ),
            ),
          );
          _updateRequestInHistory(updatedRequest);
          return;
        }

        if (updatedRequest.status == ExportRequestStatus.completed) {
          state = AsyncValue.data(
            currentState.copyWith(
              currentProgress: const ExportProgress.completed(),
            ),
          );
          _updateRequestInHistory(updatedRequest);
          return;
        }
      }

      // Mark as completed if reached the end
      final currentState = state.valueOrNull ?? const DataExportState();
      state = AsyncValue.data(
        currentState.copyWith(
          currentProgress: const ExportProgress.completed(),
        ),
      );
    } catch (e) {
      final currentState = state.valueOrNull ?? const DataExportState();
      state = AsyncValue.data(
        currentState.copyWith(
          currentProgress: ExportProgress.error(
            'Erro durante monitoramento: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Update request in history
  void _updateRequestInHistory(ExportRequest updatedRequest) {
    final currentState = state.valueOrNull ?? const DataExportState();
    final index = currentState.exportHistory.indexWhere(
      (req) => req.id == updatedRequest.id,
    );

    if (index != -1) {
      final updatedHistory = [...currentState.exportHistory];
      updatedHistory[index] = updatedRequest;

      state = AsyncValue.data(
        currentState.copyWith(exportHistory: updatedHistory),
      );
    }
  }

  /// Load export history for user
  Future<void> loadExportHistory() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const DataExportState()).copyWith(
        isLoading: true,
        error: null,
      ),
    );

    try {
      final history = await _getHistoryUseCase(_currentUserId);

      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          exportHistory: history,
          isLoading: false,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          error: 'Erro ao carregar histórico: ${e.toString()}',
          isLoading: false,
        ),
      );
    }
  }

  /// Download export file
  Future<bool> downloadExport(String exportId) async {
    try {
      return await _repository.downloadExport(exportId);
    } catch (e) {
      final currentState = state.valueOrNull ?? const DataExportState();
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Erro ao baixar arquivo: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  /// Delete export request and associated file
  Future<bool> deleteExport(String exportId) async {
    try {
      final success = await _repository.deleteExport(exportId);
      if (success) {
        final currentState = state.valueOrNull ?? const DataExportState();
        final updatedHistory = currentState.exportHistory
            .where((req) => req.id != exportId)
            .toList();

        state = AsyncValue.data(
          currentState.copyWith(exportHistory: updatedHistory),
        );
      }
      return success;
    } catch (e) {
      final currentState = state.valueOrNull ?? const DataExportState();
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Erro ao deletar exportação: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  /// Get available data types for export
  Set<DataType> getAvailableDataTypes() {
    return {
      DataType.plants,
      DataType.plantTasks,
      DataType.spaces,
      DataType.plantPhotos,
      DataType.plantComments,
      DataType.settings,
      DataType.customCare,
      DataType.reminders,
      DataType.userProfile,
    };
  }

  /// Get data type statistics
  Future<Map<DataType, int>> getDataTypeStatistics() async {
    try {
      final stats = <DataType, int>{};

      final plants = await _repository.getUserPlantsData(_currentUserId);
      stats[DataType.plants] = plants.length;

      final tasks = await _repository.getUserTasksData(_currentUserId);
      stats[DataType.plantTasks] = tasks.length;

      final spaces = await _repository.getUserSpacesData(_currentUserId);
      stats[DataType.spaces] = spaces.length;

      final photos = await _repository.getUserPlantPhotosData(_currentUserId);
      stats[DataType.plantPhotos] = photos.length;

      final comments =
          await _repository.getUserPlantCommentsData(_currentUserId);
      stats[DataType.plantComments] = comments.length;

      final customCareCount = plants.where((p) => p.config != null).length;
      stats[DataType.customCare] = customCareCount;

      final reminderCount = tasks.where((t) => t.status != 'completed').length;
      stats[DataType.reminders] = reminderCount;

      stats[DataType.settings] = 1;
      stats[DataType.userProfile] = 1;

      return stats;
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: ${e.toString()}');
    }
  }

  /// Reset current progress
  void resetProgress() {
    final currentState = state.valueOrNull ?? const DataExportState();
    state = AsyncValue.data(
      currentState.copyWith(
        currentProgress: const ExportProgress.initial(),
      ),
    );
  }

  /// Clear availability result
  void clearAvailability() {
    final currentState = state.valueOrNull ?? const DataExportState();
    state = AsyncValue.data(
      currentState.copyWith(availabilityResult: null),
    );
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([loadExportHistory(), checkExportAvailability()]);
  }

  /// Check if user can request new export (rate limiting)
  bool canRequestExport() {
    final currentState = state.valueOrNull;
    if (currentState == null) return true;

    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final recentRequest = currentState.exportHistory.where(
      (request) => request.requestDate.isAfter(oneHourAgo),
    );

    return recentRequest.isEmpty;
  }

  /// Get time until next export is allowed
  Duration? getTimeUntilNextExportAllowed() {
    if (canRequestExport()) return null;

    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final mostRecentRequest = currentState.exportHistory
        .where((request) => request.requestDate.isAfter(oneHourAgo))
        .fold<ExportRequest?>(
          null,
          (most, current) =>
              most == null || current.requestDate.isAfter(most.requestDate)
                  ? current
                  : most,
        );

    if (mostRecentRequest == null) return null;

    final nextAllowedTime = mostRecentRequest.requestDate.add(
      const Duration(hours: 1),
    );
    return nextAllowedTime.difference(DateTime.now());
  }
}

// Dependency Providers
@riverpod
CheckExportAvailabilityUseCase checkExportAvailabilityUseCase(Ref ref) {
  return GetIt.instance<CheckExportAvailabilityUseCase>();
}

@riverpod
RequestExportUseCase requestExportUseCase(Ref ref) {
  return GetIt.instance<RequestExportUseCase>();
}

@riverpod
GetExportHistoryUseCase getExportHistoryUseCase(Ref ref) {
  return GetIt.instance<GetExportHistoryUseCase>();
}

@riverpod
DataExportRepository dataExportRepository(Ref ref) {
  return GetIt.instance<DataExportRepository>();
}
