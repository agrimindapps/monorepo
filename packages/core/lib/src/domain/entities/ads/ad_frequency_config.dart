import 'package:equatable/equatable.dart';

/// Configuration for ad frequency capping
/// Controls how often ads can be shown to users
class AdFrequencyConfig extends Equatable {
  /// Maximum number of ads per day
  final int maxAdsPerDay;

  /// Maximum number of ads per session (app lifecycle)
  final int maxAdsPerSession;

  /// Minimum interval between ads (in seconds)
  final int minIntervalSeconds;

  /// Maximum number of ads per hour
  final int? maxAdsPerHour;

  /// Whether this frequency cap is enabled
  final bool isEnabled;

  const AdFrequencyConfig({
    required this.maxAdsPerDay,
    required this.maxAdsPerSession,
    required this.minIntervalSeconds,
    this.maxAdsPerHour,
    this.isEnabled = true,
  });

  /// Default configuration for interstitial ads
  /// Conservative approach: max 10/day, 5/session, 5min between
  factory AdFrequencyConfig.defaultInterstitial() => const AdFrequencyConfig(
        maxAdsPerDay: 10,
        maxAdsPerSession: 5,
        minIntervalSeconds: 300, // 5 minutes
        maxAdsPerHour: 3,
      );

  /// Default configuration for rewarded ads
  /// More generous since user-initiated
  factory AdFrequencyConfig.defaultRewarded() => const AdFrequencyConfig(
        maxAdsPerDay: 20,
        maxAdsPerSession: 10,
        minIntervalSeconds: 60, // 1 minute
        maxAdsPerHour: 5,
      );

  /// Default configuration for banner ads
  /// No strict limits since less intrusive
  factory AdFrequencyConfig.defaultBanner() => const AdFrequencyConfig(
        maxAdsPerDay: 100,
        maxAdsPerSession: 50,
        minIntervalSeconds: 0, // No minimum interval
      );

  /// Default configuration for app open ads
  /// Very conservative: only on cold starts
  factory AdFrequencyConfig.defaultAppOpen() => const AdFrequencyConfig(
        maxAdsPerDay: 5,
        maxAdsPerSession: 1,
        minIntervalSeconds: 14400, // 4 hours
        maxAdsPerHour: 1,
      );

  /// Unlimited configuration (use with caution!)
  factory AdFrequencyConfig.unlimited() => const AdFrequencyConfig(
        maxAdsPerDay: 9999,
        maxAdsPerSession: 9999,
        minIntervalSeconds: 0,
        isEnabled: false,
      );

  AdFrequencyConfig copyWith({
    int? maxAdsPerDay,
    int? maxAdsPerSession,
    int? minIntervalSeconds,
    int? maxAdsPerHour,
    bool? isEnabled,
  }) {
    return AdFrequencyConfig(
      maxAdsPerDay: maxAdsPerDay ?? this.maxAdsPerDay,
      maxAdsPerSession: maxAdsPerSession ?? this.maxAdsPerSession,
      minIntervalSeconds: minIntervalSeconds ?? this.minIntervalSeconds,
      maxAdsPerHour: maxAdsPerHour ?? this.maxAdsPerHour,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [
        maxAdsPerDay,
        maxAdsPerSession,
        minIntervalSeconds,
        maxAdsPerHour,
        isEnabled,
      ];

  @override
  String toString() => 'AdFrequencyConfig('
      'maxPerDay: $maxAdsPerDay, '
      'maxPerSession: $maxAdsPerSession, '
      'minInterval: ${minIntervalSeconds}s)';
}
