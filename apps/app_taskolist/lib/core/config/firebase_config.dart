import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Configuração específica do Firebase para o Task Manager
class TaskManagerFirebaseConfig {
  static const String appName = 'Task Manager';
  static const String version = '1.0.0';
  
  /// Configuração de Analytics
  static const bool enableAnalytics = true;
  static const bool enableAnalyticsInDebug = false;
  
  /// Configuração de Crashlytics
  static const bool enableCrashlytics = true;
  static const bool enableCrashlyticsInDebug = true;
  
  /// Configuração de Performance
  static const bool enablePerformance = true;
  static const bool enablePerformanceInDebug = true;
  
  /// Verifica se Analytics está habilitado para o ambiente atual
  static bool get shouldEnableAnalytics {
    if (kDebugMode) {
      return enableAnalytics && enableAnalyticsInDebug;
    }
    return enableAnalytics;
  }
  
  /// Verifica se Crashlytics está habilitado para o ambiente atual
  static bool get shouldEnableCrashlytics {
    if (kDebugMode) {
      return enableCrashlytics && enableCrashlyticsInDebug;
    }
    return enableCrashlytics;
  }
  
  /// Verifica se Performance está habilitado para o ambiente atual
  static bool get shouldEnablePerformance {
    if (kDebugMode) {
      return enablePerformance && enablePerformanceInDebug;
    }
    return enablePerformance;
  }
  
  /// Configuração de Performance padrão para o Task Manager
  static PerformanceConfig get defaultPerformanceConfig => const PerformanceConfig(
    enableFpsMonitoring: true,
    enableMemoryMonitoring: true,
    enableCpuMonitoring: true,
    enableFirebaseIntegration: true,
    monitoringInterval: Duration(seconds: 5),
    fpsMonitoringInterval: Duration(seconds: 1),
  );
  
  /// Configuração de thresholds de performance para o Task Manager
  static PerformanceThresholds get defaultPerformanceThresholds => const PerformanceThresholds(
    minFps: 30.0,
    maxMemoryUsagePercent: 80.0,
    maxCpuUsage: 70.0,
  );
  
  /// Tags padrão para eventos de analytics
  static Map<String, String> get defaultAnalyticsTags => {
    'app_name': appName,
    'app_version': version,
    'platform': 'flutter',
    'environment': kDebugMode ? 'debug' : 'production',
  };
  
  /// Contexto padrão para Crashlytics
  static Map<String, dynamic> get defaultCrashlyticsContext => {
    'app_name': appName,
    'app_version': version,
    'platform': 'flutter',
    'environment': kDebugMode ? 'debug' : 'production',
    'features': [
      'task_management',
      'user_authentication',
      'local_storage',
      'notifications',
      'analytics',
      'performance_monitoring',
    ].join(','),
  };
  
  /// Configuração de coleta de dados baseada no ambiente
  static Map<String, bool> get dataCollectionSettings => {
    'analytics_enabled': shouldEnableAnalytics,
    'crashlytics_enabled': shouldEnableCrashlytics,
    'performance_enabled': shouldEnablePerformance,
    'automatic_data_collection': !kDebugMode,
    'analytics_debug_view': kDebugMode,
  };
}