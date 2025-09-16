import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Domain
import '../domain/repositories/data_export_repository.dart';
import '../domain/usecases/check_export_availability_usecase.dart';
import '../domain/usecases/export_user_data_usecase.dart';

// Data
import '../data/datasources/local_data_export_datasource.dart';
import '../data/services/export_formatter_service.dart';
import '../data/services/file_service.dart';
import '../data/repositories/data_export_repository_impl.dart';

// Presentation
import '../presentation/providers/data_export_provider.dart';

class DataExportDependencies {
  static List<SingleChildWidget> get providers {
    return [
      // Data Sources
      Provider<LocalDataExportDataSource>(
        create: (_) => LocalDataExportDataSourceImpl(),
      ),

      // Services
      Provider<ExportFormatterService>(
        create: (_) => ExportFormatterServiceImpl(),
      ),

      Provider<FileService>(
        create: (_) => FileServiceImpl(),
      ),

      // Repository
      ProxyProvider3<LocalDataExportDataSource, ExportFormatterService, FileService, DataExportRepository>(
        update: (_, localDataSource, formatterService, fileService, __) =>
            DataExportRepositoryImpl(
          localDataSource,
          formatterService,
          fileService,
        ),
      ),

      // Use Cases
      ProxyProvider<DataExportRepository, CheckExportAvailabilityUsecase>(
        update: (_, repository, __) => CheckExportAvailabilityUsecase(repository),
      ),

      ProxyProvider<DataExportRepository, ExportUserDataUsecase>(
        update: (_, repository, __) => ExportUserDataUsecase(repository),
      ),

      // Provider
      ProxyProvider2<CheckExportAvailabilityUsecase, ExportUserDataUsecase, DataExportProvider>(
        update: (_, checkUsecase, exportUsecase, __) => DataExportProvider(
          checkUsecase,
          exportUsecase,
        ),
      ),
    ];
  }

  /// Método para registrar dependências manualmente (se não usar Provider)
  static void registerDependencies() {
    // Implementar registro manual aqui se necessário
    // Exemplo com GetIt ou outro container de DI
  }
}