// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/17_peso_model.dart';

class AnimalPageModel {
  final String searchQuery;
  final String selectedFilter;
  final String selectedAnimalId;
  final int? dataInicial;
  final int? dataFinal;
  final List<Animal> animals;
  final List<PesoAnimal> pesos;

  const AnimalPageModel({
    this.searchQuery = '',
    this.selectedFilter = 'todos',
    this.selectedAnimalId = '',
    this.dataInicial,
    this.dataFinal,
    this.animals = const [],
    this.pesos = const [],
  });

  AnimalPageModel copyWith({
    String? searchQuery,
    String? selectedFilter,
    String? selectedAnimalId,
    int? dataInicial,
    int? dataFinal,
    List<Animal>? animals,
    List<PesoAnimal>? pesos,
  }) {
    return AnimalPageModel(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      dataInicial: dataInicial ?? this.dataInicial,
      dataFinal: dataFinal ?? this.dataFinal,
      animals: animals ?? this.animals,
      pesos: pesos ?? this.pesos,
    );
  }

  // Getters for computed properties
  Animal? get selectedAnimal {
    if (selectedAnimalId.isEmpty || animals.isEmpty) return null;
    try {
      return animals.firstWhere((animal) => animal.id == selectedAnimalId);
    } catch (e) {
      return null;
    }
  }

  List<Animal> get filteredAnimals {
    var filtered = List<Animal>.from(animals);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((animal) {
        return animal.nome.toLowerCase().contains(query) ||
            animal.especie.toLowerCase().contains(query) ||
            animal.raca.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    switch (selectedFilter) {
      case 'cachorros':
        filtered = filtered
            .where((animal) =>
                animal.especie.toLowerCase().contains('cachorro') ||
                animal.especie.toLowerCase().contains('cão'))
            .toList();
        break;
      case 'gatos':
        filtered = filtered
            .where((animal) => animal.especie.toLowerCase().contains('gato'))
            .toList();
        break;
      case 'outros':
        filtered = filtered
            .where((animal) =>
                !animal.especie.toLowerCase().contains('cachorro') &&
                !animal.especie.toLowerCase().contains('cão') &&
                !animal.especie.toLowerCase().contains('gato'))
            .toList();
        break;
      case 'todos':
      default:
        // No additional filtering
        break;
    }

    return filtered;
  }

  List<PesoAnimal> get filteredPesos {
    var filtered = List<PesoAnimal>.from(pesos);

    // Filter by selected animal
    if (selectedAnimalId.isNotEmpty) {
      filtered =
          filtered.where((peso) => peso.animalId == selectedAnimalId).toList();
    }

    // Filter by date range
    if (dataInicial != null) {
      filtered =
          filtered.where((peso) => peso.dataPesagem >= dataInicial!).toList();
    }
    if (dataFinal != null) {
      filtered =
          filtered.where((peso) => peso.dataPesagem <= dataFinal!).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));

    return filtered;
  }

  // Statistics and computed values
  int get totalAnimals => animals.length;
  int get totalFilteredAnimals => filteredAnimals.length;
  int get totalCachorros => animals
      .where((animal) =>
          animal.especie.toLowerCase().contains('cachorro') ||
          animal.especie.toLowerCase().contains('cão'))
      .length;
  int get totalGatos => animals
      .where((animal) => animal.especie.toLowerCase().contains('gato'))
      .length;
  int get totalOutros => totalAnimals - totalCachorros - totalGatos;

  bool get hasAnimals => animals.isNotEmpty;
  bool get hasFilteredAnimals => filteredAnimals.isNotEmpty;
  bool get hasSelectedAnimal => selectedAnimal != null;
  bool get hasSearchQuery => searchQuery.isNotEmpty;
  bool get hasDateFilter => dataInicial != null || dataFinal != null;

  // Data validation
  bool get isValid => true; // Can add validation rules here

  // Helper methods for filters
  List<String> get availableFilters => [
        'todos',
        'cachorros',
        'gatos',
        'outros',
      ];

  String getFilterDisplayName(String filter) {
    switch (filter) {
      case 'todos':
        return 'Todos ($totalAnimals)';
      case 'cachorros':
        return 'Cachorros ($totalCachorros)';
      case 'gatos':
        return 'Gatos ($totalGatos)';
      case 'outros':
        return 'Outros ($totalOutros)';
      default:
        return filter;
    }
  }

  // Reset methods
  AnimalPageModel clearSearch() {
    return copyWith(searchQuery: '');
  }

  AnimalPageModel clearFilters() {
    return copyWith(
      selectedFilter: 'todos',
      searchQuery: '',
      dataInicial: null,
      dataFinal: null,
    );
  }

  AnimalPageModel clearSelection() {
    return copyWith(selectedAnimalId: '');
  }

  AnimalPageModel reset() {
    return const AnimalPageModel();
  }

  @override
  String toString() {
    return 'AnimalPageModel(animals: ${animals.length}, filteredAnimals: ${filteredAnimals.length}, '
        'searchQuery: "$searchQuery", selectedFilter: "$selectedFilter", '
        'selectedAnimalId: "$selectedAnimalId")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimalPageModel &&
        other.searchQuery == searchQuery &&
        other.selectedFilter == selectedFilter &&
        other.selectedAnimalId == selectedAnimalId &&
        other.dataInicial == dataInicial &&
        other.dataFinal == dataFinal &&
        _listEquals(other.animals, animals) &&
        _listEquals(other.pesos, pesos);
  }

  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return searchQuery.hashCode ^
        selectedFilter.hashCode ^
        selectedAnimalId.hashCode ^
        dataInicial.hashCode ^
        dataFinal.hashCode ^
        animals.hashCode ^
        pesos.hashCode;
  }
}
