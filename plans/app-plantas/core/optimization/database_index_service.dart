
class DatabaseIndexService {
  final Map<String, Set<String>> _indexes = {};

  /// Cria um índice para uma coleção
  void createIndex(String collectionName, List<String> fields) {
    _indexes[collectionName] = Set<String>.from(fields);
  }

  /// Verifica se um índice existe
  bool hasIndex(String collectionName, String field) {
    return _indexes.containsKey(collectionName) &&
        _indexes[collectionName]!.contains(field);
  }

  /// Adiciona um campo a um índice existente
  void addFieldToIndex(String collectionName, String field) {
    _indexes.putIfAbsent(collectionName, () => {}).add(field);
  }

  /// Remove um índice
  void removeIndex(String collectionName) {
    _indexes.remove(collectionName);
  }

  /// Lista todos os índices disponíveis
  Map<String, Set<String>> listIndexes() {
    return Map.unmodifiable(_indexes);
  }

  /// Limpa todos os índices
  void clearIndexes() {
    _indexes.clear();
  }
}