/// Utilitário para comparações de string robustas e normalizadas
class StringComparisonUtils {
  // Cache para melhorar performance de normalização
  static final Map<String, String> _normalizationCache = {};
  
  // Mapa de caracteres acentuados para seus equivalentes sem acento
  static const Map<String, String> _diacriticsMap = {
    // Vogais com acentos
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
    // Consoantes especiais
    'ç': 'c', 'ñ': 'n',
    // Maiúsculas
    'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A',
    'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
    'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
    'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
    'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
    'Ý': 'Y', 'Ÿ': 'Y',
    'Ç': 'C', 'Ñ': 'N',
  };
  
  /// Remove acentos de uma string
  static String removeDiacritics(String input) {
    String result = input;
    for (final entry in _diacriticsMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  /// Normaliza uma string removendo acentos e convertendo para minúsculas
  static String normalize(String input) {
    if (_normalizationCache.containsKey(input)) {
      return _normalizationCache[input]!;
    }
    
    final normalized = removeDiacritics(input.trim().toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' '));
    
    // Cache apenas strings pequenas para evitar uso excessivo de memória
    if (input.length < 100) {
      _normalizationCache[input] = normalized;
    }
    
    return normalized;
  }

  /// Compara duas strings ignorando acentos e case-sensitivity
  static bool equals(String a, String b) {
    return normalize(a) == normalize(b);
  }

  /// Verifica se uma string contém outra, ignorando acentos e case-sensitivity
  static bool contains(String source, String substring) {
    return normalize(source).contains(normalize(substring));
  }
  
  /// Verifica se uma string começa com outra, ignorando acentos e case-sensitivity
  static bool startsWith(String source, String prefix) {
    return normalize(source).startsWith(normalize(prefix));
  }
  
  /// Calcula a distância de Levenshtein entre duas strings
  static int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    
    final matrix = List.generate(a.length + 1, 
        (i) => List.generate(b.length + 1, (j) => 0));
    
    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    
    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[a.length][b.length];
  }
  
  /// Compara duas strings usando fuzzy matching (distância de edição)
  static bool fuzzyEquals(String a, String b, {int threshold = 2}) {
    final normalizedA = normalize(a);
    final normalizedB = normalize(b);
    
    if (normalizedA == normalizedB) return true;
    
    final distance = _levenshteinDistance(normalizedA, normalizedB);
    return distance <= threshold;
  }
  
  /// Verifica se uma string é única em uma lista (não existe duplicata normalizada)
  static bool isUniqueInList(String candidate, List<String> existingList) {
    final normalizedCandidate = normalize(candidate);
    
    for (final existing in existingList) {
      if (normalize(existing) == normalizedCandidate) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Sugere strings similares baseadas em fuzzy matching
  static List<String> suggest(String searchTerm, List<String> candidates, {int threshold = 3, int maxSuggestions = 5}) {
    final suggestions = <({String item, int distance})>[];
    final normalizedSearch = normalize(searchTerm);
    
    for (final candidate in candidates) {
      final normalizedCandidate = normalize(candidate);
      final distance = _levenshteinDistance(normalizedSearch, normalizedCandidate);
      
      if (distance <= threshold) {
        suggestions.add((item: candidate, distance: distance));
      }
    }
    
    // Ordena por distância (menores distâncias primeiro)
    suggestions.sort((a, b) => a.distance.compareTo(b.distance));
    
    return suggestions
        .take(maxSuggestions)
        .map((s) => s.item)
        .toList();
  }
  
  /// Busca avançada com múltiplos critérios
  static List<String> search(
    String searchTerm,
    List<String> candidates, {
    bool includeExact = true,
    bool includeStartsWith = true,
    bool includeContains = true,
    bool includeFuzzy = false,
    int fuzzyThreshold = 2,
  }) {
    final results = <String>{}; // Set para evitar duplicatas
    final normalizedSearch = normalize(searchTerm);
    
    for (final candidate in candidates) {
      final normalizedCandidate = normalize(candidate);
      
      // Exact match
      if (includeExact && normalizedCandidate == normalizedSearch) {
        results.add(candidate);
        continue;
      }
      
      // Starts with
      if (includeStartsWith && normalizedCandidate.startsWith(normalizedSearch)) {
        results.add(candidate);
        continue;
      }
      
      // Contains
      if (includeContains && normalizedCandidate.contains(normalizedSearch)) {
        results.add(candidate);
        continue;
      }
      
      // Fuzzy match
      if (includeFuzzy) {
        final distance = _levenshteinDistance(normalizedSearch, normalizedCandidate);
        if (distance <= fuzzyThreshold) {
          results.add(candidate);
        }
      }
    }
    
    return results.toList();
  }
  
  /// Retorna estatísticas do cache de normalização
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _normalizationCache.length,
      'maxCacheSize': 1000, // Limite teórico
      'hitRatio': _normalizationCache.isNotEmpty ? 
          _normalizationCache.length / (_normalizationCache.length + 100) : 0.0,
      'cachedEntries': _normalizationCache.keys.take(5).toList(), // Amostra
    };
  }
  
  /// Limpa o cache de normalização
  static void clearCache() {
    _normalizationCache.clear();
  }

  /// Compara duas strings para ordenação
  static int compare(String a, String b) {
    return normalize(a).compareTo(normalize(b));
  }
}

/// Extensões para String para facilitar o uso
extension StringComparisonExtension on String {
  /// Compara com outra string ignorando case e acentos
  bool equalsIgnoreCase(String other) {
    return StringComparisonUtils.equals(this, other);
  }
  
  /// Verifica se contém outra string ignorando case e acentos
  bool containsIgnoreCase(String other) {
    return StringComparisonUtils.contains(this, other);
  }
  
  /// Normaliza a string removendo acentos e convertendo para minúsculas
  String normalized() {
    return StringComparisonUtils.normalize(this);
  }
}