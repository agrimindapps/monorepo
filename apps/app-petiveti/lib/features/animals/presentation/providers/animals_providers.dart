import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/animal_local_datasource.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../data/repositories/noop_sync_manager.dart';
import '../../data/services/animal_error_handling_service.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/repositories/isync_manager.dart';
import '../../domain/services/animal_validation_service.dart';
import '../../domain/usecases/add_animal.dart';
import '../../domain/usecases/delete_animal.dart';
import '../../domain/usecases/get_animal_by_id.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/update_animal.dart';
import '../../../../core/interfaces/usecase.dart' as local;
import '../../../../core/interfaces/logging_service.dart';
import '../../../../core/providers/core_services_providers.dart';
import '../../domain/entities/animal.dart';

// Export state classes and providers for use in other modules
// export '../notifiers/animals_notifier.dart' show AnimalsState, AnimalsNotifier, animalsProvider;

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
    const NoOpSyncManager(), // TODO: Implement proper sync manager
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

// ============================================================================
// NOTIFIER & STATE
// ============================================================================

/// State para gerenciar dados de animais - responsabilidade ÚNICA em dados
/// Filtragem separada em AnimalsFilterNotifier (SRP)
class AnimalsState {
  final List<Animal> animals;
  final bool isLoading;
  final String? error;

  const AnimalsState({
    this.animals = const [],
    this.isLoading = false,
    this.error,
  });

  AnimalsState copyWith({
    List<Animal>? animals,
    bool? isLoading,
    String? error,
  }) {
    return AnimalsState(
      animals: animals ?? this.animals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier responsável APENAS por gerenciar dados de animais (CRUD + logging)
/// Filtragem é responsabilidade de AnimalsFilterNotifier (SRP)
/// UI state é responsabilidade de AnimalsUIStateNotifier (SRP)
///
/// Benefícios dessa separação:
/// - Cada notifier tem responsabilidade única
/// - Fácil testar cada componente isoladamente
/// - Fácil adicionar novos filtros sem modificar este notifier
/// - Padrão consistente com Clean Architecture
@riverpod
class AnimalsNotifier extends _$AnimalsNotifier {
  @override
  AnimalsState build() {
    return const AnimalsState();
  }

  /// Carregar todos os animais
  Future<void> loadAnimals() async {
    // TODO: Fix logging service call parameters
    // final logger = ref.read(loggingServiceProvider);
    // await logger.trackUserAction(
    //   category: 'animals',
    //   operation: 'read',
    //   action: 'load_animals_initiated',
    //   metadata: {'from': 'animals_notifier'},
    // );

    state = state.copyWith(isLoading: true, error: null);

    final getAnimals = ref.read(getAnimalsProvider);
    final result = await getAnimals(const local.NoParams());

    result.fold(
      (failure) {
        // logger.logError(
        //   category: 'animals',
        //   operation: 'read',
        //   message: 'Failed to load animals in notifier',
        //   error: failure.message,
        //   metadata: {'notifier': 'animals_notifier'},
        // );

        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (animals) {
        // logger.logInfo(
        //   category: 'animals',
        //   operation: 'read',
        //   message: 'Successfully loaded animals in notifier',
        //   metadata: {
        //     'notifier': 'animals_notifier',
        //     'count': animals.length,
        //   },
        // );
        state = state.copyWith(
          animals: animals,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Adicionar novo animal
  Future<void> addAnimal(Animal animal) async {
    final addAnimal = ref.read(addAnimalProvider);
    final result = await addAnimal(animal);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedAnimals = [animal, ...state.animals];
        state = state.copyWith(
          animals: updatedAnimals,
          error: null,
        );
      },
    );
  }

  /// Atualizar animal existente
  Future<void> updateAnimal(Animal animal) async {
    final updateAnimal = ref.read(updateAnimalProvider);
    final result = await updateAnimal(animal);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedAnimals = state.animals.map((a) {
          return a.id == animal.id ? animal : a;
        }).toList();

        state = state.copyWith(
          animals: updatedAnimals,
          error: null,
        );
      },
    );
  }

  /// Deletar animal
  Future<void> deleteAnimal(String id) async {
    final deleteAnimal = ref.read(deleteAnimalProvider);
    final result = await deleteAnimal(id);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        final updatedAnimals = state.animals.where((a) => a.id != id).toList();
        state = state.copyWith(
          animals: updatedAnimals,
          error: null,
        );
      },
    );
  }

  /// Buscar animal por ID
  Future<Animal?> getAnimalById(String id) async {
    final getAnimalById = ref.read(getAnimalByIdProvider);
    final result = await getAnimalById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (animal) => animal,
    );
  }

  /// Limpar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Derived providers
@riverpod
Future<Animal?> animalById(AnimalByIdRef ref, String id) async {
  final notifier = ref.read(animalsProvider.notifier);
  return await notifier.getAnimalById(id);
}

@riverpod
Stream<List<Animal>> animalsStream(AnimalsStreamRef ref) {
  final repository = ref.watch(animalRepositoryProvider);
  return repository.watchAnimals();
}
