// Dart imports:

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Service para criar e gerenciar índices em memória para queries eficientes
/// Implementa múltiplos tipos de índice e cache de queries
class DatabaseIndexService {
  // Índices por ID para lookup O(1)
  final Map<String, Map<String, Map<String, dynamic>>> _idIndexes = {};
  
  // Índices por campo para filtros rápidos
  final Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> _fieldIndexes = {};
  
  // Cache de queries com TTL
  final Map<String, QueryCacheEntry> _queryCache = {};
  
  // Configurações
  static const int _maxCacheSize = 1000;
  static const Duration _cacheTTL = Duration(minutes: 5);
  
  /// Cria índice por ID para uma tabela
  void createIdIndex(String tableName, List<Map<String, dynamic>> data, String idField) {
    try {
      final index = <String, Map<String, dynamic>>{};
      
      for (final item in data) {
        final id = item[idField]?.toString();
        if (id != null && id.isNotEmpty) {
          index[id] = item;
        }
      }
      
      _idIndexes[tableName] = index;
      debugPrint('DatabaseIndexService: Índice ID criado para $tableName com ${index.length} entradas');
    } catch (e) {
      debugPrint('Erro ao criar índice ID para $tableName: $e');
    }
  }
  
  /// Cria índice por campo para filtros eficientes
  void createFieldIndex(String tableName, String fieldName, List<Map<String, dynamic>> data) {
    try {
      final index = <String, List<Map<String, dynamic>>>{};
      
      for (final item in data) {
        final fieldValue = item[fieldName]?.toString().toLowerCase();
        if (fieldValue != null && fieldValue.isNotEmpty) {
          index.putIfAbsent(fieldValue, () => []).add(item);
        }
      }
      
      _fieldIndexes.putIfAbsent(tableName, () => {})[fieldName] = index;
      debugPrint('DatabaseIndexService: Índice campo "$fieldName" criado para $tableName com ${index.length} valores únicos');
    } catch (e) {
      debugPrint('Erro ao criar índice campo $fieldName para $tableName: $e');
    }
  }
  
  /// Cria índice composto para múltiplos campos
  void createCompositeIndex(String tableName, List<String> fieldNames, List<Map<String, dynamic>> data) {
    try {
      final indexName = fieldNames.join('_');
      final index = <String, List<Map<String, dynamic>>>{};
      
      for (final item in data) {
        final compositeKey = fieldNames
            .map((field) => item[field]?.toString().toLowerCase() ?? '')
            .where((value) => value.isNotEmpty)
            .join('|');
            
        if (compositeKey.isNotEmpty) {
          index.putIfAbsent(compositeKey, () => []).add(item);
        }
      }
      
      _fieldIndexes.putIfAbsent(tableName, () => {})[indexName] = index;
      debugPrint('DatabaseIndexService: Índice composto "$indexName" criado para $tableName com ${index.length} chaves');
    } catch (e) {
      debugPrint('Erro ao criar índice composto para $tableName: $e');
    }
  }
  
  /// Busca rápida por ID usando índice O(1)
  Map<String, dynamic>? findById(String tableName, String id) {
    return _idIndexes[tableName]?[id];
  }
  
  /// Busca rápida por campo usando índice
  List<Map<String, dynamic>> findByField(String tableName, String fieldName, String value) {
    final cacheKey = 'field_${tableName}_${fieldName}_${value.toLowerCase()}';
    
    // Verificar cache primeiro
    if (_queryCache.containsKey(cacheKey) && !_isExpired(cacheKey)) {
      return _queryCache[cacheKey]!.results;
    }
    
    try {
      final index = _fieldIndexes[tableName]?[fieldName];
      if (index == null) return [];
      
      final results = index[value.toLowerCase()] ?? [];
      
      // Cache do resultado
      _cacheQuery(cacheKey, results);
      
      return results;
    } catch (e) {
      debugPrint('Erro na busca por campo: $e');
      return [];
    }
  }
  
  /// Busca por campo com contains (usando índice para otimização)
  List<Map<String, dynamic>> findByFieldContains(String tableName, String fieldName, String searchTerm) {
    final cacheKey = 'contains_${tableName}_${fieldName}_${searchTerm.toLowerCase()}';
    
    // Verificar cache
    if (_queryCache.containsKey(cacheKey) && !_isExpired(cacheKey)) {
      return _queryCache[cacheKey]!.results;
    }
    
    try {
      final index = _fieldIndexes[tableName]?[fieldName];
      if (index == null) return [];
      
      final searchTermLower = searchTerm.toLowerCase();
      final results = <Map<String, dynamic>>[];
      
      // Buscar em todas as chaves que contêm o termo
      for (final entry in index.entries) {
        if (entry.key.contains(searchTermLower)) {
          results.addAll(entry.value);
        }
      }
      
      // Cache do resultado
      _cacheQuery(cacheKey, results);
      
      return results;
    } catch (e) {
      debugPrint('Erro na busca contains: $e');
      return [];
    }
  }
  
