/// Serviço de otimização de performance para o jogo da memória
/// 
/// Implementa lazy loading, cache inteligente, detecção de performance
/// e ajustes automáticos para melhorar experiência em dispositivos lentos.
library;

// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/memory_card.dart';

/// Configurações de performance
class PerformanceConfig {
  final bool enableLazyLoading;
  final bool enableVirtualization;
  final bool enableAdaptiveQuality;
  final int maxCacheSize;
  final Duration cacheTimeout;
  final QualityLevel qualityLevel;
  
  const PerformanceConfig({
    this.enableLazyLoading = true,
    this.enableVirtualization = true,
    this.enableAdaptiveQuality = true,
    this.maxCacheSize = 100,
    this.cacheTimeout = const Duration(minutes: 10),
    this.qualityLevel = QualityLevel.auto,
  });
}

/// Níveis de qualidade visual
enum QualityLevel {
  low,        // Qualidade baixa para dispositivos lentos
  medium,     // Qualidade média
  high,       // Qualidade alta
  auto,       // Detecção automática
}

/// Métricas de performance
class PerformanceMetrics {
  final double averageFPS;
  final int memoryUsageMB;
  final int cacheHitRate;
  final Duration averageRenderTime;
  final DateTime lastUpdate;
  
  PerformanceMetrics({
    required this.averageFPS,
    required this.memoryUsageMB,
    required this.cacheHitRate,
    required this.averageRenderTime,
    required this.lastUpdate,
  });
  
  bool get isLowPerformance => averageFPS < 30 || averageRenderTime.inMilliseconds > 50;
  bool get isHighMemoryUsage => memoryUsageMB > 100;
}

/// Item de cache
class CacheItem<T> {
  final T data;
  final DateTime timestamp;
  final int accessCount;
  
  CacheItem(this.data, this.timestamp, this.accessCount);
  
  bool isExpired(Duration timeout) {
    return DateTime.now().difference(timestamp) > timeout;
  }
}

/// Serviço de otimização de performance
class PerformanceOptimizationService {
  /// Configurações atuais
  PerformanceConfig _config = const PerformanceConfig();
  
  /// Cache de recursos
  final Map<String, CacheItem<dynamic>> _resourceCache = {};
  
  /// Cache de renderização
  final Map<String, CacheItem<Widget>> _widgetCache = {};
  
  /// Métricas de performance
  PerformanceMetrics? _lastMetrics;
  
  /// Timer para limpeza de cache
  Timer? _cacheCleanupTimer;
  
  /// Timer para monitoramento de performance
  Timer? _performanceMonitorTimer;
  
  /// Contador de frames
  int _frameCount = 0;
  
  /// Tempo de início do monitoramento
  DateTime? _monitoringStartTime;
  
  /// Lista de tempos de renderização
  final List<Duration> _renderTimes = [];
  
  /// Controle de dispose
  bool _isDisposed = false;
  
  /// Construtor
  PerformanceOptimizationService() {
    _startCacheCleanup();
    _startPerformanceMonitoring();
  }
  
  /// Atualiza configurações
  void updateConfig(PerformanceConfig config) {
    _config = config;
    debugPrint('Configurações de performance atualizadas');
  }
  
  /// Obtém configurações atuais
  PerformanceConfig get config => _config;
  
