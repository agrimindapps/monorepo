import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/usecases/add_animal.dart';
import '../../domain/usecases/delete_animal.dart';
import '../../domain/usecases/get_animal_by_id.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/update_animal.dart';

// Filter classes
class AnimalsFilter {
  final String searchQuery;
  final AnimalSpecies? speciesFilter;
  final AnimalGender? genderFilter;
  final AnimalSize? sizeFilter;
  final bool onlyActive;

  const AnimalsFilter({
    this.searchQuery = '',
    this.speciesFilter,
    this.genderFilter,
    this.sizeFilter,
    this.onlyActive = true,
  });

  AnimalsFilter copyWith({
    String? searchQuery,
    AnimalSpecies? speciesFilter,
    AnimalGender? genderFilter,
    AnimalSize? sizeFilter,
    bool? onlyActive,
  }) {
    return AnimalsFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      speciesFilter: speciesFilter,
      genderFilter: genderFilter,
      sizeFilter: sizeFilter,
      onlyActive: onlyActive ?? this.onlyActive,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      speciesFilter != null ||
      genderFilter != null ||
      sizeFilter != null;
}

// State classes
class AnimalsState {
  final List<Animal> animals;
  final List<Animal> filteredAnimals;
  final AnimalsFilter filter;
  final bool isLoading;
  final String? error;

  const AnimalsState({
    this.animals = const [],
    this.filteredAnimals = const [],
    this.filter = const AnimalsFilter(),
    this.isLoading = false,
    this.error,
  });

  AnimalsState copyWith({
    List<Animal>? animals,
    List<Animal>? filteredAnimals,
    AnimalsFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return AnimalsState(
      animals: animals ?? this.animals,
      filteredAnimals: filteredAnimals ?? this.filteredAnimals,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Animal> get displayedAnimals => filter.hasActiveFilters ? filteredAnimals : animals;
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
      (animals) {
        state = state.copyWith(
          animals: animals,
          isLoading: false,
          error: null,
        );
        // Apply current filter to new data
        _applyFilter();
      },
    );
  }

  void updateSearchQuery(String query) {
    final newFilter = state.filter.copyWith(searchQuery: query);
    state = state.copyWith(filter: newFilter);
    _applyFilter();
  }

  void updateSpeciesFilter(AnimalSpecies? species) {
    final newFilter = state.filter.copyWith(speciesFilter: species);
    state = state.copyWith(filter: newFilter);
    _applyFilter();
  }

  void updateGenderFilter(AnimalGender? gender) {
    final newFilter = state.filter.copyWith(genderFilter: gender);
    state = state.copyWith(filter: newFilter);
    _applyFilter();
  }

  void updateSizeFilter(AnimalSize? size) {
    final newFilter = state.filter.copyWith(sizeFilter: size);
    state = state.copyWith(filter: newFilter);
    _applyFilter();
  }

  void clearFilters() {
    state = state.copyWith(
      filter: const AnimalsFilter(),
      filteredAnimals: [],
    );
  }

  void _applyFilter() {
    final filter = state.filter;
    
    if (!filter.hasActiveFilters) {
      state = state.copyWith(filteredAnimals: []);
      return;
    }

    List<Animal> filtered = state.animals;

    // Apply active status filter
    if (filter.onlyActive) {
      filtered = filtered.where((animal) => animal.isActive).toList();
    }

    // Apply search query filter
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered.where((animal) {
        return animal.name.toLowerCase().contains(query) ||
            animal.breed?.toLowerCase().contains(query) == true ||
            animal.color?.toLowerCase().contains(query) == true ||
            animal.species.displayName.toLowerCase().contains(query) ||
            animal.microchipNumber?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Apply species filter
    if (filter.speciesFilter != null) {
      filtered = filtered
          .where((animal) => animal.species == filter.speciesFilter)
          .toList();
    }

    // Apply gender filter
    if (filter.genderFilter != null) {
      filtered = filtered
          .where((animal) => animal.gender == filter.genderFilter)
          .toList();
    }

    // Apply size filter
    if (filter.sizeFilter != null) {
      filtered = filtered
          .where((animal) => animal.size == filter.sizeFilter)
          .toList();
    }

    state = state.copyWith(filteredAnimals: filtered);
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
        // Reapply filter to include new animal if it matches
        _applyFilter();
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
        // Reapply filter to update filtered list
        _applyFilter();
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
        // Reapply filter to update filtered list
        _applyFilter();
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