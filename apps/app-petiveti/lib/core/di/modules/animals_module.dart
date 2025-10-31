import 'package:core/core.dart' show GetIt;

import '../../../features/animals/data/datasources/animal_local_datasource.dart';
import '../../../features/animals/data/repositories/animal_repository_impl.dart';
import '../../../features/animals/data/services/animal_error_handling_service.dart';
import '../../../features/animals/domain/repositories/animal_repository.dart';
import '../../../features/animals/domain/repositories/isync_manager.dart';
import '../../../features/animals/domain/services/animal_validation_service.dart';
import '../../../features/animals/domain/usecases/add_animal.dart';
import '../../../features/animals/domain/usecases/delete_animal.dart';
import '../../../features/animals/domain/usecases/get_animal_by_id.dart';
import '../../../features/animals/domain/usecases/get_animals.dart';
import '../../../features/animals/domain/usecases/update_animal.dart';
import '../di_module.dart';

/// Animals module responsible for animals feature dependencies
///
/// **Migrado para UnifiedSyncManager pattern:**
/// - Removido AnimalRemoteDataSource (UnifiedSyncManager gerencia sync)
/// - Adicionado DataIntegrityService para ID reconciliation
/// - AnimalRepository agora usa markAsDirty pattern
///
/// Follows SRP: Single responsibility of animals feature registration
/// Follows OCP: Open for extension via DI module interface
/// Follows DIP: Depends on abstractions (interfaces)
class AnimalsModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Services
    getIt.registerLazySingleton<AnimalValidationService>(
      () => AnimalValidationService(),
    );

    getIt.registerLazySingleton<AnimalErrorHandlingService>(
      () => AnimalErrorHandlingService(),
    );

    // Data Source (local only - UnifiedSyncManager handles remote)
    getIt.registerLazySingleton<AnimalLocalDataSource>(
      () => AnimalLocalDataSourceImpl(getIt()),
    );

    // Repository (offline-first with UnifiedSyncManager)
    getIt.registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryImpl(
        getIt<AnimalLocalDataSource>(),
        getIt<ISyncManager>(),
        getIt<AnimalErrorHandlingService>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<GetAnimals>(
      () => GetAnimals(getIt<AnimalRepository>()),
    );

    getIt.registerLazySingleton<GetAnimalById>(
      () => GetAnimalById(
        getIt<AnimalRepository>(),
        getIt<AnimalValidationService>(),
      ),
    );

    getIt.registerLazySingleton<AddAnimal>(
      () => AddAnimal(
        getIt<AnimalRepository>(),
        getIt<AnimalValidationService>(),
      ),
    );

    getIt.registerLazySingleton<UpdateAnimal>(
      () => UpdateAnimal(
        getIt<AnimalRepository>(),
        getIt<AnimalValidationService>(),
      ),
    );

    getIt.registerLazySingleton<DeleteAnimal>(
      () => DeleteAnimal(
        getIt<AnimalRepository>(),
        getIt<AnimalValidationService>(),
      ),
    );
  }
}
