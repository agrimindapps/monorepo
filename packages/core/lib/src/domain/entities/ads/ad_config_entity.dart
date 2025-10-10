import 'package:equatable/equatable.dart';
import 'ad_frequency_config.dart';
import 'ad_unit_entity.dart';

/// Domain entity for complete ad configuration
/// Contains all settings needed for ad management
class AdConfigEntity extends Equatable {
  /// Google Mobile Ads App ID (platform-specific)
  final String appId;

  /// Map of ad types to their Ad Unit IDs
  final Map<AdType, String> adUnitIds;

  /// Whether app is in test mode (shows test ads)
  final bool testMode;

  /// List of test device IDs (for production testing)
  final List<String> testDeviceIds;

  /// Whether to show ads to premium/subscribed users
  final bool showAdsForPremium;

  /// Frequency capping configurations per ad type
  final Map<AdType, AdFrequencyConfig> frequencyConfigs;

  /// Environment indicator
  final String? environment;

  const AdConfigEntity({
    required this.appId,
    required this.adUnitIds,
    this.testMode = false,
    this.testDeviceIds = const [],
    this.showAdsForPremium = false,
    this.frequencyConfigs = const {},
    this.environment,
  });

  /// Creates a default configuration for development
  factory AdConfigEntity.development({
    required String appId,
    required Map<AdType, String> testAdUnitIds,
  }) {
    return AdConfigEntity(
      appId: appId,
      adUnitIds: testAdUnitIds,
      testMode: true,
      showAdsForPremium: false,
      frequencyConfigs: {
        AdType.interstitial: AdFrequencyConfig.defaultInterstitial(),
        AdType.rewarded: AdFrequencyConfig.defaultRewarded(),
        AdType.banner: AdFrequencyConfig.defaultBanner(),
        AdType.appOpen: AdFrequencyConfig.defaultAppOpen(),
      },
      environment: 'development',
    );
  }

  /// Creates a production configuration
  factory AdConfigEntity.production({
    required String appId,
    required Map<AdType, String> productionAdUnitIds,
    List<String> testDeviceIds = const [],
  }) {
    return AdConfigEntity(
      appId: appId,
      adUnitIds: productionAdUnitIds,
      testMode: false,
      testDeviceIds: testDeviceIds,
      showAdsForPremium: false,
      frequencyConfigs: {
        AdType.interstitial: AdFrequencyConfig.defaultInterstitial(),
        AdType.rewarded: AdFrequencyConfig.defaultRewarded(),
        AdType.banner: AdFrequencyConfig.defaultBanner(),
        AdType.appOpen: AdFrequencyConfig.defaultAppOpen(),
      },
      environment: 'production',
    );
  }

  /// Get frequency config for specific ad type
  AdFrequencyConfig? getFrequencyConfig(AdType type) {
    return frequencyConfigs[type];
  }

  /// Get ad unit ID for specific ad type
  String? getAdUnitId(AdType type) {
    return adUnitIds[type];
  }

  /// Check if ad type is configured
  bool hasAdUnitId(AdType type) {
    return adUnitIds.containsKey(type) && adUnitIds[type]!.isNotEmpty;
  }

  AdConfigEntity copyWith({
    String? appId,
    Map<AdType, String>? adUnitIds,
    bool? testMode,
    List<String>? testDeviceIds,
    bool? showAdsForPremium,
    Map<AdType, AdFrequencyConfig>? frequencyConfigs,
    String? environment,
  }) {
    return AdConfigEntity(
      appId: appId ?? this.appId,
      adUnitIds: adUnitIds ?? this.adUnitIds,
      testMode: testMode ?? this.testMode,
      testDeviceIds: testDeviceIds ?? this.testDeviceIds,
      showAdsForPremium: showAdsForPremium ?? this.showAdsForPremium,
      frequencyConfigs: frequencyConfigs ?? this.frequencyConfigs,
      environment: environment ?? this.environment,
    );
  }

  @override
  List<Object?> get props => [
        appId,
        adUnitIds,
        testMode,
        testDeviceIds,
        showAdsForPremium,
        frequencyConfigs,
        environment,
      ];

  @override
  String toString() => 'AdConfigEntity('
      'appId: $appId, '
      'testMode: $testMode, '
      'environment: $environment)';
}
