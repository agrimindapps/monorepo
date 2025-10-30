import '../../../domain/entities/animal.dart';
import '../../../domain/entities/animal_enums.dart';

/// Strategy pattern para filtragem de animais
/// Permite adicionar novos filtros sem modificar código existente (OCP)
abstract class AnimalFilterStrategy {
  List<Animal> apply(List<Animal> animals);
  bool get hasActiveFilter;
}

/// Filtro por texto de busca
class SearchFilterStrategy implements AnimalFilterStrategy {
  final String searchQuery;

  SearchFilterStrategy(this.searchQuery);

  @override
  List<Animal> apply(List<Animal> animals) {
    if (searchQuery.isEmpty) return animals;

    final query = searchQuery.toLowerCase();
    return animals.where((animal) {
      return animal.name.toLowerCase().contains(query) ||
          animal.breed?.toLowerCase().contains(query) == true ||
          animal.color?.toLowerCase().contains(query) == true ||
          animal.species.displayName.toLowerCase().contains(query) ||
          animal.microchipNumber?.toLowerCase().contains(query) == true;
    }).toList();
  }

  @override
  bool get hasActiveFilter => searchQuery.isNotEmpty;
}

/// Filtro por espécie
class SpeciesFilterStrategy implements AnimalFilterStrategy {
  final AnimalSpecies species;

  SpeciesFilterStrategy(this.species);

  @override
  List<Animal> apply(List<Animal> animals) {
    return animals.where((animal) => animal.species == species).toList();
  }

  @override
  bool get hasActiveFilter => true;
}

/// Filtro por gênero
class GenderFilterStrategy implements AnimalFilterStrategy {
  final AnimalGender gender;

  GenderFilterStrategy(this.gender);

  @override
  List<Animal> apply(List<Animal> animals) {
    return animals.where((animal) => animal.gender == gender).toList();
  }

  @override
  bool get hasActiveFilter => true;
}

/// Filtro por tamanho
class SizeFilterStrategy implements AnimalFilterStrategy {
  final AnimalSize size;

  SizeFilterStrategy(this.size);

  @override
  List<Animal> apply(List<Animal> animals) {
    return animals.where((animal) => animal.size == size).toList();
  }

  @override
  bool get hasActiveFilter => true;
}

/// Filtro para animais ativos apenas
class ActiveStatusFilterStrategy implements AnimalFilterStrategy {
  final bool onlyActive;

  ActiveStatusFilterStrategy(this.onlyActive);

  @override
  List<Animal> apply(List<Animal> animals) {
    if (!onlyActive) return animals;
    return animals.where((animal) => animal.isActive).toList();
  }

  @override
  bool get hasActiveFilter => onlyActive;
}
