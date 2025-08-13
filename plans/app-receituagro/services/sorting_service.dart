/// Service responsável pela lógica de ordenação de listas
/// Centraliza diferentes estratégias de sorting que eram duplicadas nos controllers
class SortingService {
  
  /// Ordena uma lista por um campo específico
  List<T> sortList<T>(
    List<T> items,
    String sortField,
    bool isAscending,
    String Function(T) getLine1,
    String Function(T) getLine2,
  ) {
    if (items.isEmpty) return items;
    
    final sortedItems = List<T>.from(items);
    
    sortedItems.sort((a, b) {
      String valueA, valueB;
      
      switch (sortField) {
        case 'line1':
          valueA = getLine1(a);
          valueB = getLine1(b);
          break;
        case 'line2':
          valueA = getLine2(a);
          valueB = getLine2(b);
          break;
        default:
          valueA = getLine1(a);
          valueB = getLine1(b);
      }
      
      final comparison = valueA.toLowerCase().compareTo(valueB.toLowerCase());
      return isAscending ? comparison : -comparison;
    });
    
    return sortedItems;
  }
  
  /// Ordena lista por múltiplos critérios
  List<T> sortByMultipleCriteria<T>(
    List<T> items,
    List<({String field, bool ascending, String Function(T) getter})> criteria,
  ) {
    if (items.isEmpty || criteria.isEmpty) return items;
    
    final sortedItems = List<T>.from(items);
    
    sortedItems.sort((a, b) {
      for (final criterion in criteria) {
        final valueA = criterion.getter(a);
        final valueB = criterion.getter(b);
        
        final comparison = valueA.toLowerCase().compareTo(valueB.toLowerCase());
        final result = criterion.ascending ? comparison : -comparison;
        
        if (result != 0) return result;
      }
      return 0;
    });
    
    return sortedItems;
  }
  
  /// Ordena por relevância baseado em score
  List<T> sortByRelevance<T>(
    List<T> items,
    String searchTerm,
    String Function(T) getSearchableText,
  ) {
    if (items.isEmpty || searchTerm.trim().isEmpty) return items;
    
    final itemsWithScore = items.map((item) {
      final text = getSearchableText(item).toLowerCase();
      final term = searchTerm.toLowerCase();
      
      int score = 0;
      
      // Pontuação maior para matches exatos
      if (text == term) score += 100;
      
      // Pontuação para início da string
      if (text.startsWith(term)) score += 50;
      
      // Pontuação para palavra completa
      if (text.contains(' $term ')) score += 30;
      
      // Pontuação para substring
      if (text.contains(term)) score += 10;
      
      return (item: item, score: score);
    }).toList();
    
    // Ordena por score decrescente
    itemsWithScore.sort((a, b) => b.score.compareTo(a.score));
    
    return itemsWithScore.map((e) => e.item).toList();
  }
  
  /// Ordena numericamente (quando aplicável)
  List<T> sortNumerically<T>(
    List<T> items,
    double Function(T) getNumericValue,
    bool isAscending,
  ) {
    if (items.isEmpty) return items;
    
    final sortedItems = List<T>.from(items);
    
    sortedItems.sort((a, b) {
      final valueA = getNumericValue(a);
      final valueB = getNumericValue(b);
      
      final comparison = valueA.compareTo(valueB);
      return isAscending ? comparison : -comparison;
    });
    
    return sortedItems;
  }
  
  /// Ordena por data
  List<T> sortByDate<T>(
    List<T> items,
    DateTime Function(T) getDate,
    bool isAscending,
  ) {
    if (items.isEmpty) return items;
    
    final sortedItems = List<T>.from(items);
    
    sortedItems.sort((a, b) {
      final dateA = getDate(a);
      final dateB = getDate(b);
      
      final comparison = dateA.compareTo(dateB);
      return isAscending ? comparison : -comparison;
    });
    
    return sortedItems;
  }
}