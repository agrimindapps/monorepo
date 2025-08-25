import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/usecases/add_animal.dart';
import '../../domain/usecases/delete_animal.dart';
import '../../domain/usecases/get_animal_by_id.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/update_animal.dart';

// State classes
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

// State notifier
class AnimalsNotifier extends StateNotifier<AnimalsState> {
  final GetAnimals _getAnimals;
  final GetAnimalById _getAnimalById;
  final AddAnimal _addAnimal;
  final UpdateAnimal _updateAnimal;
  final DeleteAnimal _deleteAnimal;

  AnimalsNotifier({
    required GetAnimals getAnimals,
    required GetAnimalById getAnimalById,
    required AddAnimal addAnimal,
    required UpdateAnimal updateAnimal,
    required DeleteAnimal deleteAnimal,
  })  : _getAnimals = getAnimals,
        _getAnimalById = getAnimalById,
        _addAnimal = addAnimal,
        _updateAnimal = updateAnimal,
        _deleteAnimal = deleteAnimal,
        super(const AnimalsState());

  Future<void> loadAnimals() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAnimals(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (animals) => state = state.copyWith(
        animals: animals,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<void> addAnimal(Animal animal) async {
    final result = await _addAnimal(animal);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Add the animal to current state optimistically
        final updatedAnimals = [animal, ...state.animals];
        state = state.copyWith(
          animals: updatedAnimals,
          error: null,
        );
      },
    );
  }

  Future<void> updateAnimal(Animal animal) async {
    final result = await _updateAnimal(animal);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update the animal in current state
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

  Future<void> deleteAnimal(String id) async {
    final result = await _deleteAnimal(id);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Remove the animal from current state
        final updatedAnimals = state.animals.where((a) => a.id != id).toList();
        state = state.copyWith(
          animals: updatedAnimals,
          error: null,
        );
      },
    );
  }

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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final animalsProvider = StateNotifierProvider<AnimalsNotifier, AnimalsState>((ref) {
  return AnimalsNotifier(
    getAnimals: di.getIt<GetAnimals>(),
    getAnimalById: di.getIt<GetAnimalById>(),
    addAnimal: di.getIt<AddAnimal>(),
    updateAnimal: di.getIt<UpdateAnimal>(),
    deleteAnimal: di.getIt<DeleteAnimal>(),
  );
});

// Individual animal provider
final animalProvider = FutureProvider.family<Animal?, String>((ref, id) async {
  final notifier = ref.read(animalsProvider.notifier);
  return await notifier.getAnimalById(id);
});

// Stream provider for real-time updates
final animalsStreamProvider = StreamProvider<List<Animal>>((ref) {
  final repository = di.getIt.get<AnimalRepository>();
  return repository.watchAnimals();
});

// Selected animal provider for maintaining selection across pages
final selectedAnimalProvider = StateProvider<Animal?>((ref) => null);