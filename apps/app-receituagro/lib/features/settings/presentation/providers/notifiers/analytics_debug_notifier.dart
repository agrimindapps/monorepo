import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../../core/interfaces/i_premium_service.dart';
import '../../../../../core/providers/core_providers.dart';
import '../../../../../core/services/riverpod_premium_service.dart';
import '../../../../../features/analytics/analytics_providers.dart';

part 'analytics_debug_notifier.g.dart';

/// Specialized notifier for analytics and debug operations
///
/// ✅ SINGLE RESPONSIBILITY PRINCIPLE (SRP):
/// - Manages ONLY analytics, crashes, and debug-only operations
/// - Does NOT handle user settings, notifications, or theme preferences
/// - Delegates other concerns to specialized notifiers:
///   • ThemeNotifier: theme-related settings
///   • NotificationsNotifier: notification preferences
///
/// ✅ DEPENDENCY INVERSION PRINCIPLE (DIP):
/// - Depends on repository abstractions (IAnalyticsRepository, ICrashlyticsRepository, etc.)
/// - Not on concrete implementations
/// - Allows for easy mocking and testing
///
/// ✅ DEBUG-ONLY FUNCTIONALITY:
/// - testAnalytics(): Logs test events for analytics validation
/// - testCrashlytics(): Tests crash reporting functionality
/// - generateTestLicense() / removeTestLicense(): For premium testing only
/// - showRateAppDialog(): Triggers app rating flow
///
/// ⚠️ NOTE: Debug-only methods should be gated by kDebugMode in UI layer
/// This notifier contains debug functionality and should only be used in development/testing
@riverpod
class AnalyticsDebugNotifier extends _$AnalyticsDebugNotifier {
  late final IAnalyticsRepository _analyticsRepository;
  late final ICrashlyticsRepository _crashlyticsRepository;
  late final IAppRatingRepository _appRatingRepository;
  late final IPremiumService _premiumService;

  @override
  Future<void> build() async {
    // Lazy-load dependencies via DI - follows Dependency Inversion
    // All dependencies are abstractions (interfaces), enabling polymorphism
    _analyticsRepository = ref.watch(analyticsRepositoryProvider);
    _crashlyticsRepository = ref.watch(crashlyticsRepositoryProvider);
    _appRatingRepository = ref.watch(appRatingRepositoryProvider);
    _premiumService = ref.watch(premiumServiceAdapterProvider);
  }

  /// Test analytics functionality
  Future<bool> testAnalytics() async {
    try {
      final testData = {
        'test_event': 'settings_test_analytics',
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _analyticsRepository.logEvent(
        'test_analytics',
        parameters: testData,
      );

      return true;
    } catch (e) {
      debugPrint('Error testing analytics: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Test crashlytics functionality
  Future<bool> testCrashlytics() async {
    try {
      await _crashlyticsRepository.log('Test crashlytics log from settings');

      await _crashlyticsRepository.setCustomKey(
        key: 'test_timestamp',
        value: DateTime.now().toIso8601String(),
      );

      await _crashlyticsRepository.recordError(
        exception: Exception('Test exception from settings'),
        stackTrace: StackTrace.current,
        reason: 'Testing Crashlytics integration',
        fatal: false,
      );

      return true;
    } catch (e) {
      debugPrint('Error testing crashlytics: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Show rate app dialog
  Future<bool> showRateAppDialog() async {
    try {
      await _appRatingRepository.showRatingDialog();

      await _analyticsRepository.logEvent(
        'rate_app_shown',
        parameters: {'timestamp': DateTime.now().toIso8601String()},
      );

      return true;
    } catch (e) {
      debugPrint('Error showing rate app dialog: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Generate test license (development only)
  Future<bool> generateTestLicense() async {
    try {
      await _premiumService.generateTestSubscription();
      return true;
    } catch (e) {
      debugPrint('Error generating test license: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Remove test license (development only)
  Future<bool> removeTestLicense() async {
    try {
      await _premiumService.removeTestSubscription();
      return true;
    } catch (e) {
      debugPrint('Error removing test license: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

/// Provider for IPremiumService
@riverpod
IPremiumService premiumServiceAdapter(Ref ref) {
  return RiverpodPremiumService(ref.container);
}
