import 'dart:convert' as convert;

import 'package:core/core.dart';

import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../datasources/local/export_file_generator.dart';
import '../datasources/local/plants_export_datasource.dart';
import '../datasources/local/settings_export_datasource.dart';

class DataExportRepositoryImpl implements DataExportRepository {
  final PlantsExportDataSource _plantsDataSource;
  final SettingsExportDataSource _settingsDataSource;
  final ExportFileGenerator _fileGenerator;
  final IHiveManager _hiveManager;
  static const Duration _exportCooldown = Duration(hours: 1);
  static const String _boxName = 'data_export';

  DataExportRepositoryImpl({
    required PlantsExportDataSource plantsDataSource,
    required SettingsExportDataSource settingsDataSource,
    required ExportFileGenerator fileGenerator,
    required IHiveManager hiveManager,
  }) : _plantsDataSource = plantsDataSource,
       _settingsDataSource = settingsDataSource,
       _fileGenerator = fileGenerator,
       _hiveManager = hiveManager;

  // Helper methods for Hive persistence
  Future<DateTime?> _getLastExportTime() async {
    try {
      final boxResult = await _hiveManager.getBox<String>(_boxName);
      return boxResult.fold((failure) => null, (box) {
        final value = box.get('last_export_time');
        if (value is String) {
          return DateTime.tryParse(value);
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<void> _setLastExportTime(DateTime time) async {
    try {
      final boxResult = await _hiveManager.getBox<String>(_boxName);
      boxResult.fold(
        (failure) => null,
        (box) => box.put('last_export_time', time.toIso8601String()),
      );
    } catch (e) {
      // Log error but don't fail the operation
    }
  }

  Future<Map<String, ExportRequest>> _getExportRequests() async {
    try {
      final boxResult = await _hiveManager.getBox<String>(_boxName);
      return boxResult.fold((failure) => {}, (box) {
        final stored = box.get('export_requests');
        if (stored == null || stored.isEmpty) return {};

        final Map<String, ExportRequest> requests = {};
        try {
          // Parse from the stored string representation
          if (stored.startsWith('[')) {
            // It's a JSON array
            final parsed = convert.jsonDecode(stored);
            if (parsed is List) {
              for (final item in parsed) {
                if (item is Map<String, dynamic>) {
                  final request = _exportRequestFromJson(item);
                  if (request != null) {
                    requests[request.id] = request;
                  }
                }
              }
            }
          }
        } catch (e) {
          // Silently fail to parse
        }
        return requests;
      });
    } catch (e) {
      return {};
    }
  }

  ExportRequest? _exportRequestFromJson(Map<String, dynamic> json) {
    try {
      return ExportRequest(
        id: json['id'] as String,
        userId: json['userId'] as String,
        dataTypes: (json['dataTypes'] as List<dynamic>)
            .map((e) => DataType.values.firstWhere((dt) => dt.name == e))
            .toSet(),
        format: ExportFormat.values.firstWhere(
          (f) => f.name == json['format'] as String,
        ),
        requestDate: DateTime.parse(json['requestDate'] as String),
        completionDate: json['completionDate'] != null
            ? DateTime.parse(json['completionDate'] as String)
            : null,
        status: ExportRequestStatus.values.firstWhere(
          (s) => s.name == json['status'] as String,
        ),
        downloadUrl: json['downloadUrl'] as String?,
        errorMessage: json['errorMessage'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _exportRequestToJson(ExportRequest request) {
    return {
      'id': request.id,
      'userId': request.userId,
      'dataTypes': request.dataTypes.map((e) => e.name).toList(),
      'format': request.format.name,
      'requestDate': request.requestDate.toIso8601String(),
      'completionDate': request.completionDate?.toIso8601String(),
      'status': request.status.name,
      'downloadUrl': request.downloadUrl,
      'errorMessage': request.errorMessage,
      'metadata': request.metadata,
    };
  }

  @override
  Future<Either<Failure, ExportAvailabilityResult>> checkExportAvailability({
    required String userId,
    required Set<DataType> requestedDataTypes,
  }) async {
    try {
      final lastExportTime = await _getLastExportTime();

      if (lastExportTime != null) {
        final timeSinceLastExport = DateTime.now().difference(lastExportTime);
        if (timeSinceLastExport < _exportCooldown) {
          final remainingTime = _exportCooldown - timeSinceLastExport;
          return Right(
            ExportAvailabilityResult.unavailable(
              reason:
                  'Para proteger seus dados, aguarde ${remainingTime.inMinutes} minutos para solicitar outro export.',
              earliestAvailableDate: lastExportTime.add(_exportCooldown),
            ),
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
            totalSize += plants.length * 1024;
            break;

          case DataType.plantTasks:
            final tasks = await _plantsDataSource.getUserTasksData(userId);
            availableTypes[dataType] = tasks.isNotEmpty;
            totalSize += tasks.length * 512;
            break;

          case DataType.spaces:
            final spaces = await _plantsDataSource.getUserSpacesData(userId);
            availableTypes[dataType] = spaces.isNotEmpty;
            totalSize += spaces.length * 256;
            break;

          case DataType.plantPhotos:
            final photos = await _plantsDataSource.getUserPlantPhotosData(
              userId,
            );
            availableTypes[dataType] = photos.isNotEmpty;
            totalSize += photos.length * 2048;
            break;

          case DataType.plantComments:
            final comments = await _plantsDataSource.getUserPlantCommentsData(
              userId,
            );
            availableTypes[dataType] = comments.isNotEmpty;
            totalSize += comments.length * 512;
            break;

          case DataType.settings:
            final settings = await _settingsDataSource.getUserSettingsData(
              userId,
            );
            availableTypes[dataType] = settings.appPreferences.isNotEmpty;
            totalSize += 1024;
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

      return Right(
        ExportAvailabilityResult.available(
          availableDataTypes: availableTypes,
          estimatedSizeInBytes: totalSize,
        ),
      );
    } on StorageException catch (e) {
      return Left(
        CacheFailure(
          'Erro ao acessar dados locais',
          code: 'CACHE_ERROR',
          details: e,
        ),
      );
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro ao verificar disponibilidade de exportação',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ExportRequest>> requestExport({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    try {
      await _setLastExportTime(DateTime.now());

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

      return Right(request);
    } on StorageException catch (e) {
      return Left(
        CacheFailure(
          'Erro ao salvar solicitação de exportação',
          code: 'CACHE_ERROR',
          details: e,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao solicitar exportação', details: e));
    }
  }

  @override
  Future<Either<Failure, List<ExportRequest>>> getExportHistory(
    String userId,
  ) async {
    try {
      final requests = await _getExportRequests();
      final userRequests = requests.values
          .where((request) => request.userId == userId)
          .toList();
      userRequests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
      return Right(userRequests);
    } on StorageException catch (e) {
      return Left(
        CacheFailure(
          'Erro ao acessar histórico de exportações',
          code: 'CACHE_ERROR',
          details: e,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao carregar histórico', details: e));
    }
  }

  @override
  Future<Either<Failure, bool>> downloadExport(String exportId) async {
    try {
      final requests = await _getExportRequests();
      final request = requests[exportId];

      if (request == null) {
        return const Left(
          NotFoundFailure(
            'Exportação não encontrada',
            code: 'EXPORT_NOT_FOUND',
          ),
        );
      }

      if (request.status != ExportRequestStatus.completed) {
        return const Left(
          ValidationFailure(
            'Exportação ainda não foi processada',
            code: 'EXPORT_NOT_READY',
          ),
        );
      }

      if (request.downloadUrl == null) {
        return const Left(
          ValidationFailure(
            'URL de download não disponível',
            code: 'DOWNLOAD_URL_MISSING',
          ),
        );
      }

      // Simulate download delay
      await Future<void>.delayed(const Duration(seconds: 2));

      return const Right(true);
    } on StorageException catch (e) {
      return Left(
        CacheFailure(
          'Erro ao acessar dados de exportação',
          code: 'CACHE_ERROR',
          details: e,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao baixar arquivo', details: e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteExport(String exportId) async {
    try {
      final requests = await _getExportRequests();
      if (!requests.containsKey(exportId)) {
        return const Left(
          NotFoundFailure(
            'Exportação não encontrada',
            code: 'EXPORT_NOT_FOUND',
          ),
        );
      }

      requests.remove(exportId);
      await _saveAllExportRequests(requests);

      return const Right(true);
    } on StorageException catch (e) {
      return Left(
        CacheFailure(
          'Erro ao deletar exportação',
          code: 'CACHE_ERROR',
          details: e,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao deletar exportação', details: e));
    }
  }

  @override
  Future<Either<Failure, List<PlantExportData>>> getUserPlantsData(
    String userId,
  ) async {
    try {
      final plants = await _plantsDataSource.getUserPlantsData(userId);
      return Right(plants);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar dados de plantas', details: e),
      );
    }
  }

  @override
  Future<Either<Failure, List<TaskExportData>>> getUserTasksData(
    String userId,
  ) async {
    try {
      final tasks = await _plantsDataSource.getUserTasksData(userId);
      return Right(tasks);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar dados de tarefas', details: e),
      );
    }
  }

  @override
  Future<Either<Failure, List<SpaceExportData>>> getUserSpacesData(
    String userId,
  ) async {
    try {
      final spaces = await _plantsDataSource.getUserSpacesData(userId);
      return Right(spaces);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar dados de espaços', details: e),
      );
    }
  }

  @override
  Future<Either<Failure, UserSettingsExportData>> getUserSettingsData(
    String userId,
  ) async {
    try {
      final settings = await _settingsDataSource.getUserSettingsData(userId);
      return Right(settings);
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar configurações', details: e));
    }
  }

  @override
  Future<Either<Failure, List<PlantPhotoExportData>>> getUserPlantPhotosData(
    String userId,
  ) async {
    try {
      final photos = await _plantsDataSource.getUserPlantPhotosData(userId);
      return Right(photos);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar fotos das plantas', details: e),
      );
    }
  }

  @override
  Future<Either<Failure, List<PlantCommentExportData>>>
  getUserPlantCommentsData(String userId) async {
    try {
      final comments = await _plantsDataSource.getUserPlantCommentsData(userId);
      return Right(comments);
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar comentários', details: e));
    }
  }

  @override
  Future<Either<Failure, String>> generateExportFile({
    required ExportRequest request,
    required Map<DataType, dynamic> exportData,
  }) async {
    try {
      final filePath = await _fileGenerator.generateExportFile(
        request: request,
        exportData: exportData,
      );
      return Right(filePath);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao gerar arquivo de exportação', details: e),
      );
    }
  }

  /// Process export request in background
  Future<void> _processExportRequest(ExportRequest request) async {
    try {
      await _updateExportRequest(
        request.copyWith(status: ExportRequestStatus.processing),
      );
      final exportData = <DataType, dynamic>{};

      // Helper to handle data fetch results
      Future<bool> _fetchData(
        Future<Either<Failure, dynamic>> Function() fetcher,
        DataType dataType,
      ) async {
        final result = await fetcher();
        return result.fold(
          (failure) {
            // Log failure but continue processing other data types
            exportData[dataType] = {'error': failure.message};
            return false;
          },
          (data) {
            exportData[dataType] = data;
            return true;
          },
        );
      }

      for (final dataType in request.dataTypes) {
        switch (dataType) {
          case DataType.plants:
            await _fetchData(() => getUserPlantsData(request.userId), dataType);
            break;
          case DataType.plantTasks:
            await _fetchData(() => getUserTasksData(request.userId), dataType);
            break;
          case DataType.spaces:
            await _fetchData(() => getUserSpacesData(request.userId), dataType);
            break;
          case DataType.plantPhotos:
            await _fetchData(
              () => getUserPlantPhotosData(request.userId),
              dataType,
            );
            break;
          case DataType.plantComments:
            await _fetchData(
              () => getUserPlantCommentsData(request.userId),
              dataType,
            );
            break;
          case DataType.settings:
            await _fetchData(
              () => getUserSettingsData(request.userId),
              dataType,
            );
            break;
          case DataType.userProfile:
            exportData[dataType] = {
              'userId': request.userId,
              'exportDate': DateTime.now(),
            };
            break;
          case DataType.all:
            // Fetch all data types
            await _fetchData(
              () => getUserPlantsData(request.userId),
              DataType.plants,
            );
            await _fetchData(
              () => getUserTasksData(request.userId),
              DataType.plantTasks,
            );
            await _fetchData(
              () => getUserSpacesData(request.userId),
              DataType.spaces,
            );
            await _fetchData(
              () => getUserPlantPhotosData(request.userId),
              DataType.plantPhotos,
            );
            await _fetchData(
              () => getUserPlantCommentsData(request.userId),
              DataType.plantComments,
            );
            await _fetchData(
              () => getUserSettingsData(request.userId),
              DataType.settings,
            );
            break;
          default:
            exportData[dataType] = 'Data not available';
        }
      }

      final filePathResult = await generateExportFile(
        request: request,
        exportData: exportData,
      );

      await filePathResult.fold(
        (failure) async {
          await _updateExportRequest(
            request.copyWith(
              status: ExportRequestStatus.failed,
              errorMessage: failure.message,
            ),
          );
        },
        (filePath) async {
          await _updateExportRequest(
            request.copyWith(
              status: ExportRequestStatus.completed,
              completionDate: DateTime.now(),
              downloadUrl: filePath,
            ),
          );
        },
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
    try {
      final requests = await _getExportRequests();
      requests[request.id] = request;
      await _saveAllExportRequests(requests);
    } catch (e) {
      // Log error but don't fail the operation
    }
  }

  Future<void> _saveAllExportRequests(
    Map<String, ExportRequest> requests,
  ) async {
    try {
      final requestsList = requests.values.map(_exportRequestToJson).toList();
      // Serialize to JSON string for storage
      final jsonString = requestsList.toString();
      final boxResult = await _hiveManager.getBox<String>(_boxName);
      boxResult.fold(
        (failure) => null,
        (box) => box.put('export_requests', jsonString),
      );
    } catch (e) {
      // Log error
    }
  }

  Future<void> _updateExportRequest(ExportRequest request) async {
    await _saveExportRequest(request);
  }
}