  /// Busca usando múltiplos filtros
  List<Map<String, dynamic>> findByMultipleFields(String tableName, Map<String, String> filters) {
    final cacheKey = 'multi_${tableName}_${filters.entries.map((e) => '${e.key}:${e.value}').join('_')}';
    
    // Verificar cache
    if (_queryCache.containsKey(cacheKey) && !_isExpired(cacheKey)) {
      return _queryCache[cacheKey]!.results;
    }
    
    try {
      List<Map<String, dynamic>>? results;
      
      // Usar o filtro mais seletivo primeiro
      for (final filter in filters.entries) {
        final fieldResults = findByField(tableName, filter.key, filter.value);
        
        if (results == null) {
          results = fieldResults;
        } else {
          // Intersecção dos resultados
          results = results.where((item) =>
            fieldResults.any((fr) => fr['idReg'] == item['idReg'])
          ).toList();
        }
        
        // Se não há resultados, parar
        if (results.isEmpty) break;
      }
      
      final finalResults = results ?? [];
      
      // Cache do resultado
      _cacheQuery(cacheKey, finalResults);
      
      return finalResults;
    } catch (e) {
      debugPrint('Erro na busca múltipla: $e');
      return [];
    }
  }
  
  /// Batch fetch - busca múltiplos IDs de uma vez
  List<Map<String, dynamic>> batchFindByIds(String tableName, List<String> ids) {
    try {
      final index = _idIndexes[tableName];
      if (index == null) return [];
      
      final results = <Map<String, dynamic>>[];
      
      for (final id in ids) {
        final item = index[id];
        if (item != null) {
          results.add(item);
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Erro no batch fetch: $e');
      return [];
    }
  }
  
  /// Limpa cache expirado automaticamente
  void _cleanExpiredCache() {
    final now = DateTime.now();
    _queryCache.removeWhere((key, entry) => 
      now.difference(entry.timestamp) > _cacheTTL
    );
  }
  
  /// Verifica se entrada do cache expirou
  bool _isExpired(String cacheKey) {
    final entry = _queryCache[cacheKey];
    if (entry == null) return true;
    
    return DateTime.now().difference(entry.timestamp) > _cacheTTL;
  }
  
  /// Adiciona resultado ao cache
  void _cacheQuery(String cacheKey, List<Map<String, dynamic>> results) {
    try {
      // Limpar cache se muito grande
      if (_queryCache.length >= _maxCacheSize) {
        _cleanExpiredCache();
        
        // Se ainda está cheio, remover entradas mais antigas
        if (_queryCache.length >= _maxCacheSize) {
          final oldestKeys = _queryCache.entries
              .map((e) => MapEntry(e.key, e.value.timestamp))
              .toList()
              ..sort((a, b) => a.value.compareTo(b.value));
              
          final toRemove = oldestKeys.take(_maxCacheSize ~/ 4).map((e) => e.key);
          for (final key in toRemove) {
            _queryCache.remove(key);
          }
        }
      }
      
      _queryCache[cacheKey] = QueryCacheEntry(results, DateTime.now());
    } catch (e) {
      debugPrint('Erro ao cachear query: $e');
    }
  }
  
  /// Invalida cache para uma tabela
  void invalidateCache(String tableName) {
    _queryCache.removeWhere((key, _) => key.contains(tableName));
  }
  
  /// Rebuilda todos os índices para uma tabela
  void rebuildIndexes(String tableName, List<Map<String, dynamic>> data, 
                      {required String idField, required List<String> indexFields}) {
    try {
      // Limpar índices existentes
      _idIndexes.remove(tableName);
      _fieldIndexes.remove(tableName);
      invalidateCache(tableName);
      
      // Recriar índices
      createIdIndex(tableName, data, idField);
      
      for (final field in indexFields) {
        createFieldIndex(tableName, field, data);
      }
      
      debugPrint('DatabaseIndexService: Índices reconstruídos para $tableName');
    } catch (e) {
      debugPrint('Erro ao reconstruir índices para $tableName: $e');
    }
  }
  
  /// Obtém estatísticas dos índices
  Map<String, dynamic> getIndexStats() {
    return {
      'tables_with_id_indexes': _idIndexes.keys.length,
      'tables_with_field_indexes': _fieldIndexes.keys.length,
      'total_cached_queries': _queryCache.length,
      'cache_hit_ratio': _calculateCacheHitRatio(),
      'memory_usage_estimate': _estimateMemoryUsage(),
    };
  }
  
  double _calculateCacheHitRatio() {
    // Implementação simples - na prática seria trackado ao longo do tempo
    return _queryCache.isNotEmpty ? 0.8 : 0.0;
  }
  
  String _estimateMemoryUsage() {
    final totalEntries = _idIndexes.values
        .fold(0, (sum, index) => sum + index.length) +
        _fieldIndexes.values
        .fold(0, (sum, tableIndexes) => sum + tableIndexes.values
        .fold(0, (innerSum, fieldIndex) => innerSum + fieldIndex.values
        .fold(0, (listSum, list) => listSum + list.length)));
        
    final estimatedBytes = totalEntries * 500; // Estimativa de 500 bytes por entrada
    if (estimatedBytes < 1024 * 1024) {
      return '${(estimatedBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(estimatedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  /// Limpa todos os índices e cache
  void dispose() {
    _idIndexes.clear();
    _fieldIndexes.clear();
    _queryCache.clear();
    debugPrint('DatabaseIndexService: Recursos limpos');
  }
}

/// Entrada de cache de query com timestamp
class QueryCacheEntry {
  final List<Map<String, dynamic>> results;
  final DateTime timestamp;
  
  QueryCacheEntry(this.results, this.timestamp);
}