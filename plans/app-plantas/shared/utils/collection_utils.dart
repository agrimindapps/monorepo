/// Utilities para operações de coleção otimizadas
class CollectionUtils {
  /// Cache para listas ordenadas para evitar reordenação desnecessária
  static final Map<String, List<dynamic>> _sortedCache = {};

  /// Limpar cache de listas ordenadas
  static void clearSortCache() {
    _sortedCache.clear();
  }

  /// Ordenar lista com cache baseado em hash do conteúdo
  static List<T> cachedSort<T>(
    List<T> list,
    int Function(T a, T b) compare, {
    String? cacheKey,
  }) {
    if (cacheKey != null && _sortedCache.containsKey(cacheKey)) {
      return _sortedCache[cacheKey]!.cast<T>();
    }

    final sortedList = List<T>.from(list)..sort(compare);

    if (cacheKey != null) {
      _sortedCache[cacheKey] = sortedList;
    }

    return sortedList;
  }

  /// Filtrar e mapear em uma única passada (mais eficiente que where().map())
  static List<R> filterMap<T, R>(
    Iterable<T> source,
    R? Function(T item) mapper,
  ) {
    final result = <R>[];
    for (final item in source) {
      final mapped = mapper(item);
      if (mapped != null) {
        result.add(mapped);
      }
    }
    return result;
  }

  /// Filtrar por tipo de forma otimizada (usar whereType quando possível)
  static List<T> filterByType<T>(Iterable<dynamic> source) {
    return source.whereType<T>().toList();
  }

  /// Operação de busca otimizada para listas pequenas vs grandes
  static bool contains<T>(List<T> list, T item, {int threshold = 10}) {
    // Para listas pequenas, usar contains direto
    if (list.length <= threshold) {
      return list.contains(item);
    }

    // Para listas maiores, converter para Set se não for sorted
    return list.toSet().contains(item);
  }

  /// Remover duplicatas de forma eficiente
  static List<T> removeDuplicates<T>(Iterable<T> source) {
    if (source is List && source.length <= 10) {
      // Para listas pequenas, usar approach simples
      final result = <T>[];
      for (final item in source) {
        if (!result.contains(item)) {
          result.add(item);
        }
      }
      return result;
    }

    // Para listas maiores, usar Set
    return source.toSet().toList();
  }

  /// Agrupar elementos de forma eficiente
  static Map<K, List<V>> groupBy<T, K, V>(
    Iterable<T> source,
    K Function(T item) keySelector,
    V Function(T item) valueSelector,
  ) {
    final grouped = <K, List<V>>{};

    for (final item in source) {
      final key = keySelector(item);
      final value = valueSelector(item);

      grouped.putIfAbsent(key, () => <V>[]).add(value);
    }

    return grouped;
  }

  /// Partição de lista em chunks para processamento otimizado
  static List<List<T>> partition<T>(List<T> source, int chunkSize) {
    final chunks = <List<T>>[];

    for (int i = 0; i < source.length; i += chunkSize) {
      final end =
          (i + chunkSize < source.length) ? i + chunkSize : source.length;
      chunks.add(source.sublist(i, end));
    }

    return chunks;
  }

  /// Busca binária otimizada para listas ordenadas
  static int binarySearch<T extends Comparable<T>>(List<T> sortedList, T item) {
    int low = 0;
    int high = sortedList.length - 1;

    while (low <= high) {
      int mid = low + ((high - low) >> 1); // Evita overflow
      int cmp = sortedList[mid].compareTo(item);

      if (cmp == 0) return mid;
      if (cmp < 0) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return -(low + 1); // Retorna posição de inserção negativa se não encontrado
  }

  /// Merge de listas ordenadas de forma eficiente
  static List<T> mergeOrderedLists<T extends Comparable<T>>(
    List<T> list1,
    List<T> list2,
  ) {
    final result = <T>[];
    int i = 0, j = 0;

    while (i < list1.length && j < list2.length) {
      if (list1[i].compareTo(list2[j]) <= 0) {
        result.add(list1[i++]);
      } else {
        result.add(list2[j++]);
      }
    }

    // Adicionar elementos restantes
    while (i < list1.length) {
      result.add(list1[i++]);
    }
    while (j < list2.length) {
      result.add(list2[j++]);
    }

    return result;
  }
}

/// Extensions para operações de lista otimizadas
extension OptimizedList<T> on List<T> {
  /// Buscar elemento com early return
  T? findFirst(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Contar elementos sem criar lista intermediária
  int countWhere(bool Function(T element) test) {
    int count = 0;
    for (final element in this) {
      if (test(element)) count++;
    }
    return count;
  }

  /// Verificar se qualquer elemento satisfaz condição com early return
  bool anyWhere(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return true;
    }
    return false;
  }

  /// Verificar se todos elementos satisfazem condição com early return
  bool everyWhere(bool Function(T element) test) {
    for (final element in this) {
      if (!test(element)) return false;
    }
    return true;
  }

  /// Particionar lista baseada em predicado
  ({List<T> matching, List<T> notMatching}) partition(
      bool Function(T element) test) {
    final matching = <T>[];
    final notMatching = <T>[];

    for (final element in this) {
      if (test(element)) {
        matching.add(element);
      } else {
        notMatching.add(element);
      }
    }

    return (matching: matching, notMatching: notMatching);
  }

  /// Update in place para evitar criação de nova lista
  void updateWhere(
      bool Function(T element) test, T Function(T element) update) {
    for (int i = 0; i < length; i++) {
      if (test(this[i])) {
        this[i] = update(this[i]);
      }
    }
  }
}
