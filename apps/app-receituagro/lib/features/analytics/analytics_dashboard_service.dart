import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import 'services/analytics_cache_service.dart';
import 'services/analytics_metrics_calculation_service.dart';

/// ⚠️ MOCK DATA WARNING:
/// This service returns mock/fake data for development purposes when
/// DEBUG_ANALYTICS_MOCK_DATA is true. In production, this should be
/// replaced with real Firebase Analytics data.
///
/// @Deprecated('Use real Firebase Analytics API in production')
/// TODO: Integrate with Firebase Analytics API to fetch real metrics
/// See: https://firebase.google.com/docs/analytics/get-started
///
/// To disable mock data:
/// - Set DEBUG_ANALYTICS_MOCK_DATA=false in build/run configuration
/// - Or ensure ReceituagroEnvironmentConfig.DEBUG_ANALYTICS_MOCK_DATA is false in production

import '../../core/constants/receituagro_environment_config.dart';

/// 🔄 DEPRECATED: Use ReceitaAgroAnalyticsEvent instead
/// This enum is kept for backward compatibility only
@Deprecated(
  'Use ReceitaAgroAnalyticsEvent from analytics_service.dart instead. '
  'This will be removed in v2.0.0',
)
enum ConversionFunnelStep {
  appOpened('app_opened'),
  signupViewed('signup_viewed'),
  signupCompleted('signup_completed'),
  premiumViewed('premium_viewed'),
  premiumPurchased('premium_purchased'),
  featureUsed('feature_used'),
  retentionDay7('retention_day_7'),
  retentionDay30('retention_day_30');

  const ConversionFunnelStep(this.stepName);
  final String stepName;
}

/// User engagement metrics
class UserEngagementMetrics {
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;
  final double avgSessionDuration;
  final int avgScreensPerSession;
  final Map<String, int> featureUsage;
  final DateTime timestamp;

