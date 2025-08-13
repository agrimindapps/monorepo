import 'dart:async';

/// Transformers reutilizáveis para otimização de streams
///
/// Este arquivo implementa stream transformers otimizados que incluem:
/// - Stream caching com distinct()
/// - debounce para reduzir processamento
/// - switchMap para cancelar operações anteriores
/// - Transformers específicos para diferentes tipos de operações
class OptimizedStreamTransformers {
  /// Cache para armazenar últimos resultados de streams
  static final Map<String, dynamic> _streamCache = {};

  /// Timers para debounce por stream
  static final Map<String, Timer> _debounceTimers = {};

  /// Timer para limpeza de cache
  static Timer? _cacheCleanupTimer;

  /// Subscription ativa para switchMap
  static final Map<String, StreamSubscription> _activeSwitchSubscriptions = {};

  /// Inicializar cleanup automático do cache (30 minutos)
  static void _initCacheCleanup() {
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => clearCache(),
    );
  }

  /// Limpar todo o cache
  static void clearCache() {
    _streamCache.clear();
    // Cancelar timers de debounce
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Limpar cache específico por key
  static void clearCacheKey(String key) {
    _streamCache.remove(key);
  }

  /// Stream transformer com cache e distinct para listas
  static StreamTransformer<List<T>, List<T>> cachedDistinctList<T>({
    String? cacheKey,
    Duration debounceTime = const Duration(milliseconds: 300),
    bool Function(List<T> previous, List<T> current)? equals,
  }) {
    _initCacheCleanup();

    return StreamTransformer<List<T>, List<T>>.fromHandlers(
      handleData: (List<T> data, EventSink<List<T>> sink) {
        final key = cacheKey ?? T.toString();
        final cached = _streamCache[key] as List<T>?;

        // Usar função de igualdade customizada ou comparação padrão
        final isEqual = equals?.call(cached ?? [], data) ??
            _defaultListEquals(cached, data);

        if (!isEqual) {
          _streamCache[key] = List<T>.from(data);
          _debounceEmit(key, debounceTime, () => sink.add(data));
        }
      },
    );
  }

  /// Stream transformer com debounce implementado manualmente
  static StreamTransformer<T, T> debouncedDistinct<T>({
    Duration debounceTime = const Duration(milliseconds: 300),
    bool Function(T previous, T current)? equals,
  }) {
    T? lastEmitted;

    return StreamTransformer<T, T>.fromHandlers(
      handleData: (T data, EventSink<T> sink) {
        // Verificar se é diferente do último valor emitido
        final isDifferent = lastEmitted == null ||
            (equals?.call(lastEmitted as T, data) == false) ||
            (equals == null && lastEmitted != data);

        if (isDifferent) {
          final key = 'debounced_${T.toString()}_${sink.hashCode}';
          _debounceEmit(key, debounceTime, () {
            lastEmitted = data;
            sink.add(data);
          });
        }
      },
    );
  }

  /// Implementação de debounce usando Timer
  static void _debounceEmit(
      String key, Duration delay, void Function() callback) {
    // Cancelar timer existente se houver
    _debounceTimers[key]?.cancel();

    // Criar novo timer
    _debounceTimers[key] = Timer(delay, () {
      callback();
      _debounceTimers.remove(key);
    });
  }

  /// Stream transformer para filtros com cache
  static StreamTransformer<List<T>, List<T>> cachedFilter<T>(
    bool Function(T) filter, {
    String? cacheKey,
    Duration debounceTime = const Duration(milliseconds: 200),
  }) {
    _initCacheCleanup();

    return StreamTransformer<List<T>, List<T>>.fromHandlers(
      handleData: (List<T> data, EventSink<List<T>> sink) {
        final key = '${cacheKey ?? T.toString()}_filter_${filter.hashCode}';
        final cached = _streamCache[key] as List<T>?;
        final currentHash = _computeListHash(data);
        final cachedHash = _streamCache['${key}_hash'] as int?;

        if (cachedHash != currentHash || cached == null) {
          final filtered = data.where(filter).toList();
          _streamCache[key] = filtered;
          _streamCache['${key}_hash'] = currentHash;
          _debounceEmit('${key}_emit', debounceTime, () => sink.add(filtered));
        } else {
          _debounceEmit(
              '${key}_cached_emit', debounceTime, () => sink.add(cached));
        }
      },
    );
  }

  /// Stream transformer para map operations com cache
  static StreamTransformer<List<T>, List<R>> cachedMap<T, R>(
    R Function(T) mapper, {
    String? cacheKey,
    Duration debounceTime = const Duration(milliseconds: 200),
  }) {
    _initCacheCleanup();

    return StreamTransformer<List<T>, List<R>>.fromHandlers(
      handleData: (List<T> data, EventSink<List<R>> sink) {
        final key =
            '${cacheKey ?? '${T.toString()}_to_${R.toString()}'}_map_${mapper.hashCode}';
        final cached = _streamCache[key] as List<R>?;
        final currentHash = _computeListHash(data);
        final cachedHash = _streamCache['${key}_hash'] as int?;

        if (cachedHash != currentHash || cached == null) {
          final mapped = data.map(mapper).toList();
          _streamCache[key] = mapped;
          _streamCache['${key}_hash'] = currentHash;
          _debounceEmit('${key}_emit', debounceTime, () => sink.add(mapped));
        } else {
          _debounceEmit(
              '${key}_cached_emit', debounceTime, () => sink.add(cached));
        }
      },
    );
  }

  /// Stream transformer otimizado para busca por ID
  static StreamTransformer<List<T>, List<T>> cachedWhereById<T>(
    String Function(T) idExtractor,
    Set<String> targetIds, {
    String? cacheKey,
    Duration debounceTime = const Duration(milliseconds: 150),
  }) {
    _initCacheCleanup();

    return StreamTransformer<List<T>, List<T>>.fromHandlers(
      handleData: (List<T> data, EventSink<List<T>> sink) {
        final key =
            '${cacheKey ?? T.toString()}_whereById_${targetIds.hashCode}';
        final cached = _streamCache[key] as List<T>?;
        final currentHash = _computeListHash(data);
        final cachedHash = _streamCache['${key}_hash'] as int?;
        final targetIdsHash = targetIds.hashCode;
        final cachedTargetHash = _streamCache['${key}_target_hash'] as int?;

        if (cachedHash != currentHash ||
            cachedTargetHash != targetIdsHash ||
            cached == null) {
          final filtered = data
              .where((item) => targetIds.contains(idExtractor(item)))
              .toList();
          _streamCache[key] = filtered;
          _streamCache['${key}_hash'] = currentHash;
          _streamCache['${key}_target_hash'] = targetIdsHash;
          _debounceEmit('${key}_emit', debounceTime, () => sink.add(filtered));
        } else {
          _debounceEmit(
              '${key}_cached_emit', debounceTime, () => sink.add(cached));
        }
      },
    );
  }

  /// Switch map transformer implementação manual para cancelar operações anteriores
  static StreamTransformer<T, R> switchMapTransformer<T, R>(
    Stream<R> Function(T) mapper, {
    String? switchKey,
  }) {
    StreamSubscription? currentSubscription;
    final key = switchKey ?? 'switchMap_${T.toString()}_${R.toString()}';

    return StreamTransformer<T, R>.fromHandlers(
      handleData: (T data, EventSink<R> sink) {
        // Cancelar subscription anterior se existir
        currentSubscription?.cancel();

        // Criar nova subscription
        currentSubscription = mapper(data).listen(
          (R value) => sink.add(value),
          onError: (error, stackTrace) => sink.addError(error, stackTrace),
        );

        // Armazenar para cleanup posterior
        _activeSwitchSubscriptions[key] = currentSubscription!;
      },
      handleDone: (EventSink<R> sink) {
        currentSubscription?.cancel();
        _activeSwitchSubscriptions.remove(key);
        sink.close();
      },
      handleError: (Object error, StackTrace stackTrace, EventSink<R> sink) {
        sink.addError(error, stackTrace);
      },
    );
  }

  /// Transformer específico para streams de plantas por espaço
  static StreamTransformer<List<T>, List<T>> plantasByEspacoTransformer<T>(
    String Function(T) espacoIdExtractor,
    String targetEspacoId, {
    Duration debounceTime = const Duration(milliseconds: 200),
  }) {
    return cachedFilter<T>(
      (item) => espacoIdExtractor(item) == targetEspacoId,
      cacheKey: 'plantas_espaco_$targetEspacoId',
      debounceTime: debounceTime,
    );
  }

  /// Transformer específico para espaços ativos/inativos
  static StreamTransformer<List<T>, List<T>> espacosAtivoTransformer<T>(
    bool Function(T) ativoExtractor,
    bool targetAtivo, {
    Duration debounceTime = const Duration(milliseconds: 200),
  }) {
    return cachedFilter<T>(
      (item) => ativoExtractor(item) == targetAtivo,
      cacheKey: 'espacos_ativo_$targetAtivo',
      debounceTime: debounceTime,
    );
  }

  /// Transformer para tarefas por planta com otimização especial
  static StreamTransformer<List<T>, List<T>> tarefasByPlantaTransformer<T>(
    String Function(T) plantaIdExtractor,
    String targetPlantaId, {
    Duration debounceTime = const Duration(milliseconds: 150),
  }) {
    return cachedFilter<T>(
      (item) => plantaIdExtractor(item) == targetPlantaId,
      cacheKey: 'tarefas_planta_$targetPlantaId',
      debounceTime: debounceTime,
    );
  }

  /// Transformer para tarefas pendentes/concluídas
  static StreamTransformer<List<T>, List<T>> tarefasStatusTransformer<T>(
    bool Function(T) pendingExtractor,
    bool targetPending, {
    Duration debounceTime = const Duration(milliseconds: 150),
  }) {
    return cachedFilter<T>(
      (item) => pendingExtractor(item) == targetPending,
      cacheKey: 'tarefas_status_$targetPending',
      debounceTime: debounceTime,
    );
  }

  /// Comparação padrão para listas
  static bool _defaultListEquals<T>(List<T>? previous, List<T> current) {
    if (previous == null) return false;
    if (previous.length != current.length) return false;

    for (int i = 0; i < previous.length; i++) {
      if (previous[i] != current[i]) return false;
    }
    return true;
  }

  /// Calcular hash de uma lista para cache invalidation
  static int _computeListHash<T>(List<T> list) {
    var hash = 0;
    for (final item in list) {
      hash ^= item.hashCode;
    }
    return hash;
  }

  /// Obter estatísticas de cache para debug
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _streamCache.length,
      'cacheKeys': _streamCache.keys.toList(),
      'cleanupTimerActive': _cacheCleanupTimer?.isActive ?? false,
    };
  }

  /// Dispose recursos
  static void dispose() {
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer = null;
    clearCache();
  }
}

