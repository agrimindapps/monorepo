import 'package:flutter/foundation.dart';

import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/get_export_history_usecase.dart';
import '../../domain/usecases/request_export_usecase.dart';

/// Provider for managing LGPD data export functionality in Plantis
class DataExportProvider extends ChangeNotifier {
  final CheckExportAvailabilityUseCase _checkAvailabilityUseCase;
  final RequestExportUseCase _requestExportUseCase;
  final GetExportHistoryUseCase _getHistoryUseCase;
  final DataExportRepository _repository;

  ExportProgress _currentProgress = const ExportProgress.initial();
  ExportAvailabilityResult? _availabilityResult;
  List<ExportRequest> _exportHistory = [];
  bool _isLoading = false;
  String? _error;

  DataExportProvider({
    required CheckExportAvailabilityUseCase checkAvailabilityUseCase,
    required RequestExportUseCase requestExportUseCase,
    required GetExportHistoryUseCase getHistoryUseCase,
    required DataExportRepository repository,
  }) : _checkAvailabilityUseCase = checkAvailabilityUseCase,
       _requestExportUseCase = requestExportUseCase,
       _getHistoryUseCase = getHistoryUseCase,
       _repository = repository;

  // Getters
  ExportProgress get currentProgress => _currentProgress;
  ExportAvailabilityResult? get availabilityResult => _availabilityResult;
  List<ExportRequest> get exportHistory => _exportHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get current user ID (mock for demonstration)
  String get _currentUserId {
    return 'mock_user_123'; // In real implementation, get from auth service
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

      _availabilityResult = await _checkAvailabilityUseCase(
        userId: userId,
        requestedDataTypes: dataTypes,
      );

      notifyListeners();
    } catch (e) {
      _setError('Erro ao verificar disponibilidade: ${e.toString()}');
      _availabilityResult = const ExportAvailabilityResult.unavailable(
        reason: 'Erro interno do sistema',
      );
    } finally {
      _setLoading(false);
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

      // Add to history
      _exportHistory.insert(0, request);

      // Start monitoring progress
      await _monitorExportProgress(request);

      return request;
    } catch (e) {
      _setError('Erro ao solicitar exportação: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Monitor export progress
  Future<void> _monitorExportProgress(ExportRequest request) async {
    try {
      // Simulate progress monitoring with realistic steps
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

        _currentProgress = _currentProgress.copyWith(
          percentage: percentage * 100,
          currentTask: task,
          estimatedTimeRemaining:
              i < progressSteps.length - 1
                  ? '${(progressSteps.length - i - 1) * 3} segundos restantes'
                  : null,
        );
        notifyListeners();

        // Simulate processing time
        await Future<void>.delayed(const Duration(seconds: 3));

        // Check if request was completed or failed
        final updatedHistory = await _getHistoryUseCase(_currentUserId);
        final updatedRequest = updatedHistory.firstWhere(
          (r) => r.id == request.id,
          orElse: () => request,
        );

        if (updatedRequest.status == ExportRequestStatus.failed) {
          _currentProgress = ExportProgress.error(
            updatedRequest.errorMessage ?? 'Erro desconhecido',
          );
          _updateRequestInHistory(updatedRequest);
          notifyListeners();
          return;
        }

        if (updatedRequest.status == ExportRequestStatus.completed) {
          _currentProgress = const ExportProgress.completed();
          _updateRequestInHistory(updatedRequest);
          notifyListeners();
          return;
        }
      }

      // Mark as completed if reached the end
      _currentProgress = const ExportProgress.completed();
      notifyListeners();
    } catch (e) {
      _currentProgress = ExportProgress.error(
        'Erro durante monitoramento: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  /// Update request in history
  void _updateRequestInHistory(ExportRequest updatedRequest) {
    final index = _exportHistory.indexWhere(
      (req) => req.id == updatedRequest.id,
    );
    if (index != -1) {
      _exportHistory[index] = updatedRequest;
      notifyListeners();
    }
  }

  /// Load export history for user
  Future<void> loadExportHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _currentUserId;
      _exportHistory = await _getHistoryUseCase(userId);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar histórico: ${e.toString()}');
    } finally {
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
        _exportHistory.removeWhere((req) => req.id == exportId);
        notifyListeners();
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

      // Count custom care configurations
      final customCareCount = plants.where((p) => p.config != null).length;
      stats[DataType.customCare] = customCareCount;

      // Count active reminders (incomplete tasks)
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
    _currentProgress = const ExportProgress.initial();
    notifyListeners();
  }

  /// Clear availability result
  void clearAvailability() {
    _availabilityResult = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([loadExportHistory(), checkExportAvailability()]);
  }

  /// Check if user can request new export (rate limiting)
  bool canRequestExport() {
    // Check if there's a recent request (within last hour)
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

    final recentRequest = _exportHistory.where(
      (request) => request.requestDate.isAfter(oneHourAgo),
    );

    return recentRequest.isEmpty;
  }

  /// Get time until next export is allowed
  Duration? getTimeUntilNextExportAllowed() {
    if (canRequestExport()) return null;

    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final mostRecentRequest = _exportHistory
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

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
