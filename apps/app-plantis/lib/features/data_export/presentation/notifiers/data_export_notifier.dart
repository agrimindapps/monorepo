import 'dart:async';

import 'package:core/core.dart' hide Column, getIt;

import '../../../../core/providers/auth_providers.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/delete_export_usecase.dart';
import '../../domain/usecases/download_export_usecase.dart';
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
  late final DownloadExportUseCase _downloadUseCase;
  late final DeleteExportUseCase _deleteUseCase;
  late final DataExportRepository _repository;

  /// Get current authenticated user ID from auth provider
  /// Returns null if user is not authenticated
  String? get _currentUserId {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.id.isEmpty) {
      return null;
    }
    return user.id;
  }

  @override
  Future<DataExportState> build() async {
    _checkAvailabilityUseCase = ref.read(
      checkExportAvailabilityUseCaseProvider,
    );
    _requestExportUseCase = ref.read(requestExportUseCaseProvider);
    _getHistoryUseCase = ref.read(getExportHistoryUseCaseProvider);
    _downloadUseCase = ref.read(downloadExportUseCaseProvider);
    _deleteUseCase = ref.read(deleteExportUseCaseProvider);
    _repository = ref.read(dataExportRepositoryProvider);

    final userId = _currentUserId;
    if (userId == null) {
      return const DataExportState(
        error: 'Usuário não autenticado. Faça login para exportar dados.',
      );
    }

    final historyResult = await _getHistoryUseCase(userId);

    return historyResult.fold(
      (failure) =>
          DataExportState(error: 'Erro ao inicializar: ${failure.message}'),
      (history) => DataExportState(exportHistory: history),
    );
  }

  /// Check availability of data export for the current user
  Future<void> checkExportAvailability({
    Set<DataType>? requestedDataTypes,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          error: 'Usuário não autenticado',
          isLoading: false,
        ),
      );
      return;
    }

    state = AsyncValue.data(
      (state.valueOrNull ?? const DataExportState()).copyWith(
        isLoading: true,
        error: null,
      ),
    );

    final dataTypes =
        requestedDataTypes ??
        {
          DataType.plants,
          DataType.plantTasks,
          DataType.spaces,
          DataType.plantPhotos,
          DataType.plantComments,
          DataType.settings,
        };

    final result = await _checkAvailabilityUseCase(
      userId: userId,
      requestedDataTypes: dataTypes,
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const DataExportState()).copyWith(
            error: 'Erro ao verificar disponibilidade: ${failure.message}',
            availabilityResult: const ExportAvailabilityResult.unavailable(
              reason: 'Erro interno do sistema',
            ),
            isLoading: false,
          ),
        );
      },
      (availabilityResult) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const DataExportState()).copyWith(
            availabilityResult: availabilityResult,
            isLoading: false,
          ),
        );
      },
    );
  }

  /// Request data export
  Future<ExportRequest?> requestExport({
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          error: 'Usuário não autenticado',
          isLoading: false,
        ),
      );
      return null;
    }

    state = AsyncValue.data(
      (state.valueOrNull ?? const DataExportState()).copyWith(
        isLoading: true,
        error: null,
      ),
    );

    final result = await _requestExportUseCase(
      userId: userId,
      dataTypes: dataTypes,
      format: format,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const DataExportState()).copyWith(
            error: 'Erro ao solicitar exportação: ${failure.message}',
            isLoading: false,
          ),
        );
        return null;
      },
      (request) async {
        final currentState = state.valueOrNull ?? const DataExportState();
        final updatedHistory = [request, ...currentState.exportHistory];

        state = AsyncValue.data(
          currentState.copyWith(
            exportHistory: updatedHistory,
            isLoading: false,
          ),
        );

        await _monitorExportProgress(request);
        return request;
      },
    );
  }

  /// Monitor export progress
  Future<void> _monitorExportProgress(ExportRequest request) async {
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

      await Future<void>.delayed(const Duration(seconds: 3));

      final userId = _currentUserId;
      if (userId == null) {
        state = AsyncValue.data(
          currentState.copyWith(
            currentProgress: const ExportProgress.error('Usuário não autenticado'),
          ),
        );
        return;
      }

      final historyResult = await _getHistoryUseCase(userId);

      await historyResult.fold(
        (failure) async {
          state = AsyncValue.data(
            currentState.copyWith(
              currentProgress: ExportProgress.error(
                'Erro ao monitorar progresso: ${failure.message}',
              ),
            ),
          );
        },
        (updatedHistory) async {
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
        },
      );
    }

    final currentState = state.valueOrNull ?? const DataExportState();
    state = AsyncValue.data(
      currentState.copyWith(currentProgress: const ExportProgress.completed()),
    );
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
    final userId = _currentUserId;
    if (userId == null) {
      state = AsyncValue.data(
        (state.valueOrNull ?? const DataExportState()).copyWith(
          error: 'Usuário não autenticado',
          isLoading: false,
        ),
      );
      return;
    }

    state = AsyncValue.data(
      (state.valueOrNull ?? const DataExportState()).copyWith(
        isLoading: true,
        error: null,
      ),
    );

    final historyResult = await _getHistoryUseCase(userId);

    historyResult.fold(
      (failure) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const DataExportState()).copyWith(
            error: 'Erro ao carregar histórico: ${failure.message}',
            isLoading: false,
          ),
        );
      },
      (history) {
        state = AsyncValue.data(
          (state.valueOrNull ?? const DataExportState()).copyWith(
            exportHistory: history,
            isLoading: false,
          ),
        );
      },
    );
  }

  /// Download export file
  Future<bool> downloadExport(String exportId) async {
    final result = await _downloadUseCase(exportId);

    return result.fold((failure) {
      final currentState = state.valueOrNull ?? const DataExportState();
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Erro ao baixar arquivo: ${failure.message}',
        ),
      );
      return false;
    }, (success) => success);
  }

  /// Delete export request and associated file
  Future<bool> deleteExport(String exportId) async {
    final result = await _deleteUseCase(exportId);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const DataExportState();
        state = AsyncValue.data(
          currentState.copyWith(
            error: 'Erro ao deletar exportação: ${failure.message}',
          ),
        );
        return false;
      },
      (success) {
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
      },
    );
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
    final userId = _currentUserId;
    final stats = <DataType, int>{};

    if (userId == null) {
      // Return empty statistics if not authenticated
      return stats;
    }

    final plantsResult = await _repository.getUserPlantsData(userId);
    final plants = plantsResult.fold(
      (failure) => <PlantExportData>[],
      (data) => data,
    );
    stats[DataType.plants] = plants.length;

    final tasksResult = await _repository.getUserTasksData(userId);
    final tasks = tasksResult.fold(
      (failure) => <TaskExportData>[],
      (data) => data,
    );
    stats[DataType.plantTasks] = tasks.length;

    final spacesResult = await _repository.getUserSpacesData(userId);
    final spaces = spacesResult.fold(
      (failure) => <SpaceExportData>[],
      (data) => data,
    );
    stats[DataType.spaces] = spaces.length;

    final photosResult = await _repository.getUserPlantPhotosData(userId);
    final photos = photosResult.fold(
      (failure) => <PlantPhotoExportData>[],
      (data) => data,
    );
    stats[DataType.plantPhotos] = photos.length;

    final commentsResult = await _repository.getUserPlantCommentsData(userId);
    final comments = commentsResult.fold(
      (failure) => <PlantCommentExportData>[],
      (data) => data,
    );
    stats[DataType.plantComments] = comments.length;

    final customCareCount = plants.where((p) => p.config != null).length;
    stats[DataType.customCare] = customCareCount;

    final reminderCount = tasks.where((t) => t.status != 'completed').length;
    stats[DataType.reminders] = reminderCount;

    stats[DataType.settings] = 1;
    stats[DataType.userProfile] = 1;

    return stats;
  }

  /// Reset current progress
  void resetProgress() {
    final currentState = state.valueOrNull ?? const DataExportState();
    state = AsyncValue.data(
      currentState.copyWith(currentProgress: const ExportProgress.initial()),
    );
  }

  /// Clear availability result
  void clearAvailability() {
    final currentState = state.valueOrNull ?? const DataExportState();
    state = AsyncValue.data(currentState.copyWith(availabilityResult: null));
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
DownloadExportUseCase downloadExportUseCase(Ref ref) {
  return GetIt.instance<DownloadExportUseCase>();
}

@riverpod
DeleteExportUseCase deleteExportUseCase(Ref ref) {
  return GetIt.instance<DeleteExportUseCase>();
}

@riverpod
DataExportRepository dataExportRepository(Ref ref) {
  return GetIt.instance<DataExportRepository>();
}
