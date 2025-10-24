import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/get_export_history_usecase.dart';
import '../../domain/usecases/request_export_usecase.dart';

part 'data_export_provider.freezed.dart';
part 'data_export_provider.g.dart';

/// State for Data Export feature
@freezed
class DataExportState with _$DataExportState {
  const factory DataExportState({
    @Default([]) List<ExportRequest> exportHistory,
    @Default(ExportProgress.initial()) ExportProgress currentProgress,
    ExportAvailabilityResult? availabilityResult,
    @Default(false) bool isLoading,
    String? error,
  }) = _DataExportState;

  const DataExportState._();

  bool get hasError => error != null;
  bool get canRequestExport => this.isLoading == false;
}

/// Provider for managing LGPD data export functionality in Plantis
@riverpod
class DataExportNotifier extends _$DataExportNotifier {
  CheckExportAvailabilityUseCase get _checkAvailabilityUseCase =>
      ref.read(checkExportAvailabilityUseCaseProvider);
  RequestExportUseCase get _requestExportUseCase =>
      ref.read(requestExportUseCaseProvider);
  GetExportHistoryUseCase get _getHistoryUseCase =>
      ref.read(getExportHistoryUseCaseProvider);
  DataExportRepository get _repository =>
      ref.read(dataExportRepositoryProvider);

  @override
  DataExportState build() {
    ref.onDispose(() {
      // Cleanup resources if needed
    });

    // Initialize by loading export history
    initialize();

    return const DataExportState();
  }

