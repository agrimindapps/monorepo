import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart' as local;
import '../../../../core/logging/entities/log_entry.dart';
import '../../../../core/logging/services/logging_service.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/usecases/add_animal.dart';
import '../../domain/usecases/delete_animal.dart';
import '../../domain/usecases/get_animal_by_id.dart';
import '../../domain/usecases/get_animals.dart';
import '../../domain/usecases/update_animal.dart';

part 'animals_notifier.g.dart';

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

@riverpod
class AnimalsNotifier extends _$AnimalsNotifier {
  late final GetAnimals _getAnimals;
  late final GetAnimalById _getAnimalById;
  late final AddAnimal _addAnimal;
  late final UpdateAnimal _updateAnimal;
  late final DeleteAnimal _deleteAnimal;

  @override
  AnimalsState build() {
    _getAnimals = di.getIt<GetAnimals>();
    _getAnimalById = di.getIt<GetAnimalById>();
    _addAnimal = di.getIt<AddAnimal>();
    _updateAnimal = di.getIt<UpdateAnimal>();
    _deleteAnimal = di.getIt<DeleteAnimal>();

    return const AnimalsState();
  }

  Future<void> loadAnimals() async {
    await LoggingService.instance.trackUserAction(
      category: LogCategory.animals,
      operation: LogOperation.read,
      action: 'load_animals_initiated',
      metadata: {'from': 'animals_notifier'},
    );

    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAnimals(const local.NoParams());

    result.fold(
      (failure) {
        LoggingService.instance.logError(
          category: LogCategory.animals,
          operation: LogOperation.read,
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
        LoggingService.instance.logInfo(
          category: LogCategory.animals,
          operation: LogOperation.read,
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
    if (filter.onlyActive) {
      filtered = filtered.where((animal) => animal.isActive).toList();
    }
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
    if (filter.speciesFilter != null) {
      filtered = filtered
          .where((animal) => animal.species == filter.speciesFilter)
          .toList();
    }
    if (filter.genderFilter != null) {
      filtered = filtered
          .where((animal) => animal.gender == filter.genderFilter)
          .toList();
    }
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
        final updatedAnimals = [animal, ...state.animals];
        state = state.copyWith(
          animals: updatedAnimals,
          error: null,
        );
        _applyFilter();
      },
    );
  }

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
        _applyFilter();
      },
    );
  }

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
