import 'package:core/core.dart' show GetIt;

import '../../../features/animals/data/datasources/animal_local_datasource.dart';
import '../../../features/animals/data/datasources/animal_remote_datasource.dart';
import '../../../features/animals/data/repositories/animal_repository_impl.dart';
import '../../../features/animals/domain/repositories/animal_repository.dart';
import '../../../features/animals/domain/usecases/add_animal.dart';
import '../../../features/animals/domain/usecases/delete_animal.dart';
import '../../../features/animals/domain/usecases/get_animal_by_id.dart';
import '../../../features/animals/domain/usecases/get_animals.dart';
import '../../../features/animals/domain/usecases/update_animal.dart';
import '../di_module.dart';

/// Animals module responsible for animals feature dependencies
///
/// Follows SRP: Single responsibility of animals feature registration
/// Follows OCP: Open for extension via DI module interface
/// Follows DIP: Depends on abstractions (interfaces)
class AnimalsModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<AnimalLocalDataSource>(
      () => AnimalLocalDataSourceImpl(getIt()),
    );

    getIt.registerLazySingleton<AnimalRemoteDataSource>(
      () => AnimalRemoteDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<AnimalRepository>(
      () => AnimalRepositoryImpl(
        localDataSource: getIt<AnimalLocalDataSource>(),
        remoteDataSource: getIt<AnimalRemoteDataSource>(),
        connectivity: getIt(),
      ),
    );

    // Use cases
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
