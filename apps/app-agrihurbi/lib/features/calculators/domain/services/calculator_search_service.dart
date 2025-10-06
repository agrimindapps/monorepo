import '../entities/calculator_category.dart';
import '../entities/calculator_entity.dart';

/// Critérios de busca combinados para execução em single-pass
class SearchCriteria {
  final String? query;
  final CalculatorCategory? category;
  final CalculatorComplexity? complexity;
  final List<String> tags;
  final CalculatorSortOrder sortOrder;
  final List<String> favoriteIds;
  final bool showOnlyFavorites;

  const SearchCriteria({
    this.query,
    this.category,
    this.complexity,
    this.tags = const [],
    this.sortOrder = CalculatorSortOrder.nameAsc,
    this.favoriteIds = const [],
    this.showOnlyFavorites = false,
  });
}

/// Serviço otimizado de busca com algoritmo single-pass O(n)
///
/// Substitui múltiplos filtros sequenciais por um único pass através dos dados,
/// reduzindo complexidade de O(n²) para O(n) + O(n log n) para ordenação.
class CalculatorSearchService {
  CalculatorSearchService._();

  /// Executa busca otimizada em single-pass
  /// 
  /// Combina todos os filtros em uma única iteração para melhor performance.
  /// Complexidade: O(n) para filtragem + O(n log n) para ordenação
  static List<CalculatorEntity> optimizedSearch(
    List<CalculatorEntity> items,
    SearchCriteria criteria,
  ) {
    final stopwatch = Stopwatch()..start();
    final filteredItems = items.where((item) {
      if (criteria.showOnlyFavorites && !criteria.favoriteIds.contains(item.id)) {
        return false;
      }
      if (criteria.category != null && item.category != criteria.category) {
        return false;
      }
      if (criteria.complexity != null && item.complexity != criteria.complexity!) {
        return false;
      }
      if (criteria.tags.isNotEmpty) {
        final hasRequiredTags = criteria.tags.every(
          (tag) => item.tags.contains(tag)
        );
        if (!hasRequiredTags) {
          return false;
        }
      }
      if (criteria.query != null && criteria.query!.trim().isNotEmpty) {
        return _matchesTextQuery(item, criteria.query!.toLowerCase());
      }
      
      return true;
    }).toList();
    
    stopwatch.stop();
    _sortCalculators(filteredItems, criteria.sortOrder);
    
    return filteredItems;
  }
  
  /// Verifica se item corresponde à query textual
  static bool _matchesTextQuery(CalculatorEntity item, String query) {
    final searchableText = [
      item.name,
      item.description,
      item.category.displayName,
      ...item.tags,
      ...item.parameters.map((p) => '${p.name} ${p.description}'),
    ].join(' ').toLowerCase();
    final queryWords = query.split(' ').where((w) => w.isNotEmpty).toList();
    
    return queryWords.every((word) => searchableText.contains(word));
  }
  
  /// Ordena lista in-place para melhor performance de memória
  static void _sortCalculators(List<CalculatorEntity> items, CalculatorSortOrder order) {
    switch (order) {
      case CalculatorSortOrder.nameAsc:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CalculatorSortOrder.nameDesc:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CalculatorSortOrder.categoryAsc:
        items.sort((a, b) {
          final categoryCompare = a.category.displayName.compareTo(b.category.displayName);
          return categoryCompare != 0 ? categoryCompare : a.name.compareTo(b.name);
        });
        break;
      case CalculatorSortOrder.complexityAsc:
        items.sort((a, b) {
          final complexityCompare = a.complexity.index.compareTo(b.complexity.index);
          return complexityCompare != 0 ? complexityCompare : a.name.compareTo(b.name);
        });
        break;
      case CalculatorSortOrder.complexityDesc:
        items.sort((a, b) {
          final complexityCompare = b.complexity.index.compareTo(a.complexity.index);
          return complexityCompare != 0 ? complexityCompare : a.name.compareTo(b.name);
        });
        break;
    }
  }
  
  @Deprecated('Use optimizedSearch com SearchCriteria para melhor performance')
  static List<CalculatorEntity> searchCalculators(
    List<CalculatorEntity> items,
    String query,
  ) {
    return optimizedSearch(items, SearchCriteria(query: query));
  }
  
  @Deprecated('Use optimizedSearch com SearchCriteria para melhor performance')
  static List<CalculatorEntity> filterByCategory(
    List<CalculatorEntity> items,
    CalculatorCategory? category,
  ) {
    return optimizedSearch(items, SearchCriteria(category: category));
  }
  
  @Deprecated('Use optimizedSearch com SearchCriteria para melhor performance')
  static List<CalculatorEntity> filterByComplexity(
    List<CalculatorEntity> items,
    CalculatorComplexity? complexity,
  ) {
    return optimizedSearch(items, SearchCriteria(complexity: complexity));
  }
  
  @Deprecated('Use optimizedSearch com SearchCriteria para melhor performance')
  static List<CalculatorEntity> filterByTags(
    List<CalculatorEntity> items,
    List<String> tags,
  ) {
    return optimizedSearch(items, SearchCriteria(tags: tags));
  }
  
  @Deprecated('Use optimizedSearch com SearchCriteria para melhor performance')
  static List<CalculatorEntity> sortCalculators(
    List<CalculatorEntity> items,
    CalculatorSortOrder order,
  ) {
    final result = List<CalculatorEntity>.from(items);
    _sortCalculators(result, order);
    return result;
  }
}

/// Enum para ordenação de calculadoras
enum CalculatorSortOrder {
  nameAsc,
  nameDesc,
  categoryAsc,
  complexityAsc,
  complexityDesc,
}
