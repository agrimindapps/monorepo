import 'package:core/core.dart' hide Ref;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart' as local;
import '../../../../core/mixins/optimistic_delete_mixin.dart';
import '../../../../core/providers/app_state_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../database/providers/unified_sync_manager_provider.dart';
import '../../data/datasources/animal_local_datasource.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../data/repositories/unified_sync_manager_adapter.dart';
import '../../data/services/animal_error_handling_service.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/repositories/isync_manager.dart';
import '../../domain/services/animal_validation_service.dart';
import '../../domain/usecases/add_animal.dart';
import '../../domain/usecases/delete_animal.dart';
import '../../domain/usecases/get_animal_by_id.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/update_animal.dart';

// Export state classes and providers for use in other modules
// export '../notifiers/animals_notifier.dart' show AnimalsState, AnimalsNotifier, animalsProvider;

part 'animals_providers.g.dart';

// ============================================================================
// SERVICES
// ============================================================================

@riverpod
AnimalValidationService animalValidationService(Ref ref) {
  return AnimalValidationService();
}

@riverpod
AnimalErrorHandlingService animalErrorHandlingService(Ref ref) {
  return AnimalErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
AnimalLocalDataSource animalLocalDataSource(Ref ref) {
  return AnimalLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

// ============================================================================
// SYNC MANAGER
// ============================================================================

/// Adapter que conecta ISyncManager com UnifiedSyncManager
@riverpod
ISyncManager animalSyncManager(Ref ref) {
  final unifiedSyncManager = ref.watch(unifiedSyncManagerProvider);
  return UnifiedSyncManagerAdapter(unifiedSyncManager, 'petiveti');
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
AnimalRepository animalRepository(Ref ref) {
  return AnimalRepositoryImpl(
    ref.watch(animalLocalDataSourceProvider),
    ref.watch(animalSyncManagerProvider),
    ref.watch(animalErrorHandlingServiceProvider),
  );
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetAnimals getAnimals(Ref ref) {
  return GetAnimals(ref.watch(animalRepositoryProvider));
}

@riverpod
GetAnimalById getAnimalById(Ref ref) {
  return GetAnimalById(
    ref.watch(animalRepositoryProvider),
    ref.watch(animalValidationServiceProvider),
  );
}

@riverpod
AddAnimal addAnimal(Ref ref) {
  return AddAnimal(
    ref.watch(animalRepositoryProvider),
    ref.watch(animalValidationServiceProvider),
  );
}

@riverpod
UpdateAnimal updateAnimal(Ref ref) {
  return UpdateAnimal(
    ref.watch(animalRepositoryProvider),
    ref.watch(animalValidationServiceProvider),
  );
}

@riverpod
DeleteAnimal deleteAnimal(Ref ref) {
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
///
/// Agora com suporte a Swipe-to-Delete otimista:
/// - Remove da UI imediatamente (melhor UX)
/// - Permite undo por 5 segundos
/// - Delete permanente após timeout
@riverpod
class AnimalsNotifier extends _$AnimalsNotifier with OptimisticDeleteMixin<Animal> {
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

    if (!ref.mounted) return;

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

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // 📊 Analytics: Track pet created
        _trackPetCreated(animal);
        // Recarregar do banco para obter o ID correto gerado pelo Drift
        loadAnimals();
      },
    );
  }

  /// 📊 Track pet created event to Firebase Analytics
  void _trackPetCreated(Animal animal) {
    try {
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Pet created tracked: ${animal.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Error tracking pet created: $e');
      }
    }
  }

  /// Atualizar animal existente
  Future<void> updateAnimal(Animal animal) async {
    final updateAnimal = ref.read(updateAnimalProvider);
    final result = await updateAnimal(animal);

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Recarregar do banco para garantir consistência
        loadAnimals();
      },
    );
  }

  /// Deletar animal
  Future<void> deleteAnimal(String id) async {
    final deleteAnimal = ref.read(deleteAnimalProvider);
    final result = await deleteAnimal(id);

    if (!ref.mounted) return;

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Recarregar do banco para garantir consistência
        loadAnimals();
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

  // ============================================================================
  // OPTIMISTIC DELETE MIXIN IMPLEMENTATION
  // ============================================================================

  @override
  String getItemId(Animal item) => item.id;

  @override
  Future<void> performDelete(String id) async {
    final deleteAnimal = ref.read(deleteAnimalProvider);
    final result = await deleteAnimal(id);

    result.fold(
      (failure) {
        // Log erro mas não propaga - item já foi removido da UI
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Sucesso - delete permanente confirmado
      },
    );
  }

  @override
  Future<void> performRestore(Animal item) async {
    // Re-adiciona o animal à lista
    final updatedList = [...state.animals, item];
    state = state.copyWith(animals: updatedList);
  }

  /// Remove animal otimisticamente (para uso com SwipeToDeleteWrapper)
  ///
  /// Este método remove o animal da UI imediatamente e agenda o delete
  /// permanente após 5 segundos. O usuário pode desfazer durante esse período.
  Future<void> deleteAnimalOptimistic(Animal animal) async {
    // Remove da UI imediatamente
    final updatedList = state.animals.where((a) => a.id != animal.id).toList();
    state = state.copyWith(animals: updatedList);

    // Agenda delete permanente com possibilidade de undo
    await removeOptimistic(animal);
  }

  /// Restaura um animal que foi removido otimisticamente
  ///
  /// Chamado quando o usuário clica em "DESFAZER" no SnackBar.
  Future<void> restoreAnimal(String id) async {
    await restoreItem(id);
  }
}

// Derived providers
@riverpod
Future<Animal?> animalById(Ref ref, String id) async {
  final notifier = ref.read(animalsProvider.notifier);
  return await notifier.getAnimalById(id);
}

@riverpod
Stream<List<Animal>> animalsStream(Ref ref) {
  final repository = ref.watch(animalRepositoryProvider);
  return repository.watchAnimals();
}

/// Provider que retorna o animal atualmente selecionado
/// Usa o selectedAnimalIdProvider (core) para evitar dependências circulares
@riverpod
Future<Animal?> selectedAnimal(Ref ref) async {
  // Observa o ID selecionado
  final selectedId = ref.watch(selectedAnimalIdProvider);

  if (selectedId == null) return null;

  // Busca o animal pelo ID
  return await ref.read(animalByIdProvider(selectedId).future);
}
