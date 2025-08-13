import '../entities/performance_entity.dart';

/// Interface para operações de monitoramento de performance
abstract class IPerformanceRepository {
  // ==========================================================================
  // CONTROLE DE MONITORAMENTO
  // ==========================================================================

  /// Inicializar monitoramento de performance
  Future<bool> startPerformanceTracking({PerformanceConfig? config});

  /// Parar monitoramento de performance
  Future<bool> stopPerformanceTracking();

  /// Pausar monitoramento temporariamente
  Future<bool> pausePerformanceTracking();

  /// Retomar monitoramento
  Future<bool> resumePerformanceTracking();

  /// Obter estado atual do monitoramento
  PerformanceMonitoringState getMonitoringState();

  /// Configurar thresholds de performance
  Future<void> setPerformanceThresholds(PerformanceThresholds thresholds);

  // ==========================================================================
  // MONITORAMENTO DE FPS
  // ==========================================================================

  /// Stream de FPS em tempo real
  Stream<double> getFpsStream();

  /// Obter FPS atual
  Future<double> getCurrentFps();

  /// Obter métricas detalhadas de FPS
  Future<FpsMetrics> getFpsMetrics({Duration? period});

  /// Verificar se FPS está dentro do threshold aceitável
  Future<bool> isFpsHealthy();

  // ==========================================================================
  // MONITORAMENTO DE MEMÓRIA
  // ==========================================================================

  /// Stream de uso de memória em tempo real
  Stream<MemoryUsage> getMemoryStream();

  /// Obter uso atual de memória
  Future<MemoryUsage> getMemoryUsage();

  /// Verificar se uso de memória está saudável
  Future<bool> isMemoryHealthy();

  /// Forçar garbage collection (apenas para debug)
  Future<void> forceGarbageCollection();

  // ==========================================================================
  // MONITORAMENTO DE CPU
  // ==========================================================================

  /// Obter uso atual de CPU
  Future<double> getCpuUsage();

  /// Stream de uso de CPU
  Stream<double> getCpuStream();

  /// Verificar se CPU está com uso saudável
  Future<bool> isCpuHealthy();

  // ==========================================================================
  // MÉTRICAS DE INICIALIZAÇÃO
  // ==========================================================================

  /// Obter métricas de startup do app
  Future<AppStartupMetrics> getStartupMetrics();

  /// Marcar início da inicialização
  Future<void> markAppStarted();

  /// Marcar primeiro frame renderizado
  Future<void> markFirstFrame();

  /// Marcar app como interativo
  Future<void> markAppInteractive();

  // ==========================================================================
  // TRACES CUSTOMIZADOS
  // ==========================================================================

  /// Iniciar trace customizado
  Future<void> startTrace(String traceName, {Map<String, String>? attributes});

  /// Parar trace customizado
  Future<TraceResult?> stopTrace(String traceName, {Map<String, double>? metrics});

  /// Medir tempo de execução de uma operação
  Future<Duration> measureOperationTime(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  });

  /// Obter traces ativos
  List<String> getActiveTraces();

  // ==========================================================================
  // MÉTRICAS CUSTOMIZADAS
  // ==========================================================================

  /// Registrar métrica customizada
  Future<void> recordCustomMetric({
    required String name,
    required double value,
    required MetricType type,
    String? unit,
    Map<String, String>? tags,
  });

  /// Incrementar contador
  Future<void> incrementCounter(String name, {Map<String, String>? tags});

  /// Registrar valor de gauge
  Future<void> recordGauge(String name, double value, {Map<String, String>? tags});

  /// Registrar tempo de operação
  Future<void> recordTiming(String name, Duration duration, {Map<String, String>? tags});

  // ==========================================================================
  // RELATÓRIOS E HISTÓRICO
  // ==========================================================================

  /// Obter métricas atuais consolidadas
  Future<PerformanceMetrics> getCurrentMetrics();

  /// Obter histórico de performance
  Future<List<PerformanceMetrics>> getPerformanceHistory({
    DateTime? since,
    int? limit,
    Duration? period,
  });

  /// Obter relatório de performance
  Future<Map<String, dynamic>> getPerformanceReport({
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Exportar dados de performance
  Future<String> exportPerformanceData({
    required String format, // 'json', 'csv', etc.
    DateTime? startTime,
    DateTime? endTime,
  });

  // ==========================================================================
  // ALERTAS E NOTIFICAÇÕES
  // ==========================================================================

  /// Stream de alertas de performance
  Stream<Map<String, dynamic>> getPerformanceAlertsStream();

  /// Verificar se há problemas de performance
  Future<List<String>> checkPerformanceIssues();

  /// Configurar callback para alertas
  Future<void> setPerformanceAlertCallback(
    void Function(String alertType, Map<String, dynamic> data) callback,
  );

  // ==========================================================================
  // INTEGRAÇÃO FIREBASE
  // ==========================================================================

  /// Enviar métricas para Firebase Performance
  Future<bool> syncWithFirebase();

  /// Configurar envio automático para Firebase
  Future<void> enableFirebaseSync({Duration? interval});

  /// Desabilitar integração com Firebase
  Future<void> disableFirebaseSync();

  // ==========================================================================
  // UTILITÁRIOS
  // ==========================================================================

  /// Limpar dados de performance antigos
  Future<void> clearOldPerformanceData({Duration? olderThan});

  /// Obter informações do dispositivo relacionadas à performance
  Future<Map<String, dynamic>> getDevicePerformanceInfo();

  /// Verificar se o dispositivo suporta todas as funcionalidades
  Future<Map<String, bool>> getFeatureSupport();

  /// Reset de todas as métricas
  Future<void> resetAllMetrics();
}