  UserEngagementMetrics({
    required this.dailyActiveUsers,
    required this.weeklyActiveUsers,
    required this.monthlyActiveUsers,
    required this.avgSessionDuration,
    required this.avgScreensPerSession,
    required this.featureUsage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'daily_active_users': dailyActiveUsers,
    'weekly_active_users': weeklyActiveUsers,
    'monthly_active_users': monthlyActiveUsers,
    'avg_session_duration': avgSessionDuration,
    'avg_screens_per_session': avgScreensPerSession,
    'feature_usage': featureUsage,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Conversion funnel metrics
class ConversionFunnelMetrics {
  final Map<ConversionFunnelStep, int> stepCounts;
  final Map<ConversionFunnelStep, double> conversionRates;
  final Map<ConversionFunnelStep, double> dropOffRates;
  final DateTime timestamp;

  ConversionFunnelMetrics({
    required this.stepCounts,
    required this.conversionRates,
    required this.dropOffRates,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'step_counts': stepCounts.map((k, v) => MapEntry(k.stepName, v)),
    'conversion_rates': conversionRates.map((k, v) => MapEntry(k.stepName, v)),
    'drop_off_rates': dropOffRates.map((k, v) => MapEntry(k.stepName, v)),
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Performance metrics
class PerformanceMetrics {
  final double avgAppStartupTime;
  final double avgScreenLoadTime;
  final Map<String, double> featurePerformance;
  final int crashCount;
  final int errorCount;
  final Map<String, int> slowOperations;
  final DateTime timestamp;

  PerformanceMetrics({
    required this.avgAppStartupTime,
    required this.avgScreenLoadTime,
    required this.featurePerformance,
    required this.crashCount,
    required this.errorCount,
    required this.slowOperations,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'avg_app_startup_time': avgAppStartupTime,
    'avg_screen_load_time': avgScreenLoadTime,
    'feature_performance': featurePerformance,
    'crash_count': crashCount,
    'error_count': errorCount,
    'slow_operations': slowOperations,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Revenue metrics
class RevenueMetrics {
  final double totalRevenue;
  final double averageRevenuePerUser;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final double churnRate;
  final Map<String, double> revenueByPlan;
  final DateTime timestamp;

  RevenueMetrics({
    required this.totalRevenue,
    required this.averageRevenuePerUser,
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.churnRate,
    required this.revenueByPlan,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'total_revenue': totalRevenue,
    'average_revenue_per_user': averageRevenuePerUser,
    'total_subscriptions': totalSubscriptions,
    'active_subscriptions': activeSubscriptions,
    'churn_rate': churnRate,
    'revenue_by_plan': revenueByPlan,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Analytics Dashboard Service for ReceitauAgro
/// Provides comprehensive analytics insights and conversion tracking
class AnalyticsDashboardService {
  static AnalyticsDashboardService? _instance;
  static AnalyticsDashboardService get instance =>
      _instance ??= AnalyticsDashboardService._();

  AnalyticsDashboardService._();

  late IAnalyticsRepository _analytics;
  late AnalyticsMetricsCalculationService _calculationService;
  late AnalyticsCacheService _cacheService;
  bool _isInitialized = false;
  Timer? _cacheRefreshTimer;

  /// Helper method para verificar se deve usar mock data
  bool get _useMockData =>
      ReceituagroEnvironmentConfig.DEBUG_ANALYTICS_MOCK_DATA;

  /// Initialize analytics dashboard
  Future<void> initialize({
    required IAnalyticsRepository analytics,
    required IStorageRepository storage,
    AnalyticsMetricsCalculationService? calculationService,
    AnalyticsCacheService? cacheService,
  }) async {
    if (_isInitialized) return;

    _analytics = analytics;
    _calculationService =
        calculationService ?? AnalyticsMetricsCalculationService();
    _cacheService = cacheService ?? AnalyticsCacheService();
    _isInitialized = true;
    _startCacheRefresh();

    if (kDebugMode) {
      final mockStatus = _useMockData ? '(MOCK DATA)' : '(REAL DATA)';
      print('📊 Analytics Dashboard Service initialized $mockStatus');
    }
  }

  /// Start periodic cache refresh
  void _startCacheRefresh() {
    _cacheRefreshTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      await _refreshAllMetrics();
    });
  }

  /// Get user engagement metrics
  /// ⚠️ Returns mock data when DEBUG_ANALYTICS_MOCK_DATA is true
  Future<UserEngagementMetrics> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) throw Exception('Analytics Dashboard not initialized');

    // Alertar se usando mock data
    if (_useMockData && kDebugMode) {
      debugPrint(
        '⚠️ WARNING: Using MOCK analytics data. Set DEBUG_ANALYTICS_MOCK_DATA=false for production',
      );
    }

    final cacheKey = _cacheService.generateCacheKey(
      'user_engagement',
      startDate,
      endDate,
    );

    final cachedMetrics = _cacheService.get<UserEngagementMetrics>(cacheKey);
    if (cachedMetrics != null) {
      return cachedMetrics;
    }

    try {
      final metrics = UserEngagementMetrics(
        dailyActiveUsers: _useMockData
            ? _calculationService.calculateDAU({})
            : 0, // TODO: fetch from Firebase
        weeklyActiveUsers: _useMockData
            ? _calculationService.calculateWAU({})
            : 0, // TODO: fetch from Firebase
        monthlyActiveUsers: _useMockData
            ? _calculationService.calculateMAU({})
            : 0, // TODO: fetch from Firebase
        avgSessionDuration: _useMockData
            ? _calculationService.calculateAvgSessionDuration({})
            : 0.0,
        avgScreensPerSession: _useMockData
            ? _calculationService.calculateAvgScreensPerSession({})
            : 0,
        featureUsage: _useMockData
            ? _calculationService.calculateFeatureUsage({})
            : {},
        timestamp: DateTime.now(),
      );

      _cacheService.set(cacheKey, metrics);
      return metrics;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting engagement metrics: $e');
      rethrow;
    }
  }

  /// Get conversion funnel metrics
  Future<ConversionFunnelMetrics> getConversionFunnelMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) throw Exception('Analytics Dashboard not initialized');

    final cacheKey = _cacheService.generateCacheKey(
      'conversion_funnel',
      startDate,
      endDate,
    );

    final cachedMetrics = _cacheService.get<ConversionFunnelMetrics>(cacheKey);
    if (cachedMetrics != null) {
      return cachedMetrics;
    }

    try {
      final funnelData = <ConversionFunnelStep, int>{};

      for (final step in ConversionFunnelStep.values) {
        funnelData[step] = _calculationService.getMockFunnelData(step);
      }
      final conversionRates = _calculationService.calculateConversionRates(
        funnelData,
      );
      final dropOffRates = _calculationService.calculateDropOffRates(
        funnelData,
      );

      final metrics = ConversionFunnelMetrics(
        stepCounts: funnelData,
        conversionRates: conversionRates,
        dropOffRates: dropOffRates,
        timestamp: DateTime.now(),
      );

      _cacheService.set(cacheKey, metrics);
      return metrics;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting funnel metrics: $e');
      rethrow;
    }
  }

  /// Get performance metrics
  Future<PerformanceMetrics> getPerformanceMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) throw Exception('Analytics Dashboard not initialized');

    final cacheKey = _cacheService.generateCacheKey(
      'performance',
      startDate,
      endDate,
    );

    final cachedMetrics = _cacheService.get<PerformanceMetrics>(cacheKey);
    if (cachedMetrics != null) {
      return cachedMetrics;
    }

    try {
      final metrics = PerformanceMetrics(
        avgAppStartupTime: _calculationService.calculateAvgStartupTime({}),
        avgScreenLoadTime: _calculationService.calculateAvgScreenLoadTime({}),
        featurePerformance: _calculationService.calculateFeaturePerformance({}),
        crashCount: _calculationService.calculateCrashCount({}),
        errorCount: _calculationService.calculateErrorCount({}),
        slowOperations: _calculationService.calculateSlowOperations({}),
        timestamp: DateTime.now(),
      );

      _cacheService.set(cacheKey, metrics);
      return metrics;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting performance metrics: $e');
      rethrow;
    }
  }

  /// Get revenue metrics
  Future<RevenueMetrics> getRevenueMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) throw Exception('Analytics Dashboard not initialized');

    final cacheKey = _cacheService.generateCacheKey(
      'revenue',
      startDate,
      endDate,
    );

    final cachedMetrics = _cacheService.get<RevenueMetrics>(cacheKey);
    if (cachedMetrics != null) {
      return cachedMetrics;
    }

    try {
      final mockSubscriptionData = <Map<String, dynamic>>[];

      final metrics = RevenueMetrics(
        totalRevenue: _calculationService.calculateTotalRevenue(
          mockSubscriptionData,
        ),
        averageRevenuePerUser: _calculationService.calculateARPU(
          mockSubscriptionData,
        ),
        totalSubscriptions: _calculationService.calculateTotalSubscriptions(
          mockSubscriptionData,
        ),
        activeSubscriptions: _calculationService.calculateActiveSubscriptions(
          mockSubscriptionData,
        ),
        churnRate: _calculationService.calculateChurnRate(mockSubscriptionData),
        revenueByPlan: _calculationService.calculateRevenueByPlan(
          mockSubscriptionData,
        ),
        timestamp: DateTime.now(),
      );

      _cacheService.set(cacheKey, metrics);
      return metrics;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting revenue metrics: $e');
      rethrow;
    }
  }

  /// Export analytics report
  Future<Map<String, dynamic>> exportAnalyticsReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final engagement = await getUserEngagementMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final funnel = await getConversionFunnelMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final performance = await getPerformanceMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final revenue = await getRevenueMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final report = {
      'report_metadata': {
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'generated_at': DateTime.now().toIso8601String(),
        'app_name': 'ReceitauAgro',
      },
      'engagement_metrics': engagement.toJson(),
      'conversion_funnel': funnel.toJson(),
      'performance_metrics': performance.toJson(),
      'revenue_metrics': revenue.toJson(),
    };
    await _analytics.logEvent(
      'analytics_report_exported',
      parameters: {
        'report_type': 'comprehensive',
        'date_range':
            '${startDate?.toIso8601String()}_${endDate?.toIso8601String()}',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    return report;
  }

  /// Refresh all cached metrics
  Future<void> _refreshAllMetrics() async {
    if (!_isInitialized) return;

    try {
      _cacheService.clearAll();
      await getUserEngagementMetrics();
      await getConversionFunnelMetrics();
      await getPerformanceMetrics();
      await getRevenueMetrics();

      if (kDebugMode) {
        print('📊 Analytics metrics cache refreshed');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error refreshing metrics cache: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _cacheRefreshTimer?.cancel();
    _cacheService.clearAll();
    _isInitialized = false;
  }
}
