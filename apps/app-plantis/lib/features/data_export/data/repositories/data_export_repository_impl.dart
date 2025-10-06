import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../datasources/local/export_file_generator.dart';
import '../datasources/local/plants_export_datasource.dart';
import '../datasources/local/settings_export_datasource.dart';

class DataExportRepositoryImpl implements DataExportRepository {
  final PlantsExportDataSource _plantsDataSource;
  final SettingsExportDataSource _settingsDataSource;
  final ExportFileGenerator _fileGenerator;
  static const Duration _exportCooldown = Duration(hours: 1);
  static DateTime? _lastExportTime;
  static final Map<String, ExportRequest> _exportRequests = {};

  DataExportRepositoryImpl({
    required PlantsExportDataSource plantsDataSource,
    required SettingsExportDataSource settingsDataSource,
    required ExportFileGenerator fileGenerator,
  }) : _plantsDataSource = plantsDataSource,
       _settingsDataSource = settingsDataSource,
       _fileGenerator = fileGenerator;

  @override
  Future<ExportAvailabilityResult> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  }) async {
    try {
      if (_lastExportTime != null) {
        final timeSinceLastExport = DateTime.now().difference(_lastExportTime!);
        if (timeSinceLastExport < _exportCooldown) {
          final remainingTime = _exportCooldown - timeSinceLastExport;
          return ExportAvailabilityResult.unavailable(
            reason:
                'Para proteger seus dados, aguarde ${remainingTime.inMinutes} minutos para solicitar outro export.',
            earliestAvailableDate: _lastExportTime!.add(_exportCooldown),
          );
        }
      }

      final availableTypes = <DataType, bool>{};
      int totalSize = 0;

      for (final dataType in requestedDataTypes) {
        switch (dataType) {
          case DataType.plants:
            final plants = await _plantsDataSource.getUserPlantsData(userId);
            availableTypes[dataType] = plants.isNotEmpty;
            totalSize += plants.length * 1024; // Rough estimate
            break;

          case DataType.plantTasks:
            final tasks = await _plantsDataSource.getUserTasksData(userId);
            availableTypes[dataType] = tasks.isNotEmpty;
            totalSize += tasks.length * 512; // Rough estimate
            break;

          case DataType.spaces:
            final spaces = await _plantsDataSource.getUserSpacesData(userId);
            availableTypes[dataType] = spaces.isNotEmpty;
            totalSize += spaces.length * 256; // Rough estimate
            break;

          case DataType.plantPhotos:
            final photos = await _plantsDataSource.getUserPlantPhotosData(
              userId,
            );
            availableTypes[dataType] = photos.isNotEmpty;
            totalSize += photos.length * 2048; // Rough estimate for metadata
            break;

          case DataType.plantComments:
            final comments = await _plantsDataSource.getUserPlantCommentsData(
              userId,
            );
            availableTypes[dataType] = comments.isNotEmpty;
            totalSize +=
                comments.length * 512; // Rough estimate for comment text
            break;

          case DataType.settings:
            final settings = await _settingsDataSource.getUserSettingsData(
              userId,
            );
            availableTypes[dataType] = settings.appPreferences.isNotEmpty;
            totalSize += 1024; // Settings are usually small
            break;

          case DataType.userProfile:
            availableTypes[dataType] = userId.isNotEmpty;
            totalSize += 512;
            break;

          case DataType.customCare:
            availableTypes[dataType] = true;
            totalSize += 256;
            break;

          case DataType.reminders:
            availableTypes[dataType] = true;
            totalSize += 512;
            break;

          case DataType.all:
            availableTypes[dataType] = true;
            break;
        }
      }

      return ExportAvailabilityResult.available(
        availableDataTypes: availableTypes,
        estimatedSizeInBytes: totalSize,
      );
    } catch (e) {
      return ExportAvailabilityResult.unavailable(
        reason: 'Erro ao verificar disponibilidade: ${e.toString()}',
      );
    }
  }

  @override
  Future<ExportRequest> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    try {
      _lastExportTime = DateTime.now();

      final request = ExportRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        dataTypes: dataTypes,
        format: format,
        requestDate: DateTime.now(),
        status: ExportRequestStatus.pending,
        metadata: const {
          'app_version': '1.0.0',
          'platform': 'Flutter',
          'compliance': 'LGPD',
        },
      );
      await _saveExportRequest(request);
      _processExportRequest(request);

      return request;
    } catch (e) {
      throw Exception('Erro ao solicitar exportação: ${e.toString()}');
    }
  }

  @override
  Future<List<ExportRequest>> getExportHistory(String userId) async {
    try {
      final requests =
          _exportRequests.values
              .where((request) => request.userId == userId)
              .toList();
      requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
      return requests;
    } catch (e) {
      throw Exception('Erro ao carregar histórico: ${e.toString()}');
    }
  }

  @override
  Future<bool> downloadExport(String exportId) async {
    try {
      final request = _exportRequests[exportId];

      if (request == null) {
        throw Exception('Export não encontrado');
      }

      if (request.status != ExportRequestStatus.completed) {
        throw Exception('Export ainda não foi processado');
      }

      if (request.downloadUrl == null) {
        throw Exception('URL de download não disponível');
      }
      await Future<void>.delayed(const Duration(seconds: 2));

      return true;
    } catch (e) {
      throw Exception('Erro ao baixar arquivo: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteExport(String exportId) async {
    try {
      _exportRequests.remove(exportId);
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar exportação: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantExportData>> getUserPlantsData(String userId) =>
      _plantsDataSource.getUserPlantsData(userId);

  @override
  Future<List<TaskExportData>> getUserTasksData(String userId) =>
      _plantsDataSource.getUserTasksData(userId);

  @override
  Future<List<SpaceExportData>> getUserSpacesData(String userId) =>
      _plantsDataSource.getUserSpacesData(userId);

  @override
  Future<UserSettingsExportData> getUserSettingsData(String userId) =>
      _settingsDataSource.getUserSettingsData(userId);

  @override
  Future<List<PlantPhotoExportData>> getUserPlantPhotosData(String userId) =>
      _plantsDataSource.getUserPlantPhotosData(userId);

  @override
  Future<List<PlantCommentExportData>> getUserPlantCommentsData(
    String userId,
  ) => _plantsDataSource.getUserPlantCommentsData(userId);

  @override
  Future<String> generateExportFile({
    required ExportRequest request,
    required Map<DataType, dynamic> exportData,
  }) => _fileGenerator.generateExportFile(
    request: request,
    exportData: exportData,
  );

  /// Process export request in background
  Future<void> _processExportRequest(ExportRequest request) async {
    try {
      await _updateExportRequest(
        request.copyWith(status: ExportRequestStatus.processing),
      );
      final exportData = <DataType, dynamic>{};

      for (final dataType in request.dataTypes) {
        switch (dataType) {
          case DataType.plants:
            exportData[dataType] = await getUserPlantsData(request.userId);
            break;
          case DataType.plantTasks:
            exportData[dataType] = await getUserTasksData(request.userId);
            break;
          case DataType.spaces:
            exportData[dataType] = await getUserSpacesData(request.userId);
            break;
          case DataType.plantPhotos:
            exportData[dataType] = await getUserPlantPhotosData(request.userId);
            break;
          case DataType.plantComments:
            exportData[dataType] = await getUserPlantCommentsData(
              request.userId,
            );
            break;
          case DataType.settings:
            exportData[dataType] = await getUserSettingsData(request.userId);
            break;
          case DataType.userProfile:
            exportData[dataType] = {
              'userId': request.userId,
              'exportDate': DateTime.now(),
            };
            break;
          case DataType.all:
            exportData[DataType.plants] = await getUserPlantsData(
              request.userId,
            );
            exportData[DataType.plantTasks] = await getUserTasksData(
              request.userId,
            );
            exportData[DataType.spaces] = await getUserSpacesData(
              request.userId,
            );
            exportData[DataType.plantPhotos] = await getUserPlantPhotosData(
              request.userId,
            );
            exportData[DataType.plantComments] = await getUserPlantCommentsData(
              request.userId,
            );
            exportData[DataType.settings] = await getUserSettingsData(
              request.userId,
            );
            break;
          default:
            exportData[dataType] = 'Data not available';
        }
      }
      final filePath = await generateExportFile(
        request: request,
        exportData: exportData,
      );
      await _updateExportRequest(
        request.copyWith(
          status: ExportRequestStatus.completed,
          completionDate: DateTime.now(),
          downloadUrl: filePath,
        ),
      );
    } catch (e) {
      await _updateExportRequest(
        request.copyWith(
          status: ExportRequestStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _saveExportRequest(ExportRequest request) async {
    _exportRequests[request.id] = request;
  }

  Future<void> _updateExportRequest(ExportRequest request) async {
    await _saveExportRequest(request);
  }
}
