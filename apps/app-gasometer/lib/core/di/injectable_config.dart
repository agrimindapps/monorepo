import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import do arquivo gerado (será criado pelo build_runner)
import 'injectable_config.config.dart';
import '../interfaces/i_sync_service.dart';
import '../sync/services/sync_service.dart';
import '../../features/data_export/domain/repositories/data_export_repository.dart';
import '../../features/data_export/data/repositories/data_export_repository_impl.dart';
import '../../features/data_export/domain/services/platform_export_service.dart';

final getIt = GetIt.instance;

/// Configuração automática do DI usando build_runner
/// 
/// Este arquivo substitui a configuração manual por uma abordagem automática
/// baseada em annotations @injectable, @singleton, @factory, etc.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  getIt.init();
  registerExternalDependencies();
}

/// Inicializa dependências com suporte a environment
void configureDependenciesForEnvironment(String environment) {
  getIt.init(environment: environment);
  registerExternalDependencies();
}

/// Reset do container para testes
void resetDependencies() {
  getIt.reset();
}

/// Registra dependências externas que não podem ser anotadas
void registerExternalDependencies() {
  // Registrar ISyncService manualmente usando SyncService
  if (!getIt.isRegistered<ISyncService>()) {
    getIt.registerLazySingleton<ISyncService>(() => getIt<SyncService>());
  }
  
  // Registrar DataExportRepository manualmente
  if (!getIt.isRegistered<DataExportRepository>()) {
    getIt.registerLazySingleton<DataExportRepository>(() => DataExportRepositoryImpl());
  }
  
  // Registrar PlatformExportService manualmente 
  if (!getIt.isRegistered<PlatformExportService>()) {
    getIt.registerLazySingleton<PlatformExportService>(() => PlatformExportServiceFactory.create());
  }
}