import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../domain/entities/ads/ad_config_entity.dart';
import '../../../../domain/entities/ads/ad_frequency_config.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../domain/entities/ads/ad_unit_entity.dart';
import '../../../../shared/utils/failure.dart';
import '../models/ad_unit_config_model.dart';

/// Specialized service for ad configuration management
/// Responsible for loading, storing, and managing ad configurations
/// Follows SRP - Single Responsibility: Configuration Management
class AdConfigService {
  static const String _boxName = 'ads_config';
  static const String _configKey = 'current_config';

  Box<AdUnitConfigModel>? _configBox;
  AdConfigEntity? _currentConfig;

  /// Get current platform identifier
  String get platform => Platform.isAndroid ? 'android' : 'ios';

  /// Get current configuration
  AdConfigEntity? get currentConfig => _currentConfig;

  /// Initialize the service and load saved configuration
  Future<Either<Failure, void>> initialize() async {
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(40)) {
        // Will be registered after code generation
        // Hive.registerAdapter(AdUnitConfigModelAdapter());
      }

      // Open Hive box
      _configBox = await Hive.openBox<AdUnitConfigModel>(_boxName);

      // Load saved config or create default
      final savedConfig = _configBox!.get(_configKey);
      if (savedConfig != null) {
        _currentConfig = savedConfig.toEntity();
      } else {
        // Create default development config
        final defaultModel = AdUnitConfigModel.development(platform: platform);
        await _configBox!.put(_configKey, defaultModel);
        _currentConfig = defaultModel.toEntity();
      }

      return const Right(null);
    } catch (e) {
      return Left(
        AdConfigFailure(
          'Failed to initialize ad config service: ${e.toString()}',
          code: 'CONFIG_INIT_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Update configuration
  Future<Either<Failure, void>> updateConfig(AdConfigEntity config) async {
    try {
      if (_configBox == null) {
        return Left(
          AdConfigFailure.missingConfiguration(),
        );
      }

      final model = AdUnitConfigModel.fromEntity(config);
      await _configBox!.put(_configKey, model);
      _currentConfig = config;

      return const Right(null);
    } catch (e) {
      return Left(
        AdConfigFailure(
          'Failed to update config: ${e.toString()}',
          code: 'CONFIG_UPDATE_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Set production configuration
  Future<Either<Failure, void>> setProductionConfig({
    required String appId,
    required Map<AdType, String> productionAdUnitIds,
    List<String> testDeviceIds = const [],
  }) async {
    final config = AdConfigEntity.production(
      appId: appId,
      productionAdUnitIds: productionAdUnitIds,
      testDeviceIds: testDeviceIds,
    );

    return updateConfig(config);
  }

  /// Set development configuration
  Future<Either<Failure, void>> setDevelopmentConfig() async {
    final model = AdUnitConfigModel.development(platform: platform);
    return updateConfig(model.toEntity());
  }

  /// Get ad unit ID for specific ad type
  Either<Failure, String> getAdUnitId(AdType adType) {
    if (_currentConfig == null) {
      return Left(AdConfigFailure.missingConfiguration());
    }

    final adUnitId = _currentConfig!.getAdUnitId(adType);
    if (adUnitId == null || adUnitId.isEmpty) {
      return Left(AdConfigFailure.invalidAdUnitId(adType.name));
    }

    return Right(adUnitId);
  }

  /// Get frequency config for specific ad type
  Either<Failure, AdFrequencyConfig> getFrequencyConfig(AdType adType) {
    if (_currentConfig == null) {
      return Left(AdConfigFailure.missingConfiguration());
    }

    final frequencyConfig = _currentConfig!.getFrequencyConfig(adType);
    if (frequencyConfig == null) {
      // Return default config based on ad type
      return Right(_getDefaultFrequencyConfig(adType));
    }

    return Right(frequencyConfig);
  }

  /// Get default frequency config for ad type
  AdFrequencyConfig _getDefaultFrequencyConfig(AdType adType) {
    switch (adType) {
      case AdType.interstitial:
      case AdType.rewardedInterstitial:
        return AdFrequencyConfig.defaultInterstitial();
      case AdType.rewarded:
        return AdFrequencyConfig.defaultRewarded();
      case AdType.banner:
      case AdType.native:
        return AdFrequencyConfig.defaultBanner();
      case AdType.appOpen:
        return AdFrequencyConfig.defaultAppOpen();
    }
  }

  /// Check if configuration is valid
  bool get isConfigValid {
    return _currentConfig != null && _currentConfig!.appId.isNotEmpty;
  }

  /// Check if test mode is enabled
  bool get isTestMode {
    return _currentConfig?.testMode ?? false;
  }

  /// Get test device IDs
  List<String> get testDeviceIds {
    return _currentConfig?.testDeviceIds ?? [];
  }

  /// Get app ID
  String get appId {
    return _currentConfig?.appId ?? '';
  }

  /// Check if should show ads for premium users
  bool get showAdsForPremium {
    return _currentConfig?.showAdsForPremium ?? false;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _configBox?.close();
    _configBox = null;
    _currentConfig = null;
  }
}
