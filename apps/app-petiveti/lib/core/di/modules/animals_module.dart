import 'package:core/core.dart' show GetIt;

import '../../../features/animals/data/datasources/animal_local_datasource.dart';
import '../../../features/animals/data/repositories/animal_repository_impl.dart';
import '../../../features/animals/domain/repositories/animal_repository.dart';
import '../../../features/animals/domain/usecases/add_animal.dart';
import '../../../features/animals/domain/usecases/delete_animal.dart';
import '../../../features/animals/domain/usecases/get_animal_by_id.dart';
import '../../../features/animals/domain/usecases/get_animals.dart';
import '../../../features/animals/domain/usecases/update_animal.dart';
import '../../services/data_integrity_service.dart';
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
    // Data Integrity Service
    getIt.registerLazySingleton<DataIntegrityService>(
      () => DataIntegrityService(getIt<AnimalLocalDataSource>()),
    );

    // Data Source (local only - UnifiedSyncManager handles remote)
    getIt.registerLazySingleton<AnimalLocalDataSource>(
      () => AnimalLocalDataSourceImpl(getIt()),
    );

    // Repository (offline-first with UnifiedSyncManager)
    getIt.registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryImpl(
        getIt<AnimalLocalDataSource>(),
        getIt<DataIntegrityService>(),
      ),
    );
    getIt.registerLazySingleton<GetAnimals>(
      () => GetAnimals(getIt<AnimalRepository>()),
    );

    getIt.registerLazySingleton<GetAnimalById>(
      () => GetAnimalById(getIt<AnimalRepository>()),
    );

    getIt.registerLazySingleton<AddAnimal>(
      () => AddAnimal(getIt<AnimalRepository>()),
    );

    getIt.registerLazySingleton<UpdateAnimal>(
      () => UpdateAnimal(getIt<AnimalRepository>()),
    );

    getIt.registerLazySingleton<DeleteAnimal>(
      () => DeleteAnimal(getIt<AnimalRepository>()),
    );
  }
}
