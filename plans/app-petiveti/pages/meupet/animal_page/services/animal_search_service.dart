// Project imports:
import '../../../../models/11_animal_model.dart';

class AnimalSearchService {
  // Search animals by query
  static List<Animal> searchAnimals(List<Animal> animals, String query) {
    if (query.isEmpty) return animals;

    final searchQuery = query.toLowerCase();
    return animals.where((animal) {
      return animal.nome.toLowerCase().contains(searchQuery) ||
          animal.especie.toLowerCase().contains(searchQuery) ||
          animal.raca.toLowerCase().contains(searchQuery) ||
          animal.cor.toLowerCase().contains(searchQuery) ||
          (animal.observacoes?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  // Filter animals by species/type
  static List<Animal> filterByType(List<Animal> animals, String filterType) {
    switch (filterType.toLowerCase()) {
      case 'cachorros':
        return animals
            .where((animal) =>
                animal.especie.toLowerCase().contains('cachorro') ||
                animal.especie.toLowerCase().contains('cão'))
            .toList();

      case 'gatos':
        return animals
            .where((animal) => animal.especie.toLowerCase().contains('gato'))
            .toList();

      case 'outros':
        return animals
            .where((animal) =>
                !animal.especie.toLowerCase().contains('cachorro') &&
                !animal.especie.toLowerCase().contains('cão') &&
                !animal.especie.toLowerCase().contains('gato'))
            .toList();

      case 'todos':
      default:
        return animals;
    }
  }

  // Filter animals by age range
  static List<Animal> filterByAge(
      List<Animal> animals, int? minAge, int? maxAge) {
    if (minAge == null && maxAge == null) return animals;

    return animals.where((animal) {
      final age = _getAnimalAge(animal.dataNascimento);
      if (minAge != null && age < minAge) return false;
      if (maxAge != null && age > maxAge) return false;
      return true;
    }).toList();
  }

  // Combined search and filter
  static List<Animal> searchAndFilter({
    required List<Animal> animals,
    String searchQuery = '',
    String filterType = 'todos',
    int? minAge,
    int? maxAge,
  }) {
    var filtered = List<Animal>.from(animals);

    // Apply search first
    filtered = searchAnimals(filtered, searchQuery);

    // Apply type filter
    filtered = filterByType(filtered, filterType);

    // Apply age filter
    filtered = filterByAge(filtered, minAge, maxAge);

    return filtered;
  }

  // Sort animals by different criteria
  static List<Animal> sortAnimals(List<Animal> animals, String sortBy,
      {bool ascending = true}) {
    final sorted = List<Animal>.from(animals);

    switch (sortBy.toLowerCase()) {
      case 'nome':
        sorted.sort((a, b) =>
            ascending ? a.nome.compareTo(b.nome) : b.nome.compareTo(a.nome));
        break;

      case 'idade':
        sorted.sort((a, b) {
          final ageA = _getAnimalAge(a.dataNascimento);
          final ageB = _getAnimalAge(b.dataNascimento);
          return ascending ? ageA.compareTo(ageB) : ageB.compareTo(ageA);
        });
        break;

      case 'especie':
        sorted.sort((a, b) => ascending
            ? a.especie.compareTo(b.especie)
            : b.especie.compareTo(a.especie));
        break;

      case 'data_nascimento':
        sorted.sort((a, b) => ascending
            ? a.dataNascimento.compareTo(b.dataNascimento)
            : b.dataNascimento.compareTo(a.dataNascimento));
        break;

      case 'data_criacao':
        sorted.sort((a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;

      default:
        // Default sort by name
        sorted.sort((a, b) =>
            ascending ? a.nome.compareTo(b.nome) : b.nome.compareTo(a.nome));
    }

    return sorted;
  }

  // Get search suggestions based on existing animals
  static List<String> getSearchSuggestions(List<Animal> animals, String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>{};
    final searchQuery = query.toLowerCase();

    for (final animal in animals) {
      // Add name suggestions
      if (animal.nome.toLowerCase().contains(searchQuery)) {
        suggestions.add(animal.nome);
      }

      // Add species suggestions
      if (animal.especie.toLowerCase().contains(searchQuery)) {
        suggestions.add(animal.especie);
      }

      // Add breed suggestions
      if (animal.raca.toLowerCase().contains(searchQuery)) {
        suggestions.add(animal.raca);
      }

      // Add color suggestions
      if (animal.cor.toLowerCase().contains(searchQuery)) {
        suggestions.add(animal.cor);
      }
    }

    return suggestions.toList()..sort();
  }

  // Get filter counts for UI
  static Map<String, int> getFilterCounts(List<Animal> animals) {
    int cachorros = 0;
    int gatos = 0;
    int outros = 0;

    for (final animal in animals) {
      final especie = animal.especie.toLowerCase();
      if (especie.contains('cachorro') || especie.contains('cão')) {
        cachorros++;
      } else if (especie.contains('gato')) {
        gatos++;
      } else {
        outros++;
      }
    }

    return {
      'todos': animals.length,
      'cachorros': cachorros,
      'gatos': gatos,
      'outros': outros,
    };
  }

  // Check if search has results
  static bool hasSearchResults(List<Animal> animals, String query) {
    return searchAnimals(animals, query).isNotEmpty;
  }

  // Get most popular search terms (based on animal data)
  static List<String> getPopularSearchTerms(List<Animal> animals) {
    final terms = <String, int>{};

    for (final animal in animals) {
      // Count species
      terms[animal.especie] = (terms[animal.especie] ?? 0) + 1;

      // Count breeds
      terms[animal.raca] = (terms[animal.raca] ?? 0) + 1;

      // Count colors
      terms[animal.cor] = (terms[animal.cor] ?? 0) + 1;
    }

    // Sort by frequency and return top terms
    final sortedTerms = terms.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTerms.take(10).map((e) => e.key).toList();
  }

  // Helper method to calculate animal age in years
  static int _getAnimalAge(int dataNascimento) {
    final birthDate = DateTime.fromMillisecondsSinceEpoch(dataNascimento);
    final now = DateTime.now();

    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
