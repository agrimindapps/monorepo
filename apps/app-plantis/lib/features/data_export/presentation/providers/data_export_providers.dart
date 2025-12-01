import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/comments_providers.dart';
import '../../../../core/providers/core_di_providers.dart';
import '../../../../core/providers/repository_providers.dart';
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
PlantsExportDataSource plantsExportDataSource(Ref ref) {
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
SettingsExportDataSource settingsExportDataSource(Ref ref) {
  return SettingsExportLocalDataSource();
}

@riverpod
ExportFileGenerator exportFileGenerator(Ref ref) {
  final fileRepo = ref.watch(fileRepositoryProvider);
  return ExportFileGenerator(fileRepository: fileRepo);
}

@riverpod
DataExportRepository dataExportRepository(Ref ref) {
  final plantsDataSource = ref.watch(plantsExportDataSourceProvider);
  final settingsDataSource = ref.watch(settingsExportDataSourceProvider);
  final fileGenerator = ref.watch(exportFileGeneratorProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  return DataExportRepositoryImpl(
    plantsDataSource: plantsDataSource,
    settingsDataSource: settingsDataSource,
    fileGenerator: fileGenerator,
    prefs: prefs,
  );
}

@riverpod
CheckExportAvailabilityUseCase checkExportAvailabilityUseCase(Ref ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return CheckExportAvailabilityUseCase(repository);
}

@riverpod
RequestExportUseCase requestExportUseCase(Ref ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return RequestExportUseCase(repository);
}

@riverpod
GetExportHistoryUseCase getExportHistoryUseCase(Ref ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return GetExportHistoryUseCase(repository);
}

@riverpod
DownloadExportUseCase downloadExportUseCase(Ref ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return DownloadExportUseCase(repository);
}

@riverpod
DeleteExportUseCase deleteExportUseCase(Ref ref) {
  final repository = ref.watch(dataExportRepositoryProvider);
  return DeleteExportUseCase(repository);
}
