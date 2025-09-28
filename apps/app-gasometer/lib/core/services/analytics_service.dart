import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Serviço centralizado para Analytics e Crashlytics do Gasometer
@singleton
class AnalyticsService {
  AnalyticsService();

  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;

  /// Verifica se analytics está habilitado (desabilitado em debug)
  bool get _isAnalyticsEnabled => !kDebugMode;

  /// Inicializa o serviço
  void initialize() {
    _analytics = FirebaseAnalytics.instance;
    _crashlytics = FirebaseCrashlytics.instance;
    
    // Configure analytics collection
    _analytics.setAnalyticsCollectionEnabled(_isAnalyticsEnabled);
    
    if (kDebugMode) {
      debugPrint('📊 Analytics Service initialized (Debug Mode - Analytics disabled)');
    } else {
      debugPrint('📊 Analytics Service initialized (Production Mode - Analytics enabled)');
    }
  }

  // ===== ANALYTICS METHODS =====

  /// Log de visualização de tela
  Future<void> logScreenView(String screenName) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('📊 [DEV] Screen view: $screenName');
      return;
    }

    try {
      await _analytics.logScreenView(
        screenName: screenName,
      );
      debugPrint('📊 Screen view logged: $screenName');
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace);
    }
  }

  /// Log de evento customizado
  Future<void> logEvent(String eventName, Map<String, Object>? parameters) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('📊 [DEV] Event: $eventName ${parameters ?? '{}'}');
      return;
    }

    try {
      // Filter out null values from parameters
      Map<String, Object>? cleanParameters;
      if (parameters != null) {
        cleanParameters = Map.fromEntries(
          parameters.entries.where((entry) => entry.value != null)
        );
        // If all values were null, set to null
        if (cleanParameters.isEmpty) {
          cleanParameters = null;
        }
      }

      await _analytics.logEvent(
        name: eventName,
        parameters: cleanParameters,
      );
      debugPrint('📊 Event logged: $eventName');
    } catch (e) {
      debugPrint('Failed to report to Analytics: $e');
      // Don't recursively call crashlytics if analytics fails
    }
  }

  /// Log de ação do usuário
  Future<void> logUserAction(String action, {Map<String, Object>? parameters}) async {
    await logEvent('user_action', {
      'action': action,
      ...?parameters,
    });
  }

  // ===== AUTH EVENTS =====

  Future<void> logLogin(String method) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('📊 [DEV] Login: $method');
      return;
    }
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('📊 [DEV] SignUp: $method');
      return;
    }
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logAnonymousSignIn() async {
    await logEvent('anonymous_sign_in', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logLogout() async {
    await logEvent('logout', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ===== APP LIFECYCLE EVENTS =====

  Future<void> logAppOpen() async {
    await logEvent('app_open', null);
  }

  Future<void> logAppBackground() async {
    await logEvent('app_background', null);
  }

  // ===== GASOMETER SPECIFIC EVENTS =====

  /// Eventos de abastecimento
  Future<void> logFuelRefill({
    required String fuelType,
    required double liters,
    required double totalCost,
    required bool fullTank,
  }) async {
    await logEvent('fuel_refill', {
      'fuel_type': fuelType,
      'liters': liters,
      'total_cost': totalCost,
      'full_tank': fullTank,
    });
  }

  /// Eventos de manutenção
  Future<void> logMaintenance({
    required String maintenanceType,
    required double cost,
    required int odometer,
  }) async {
    await logEvent('maintenance_logged', {
      'maintenance_type': maintenanceType,
      'cost': cost,
      'odometer': odometer,
    });
  }

  /// Eventos de despesas
  Future<void> logExpense({
    required String expenseType,
    required double amount,
  }) async {
    await logEvent('expense_logged', {
      'expense_type': expenseType,
      'amount': amount,
    });
  }

  /// Eventos de veículo
  Future<void> logVehicleCreated(String vehicleType) async {
    await logEvent('vehicle_created', {
      'vehicle_type': vehicleType,
    });
  }

  /// Eventos de relatórios
  Future<void> logReportViewed(String reportType) async {
    await logEvent('report_viewed', {
      'report_type': reportType,
    });
  }

  /// Eventos de features premium
  Future<void> logPremiumFeatureAttempted(String featureName) async {
    await logEvent('premium_feature_attempted', {
      'feature': featureName,
    });
  }

  /// Eventos de exportação
  Future<void> logDataExport(String exportType) async {
    await logEvent('data_exported', {
      'export_type': exportType,
    });
  }

  // ===== USER PROPERTIES =====

  Future<void> setUserId(String userId) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('👤 [DEV] User ID configurado');
      return;
    }

    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> setUserProperties(Map<String, String> properties) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('👤 [DEV] User properties configuradas');
      return;
    }

    for (final entry in properties.entries) {
      await _analytics.setUserProperty(
        name: entry.key,
        value: entry.value,
      );
    }
  }

  // ===== LGPD DATA EXPORT ANALYTICS =====

  /// Analytics para início de exportação de dados LGPD
  Future<void> logDataExportStarted({
    required String userId,
    required List<String> categories,
    int? estimatedSizeMb,
    bool? includeAttachments,
  }) async {
    await logEvent('data_export_started', {
      'user_id_hash': _hashUserId(userId),
      'categories_count': categories.length,
      'categories': categories.join(','),
      'estimated_size_mb': estimatedSizeMb ?? 0,
      'include_attachments': includeAttachments ?? true,
      'timestamp': DateTime.now().toIso8601String(),
      'compliance_type': 'LGPD',
    });
  }

  /// Analytics para conclusão de exportação de dados LGPD
  Future<void> logDataExportCompleted({
    required String userId,
    required bool success,
    int? fileSizeMb,
    int? processingTimeMs,
    String? errorReason,
  }) async {
    await logEvent('data_export_completed', {
      'user_id_hash': _hashUserId(userId),
      'success': success,
      'file_size_mb': fileSizeMb ?? 0,
      'processing_time_ms': processingTimeMs ?? 0,
      'error_reason': errorReason ?? '',
      'timestamp': DateTime.now().toIso8601String(),
      'compliance_type': 'LGPD',
    });
  }

  /// Analytics para verificação de rate limit
  Future<void> logDataExportRateLimited({
    required String userId,
  }) async {
    await logEvent('data_export_rate_limited', {
      'user_id_hash': _hashUserId(userId),
      'timestamp': DateTime.now().toIso8601String(),
      'compliance_type': 'LGPD',
    });
  }

  /// Analytics para compartilhamento de arquivo exportado
  Future<void> logDataExportShared({
    required String userId,
    required String platform,
  }) async {
    await logEvent('data_export_shared', {
      'user_id_hash': _hashUserId(userId),
      'platform': platform,
      'timestamp': DateTime.now().toIso8601String(),
      'compliance_type': 'LGPD',
    });
  }

  /// Analytics para estimativa de tamanho da exportação
  Future<void> logDataExportSizeEstimated({
    required String userId,
    required int estimatedSizeMb,
    required int totalRecords,
    required int totalCategories,
  }) async {
    await logEvent('data_export_size_estimated', {
      'user_id_hash': _hashUserId(userId),
      'estimated_size_mb': estimatedSizeMb,
      'total_records': totalRecords,
      'total_categories': totalCategories,
      'timestamp': DateTime.now().toIso8601String(),
      'compliance_type': 'LGPD',
    });
  }

  /// Hash do user ID para compliance (não armazenar ID real)
  String _hashUserId(String userId) {
    // Simples hash para não armazenar o ID real do usuário
    return userId.hashCode.abs().toString();
  }

  // ===== CRASHLYTICS METHODS =====

  /// Registra erro não fatal
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, Object>? customKeys,
  }) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('🔥 [DEV] Error: ${error.toString()}');
      if (reason != null) debugPrint('🔥 [DEV] Reason: $reason');
      return;
    }

    if (customKeys != null) {
      for (final entry in customKeys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    }

    await _crashlytics.recordError(
      error,
      stackTrace ?? StackTrace.current,
      reason: reason,
    );

    debugPrint('🔥 Error recorded: ${error.toString()}');
  }

  /// Log customizado para Crashlytics
  Future<void> log(String message) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('📝 [DEV] Log: $message');
      return;
    }

    await _crashlytics.log(message);
  }

  /// Define chave customizada
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isAnalyticsEnabled) {
      debugPrint('🔑 [DEV] Custom key - $key: $value');
      return;
    }

    await _crashlytics.setCustomKey(key, value as Object);
  }

  // ===== TEST METHODS =====

  /// Força crash para teste (apenas em debug)
  Future<void> testCrash() async {
    if (kDebugMode) {
      throw Exception('Test crash from Gasometer Analytics Service');
    }
  }

  /// Testa erro não fatal (apenas em debug)
  Future<void> testNonFatalError() async {
    if (kDebugMode) {
      await recordError(
        Exception('Test non-fatal error'),
        StackTrace.current,
        reason: 'Testing non-fatal error reporting',
      );
    }
  }
}