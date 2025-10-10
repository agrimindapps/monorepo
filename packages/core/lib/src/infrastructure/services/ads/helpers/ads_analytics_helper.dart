import 'package:firebase_analytics/firebase_analytics.dart';
import '../../../../domain/entities/ads/ad_event_entity.dart';
import '../../../../domain/entities/ads/ad_unit_entity.dart';

/// Helper class for integrating ads events with Firebase Analytics
/// Provides standardized event tracking for all ad interactions
class AdsAnalyticsHelper {
  final FirebaseAnalytics _analytics;

  AdsAnalyticsHelper(this._analytics);

  /// Log ad impression event
  Future<void> logAdImpression({
    required AdType adType,
    required String placement,
    String? adUnitId,
  }) async {
    await _analytics.logEvent(
      name: 'ad_impression',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad clicked event
  Future<void> logAdClicked({
    required AdType adType,
    required String placement,
    String? adUnitId,
  }) async {
    await _analytics.logEvent(
      name: 'ad_clicked',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad loaded event
  Future<void> logAdLoaded({
    required AdType adType,
    required String placement,
    String? adUnitId,
    int? loadTimeMs,
  }) async {
    await _analytics.logEvent(
      name: 'ad_loaded',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        if (loadTimeMs != null) 'load_time_ms': loadTimeMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad failed to load event
  Future<void> logAdFailedToLoad({
    required AdType adType,
    required String placement,
    String? adUnitId,
    required String errorCode,
    String? errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'ad_failed_to_load',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        'error_code': errorCode,
        if (errorMessage != null) 'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad showed event
  Future<void> logAdShowed({
    required AdType adType,
    required String placement,
    String? adUnitId,
  }) async {
    await _analytics.logEvent(
      name: 'ad_showed',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad closed event
  Future<void> logAdClosed({
    required AdType adType,
    required String placement,
    String? adUnitId,
    int? viewDurationMs,
  }) async {
    await _analytics.logEvent(
      name: 'ad_closed',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        if (viewDurationMs != null) 'view_duration_ms': viewDurationMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log rewarded ad reward earned event
  Future<void> logAdRewarded({
    required String placement,
    String? adUnitId,
    required int rewardAmount,
    required String rewardType,
  }) async {
    await _analytics.logEvent(
      name: 'ad_rewarded',
      parameters: {
        'ad_type': 'rewarded',
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        'reward_amount': rewardAmount,
        'reward_type': rewardType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad frequency cap reached event
  Future<void> logAdFrequencyCapped({
    required AdType adType,
    required String placement,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'ad_frequency_capped',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        'reason': reason, // 'daily_limit', 'session_limit', 'too_soon', etc.
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log premium user blocked from seeing ad
  Future<void> logAdPremiumBlocked({
    required AdType adType,
    required String placement,
  }) async {
    await _analytics.logEvent(
      name: 'ad_premium_blocked',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad revenue (if available)
  Future<void> logAdRevenue({
    required AdType adType,
    required String placement,
    String? adUnitId,
    required double revenue,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: 'ad_revenue',
      parameters: {
        'ad_type': adType.name,
        'ad_placement': placement,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
        'value': revenue,
        'currency': currency,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log ad event from entity
  Future<void> logAdEvent(AdEventEntity event) async {
    final params = event.toAnalyticsParams();
    await _analytics.logEvent(
      name: 'ad_event',
      parameters: params.map((key, value) => MapEntry(key, value as Object)),
    );
  }

  /// Set user property for ad interactions
  Future<void> setAdUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(
      name: name,
      value: value,
    );
  }

  /// Log daily ad summary
  Future<void> logDailyAdSummary({
    required int totalAdsShown,
    required Map<String, int> adsByType,
    required Map<String, int> adsByPlacement,
  }) async {
    await _analytics.logEvent(
      name: 'ad_daily_summary',
      parameters: {
        'total_ads_shown': totalAdsShown,
        'ads_by_type': adsByType.toString(),
        'ads_by_placement': adsByPlacement.toString(),
        'date': DateTime.now().toIso8601String(),
      },
    );
  }
}