/// Extension para facilitar uso dos transformers em streams
extension OptimizedStreamExtensions<T> on Stream<List<T>> {
  /// Aplicar cache com distinct para listas
  Stream<List<T>> cachedDistinct({
    String? cacheKey,
    Duration debounceTime = const Duration(milliseconds: 300),
    bool Function(List<T> previous, List<T> current)? equals,
  }) {
    return transform(OptimizedStreamTransformers.cachedDistinctList<T>(
      cacheKey: cacheKey,
      debounceTime: debounceTime,
      equals: equals,
    ));
  }

  /// Aplicar filtro com cache
  Stream<List<T>> cachedWhere(
    bool Function(T) filter, {
    String? cacheKey,
    Duration debounceTime = const Duration(milliseconds: 200),
  }) {
    return transform(OptimizedStreamTransformers.cachedFilter<T>(
      filter,
      cacheKey: cacheKey,
      debounceTime: debounceTime,
    ));
  }

  /// Aplicar map com cache
  Stream<List<R>> cachedMapList<R>(
    R Function(T) mapper, {
    String? cacheKey,
    Duration debounceTime = const Duration(milliseconds: 200),
  }) {
    return transform(OptimizedStreamTransformers.cachedMap<T, R>(
      mapper,
      cacheKey: cacheKey,
      debounceTime: debounceTime,
    ));
  }

  /// Switch map manual para cancelar operações anteriores
  Stream<R> switchMapOptimized<R>(
    Stream<R> Function(List<T>) mapper, {
    String? switchKey,
  }) {
    return transform(
        OptimizedStreamTransformers.switchMapTransformer<List<T>, R>(
      mapper,
      switchKey: switchKey,
    ));
  }
}

/// Extension para streams simples
extension OptimizedSingleStreamExtensions<T> on Stream<T> {
  /// Debounce com distinct
  Stream<T> debouncedDistinct({
    Duration debounceTime = const Duration(milliseconds: 300),
    bool Function(T previous, T current)? equals,
  }) {
    return transform(OptimizedStreamTransformers.debouncedDistinct<T>(
      debounceTime: debounceTime,
      equals: equals,
    ));
  }
}
