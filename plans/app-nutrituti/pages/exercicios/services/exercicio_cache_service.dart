// Project imports:
import '../constants/exercicio_constants.dart';
import '../models/exercicio_model.dart';

/// Service responsável por cache e memoização de dados de exercícios
class ExercicioCacheService {
  // Cache para estatísticas calculadas
  static final Map<String, dynamic> _statisticsCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache para totais semanais
  static Map<String, int>? _weeklyTotalsCache;
  static DateTime? _weeklyTotalsTimestamp;
  static String? _weeklyTotalsHash;

  // Cache para dados de gráfico
  static Map<DateTime, Map<String, int>>? _chartDataCache;
  static DateTime? _chartDataTimestamp;
  static String? _chartDataHash;

  // Cache para eventos do calendário
  static Map<DateTime, List<ExercicioModel>>? _eventsCache;
  static DateTime? _eventsTimestamp;
  static String? _eventsHash;

  // Configurações de cache
  static const Duration _cacheExpiry = Duration(minutes: ExercicioConstants.cacheExpiryMinutes);

  /// Limpa todo o cache
  static void clearAll() {
    _statisticsCache.clear();
    _cacheTimestamps.clear();
    _weeklyTotalsCache = null;
    _weeklyTotalsTimestamp = null;
    _weeklyTotalsHash = null;
    _chartDataCache = null;
    _chartDataTimestamp = null;
    _chartDataHash = null;
    _eventsCache = null;
    _eventsTimestamp = null;
    _eventsHash = null;
  }

  /// Gera hash dos registros para detectar mudanças
  static String _generateHash(List<ExercicioModel> registros) {
    if (registros.isEmpty) return 'empty';
    
    final buffer = StringBuffer();
    for (final registro in registros) {
      buffer.write('${registro.id}_${registro.dataRegistro}_${registro.duracao}_${registro.caloriasQueimadas}');
    }
    return buffer.toString().hashCode.toString();
  }

  /// Cache para totais semanais
  static Map<String, int>? getCachedWeeklyTotals(List<ExercicioModel> registros) {
    final hash = _generateHash(registros);
    final now = DateTime.now();

    if (_weeklyTotalsCache != null &&
        _weeklyTotalsHash == hash &&
        _weeklyTotalsTimestamp != null &&
        now.difference(_weeklyTotalsTimestamp!).inMinutes < _cacheExpiry.inMinutes) {
      return _weeklyTotalsCache;
    }

    return null;
  }

  static void setCachedWeeklyTotals(List<ExercicioModel> registros, Map<String, int> totals) {
    _weeklyTotalsCache = Map.from(totals);
    _weeklyTotalsHash = _generateHash(registros);
    _weeklyTotalsTimestamp = DateTime.now();
  }

  /// Cache para dados do gráfico
  static Map<DateTime, Map<String, int>>? getCachedChartData(List<ExercicioModel> registros) {
    final hash = _generateHash(registros);
    final now = DateTime.now();

    if (_chartDataCache != null &&
        _chartDataHash == hash &&
        _chartDataTimestamp != null &&
        now.difference(_chartDataTimestamp!).inMinutes < _cacheExpiry.inMinutes) {
      return _chartDataCache;
    }

    return null;
  }

  static void setCachedChartData(List<ExercicioModel> registros, Map<DateTime, Map<String, int>> data) {
    _chartDataCache = Map.from(data);
    _chartDataHash = _generateHash(registros);
    _chartDataTimestamp = DateTime.now();
  }

  /// Cache para eventos do calendário
  static Map<DateTime, List<ExercicioModel>>? getCachedEvents(List<ExercicioModel> registros) {
    final hash = _generateHash(registros);
    final now = DateTime.now();

    if (_eventsCache != null &&
        _eventsHash == hash &&
        _eventsTimestamp != null &&
        now.difference(_eventsTimestamp!).inMinutes < _cacheExpiry.inMinutes) {
      return _eventsCache;
    }

    return null;
  }

  static void setCachedEvents(List<ExercicioModel> registros, Map<DateTime, List<ExercicioModel>> events) {
    _eventsCache = Map.from(events);
    _eventsHash = _generateHash(registros);
    _eventsTimestamp = DateTime.now();
  }

  /// Cache genérico para estatísticas
  static T? getCachedStatistic<T>(String key) {
    final now = DateTime.now();
    final timestamp = _cacheTimestamps[key];

    if (timestamp != null && 
        now.difference(timestamp).inMinutes < _cacheExpiry.inMinutes &&
        _statisticsCache.containsKey(key)) {
      return _statisticsCache[key] as T?;
    }

    return null;
  }

  static void setCachedStatistic<T>(String key, T value) {
    // Limitar tamanho do cache
    if (_statisticsCache.length >= ExercicioConstants.maxCacheSize) {
      _cleanupOldEntries();
    }

    _statisticsCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Remove entradas antigas do cache
  static void _cleanupOldEntries() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp).inMinutes >= _cacheExpiry.inMinutes) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _statisticsCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Cache para validação de streak
  static bool? getCachedStreakValidation(List<ExercicioModel> registros, int dias) {
    final key = 'streak_${_generateHash(registros)}_$dias';
    return getCachedStatistic<bool>(key);
  }

  static void setCachedStreakValidation(List<ExercicioModel> registros, int dias, bool result) {
    final key = 'streak_${_generateHash(registros)}_$dias';
    setCachedStatistic(key, result);
  }

  /// Cache para estatísticas gerais
  static Map<String, dynamic>? getCachedGeneralStats(List<ExercicioModel> registros) {
    final key = 'general_stats_${_generateHash(registros)}';
    return getCachedStatistic<Map<String, dynamic>>(key);
  }

  static void setCachedGeneralStats(List<ExercicioModel> registros, Map<String, dynamic> stats) {
    final key = 'general_stats_${_generateHash(registros)}';
    setCachedStatistic(key, Map.from(stats));
  }

  /// Cache para conquistas
  static List<dynamic>? getCachedAchievements(
    List<ExercicioModel> registros, 
    double metaMinutos, 
    double metaCalorias
  ) {
    final key = 'achievements_${_generateHash(registros)}_${metaMinutos}_$metaCalorias';
    return getCachedStatistic<List<dynamic>>(key);
  }

  static void setCachedAchievements(
    List<ExercicioModel> registros, 
    double metaMinutos, 
    double metaCalorias,
    List<dynamic> achievements
  ) {
    final key = 'achievements_${_generateHash(registros)}_${metaMinutos}_$metaCalorias';
    setCachedStatistic(key, List.from(achievements));
  }

  /// Invalida caches relacionados quando dados mudam
  static void invalidateOnDataChange() {
    _weeklyTotalsCache = null;
    _chartDataCache = null;
    _eventsCache = null;
    // Manter cache de estatísticas por mais tempo, apenas limpar por hash
  }

  /// Obtém informações do cache para debug
  static Map<String, dynamic> getCacheInfo() {
    final now = DateTime.now();
    int validEntries = 0;
    int expiredEntries = 0;

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp).inMinutes < _cacheExpiry.inMinutes) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    });

    return {
      'totalEntries': _statisticsCache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'weeklyTotalsCached': _weeklyTotalsCache != null,
      'chartDataCached': _chartDataCache != null,
      'eventsCached': _eventsCache != null,
      'cacheExpiry': _cacheExpiry.inMinutes,
    };
  }
}
