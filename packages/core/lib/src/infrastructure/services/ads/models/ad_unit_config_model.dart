import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../domain/entities/ads/ad_config_entity.dart';
import '../../../../domain/entities/ads/ad_frequency_config.dart';
import '../../../../domain/entities/ads/ad_unit_entity.dart';

part 'ad_unit_config_model.g.dart';

/// Hive model for ad unit configuration
/// TypeId: 40
@HiveType(typeId: 40)
@JsonSerializable()
class AdUnitConfigModel extends HiveObject {
  /// Google Mobile Ads App ID
  @HiveField(0)
  final String appId;

  /// Map of ad type keys to Ad Unit IDs
  /// Keys: 'banner', 'interstitial', 'rewarded', etc.
  @HiveField(1)
  final Map<String, String> adUnitIds;

  /// Whether app is in test mode
  @HiveField(2)
  final bool testMode;

  /// Test device IDs for production testing
  @HiveField(3)
  final List<String> testDeviceIds;

  /// Show ads to premium users
  @HiveField(4)
  final bool showAdsForPremium;

  /// When this config was created
  @HiveField(5)
  final DateTime? createdAt;

  /// When this config was last updated
  @HiveField(6)
  final DateTime? updatedAt;

  /// Environment: 'development', 'staging', 'production'
  @HiveField(7)
  final String? environment;

  AdUnitConfigModel({
    required this.appId,
    required this.adUnitIds,
    this.testMode = false,
    this.testDeviceIds = const [],
    this.showAdsForPremium = false,
    this.createdAt,
    this.updatedAt,
    this.environment,
  });

  /// Create from JSON
  factory AdUnitConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AdUnitConfigModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$AdUnitConfigModelToJson(this);

  /// Convert to domain entity
  AdConfigEntity toEntity() {
    return AdConfigEntity(
      appId: appId,
      adUnitIds: adUnitIds.map(
        (key, value) => MapEntry(_parseAdType(key), value),
      ),
      testMode: testMode,
      testDeviceIds: testDeviceIds,
      showAdsForPremium: showAdsForPremium,
      frequencyConfigs: _getDefaultFrequencyConfigs(),
      environment: environment,
    );
  }

  /// Create from domain entity
  factory AdUnitConfigModel.fromEntity(AdConfigEntity entity) {
    return AdUnitConfigModel(
      appId: entity.appId,
      adUnitIds: entity.adUnitIds.map(
        (key, value) => MapEntry(key.key, value),
      ),
      testMode: entity.testMode,
      testDeviceIds: entity.testDeviceIds,
      showAdsForPremium: entity.showAdsForPremium,
      environment: entity.environment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default development config
  factory AdUnitConfigModel.development({
    required String platform, // 'android' or 'ios'
  }) {
    return AdUnitConfigModel(
      appId: platform == 'android'
          ? 'ca-app-pub-3940256099942544~3347511713' // Android test app ID
          : 'ca-app-pub-3940256099942544~1458002511', // iOS test app ID
      adUnitIds: {
        'banner': platform == 'android'
            ? 'ca-app-pub-3940256099942544/6300978111' // Android test banner
            : 'ca-app-pub-3940256099942544/2934735716', // iOS test banner
        'interstitial': platform == 'android'
            ? 'ca-app-pub-3940256099942544/1033173712' // Android test interstitial
            : 'ca-app-pub-3940256099942544/4411468910', // iOS test interstitial
        'rewarded': platform == 'android'
            ? 'ca-app-pub-3940256099942544/5224354917' // Android test rewarded
            : 'ca-app-pub-3940256099942544/1712485313', // iOS test rewarded
        'rewarded_interstitial': platform == 'android'
            ? 'ca-app-pub-3940256099942544/5354046379' // Android test rewarded interstitial
            : 'ca-app-pub-3940256099942544/6978759866', // iOS test rewarded interstitial
        'app_open': platform == 'android'
            ? 'ca-app-pub-3940256099942544/3419835294' // Android test app open
            : 'ca-app-pub-3940256099942544/5662855259', // iOS test app open
      },
      testMode: true,
      showAdsForPremium: false,
      environment: 'development',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Parse ad type key to enum
  static AdType _parseAdType(String key) {
    switch (key) {
      case 'banner':
        return AdType.banner;
      case 'interstitial':
        return AdType.interstitial;
      case 'rewarded':
        return AdType.rewarded;
      case 'rewarded_interstitial':
        return AdType.rewardedInterstitial;
      case 'app_open':
        return AdType.appOpen;
      case 'native':
        return AdType.native;
      default:
        throw ArgumentError('Unknown AdType key: $key');
    }
  }

  /// Get default frequency configs
  Map<AdType, AdFrequencyConfig> _getDefaultFrequencyConfigs() {
    return {
      AdType.interstitial: AdFrequencyConfig.defaultInterstitial(),
      AdType.rewarded: AdFrequencyConfig.defaultRewarded(),
      AdType.banner: AdFrequencyConfig.defaultBanner(),
      AdType.appOpen: AdFrequencyConfig.defaultAppOpen(),
      AdType.rewardedInterstitial: AdFrequencyConfig.defaultInterstitial(),
    };
  }

  /// Copy with new values
  AdUnitConfigModel copyWith({
    String? appId,
    Map<String, String>? adUnitIds,
    bool? testMode,
    List<String>? testDeviceIds,
    bool? showAdsForPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? environment,
  }) {
    return AdUnitConfigModel(
      appId: appId ?? this.appId,
      adUnitIds: adUnitIds ?? this.adUnitIds,
      testMode: testMode ?? this.testMode,
      testDeviceIds: testDeviceIds ?? this.testDeviceIds,
      showAdsForPremium: showAdsForPremium ?? this.showAdsForPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      environment: environment ?? this.environment,
    );
  }
}
