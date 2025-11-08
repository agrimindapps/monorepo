import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Gasometer-specific Analytics Service built on top of EnhancedAnalyticsService
///
/// Provides:
/// - All core analytics functionality via EnhancedAnalyticsService
/// - Gasometer-specific business events (fuel, maintenance, expenses)
/// - LGPD compliance analytics (data export tracking)
/// - Consistent error handling and environment awareness
@singleton
class GasometerAnalyticsService {
  GasometerAnalyticsService(this._enhanced);

  final EnhancedAnalyticsService _enhanced;

  /// Logs a custom event
  Future<void> logEvent(String eventName, Map<String, Object>? parameters) async {
    await _enhanced.logEvent(eventName, parameters?.cast<String, dynamic>());
  }

  /// Logs screen view
  Future<void> logScreenView(String screenName) async {
    await _enhanced.setCurrentScreen(screenName);
  }

  /// Logs user action
  Future<void> logUserAction(String action, {Map<String, Object>? parameters}) async {
    await logEvent('user_action', {
      'action': action,
      ...?parameters,
    });
  }

  Future<void> logLogin(String method) async {
    await _enhanced.logAuthEvent('login', parameters: {'method': method});
  }

  Future<void> logSignUp(String method) async {
    await _enhanced.logAuthEvent('signup', parameters: {'method': method});
  }

  Future<void> logAnonymousSignIn() async {
    await logEvent('anonymous_sign_in', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logLogout() async {
    await _enhanced.logAuthEvent('logout');
  }

  Future<void> logAppOpen() async {
    await logEvent('app_open', null);
  }

  Future<void> logAppBackground() async {
    await logEvent('app_background', null);
  }

  /// Eventos de abastecimento
  Future<void> logFuelRefill({
    required String fuelType,
    required double liters,
    required double totalCost,
    required bool fullTank,
  }) async {
    await _enhanced.logAppSpecificEvent(
      GasometerEvent.fuelRecorded,
      additionalParameters: {
        'fuel_type': fuelType,
        'liters': liters,
        'total_cost': totalCost,
        'full_tank': fullTank,
      },
    );
  }

  /// Eventos de manutenção
  Future<void> logMaintenance({
    required String maintenanceType,
    required double cost,
    required int odometer,
  }) async {
    await _enhanced.logAppSpecificEvent(
      GasometerEvent.maintenanceScheduled,
      additionalParameters: {
        'maintenance_type': maintenanceType,
        'cost': cost,
        'odometer': odometer,
      },
    );
  }

  /// Eventos de despesas
  Future<void> logExpense({
    required String expenseType,
    required double amount,
  }) async {
    await _enhanced.logAppSpecificEvent(
      GasometerEvent.expenseAdded,
      additionalParameters: {
        'expense_type': expenseType,
        'amount': amount,
      },
    );
  }

  /// Eventos de veículo
  Future<void> logVehicleCreated(String vehicleType) async {
    await _enhanced.logAppSpecificEvent(
      GasometerEvent.vehicleCreated,
      additionalParameters: {
        'vehicle_type': vehicleType,
      },
    );
  }

  /// Eventos de relatórios
  Future<void> logReportViewed(String reportType) async {
    await _enhanced.logAppSpecificEvent(
      GasometerEvent.reportGenerated,
      additionalParameters: {
        'report_type': reportType,
      },
    );
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

  Future<void> setUserId(String userId) async {
    await _enhanced.setUser(userId: userId);
  }

  Future<void> setUserProperties(Map<String, String> properties) async {
    await _enhanced.setUser(
      userId: '', // Will be set by auth service
      properties: properties,
    );
  }

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
    return userId.hashCode.abs().toString();
  }

  /// Registra erro não fatal
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, Object>? customKeys,
  }) async {
    await _enhanced.recordError(
      error,
      stackTrace,
      reason: reason,
      customKeys: customKeys?.cast<String, dynamic>(),
    );
  }

  /// Log customizado para Crashlytics
  Future<void> log(String message) async {
    if (kDebugMode) {
      debugPrint('📝 [Gasometer] $message');
    }
  }

  /// Define chave customizada
  Future<void> setCustomKey(String key, dynamic value) async {
    if (kDebugMode) {
      debugPrint('🔑 [Gasometer] Custom key - $key: $value');
    }
  }

  /// Força crash para teste (apenas em debug)
  Future<void> testCrash() async {
    await _enhanced.testCrash();
  }

  /// Testa erro não fatal (apenas em debug)
  Future<void> testNonFatalError() async {
    if (kDebugMode) {
      await recordError(
        Exception('Test non-fatal error from Gasometer'),
        StackTrace.current,
        reason: 'Testing non-fatal error reporting',
      );
    }
  }
}
