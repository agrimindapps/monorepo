

/// Gerenciamento de cache local para pragas por cultura
///
/// Responsabilidades:
/// - Armazenar pragas em cache (memória)
/// - Gerenciar expiração de cache (TTL)
/// - Limpar cache quando necessário
///
/// Estratégia: Cache é OPCIONAL e fire-and-forget
/// Não bloqueia operações principais se falhar
///
/// Nota: Cache é armazenado em memória durante a sessão
library;

class PragasCulturaLocalDataSource {
  static const String _cacheBoxName = 'pragas_cultura_cache';
  static const Duration _cacheDuration = Duration(hours: 24);

  // Cache em memória durante a sessão
  final Map<String, _CachedItem> _memoryCache = {};

  PragasCulturaLocalDataSource();

  /// Obtém pragas em cache para uma cultura
  ///
  /// [culturaId]: ID da cultura
  /// Returns: Lista de pragas em cache ou null se não houver ou expirou
  Future<List<dynamic>?> getCachedPragas(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return null;
      }

      // Verificar cache em memória
      final cached = _memoryCache[culturaId];
      if (cached != null && !cached.isExpired()) {
        return cached.pragas;
      }

      // Remover se expirou
      if (cached != null && cached.isExpired()) {
        _memoryCache.remove(culturaId);
      }

      return null;
    } catch (e) {
      // Falha silenciosa - cache não é crítico
      return null;
    }
  }

  /// Armazena pragas em cache localmente
  ///
  /// Operação fire-and-forget - não bloqueia
  /// [culturaId]: ID da cultura
  /// [pragas]: Lista de pragas para cachear
  Future<void> cachePragas(String culturaId, List<dynamic> pragas) async {
    try {
      if (culturaId.isEmpty) {
        return;
      }

      // Armazenar em memória com timestamp
      _memoryCache[culturaId] = _CachedItem(
        pragas: pragas,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Falha silenciosa - cache não é crítico
    }
  }

  /// Limpa cache para uma cultura específica
  ///
  /// [culturaId]: ID da cultura
  Future<void> clearCache(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return;
      }

      _memoryCache.remove(culturaId);
    } catch (e) {
      // Falha silenciosa
    }
  }

  /// Limpa todo o cache de pragas por cultura
  ///
  /// Útil para sincronização ou reset completo
  Future<void> clearAllCache() async {
    try {
      _memoryCache.clear();
    } catch (e) {
      // Falha silenciosa
    }
  }

  /// Verifica se existe cache válido para uma cultura
  ///
  /// [culturaId]: ID da cultura
  /// Returns: true se cache existe e ainda é válido
  Future<bool> hasCachedPragas(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return false;
      }

      final cached = await getCachedPragas(culturaId);
      return cached != null && cached.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações sobre o cache (debug/admin)
  ///
  /// Returns: Mapa com estatísticas de cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final stats = {
        'totalCached': _memoryCache.length,
        'boxName': _cacheBoxName,
        'cacheDuration': '${_cacheDuration.inHours} horas',
      };

      return stats;
    } catch (e) {
      return {
        'error': 'Erro ao obter estatísticas de cache: $e',
      };
    }
  }
}

/// Classe interna para armazenar item em cache com timestamp
class _CachedItem {
  final List<dynamic> pragas;
  final DateTime timestamp;

  _CachedItem({
    required this.pragas,
    required this.timestamp,
  });

  bool isExpired() {
    const cacheDuration = Duration(hours: 24);
    return DateTime.now().difference(timestamp) > cacheDuration;
  }
}
