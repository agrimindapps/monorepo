import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart' as local;
import '../../../../core/interfaces/logging_service.dart';
import '../../../../core/providers/logging_providers.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/usecases/add_animal.dart';
import '../../domain/usecases/delete_animal.dart';
import '../../domain/usecases/get_animal_by_id.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/update_animal.dart';

part 'animals_notifier.g.dart';

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
  late final GetAnimals _getAnimals;
  late final GetAnimalById _getAnimalById;
  late final AddAnimal _addAnimal;
  late final UpdateAnimal _updateAnimal;
  late final DeleteAnimal _deleteAnimal;
  late final ILoggingService _logger;

  @override
  AnimalsState build() {
    _getAnimals = di.getIt<GetAnimals>();
    _getAnimalById = di.getIt<GetAnimalById>();
    _addAnimal = di.getIt<AddAnimal>();
    _updateAnimal = di.getIt<UpdateAnimal>();
    _deleteAnimal = di.getIt<DeleteAnimal>();
    _logger = ref.watch(loggingServiceProvider);

    return const AnimalsState();
  }

  /// Carregar todos os animais
  Future<void> loadAnimals() async {
    await _logger.trackUserAction(
      category: 'animals',
      operation: 'read',
      action: 'load_animals_initiated',
      metadata: {'from': 'animals_notifier'},
    );

    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAnimals(const local.NoParams());

    result.fold(
      (failure) {
        _logger.logError(
          category: 'animals',
          operation: 'read',
          message: 'Failed to load animals in notifier',
          error: failure.message,
          metadata: {'notifier': 'animals_notifier'},
        );

        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (animals) {
        _logger.logInfo(
          category: 'animals',
          operation: 'read',
          message: 'Successfully loaded animals in notifier',
          metadata: {
            'notifier': 'animals_notifier',
            'count': animals.length,
          },
        );
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
    final result = await _addAnimal(animal);

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
    final result = await _updateAnimal(animal);

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
    final result = await _deleteAnimal(id);

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
    final result = await _getAnimalById(id);

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
  final notifier = ref.read(animalsNotifierProvider.notifier);
  return await notifier.getAnimalById(id);
}

@riverpod
Stream<List<Animal>> animalsStream(AnimalsStreamRef ref) {
  final repository = di.getIt.get<AnimalRepository>();
  return repository.watchAnimals();
}