  /// Get current authenticated user ID from auth provider
  String get _currentUserId {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.id.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login para exportar dados.');
    }
    return user.id;
  }

  /// Initialize provider by loading export history
  Future<void> initialize() async {
    try {
      await loadExportHistory();
    } catch (e) {
      _setError('Erro ao inicializar: ${e.toString()}');
    }
  }

  /// Check availability of data export for the current user
  Future<void> checkExportAvailability({
    Set<DataType>? requestedDataTypes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _currentUserId;
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
        userId: userId,
        requestedDataTypes: dataTypes,
      );

      state = state.copyWith(
        availabilityResult: result,
        isLoading: false,
      );
    } catch (e) {
      _setError('Erro ao verificar disponibilidade: ${e.toString()}');
      state = state.copyWith(
        availabilityResult: const ExportAvailabilityResult.unavailable(
          reason: 'Erro interno do sistema',
        ),
        isLoading: false,
      );
    }
  }

  /// Request data export
  Future<ExportRequest?> requestExport({
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _currentUserId;

      final request = await _requestExportUseCase(
        userId: userId,
        dataTypes: dataTypes,
        format: format,
      );

      final updatedHistory = [request, ...state.exportHistory];
      state = state.copyWith(
        exportHistory: updatedHistory,
        isLoading: false,
      );

      await _monitorExportProgress(request);

      return request;
    } catch (e) {
      _setError('Erro ao solicitar exportação: ${e.toString()}');
      _setLoading(false);
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

        state = state.copyWith(
          currentProgress: state.currentProgress.copyWith(
            percentage: percentage * 100,
            currentTask: task,
            estimatedTimeRemaining: i < progressSteps.length - 1
                ? '${(progressSteps.length - i - 1) * 3} segundos restantes'
                : null,
          ),
        );

        await Future<void>.delayed(const Duration(seconds: 3));

        final updatedHistory = await _getHistoryUseCase(_currentUserId);
        final updatedRequest = updatedHistory.firstWhere(
          (r) => r.id == request.id,
          orElse: () => request,
        );

        if (updatedRequest.status == ExportRequestStatus.failed) {
          state = state.copyWith(
            currentProgress: ExportProgress.error(
              updatedRequest.errorMessage ?? 'Erro desconhecido',
            ),
          );
          _updateRequestInHistory(updatedRequest);
          return;
        }

        if (updatedRequest.status == ExportRequestStatus.completed) {
          state = state.copyWith(
            currentProgress: const ExportProgress.completed(),
          );
          _updateRequestInHistory(updatedRequest);
          return;
        }
      }

      state = state.copyWith(
        currentProgress: const ExportProgress.completed(),
      );
    } catch (e) {
      state = state.copyWith(
        currentProgress: ExportProgress.error(
          'Erro durante monitoramento: ${e.toString()}',
        ),
      );
    }
  }

  /// Update request in history
  void _updateRequestInHistory(ExportRequest updatedRequest) {
    final updatedHistory = state.exportHistory.map((req) {
      if (req.id == updatedRequest.id) {
        return updatedRequest;
      }
      return req;
    }).toList();

    state = state.copyWith(exportHistory: updatedHistory);
  }

  /// Load export history for user
  Future<void> loadExportHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _currentUserId;
      final history = await _getHistoryUseCase(userId);
      state = state.copyWith(
        exportHistory: history,
        isLoading: false,
      );
    } catch (e) {
      _setError('Erro ao carregar histórico: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Download export file
  Future<bool> downloadExport(String exportId) async {
    try {
      return await _repository.downloadExport(exportId);
    } catch (e) {
      _setError('Erro ao baixar arquivo: ${e.toString()}');
      return false;
    }
  }

  /// Delete export request and associated file
  Future<bool> deleteExport(String exportId) async {
    try {
      final success = await _repository.deleteExport(exportId);
      if (success) {
        final updatedHistory =
            state.exportHistory.where((req) => req.id != exportId).toList();
        state = state.copyWith(exportHistory: updatedHistory);
      }
      return success;
    } catch (e) {
      _setError('Erro ao deletar exportação: ${e.toString()}');
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
      final userId = _currentUserId;
      final stats = <DataType, int>{};

      final plants = await _repository.getUserPlantsData(userId);
      stats[DataType.plants] = plants.length;

      final tasks = await _repository.getUserTasksData(userId);
      stats[DataType.plantTasks] = tasks.length;

      final spaces = await _repository.getUserSpacesData(userId);
      stats[DataType.spaces] = spaces.length;

      final photos = await _repository.getUserPlantPhotosData(userId);
      stats[DataType.plantPhotos] = photos.length;

      final comments = await _repository.getUserPlantCommentsData(userId);
      stats[DataType.plantComments] = comments.length;

      final customCareCount = plants.where((p) => p.config != null).length;
      stats[DataType.customCare] = customCareCount;

      final reminderCount = tasks.where((t) => t.status != 'completed').length;
      stats[DataType.reminders] = reminderCount;

      stats[DataType.settings] = 1; // User always has settings
      stats[DataType.userProfile] = 1; // User always has profile

      return stats;
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: ${e.toString()}');
    }
  }

  /// Reset current progress
  void resetProgress() {
    state = state.copyWith(
      currentProgress: const ExportProgress.initial(),
    );
  }

  /// Clear availability result
  void clearAvailability() {
    state = state.copyWith(availabilityResult: null);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([loadExportHistory(), checkExportAvailability()]);
  }

  /// Check if user can request new export (rate limiting)
  bool canRequestExportNow() {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

    final recentRequest = state.exportHistory.where(
      (request) => request.requestDate.isAfter(oneHourAgo),
    );

    return recentRequest.isEmpty;
  }

  /// Get time until next export is allowed
  Duration? getTimeUntilNextExportAllowed() {
    if (canRequestExportNow()) return null;

    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final mostRecentRequest = state.exportHistory
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

  void _setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void _setError(String error) {
    state = state.copyWith(error: error);
  }

  void _clearError() {
    state = state.copyWith(error: null);
  }
}

// Dependency providers (to be defined in DI setup)
@riverpod
CheckExportAvailabilityUseCase checkExportAvailabilityUseCase(
  CheckExportAvailabilityUseCaseRef ref,
) {
  throw UnimplementedError('Define in DI setup');
}

@riverpod
RequestExportUseCase requestExportUseCase(RequestExportUseCaseRef ref) {
  throw UnimplementedError('Define in DI setup');
}

@riverpod
GetExportHistoryUseCase getExportHistoryUseCase(
  GetExportHistoryUseCaseRef ref,
) {
  throw UnimplementedError('Define in DI setup');
}

@riverpod
DataExportRepository dataExportRepository(DataExportRepositoryRef ref) {
  throw UnimplementedError('Define in DI setup');
}
