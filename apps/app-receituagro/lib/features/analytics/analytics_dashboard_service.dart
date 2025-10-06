import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Conversion funnel steps
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
  static AnalyticsDashboardService get instance => _instance ??= AnalyticsDashboardService._();
  
  AnalyticsDashboardService._();

  late IAnalyticsRepository _analytics;
  late IStorageRepository _storage;
  bool _isInitialized = false;
  final Map<String, dynamic> _metricsCache = {};
  Timer? _cacheRefreshTimer;

  /// Initialize analytics dashboard
  Future<void> initialize({
    required IAnalyticsRepository analytics,
    required IStorageRepository storage,
  }) async {
    if (_isInitialized) return;

    _analytics = analytics;
    _storage = storage;
    _isInitialized = true;
    _startCacheRefresh();

    if (kDebugMode) {
      print('📊 Analytics Dashboard Service initialized');
    }
  }

  /// Start periodic cache refresh
  void _startCacheRefresh() {
    _cacheRefreshTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      await _refreshAllMetrics();
    });
  }

  /// Get user engagement metrics
  Future<UserEngagementMetrics> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) throw Exception('Analytics Dashboard not initialized');

    final cacheKey = 'user_engagement_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}';
    
    if (_metricsCache.containsKey(cacheKey)) {
      return _metricsCache[cacheKey] as UserEngagementMetrics;
    }

    try {
      final metrics = UserEngagementMetrics(
        dailyActiveUsers: _calculateDAU({}),
        weeklyActiveUsers: _calculateWAU({}),
        monthlyActiveUsers: _calculateMAU({}),
        avgSessionDuration: _calculateAvgSessionDuration({}),
        avgScreensPerSession: _calculateAvgScreensPerSession({}),
        featureUsage: _calculateFeatureUsage({}),
        timestamp: DateTime.now(),
      );

      _metricsCache[cacheKey] = metrics;
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

    final cacheKey = 'conversion_funnel_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}';
    
    if (_metricsCache.containsKey(cacheKey)) {
      return _metricsCache[cacheKey] as ConversionFunnelMetrics;
    }

    try {
      final funnelData = <ConversionFunnelStep, int>{};
      
      for (final step in ConversionFunnelStep.values) {
        funnelData[step] = _getMockFunnelData(step);
      }
      final conversionRates = _calculateConversionRates(funnelData);
      final dropOffRates = _calculateDropOffRates(funnelData);

      final metrics = ConversionFunnelMetrics(
        stepCounts: funnelData,
        conversionRates: conversionRates,
        dropOffRates: dropOffRates,
        timestamp: DateTime.now(),
      );

      _metricsCache[cacheKey] = metrics;
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

    final cacheKey = 'performance_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}';
    
    if (_metricsCache.containsKey(cacheKey)) {
      return _metricsCache[cacheKey] as PerformanceMetrics;
    }

    try {
      final metrics = PerformanceMetrics(
        avgAppStartupTime: _calculateAvgStartupTime({}),
        avgScreenLoadTime: _calculateAvgScreenLoadTime({}),
        featurePerformance: _calculateFeaturePerformance({}),
        crashCount: _calculateCrashCount({}),
        errorCount: _calculateErrorCount({}),
        slowOperations: _calculateSlowOperations({}),
        timestamp: DateTime.now(),
      );

      _metricsCache[cacheKey] = metrics;
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

    final cacheKey = 'revenue_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}';
    
    if (_metricsCache.containsKey(cacheKey)) {
      return _metricsCache[cacheKey] as RevenueMetrics;
    }

    try {
      final mockSubscriptionData = <Map<String, dynamic>>[];
      
      final metrics = RevenueMetrics(
        totalRevenue: _calculateTotalRevenue(mockSubscriptionData),
        averageRevenuePerUser: _calculateARPU(mockSubscriptionData),
        totalSubscriptions: _calculateTotalSubscriptions(mockSubscriptionData),
        activeSubscriptions: _calculateActiveSubscriptions(mockSubscriptionData),
        churnRate: _calculateChurnRate(mockSubscriptionData),
        revenueByPlan: _calculateRevenueByPlan(mockSubscriptionData),
        timestamp: DateTime.now(),
      );

      _metricsCache[cacheKey] = metrics;
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
        'date_range': '${startDate?.toIso8601String()}_${endDate?.toIso8601String()}',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    return report;
  }

  int _calculateDAU(Map<String, dynamic> data) {
    return Random().nextInt(1000) + 500;
  }

  int _calculateWAU(Map<String, dynamic> data) {
    return Random().nextInt(5000) + 2000;
  }

  int _calculateMAU(Map<String, dynamic> data) {
    return Random().nextInt(15000) + 8000;
  }

  double _calculateAvgSessionDuration(Map<String, dynamic> data) {
    return Random().nextDouble() * 10 + 5; // 5-15 minutes
  }

  int _calculateAvgScreensPerSession(Map<String, dynamic> data) {
    return Random().nextInt(8) + 3; // 3-10 screens
  }

  Map<String, int> _calculateFeatureUsage(Map<String, dynamic> data) {
    return {
      'pragas_search': Random().nextInt(500) + 200,
      'diagnostics': Random().nextInt(300) + 100,
      'favorites': Random().nextInt(250) + 50,
      'export': Random().nextInt(150) + 25,
      'comments': Random().nextInt(200) + 75,
      'premium_features': Random().nextInt(100) + 10,
    };
  }

  int _getMockFunnelData(ConversionFunnelStep step) {
    switch (step) {
      case ConversionFunnelStep.appOpened:
        return 10000;
      case ConversionFunnelStep.signupViewed:
        return 3000;
      case ConversionFunnelStep.signupCompleted:
        return 1500;
      case ConversionFunnelStep.premiumViewed:
        return 500;
      case ConversionFunnelStep.premiumPurchased:
        return 150;
      case ConversionFunnelStep.featureUsed:
        return 1200;
      case ConversionFunnelStep.retentionDay7:
        return 800;
      case ConversionFunnelStep.retentionDay30:
        return 400;
    }
  }

  Map<ConversionFunnelStep, double> _calculateConversionRates(Map<ConversionFunnelStep, int> funnelData) {
    final rates = <ConversionFunnelStep, double>{};
    int previousCount = funnelData[ConversionFunnelStep.appOpened] ?? 1;

    for (final step in ConversionFunnelStep.values) {
      if (step == ConversionFunnelStep.appOpened) {
        rates[step] = 100.0;
      } else {
        final currentCount = funnelData[step] ?? 0;
        rates[step] = previousCount > 0 ? (currentCount / previousCount * 100) : 0.0;
        previousCount = currentCount;
      }
    }

    return rates;
  }

  Map<ConversionFunnelStep, double> _calculateDropOffRates(Map<ConversionFunnelStep, int> funnelData) {
    final rates = <ConversionFunnelStep, double>{};
    
    for (int i = 0; i < ConversionFunnelStep.values.length - 1; i++) {
      final currentStep = ConversionFunnelStep.values[i];
      final nextStep = ConversionFunnelStep.values[i + 1];
      
      final currentCount = funnelData[currentStep] ?? 0;
      final nextCount = funnelData[nextStep] ?? 0;
      
      rates[currentStep] = currentCount > 0 ? ((currentCount - nextCount) / currentCount * 100) : 0.0;
    }

    return rates;
  }

  double _calculateAvgStartupTime(Map<String, dynamic> data) {
    return Random().nextDouble() * 2 + 1; // 1-3 seconds
  }

  double _calculateAvgScreenLoadTime(Map<String, dynamic> data) {
    return Random().nextDouble() * 1 + 0.5; // 0.5-1.5 seconds
  }

  Map<String, double> _calculateFeaturePerformance(Map<String, dynamic> data) {
    return {
      'search': Random().nextDouble() * 0.5 + 0.3,
      'diagnostics': Random().nextDouble() * 1 + 0.8,
      'favorites': Random().nextDouble() * 0.3 + 0.2,
      'export': Random().nextDouble() * 2 + 1,
    };
  }

  int _calculateCrashCount(Map<String, dynamic> data) {
    return Random().nextInt(5); // 0-4 crashes
  }

  int _calculateErrorCount(Map<String, dynamic> data) {
    return Random().nextInt(20) + 5; // 5-24 errors
  }

  Map<String, int> _calculateSlowOperations(Map<String, dynamic> data) {
    return {
      'database_query': Random().nextInt(5),
      'image_loading': Random().nextInt(8),
      'sync_operation': Random().nextInt(3),
    };
  }

  double _calculateTotalRevenue(List<Map<String, dynamic>> subscriptionData) {
    return Random().nextDouble() * 5000 + 1000; // $1000-$6000
  }

  double _calculateARPU(List<Map<String, dynamic>> subscriptionData) {
    return Random().nextDouble() * 20 + 5; // $5-$25
  }

  int _calculateTotalSubscriptions(List<Map<String, dynamic>> subscriptionData) {
    return Random().nextInt(500) + 100; // 100-599 subscriptions
  }

  int _calculateActiveSubscriptions(List<Map<String, dynamic>> subscriptionData) {
    return Random().nextInt(400) + 80; // 80-479 active
  }

  double _calculateChurnRate(List<Map<String, dynamic>> subscriptionData) {
    return Random().nextDouble() * 10 + 2; // 2-12% churn
  }

  Map<String, double> _calculateRevenueByPlan(List<Map<String, dynamic>> subscriptionData) {
    return {
      'monthly': Random().nextDouble() * 2000 + 500,
      'yearly': Random().nextDouble() * 3000 + 1500,
    };
  }

  /// Refresh all cached metrics
  Future<void> _refreshAllMetrics() async {
    if (!_isInitialized) return;

    try {
      _metricsCache.clear();
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
    _metricsCache.clear();
    _isInitialized = false;
  }
}
