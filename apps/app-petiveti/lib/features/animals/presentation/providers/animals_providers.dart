import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/animal_local_datasource.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../data/services/animal_error_handling_service.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/repositories/isync_manager.dart';
import '../../domain/services/animal_validation_service.dart';
import '../../domain/usecases/add_animal.dart';
import '../../domain/usecases/delete_animal.dart';
import '../../domain/usecases/get_animal_by_id.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/update_animal.dart';
import '../../../sync/providers/sync_providers.dart';

part 'animals_providers.g.dart';

// ============================================================================
// SERVICES
// ============================================================================

@riverpod
AnimalValidationService animalValidationService(
  AnimalValidationServiceRef ref,
) {
  return AnimalValidationService();
}

@riverpod
AnimalErrorHandlingService animalErrorHandlingService(
  AnimalErrorHandlingServiceRef ref,
) {
  return AnimalErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
AnimalLocalDataSource animalLocalDataSource(AnimalLocalDataSourceRef ref) {
  return AnimalLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
AnimalRepository animalRepository(AnimalRepositoryRef ref) {
  return AnimalRepositoryImpl(
    ref.watch(animalLocalDataSourceProvider),
    ref.watch(syncManagerProvider),
    ref.watch(animalErrorHandlingServiceProvider),
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetAnimals getAnimals(GetAnimalsRef ref) {
  return GetAnimals(ref.watch(animalRepositoryProvider));
}

@riverpod
GetAnimalById getAnimalById(GetAnimalByIdRef ref) {
  return GetAnimalById(
    ref.watch(animalRepositoryProvider),
    ref.watch(animalValidationServiceProvider),
  );
}

@riverpod
AddAnimal addAnimal(AddAnimalRef ref) {
  return AddAnimal(
    ref.watch(animalRepositoryProvider),
    ref.watch(animalValidationServiceProvider),
  );
}

@riverpod
UpdateAnimal updateAnimal(UpdateAnimalRef ref) {
  return UpdateAnimal(
    ref.watch(animalRepositoryProvider),
    ref.watch(animalValidationServiceProvider),
  );
}

@riverpod
DeleteAnimal deleteAnimal(DeleteAnimalRef ref) {
  return DeleteAnimal(
    ref.watch(animalRepositoryProvider),
    ref.watch(animalValidationServiceProvider),
  );
}
