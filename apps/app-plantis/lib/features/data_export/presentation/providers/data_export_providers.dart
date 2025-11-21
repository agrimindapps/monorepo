import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/services_providers.dart';
import '../../../../features/plants/presentation/providers/plants_providers.dart';
import '../../../../features/plants/presentation/providers/spaces_provider.dart';
import '../../../../features/tasks/presentation/providers/tasks_providers.dart';
import '../../data/datasources/local/export_file_generator.dart';
import '../../data/datasources/local/plants_export_datasource.dart';
import '../../data/datasources/local/settings_export_datasource.dart';
import '../../data/repositories/data_export_repository_impl.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/delete_export_usecase.dart';
import '../../domain/usecases/download_export_usecase.dart';
import '../../domain/usecases/get_export_history_usecase.dart';
import '../../domain/usecases/request_export_usecase.dart';

part 'data_export_providers.g.dart';

@riverpod
IFileRepository fileRepository(FileRepositoryRef ref) {
  return FileManagerService();
}

@riverpod
PlantsExportDataSource plantsExportDataSource(PlantsExportDataSourceRef ref) {
  final plantsRepo = ref.watch(plantsRepositoryProvider);
  final commentsRepo = ref.watch(plantCommentsRepositoryProvider);
  final tasksRepo = ref.watch(tasksRepositoryProvider);
  final spacesRepo = ref.watch(spacesRepositoryProvider);

  return PlantsExportLocalDataSource(
    plantsRepository: plantsRepo,
    commentsRepository: commentsRepo,
    tasksRepository: tasksRepo,
    spacesRepository: spacesRepo,
  );
}

@riverpod
SettingsExportDataSource settingsExportDataSource(SettingsExportDataSourceRef ref) {
  return SettingsExportLocalDataSource();
}

@riverpod
ExportFileGenerator exportFileGenerator(ExportFileGeneratorRef ref) {
  final fileRepo = ref.watch(fileRepositoryProvider);
  return ExportFileGenerator(fileRepository: fileRepo);
}

@riverpod
DataExportRepository dataExportRepository(DataExportRepositoryRef ref) {
  final plantsDataSource = ref.watch(plantsExportDataSourceProvider);
  final settingsDataSource = ref.watch(settingsExportDataSourceProvider);
  final fileGenerator = ref.watch(exportFileGeneratorProvider);
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;

  return DataExportRepositoryImpl(
    plantsDataSource: plantsDataSource,
    settingsDataSource: settingsDataSource,
    fileGenerator: fileGenerator,
    prefs: prefs,
  );
}

@riverpod
CheckExportAvailabilityUseCase checkExportAvailabilityUseCase(CheckExportAvailabilityUseCaseRef ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return CheckExportAvailabilityUseCase(repository);
}

@riverpod
RequestExportUseCase requestExportUseCase(RequestExportUseCaseRef ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return RequestExportUseCase(repository);
}

@riverpod
GetExportHistoryUseCase getExportHistoryUseCase(GetExportHistoryUseCaseRef ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return GetExportHistoryUseCase(repository);
}

@riverpod
DownloadExportUseCase downloadExportUseCase(DownloadExportUseCaseRef ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return DownloadExportUseCase(repository);
}

@riverpod
DeleteExportUseCase deleteExportUseCase(DeleteExportUseCaseRef ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return DeleteExportUseCase(repository);
}
