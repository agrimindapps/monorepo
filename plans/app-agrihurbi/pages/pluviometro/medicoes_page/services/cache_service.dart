// Project imports:
import '../../../../models/medicoes_models.dart';
import '../model/medicoes_page_model.dart';

/// Service responsável por cache e memoização de cálculos custosos
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  /// Cache para estatísticas de mês
  final Map<String, _CacheEntry<MonthStatistics>> _monthStatsCache = {};

  /// Cache para formatações
  final Map<String, _CacheEntry<String>> _formattingCache = {};

  /// Cache para cálculos gerais
  final Map<String, _CacheEntry<dynamic>> _generalCache = {};

  /// Cache para lista de meses
  final Map<String, _CacheEntry<List<DateTime>>> _monthsListCache = {};

  /// TTL padrão para cache (5 minutos)
  static const Duration _defaultTTL = Duration(minutes: 5);

  /// TTL curto para formatações (1 minuto)
  static const Duration _shortTTL = Duration(minutes: 1);

  /// TTL longo para dados estáticos (30 minutos)
  static const Duration _longTTL = Duration(minutes: 30);

  /// Obtém estatísticas do mês com cache
  MonthStatistics? getCachedMonthStatistics(
      DateTime date, List<Medicoes> medicoes) {
    final key = _generateMonthStatsKey(date, medicoes);
    final cached = _monthStatsCache[key];

    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    return null;
  }

  /// Armazena estatísticas do mês no cache
  void cacheMonthStatistics(
      DateTime date, List<Medicoes> medicoes, MonthStatistics stats) {
    final key = _generateMonthStatsKey(date, medicoes);
    _monthStatsCache[key] = _CacheEntry(stats, _defaultTTL);
    _cleanupExpiredEntries(_monthStatsCache);
  }

  /// Obtém formatação com cache
  String? getCachedFormatting(String input, String operation) {
    final key = '${operation}_$input';
    final cached = _formattingCache[key];

    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    return null;
  }

  /// Armazena formatação no cache
  void cacheFormatting(String input, String operation, String result) {
    final key = '${operation}_$input';
    _formattingCache[key] = _CacheEntry(result, _shortTTL);
    _cleanupExpiredEntries(_formattingCache);
  }

  /// Obtém lista de meses com cache
  List<DateTime>? getCachedMonthsList(List<Medicoes> medicoes) {
    final key = _generateMedicoesKey(medicoes);
    final cached = _monthsListCache[key];

    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    return null;
  }

  /// Armazena lista de meses no cache
  void cacheMonthsList(List<Medicoes> medicoes, List<DateTime> months) {
    final key = _generateMedicoesKey(medicoes);
    _monthsListCache[key] = _CacheEntry(months, _longTTL);
    _cleanupExpiredEntries(_monthsListCache);
  }

  /// Cache genérico com TTL customizado
  T? getCached<T>(String key) {
    final cached = _generalCache[key];

    if (cached != null && !cached.isExpired) {
      return cached.value as T?;
    }

    return null;
  }

  /// Armazena no cache genérico
  void cache<T>(String key, T value, {Duration? ttl}) {
    _generalCache[key] = _CacheEntry(value, ttl ?? _defaultTTL);
    _cleanupExpiredEntries(_generalCache);
  }

  /// Memoização para funções computacionalmente custosas
  T memoize<T>(String key, T Function() computation, {Duration? ttl}) {
    final cached = getCached<T>(key);
    if (cached != null) {
      return cached;
    }

    final result = computation();
    cache(key, result, ttl: ttl);
    return result;
  }

  /// Invalidação específica por chave
  void invalidate(String key) {
    _generalCache.remove(key);
    _formattingCache.remove(key);
    _monthStatsCache.remove(key);
    _monthsListCache.remove(key);
  }

  /// Invalidação por padrão
  void invalidatePattern(String pattern) {
    _invalidateMapByPattern(_generalCache, pattern);
    _invalidateMapByPattern(_formattingCache, pattern);
    _invalidateMapByPattern(_monthStatsCache, pattern);
    _invalidateMapByPattern(_monthsListCache, pattern);
  }

  /// Invalidação de dados de um pluviômetro específico
  void invalidatePluviometro(String pluviometroId) {
    invalidatePattern('pluviometro_$pluviometroId');
    invalidatePattern('stats_${pluviometroId}_');
    invalidatePattern('months_${pluviometroId}_');
  }

  /// Invalidação de dados de uma data específica
  void invalidateDate(DateTime date) {
    final dateKey = '${date.year}_${date.month}_${date.day}';
    invalidatePattern(dateKey);
  }

  /// Limpeza completa do cache
  void clearAll() {
    _generalCache.clear();
    _formattingCache.clear();
    _monthStatsCache.clear();
    _monthsListCache.clear();
  }

  /// Limpeza automática de entradas expiradas
  void _cleanupExpiredEntries<T>(Map<String, _CacheEntry<T>> cache) {
    if (cache.length > 100) {
      // Cleanup quando cache fica muito grande
      cache.removeWhere((key, entry) => entry.isExpired);
    }
  }

  /// Invalidação por padrão em um mapa específico
  void _invalidateMapByPattern<T>(
      Map<String, _CacheEntry<T>> cache, String pattern) {
    cache.removeWhere((key, value) => key.contains(pattern));
  }

  /// Gera chave única para estatísticas de mês
  String _generateMonthStatsKey(DateTime date, List<Medicoes> medicoes) {
    final dateKey = '${date.year}_${date.month}';
    final medicoesHash = medicoes.length.toString() +
        medicoes.fold(0.0, (sum, m) => sum + m.quantidade).toString();
    return 'stats_${dateKey}_$medicoesHash';
  }

  /// Gera chave única para lista de medições
  String _generateMedicoesKey(List<Medicoes> medicoes) {
    if (medicoes.isEmpty) return 'empty_medicoes';

    final hash = medicoes.length.toString() +
        medicoes.first.fkPluviometro +
        medicoes.fold(0, (sum, m) => sum + m.dtMedicao).toString();
    return 'medicoes_$hash';
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStats() {
    return {
      'monthStats': _monthStatsCache.length,
      'formatting': _formattingCache.length,
      'general': _generalCache.length,
      'monthsList': _monthsListCache.length,
      'totalEntries': _monthStatsCache.length +
          _formattingCache.length +
          _generalCache.length +
          _monthsListCache.length,
    };
  }
}

/// Entrada de cache com TTL
class _CacheEntry<T> {
  final T value;
  final DateTime expiry;

  _CacheEntry(this.value, Duration ttl) : expiry = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Mixin para classes que querem usar cache facilmente
mixin CacheableMixin {
  final CacheService _cache = CacheService();

  /// Memoização simplificada
  T memoize<T>(String key, T Function() computation, {Duration? ttl}) {
    return _cache.memoize(key, computation, ttl: ttl);
  }

  /// Invalidação simplificada
  void invalidateCache(String pattern) {
    _cache.invalidatePattern(pattern);
  }
}

/// Decorator para funções computacionalmente custosas
class MemoizedFunction<T> {
  final T Function() _function;
  final String _key;
  final Duration? _ttl;
  final CacheService _cache = CacheService();

  MemoizedFunction(this._function, this._key, {Duration? ttl}) : _ttl = ttl;

  T call() {
    return _cache.memoize(_key, _function, ttl: _ttl);
  }

  void invalidate() {
    _cache.invalidate(_key);
  }
}
