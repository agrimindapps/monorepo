import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Features - Animals
import '../../features/animals/data/datasources/animal_local_datasource.dart';
import '../../features/animals/data/repositories/animal_repository_local_only_impl.dart';
import '../../features/animals/domain/repositories/animal_repository.dart';
import '../../features/animals/domain/usecases/get_animals.dart';
import '../../features/animals/domain/usecases/get_animal_by_id.dart';
import '../../features/animals/domain/usecases/add_animal.dart';
import '../../features/animals/domain/usecases/update_animal.dart';
import '../../features/animals/domain/usecases/delete_animal.dart';
import '../../features/animals/data/models/animal_model.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(AnimalModelAdapter());
  }
  
  // External services
  _registerExternalServices();
  
  // Core services
  _registerCoreServices();
  
  // Features services
  _registerAnimalsFeature();
}

void _registerExternalServices() {
  // Connectivity
  getIt.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );
}

void _registerCoreServices() {
  // Core services will be registered here as needed
}

void _registerAnimalsFeature() {
  // Data Sources
  getIt.registerLazySingleton<AnimalLocalDataSource>(
    () => AnimalLocalDataSourceImpl(),
  );
  
  // Repository (without remote datasource for now)
  getIt.registerLazySingleton<AnimalRepository>(
    () => AnimalRepositoryLocalOnlyImpl(
      localDataSource: getIt<AnimalLocalDataSource>(),
    ),
  );
  
  // Use Cases
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