import 'package:injectable/injectable.dart';

import '../analytics_dashboard_service.dart';

/// Service responsible for calculating analytics metrics
///
/// Following Single Responsibility Principle (SRP):
/// - Separates metric calculation logic from service orchestration
/// - Provides reusable calculation methods
/// - Eliminates code duplication across metric types
@lazySingleton
class AnalyticsMetricsCalculationService {
  /// Calculate Daily Active Users
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Analytics data in production
  int calculateDAU(Map<String, dynamic> data) {
    // Mock: 750 daily active users (realistic for growing app)
    return 750;
  }

  /// Calculate Weekly Active Users
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Analytics data in production
  int calculateWAU(Map<String, dynamic> data) {
    // Mock: 3500 weekly active users (~4.7x DAU is typical)
    return 3500;
  }

  /// Calculate Monthly Active Users
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Analytics data in production
  int calculateMAU(Map<String, dynamic> data) {
    // Mock: 12000 monthly active users (~16x DAU is typical)
    return 12000;
  }

  /// Calculate average session duration in minutes
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Analytics data in production
  double calculateAvgSessionDuration(Map<String, dynamic> data) {
    // Mock: 8.5 minutes average session (realistic for utility app)
    return 8.5;
  }

  /// Calculate average screens per session
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Analytics data in production
  int calculateAvgScreensPerSession(Map<String, dynamic> data) {
    // Mock: 5 screens per session average
    return 5;
  }

  /// Calculate feature usage statistics
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Analytics data in production
  Map<String, int> calculateFeatureUsage(Map<String, dynamic> data) {
    return {
      'pragas_search': 420, // Most used feature
      'diagnostics': 280, // Core feature
      'favorites': 180, // Moderate use
      'export': 95, // Less frequent
      'comments': 145, // Moderate engagement
      'premium_features': 65, // Premium adoption
    };
  }

  /// Calculate conversion rates for funnel steps
  Map<ConversionFunnelStep, double> calculateConversionRates(
    Map<ConversionFunnelStep, int> funnelData,
  ) {
    final rates = <ConversionFunnelStep, double>{};
    int previousCount = funnelData[ConversionFunnelStep.appOpened] ?? 1;

    for (final step in ConversionFunnelStep.values) {
      if (step == ConversionFunnelStep.appOpened) {
        rates[step] = 100.0;
      } else {
        final currentCount = funnelData[step] ?? 0;
        rates[step] = previousCount > 0
            ? (currentCount / previousCount * 100)
            : 0.0;
        previousCount = currentCount;
      }
    }

    return rates;
  }

  /// Calculate drop-off rates between funnel steps
  Map<ConversionFunnelStep, double> calculateDropOffRates(
    Map<ConversionFunnelStep, int> funnelData,
  ) {
    final rates = <ConversionFunnelStep, double>{};

    for (int i = 0; i < ConversionFunnelStep.values.length - 1; i++) {
      final currentStep = ConversionFunnelStep.values[i];
      final nextStep = ConversionFunnelStep.values[i + 1];

      final currentCount = funnelData[currentStep] ?? 0;
      final nextCount = funnelData[nextStep] ?? 0;

      rates[currentStep] = currentCount > 0
          ? ((currentCount - nextCount) / currentCount * 100)
          : 0.0;
    }

    return rates;
  }

  /// Get mock funnel data for a specific step
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Analytics data in production
  int getMockFunnelData(ConversionFunnelStep step) {
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

  /// Calculate average app startup time
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Performance Monitoring data in production
  double calculateAvgStartupTime(Map<String, dynamic> data) {
    // Mock: 1.8 seconds average startup (good for mobile app)
    return 1.8;
  }

  /// Calculate average screen load time
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Performance Monitoring data in production
  double calculateAvgScreenLoadTime(Map<String, dynamic> data) {
    // Mock: 0.9 seconds average screen load
    return 0.9;
  }

  /// Calculate feature performance metrics
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Performance Monitoring data in production
  Map<String, double> calculateFeaturePerformance(Map<String, dynamic> data) {
    return {
      'search': 0.5, // Fast search: 500ms
      'diagnostics': 1.2, // Complex feature: 1.2s
      'favorites': 0.3, // Simple operation: 300ms
      'export': 2.5, // Heavy operation: 2.5s
    };
  }

  /// Calculate crash count
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real Firebase Crashlytics data in production
  int calculateCrashCount(Map<String, dynamic> data) {
    // Mock: 2 crashes (realistic for stable app)
    return 2;
  }

  /// Calculate error count
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real error tracking data in production
  int calculateErrorCount(Map<String, dynamic> data) {
    // Mock: 12 non-fatal errors
    return 12;
  }

  /// Calculate slow operations
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real performance monitoring data in production
  Map<String, int> calculateSlowOperations(Map<String, dynamic> data) {
    return {
      'database_query': 3, // 3 slow queries detected
      'image_loading': 5, // 5 slow image loads
      'sync_operation': 2, // 2 slow sync operations
    };
  }

  /// Calculate total revenue
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real RevenueCat/subscription data in production
  double calculateTotalRevenue(List<Map<String, dynamic>> subscriptionData) {
    // Mock: $3,450 total monthly revenue
    return 3450.00;
  }

  /// Calculate average revenue per user
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real RevenueCat/subscription data in production
  double calculateARPU(List<Map<String, dynamic>> subscriptionData) {
    // Mock: $12.50 average revenue per user
    return 12.50;
  }

  /// Calculate total subscriptions
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real RevenueCat/subscription data in production
  int calculateTotalSubscriptions(List<Map<String, dynamic>> subscriptionData) {
    // Mock: 320 total subscriptions
    return 320;
  }

  /// Calculate active subscriptions
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real RevenueCat/subscription data in production
  int calculateActiveSubscriptions(
    List<Map<String, dynamic>> subscriptionData,
  ) {
    // Mock: 276 active subscriptions (~86% retention)
    return 276;
  }

  /// Calculate churn rate
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real RevenueCat/subscription data in production
  double calculateChurnRate(List<Map<String, dynamic>> subscriptionData) {
    // Mock: 5.8% monthly churn rate (good for SaaS)
    return 5.8;
  }

  /// Calculate revenue by plan
  /// ⚠️ MOCK DATA: Returns fixed realistic values for development
  /// TODO: Replace with real RevenueCat/subscription data in production
  Map<String, double> calculateRevenueByPlan(
    List<Map<String, dynamic>> subscriptionData,
  ) {
    return {
      'monthly': 1250.00, // Monthly plan revenue
      'yearly': 2200.00, // Yearly plan revenue (discounted but more upfront)
    };
  }
}