  /// Inicia limpeza automática de cache
  void _startCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _cleanExpiredCache(),
    );
  }
  
  /// Inicia monitoramento de performance
  void _startPerformanceMonitoring() {
    _monitoringStartTime = DateTime.now();
    _performanceMonitorTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _updatePerformanceMetrics(),
    );
  }
  
  /// Limpa cache expirado
  void _cleanExpiredCache() {
    if (_isDisposed) return;
    
    final keysToRemove = <String>[];
    
    // Limpa cache de recursos
    for (final entry in _resourceCache.entries) {
      if (entry.value.isExpired(_config.cacheTimeout)) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _resourceCache.remove(key);
    }
    
    // Limpa cache de widgets
    keysToRemove.clear();
    for (final entry in _widgetCache.entries) {
      if (entry.value.isExpired(_config.cacheTimeout)) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _widgetCache.remove(key);
    }
    
    // Limita tamanho do cache
    _limitCacheSize();
    
    debugPrint('Cache limpo. Recursos: ${_resourceCache.length}, Widgets: ${_widgetCache.length}');
  }
  
  /// Limita tamanho do cache
  void _limitCacheSize() {
    if (_resourceCache.length > _config.maxCacheSize) {
      // Remove itens menos acessados
      final sortedEntries = _resourceCache.entries.toList()
        ..sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));
      
      final itemsToRemove = sortedEntries.take(_resourceCache.length - _config.maxCacheSize);
      for (final entry in itemsToRemove) {
        _resourceCache.remove(entry.key);
      }
    }
    
    if (_widgetCache.length > _config.maxCacheSize) {
      final sortedEntries = _widgetCache.entries.toList()
        ..sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));
      
      final itemsToRemove = sortedEntries.take(_widgetCache.length - _config.maxCacheSize);
      for (final entry in itemsToRemove) {
        _widgetCache.remove(entry.key);
      }
    }
  }
  
  /// Atualiza métricas de performance
  void _updatePerformanceMetrics() {
    if (_isDisposed || _monitoringStartTime == null) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(_monitoringStartTime!);
    final averageFPS = _frameCount / elapsed.inSeconds.toDouble();
    
    // Simula uso de memória (em produção, usaria dart:developer)
    final memoryUsageMB = _estimateMemoryUsage();
    
    // Calcula taxa de hit do cache
    final totalAccesses = _resourceCache.values.fold(0, (sum, item) => sum + item.accessCount);
    final cacheHitRate = totalAccesses > 0 ? 
        (_resourceCache.length / totalAccesses * 100).round() : 0;
    
    // Calcula tempo médio de renderização
    final averageRenderTime = _renderTimes.isEmpty ? 
        Duration.zero : 
        Duration(microseconds: _renderTimes.fold(0, (sum, time) => sum + time.inMicroseconds) ~/ _renderTimes.length);
    
    _lastMetrics = PerformanceMetrics(
      averageFPS: averageFPS,
      memoryUsageMB: memoryUsageMB,
      cacheHitRate: cacheHitRate,
      averageRenderTime: averageRenderTime,
      lastUpdate: now,
    );
    
    // Ajusta qualidade automaticamente se necessário
    if (_config.enableAdaptiveQuality && _config.qualityLevel == QualityLevel.auto) {
      _adjustQualityBasedOnPerformance();
    }
    
    // Limpa dados antigos
    if (_renderTimes.length > 100) {
      _renderTimes.removeRange(0, 50);
    }
  }
  
  /// Estima uso de memória
  int _estimateMemoryUsage() {
    // Estimativa baseada no cache
    int estimatedMB = _resourceCache.length + _widgetCache.length;
    
    // Adiciona overhead do sistema
    estimatedMB += 20;
    
    return estimatedMB;
  }
  
  /// Ajusta qualidade baseada na performance
  void _adjustQualityBasedOnPerformance() {
    if (_lastMetrics == null) return;
    
    QualityLevel newLevel = _getCurrentQualityLevel();
    
    if (_lastMetrics!.isLowPerformance) {
      if (newLevel == QualityLevel.high) {
        newLevel = QualityLevel.medium;
      } else if (newLevel == QualityLevel.medium) {
        newLevel = QualityLevel.low;
      }
      debugPrint('Performance baixa detectada, reduzindo qualidade para ${newLevel.name}');
    } else if (_lastMetrics!.averageFPS > 50 && newLevel == QualityLevel.low) {
      newLevel = QualityLevel.medium;
      debugPrint('Performance melhorou, aumentando qualidade para ${newLevel.name}');
    }
    
    _setCurrentQualityLevel(newLevel);
  }
  
  /// Obtém nível de qualidade atual
  QualityLevel _getCurrentQualityLevel() {
    // Placeholder - em implementação real, seria armazenado no config
    return QualityLevel.medium;
  }
  
  /// Define nível de qualidade atual
  void _setCurrentQualityLevel(QualityLevel level) {
    // Placeholder - em implementação real, atualizaria config e aplicaria mudanças
    debugPrint('Qualidade definida para: ${level.name}');
  }
  
  /// Carrega recurso com cache
  Future<T> loadResourceWithCache<T>(
    String key,
    Future<T> Function() loader, {
    Duration? cacheTimeout,
  }) async {
    if (_isDisposed) throw Exception('Service is disposed');
    
    final timeout = cacheTimeout ?? _config.cacheTimeout;
    
    // Verifica cache
    final cachedItem = _resourceCache[key];
    if (cachedItem != null && !cachedItem.isExpired(timeout)) {
      // Atualiza contador de acesso
      _resourceCache[key] = CacheItem(
        cachedItem.data,
        cachedItem.timestamp,
        cachedItem.accessCount + 1,
      );
      return cachedItem.data as T;
    }
    
    // Carrega recurso
    try {
      final resource = await loader();
      
      // Armazena no cache
      _resourceCache[key] = CacheItem(resource, DateTime.now(), 1);
      
      return resource;
    } catch (e) {
      debugPrint('Erro ao carregar recurso $key: $e');
      rethrow;
    }
  }
  
  /// Carrega widget com cache
  Widget loadWidgetWithCache(
    String key,
    Widget Function() builder, {
    Duration? cacheTimeout,
  }) {
    if (_isDisposed) return const SizedBox.shrink();
    
    final timeout = cacheTimeout ?? _config.cacheTimeout;
    
    // Verifica cache
    final cachedItem = _widgetCache[key];
    if (cachedItem != null && !cachedItem.isExpired(timeout)) {
      // Atualiza contador de acesso
      _widgetCache[key] = CacheItem(
        cachedItem.data,
        cachedItem.timestamp,
        cachedItem.accessCount + 1,
      );
      return cachedItem.data;
    }
    
    // Constrói widget
    try {
      final widget = builder();
      
      // Armazena no cache
      _widgetCache[key] = CacheItem(widget, DateTime.now(), 1);
      
      return widget;
    } catch (e) {
      debugPrint('Erro ao construir widget $key: $e');
      return const SizedBox.shrink();
    }
  }
  
  /// Cria cartas com lazy loading
  List<MemoryCard> createCardsWithLazyLoading(
    int totalPairs,
    GameDifficulty difficulty,
  ) {
    final List<MemoryCard> cards = [];
    
    if (_config.enableLazyLoading) {
      // Carrega apenas cartas visíveis inicialmente
      final visibleCount = _config.enableVirtualization ? 
          (difficulty.gridSize * 2).clamp(8, totalPairs * 2) : 
          totalPairs * 2;
      
      for (int i = 0; i < visibleCount; i++) {
        cards.add(_createCard(i, totalPairs));
      }
      
      // Carrega restante em background
      if (visibleCount < totalPairs * 2) {
        _loadRemainingCardsInBackground(cards, visibleCount, totalPairs);
      }
    } else {
      // Carrega todas as cartas normalmente
      for (int i = 0; i < totalPairs * 2; i++) {
        cards.add(_createCard(i, totalPairs));
      }
    }
    
    return cards;
  }
  
  /// Cria uma carta individual
  MemoryCard _createCard(int index, int totalPairs) {
    final pairId = index ~/ 2;
    final cardId = index;
    
    // Usa cache para cores e ícones
    final cacheKey = 'card_${pairId % CardThemes.cardColors.length}';
    
    return loadResourceWithCache<MemoryCard>(
      cacheKey,
      () async {
        final color = CardThemes.cardColors[pairId % CardThemes.cardColors.length];
        final icon = CardThemes.cardIcons[pairId % CardThemes.cardIcons.length];
        
        return MemoryCard(
          id: cardId,
          pairId: pairId,
          color: color,
          icon: icon,
        );
      },
    ).then((cachedCard) {
      return MemoryCard(
        id: cardId,
        pairId: pairId,
        color: cachedCard.color,
        icon: cachedCard.icon,
      );
    }) as MemoryCard;
  }
  
  /// Carrega cartas restantes em background
  void _loadRemainingCardsInBackground(
    List<MemoryCard> cards,
    int startIndex,
    int totalPairs,
  ) {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isDisposed || startIndex >= totalPairs * 2) {
        timer.cancel();
        return;
      }
      
      // Carrega uma carta por vez para não bloquear UI
      cards.add(_createCard(startIndex, totalPairs));
      startIndex++;
      
      if (startIndex >= totalPairs * 2) {
        timer.cancel();
        debugPrint('Carregamento lazy concluído');
      }
    });
  }
  
  /// Registra tempo de renderização
  void recordRenderTime(Duration renderTime) {
    if (_isDisposed) return;
    
    _renderTimes.add(renderTime);
    _frameCount++;
  }
  
  /// Libera recursos não utilizados
  void releaseUnusedResources() {
    // Remove itens do cache não acessados recentemente
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _resourceCache.entries) {
      if (now.difference(entry.value.timestamp).inMinutes > 5 && entry.value.accessCount <= 1) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _resourceCache.remove(key);
    }
    
    debugPrint('Recursos não utilizados liberados: ${keysToRemove.length}');
  }
  
  /// Obtém métricas atuais de performance
  PerformanceMetrics? get currentMetrics => _lastMetrics;
  
  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStatistics() {
    return {
      'resourceCacheSize': _resourceCache.length,
      'widgetCacheSize': _widgetCache.length,
      'totalCacheSize': _resourceCache.length + _widgetCache.length,
      'maxCacheSize': _config.maxCacheSize,
      'cacheUtilization': '${((_resourceCache.length + _widgetCache.length) / (_config.maxCacheSize * 2) * 100).toStringAsFixed(1)}%',
    };
  }
  
  /// Força limpeza completa do cache
  void clearCache() {
    _resourceCache.clear();
    _widgetCache.clear();
    debugPrint('Cache limpo completamente');
  }
  
  /// Otimiza configurações para dispositivo atual
  PerformanceConfig optimizeForDevice() {
    // Detecção básica de dispositivo (em produção, seria mais sofisticada)
    final isLowEndDevice = _estimateDevicePerformance() == DevicePerformance.low;
    
    return PerformanceConfig(
      enableLazyLoading: true,
      enableVirtualization: isLowEndDevice,
      enableAdaptiveQuality: true,
      maxCacheSize: isLowEndDevice ? 50 : 100,
      cacheTimeout: isLowEndDevice ? const Duration(minutes: 5) : const Duration(minutes: 10),
      qualityLevel: isLowEndDevice ? QualityLevel.low : QualityLevel.auto,
    );
  }
  
  /// Estima performance do dispositivo
  DevicePerformance _estimateDevicePerformance() {
    // Heurística simples baseada na plataforma
    if (Platform.isAndroid) {
      return DevicePerformance.medium; // Placeholder
    } else if (Platform.isIOS) {
      return DevicePerformance.high; // Placeholder
    }
    return DevicePerformance.medium;
  }
  
  /// Dispose do serviço
  void dispose() {
    if (_isDisposed) return;
    
    debugPrint('Fazendo dispose do PerformanceOptimizationService');
    
    _cacheCleanupTimer?.cancel();
    _performanceMonitorTimer?.cancel();
    
    clearCache();
    
    _isDisposed = true;
    debugPrint('PerformanceOptimizationService disposed');
  }
}

/// Tipos de performance de dispositivo
enum DevicePerformance {
  low,
  medium,
  high,
}
