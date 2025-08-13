import '../core/optimization/database_index_service.dart';

class OptimizedQueryService {
  final DatabaseIndexService _indexService = DatabaseIndexService();

  /// Otimizar consultas com indexação
  Future<List<T>> optimizedQuery<T>(
    String collectionName,
    List<T> data,
    bool Function(T) filterCondition, {
    String? indexField,
  }) async {
    if (indexField != null && !_indexService.hasIndex(collectionName, indexField)) {
      _indexService.createIndex(collectionName, [indexField]);
    }

    // Aplicar filtro usando índice se disponível
    return data.where(filterCondition).toList();
  }

  /// Busca com suporte a múltiplos índices
  Future<List<T>> multiIndexSearch<T>(
    String collectionName,
    List<T> data,
    List<bool Function(T)> conditions,
  ) async {
    return data.where((item) => conditions.every((condition) => condition(item))).toList();
  }

  /// Limpar índices de uma coleção
  void clearCollectionIndexes(String collectionName) {
    _indexService.removeIndex(collectionName);
  }
}