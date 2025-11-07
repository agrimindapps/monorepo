/// Service especializado para cache em memória de favoritos
/// Responsabilidade: Cache simples com TTL de 5 minutos
class FavoritosCacheServiceInline {
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  /// TTL do cache em minutos
  static const int _cacheTtlMinutes = 5;

  /// Obtém um valor do cache
  ///
  /// Retorna null se:
  /// - Chave não existe
  /// - Cache expirou (>5 minutos)
  Future<T?> get<T>(String key) async {
    try {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null) {
        if (DateTime.now().difference(timestamp).inMinutes > _cacheTtlMinutes) {
          await remove(key);
          return null;
        }
      }

      return _memoryCache[key] as T?;
    } catch (e) {
      return null;
    }
  }

  /// Adiciona um valor ao cache
  Future<void> put<T>(String key, T data) async {
    try {
      _memoryCache[key] = data;
      _cacheTimestamps[key] = DateTime.now();
    } catch (e) {
      // Silently fail
    }
  }

  /// Remove um valor do cache
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    } catch (e) {
      // Silently fail
    }
  }

  /// Limpa cache para um tipo específico
  ///
  /// Remove todas as entradas que contêm 'resolve_{tipo}_' na chave
  Future<void> clearForTipo(String tipo) async {
    try {
      final keysToRemove = _memoryCache.keys
          .where((key) => key.contains('resolve_${tipo}_'))
          .toList();

      for (final key in keysToRemove) {
        await remove(key);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Limpa todo o cache
  Future<void> clearAll() async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();
    } catch (e) {
      // Silently fail
    }
  }

  /// Retorna o número de entradas no cache
  int get size => _memoryCache.length;

  /// Verifica se uma chave existe no cache (válida)
  Future<bool> has(String key) async {
    final value = await get<Object?>(key);
    return value != null;
  }
}
