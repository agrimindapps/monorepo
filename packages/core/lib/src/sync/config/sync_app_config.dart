/// Configuration classes for app-specific sync settings
/// Apps should register their configuration at startup instead of hardcoding in core
library;

/// Sync limits configuration for an app
class SyncLimitsConfig {
  final String appId;
  final int maxOfflineItems;
  final int maxSyncFrequencyMinutes;
  final bool allowBackgroundSync;
  final bool allowLargeFileSync;

  const SyncLimitsConfig({
    required this.appId,
    required this.maxOfflineItems,
    required this.maxSyncFrequencyMinutes,
    required this.allowBackgroundSync,
    required this.allowLargeFileSync,
  });

  /// Default configuration for apps that don't specify their own
  static const SyncLimitsConfig defaultConfig = SyncLimitsConfig(
    appId: 'default',
    maxOfflineItems: 50,
    maxSyncFrequencyMinutes: 30,
    allowBackgroundSync: false,
    allowLargeFileSync: false,
  );

  /// Premium configuration (unlimited)
  static const SyncLimitsConfig premiumConfig = SyncLimitsConfig(
    appId: 'premium',
    maxOfflineItems: -1,
    maxSyncFrequencyMinutes: 1,
    allowBackgroundSync: true,
    allowLargeFileSync: true,
  );
}

/// Offline capabilities configuration for an app
class OfflineCapabilitiesConfig {
  final String appId;
  final bool hasOfflineSupport;
  final bool canCreateOffline;
  final bool canEditOffline;
  final bool canDeleteOffline;
  final Set<String> offlineFeatures;

  const OfflineCapabilitiesConfig({
    required this.appId,
    required this.hasOfflineSupport,
    required this.canCreateOffline,
    required this.canEditOffline,
    required this.canDeleteOffline,
    required this.offlineFeatures,
  });

  /// Default configuration for apps without offline support
  static OfflineCapabilitiesConfig noOfflineSupport(String appId) {
    return OfflineCapabilitiesConfig(
      appId: appId,
      hasOfflineSupport: false,
      canCreateOffline: false,
      canEditOffline: false,
      canDeleteOffline: false,
      offlineFeatures: const {},
    );
  }

  /// Full offline support configuration
  static OfflineCapabilitiesConfig fullOfflineSupport(
    String appId,
    Set<String> features,
  ) {
    return OfflineCapabilitiesConfig(
      appId: appId,
      hasOfflineSupport: true,
      canCreateOffline: true,
      canEditOffline: true,
      canDeleteOffline: true,
      offlineFeatures: features,
    );
  }

  bool supportsFeature(String feature) => offlineFeatures.contains(feature);
}

/// Registry for app-specific sync configurations
/// Apps should register their configuration at startup
class SyncConfigRegistry {
  static final Map<String, SyncLimitsConfig> _syncLimitsConfigs = {};
  static final Map<String, OfflineCapabilitiesConfig> _offlineCapabilitiesConfigs = {};

  /// Register sync limits configuration for an app
  static void registerSyncLimits(SyncLimitsConfig config) {
    _syncLimitsConfigs[config.appId] = config;
  }

  /// Register offline capabilities configuration for an app
  static void registerOfflineCapabilities(OfflineCapabilitiesConfig config) {
    _offlineCapabilitiesConfigs[config.appId] = config;
  }

  /// Get sync limits configuration for an app
  /// Returns premium config if isPremium is true, otherwise returns app-specific or default
  static SyncLimitsConfig getSyncLimits(String appId, bool isPremium) {
    if (isPremium) {
      return SyncLimitsConfig.premiumConfig;
    }
    return _syncLimitsConfigs[appId] ?? SyncLimitsConfig.defaultConfig;
  }

  /// Get offline capabilities configuration for an app
  static OfflineCapabilitiesConfig getOfflineCapabilities(String appId) {
    return _offlineCapabilitiesConfigs[appId] ??
           OfflineCapabilitiesConfig.noOfflineSupport(appId);
  }

  /// Clear all registered configurations (useful for testing)
  static void clearAll() {
    _syncLimitsConfigs.clear();
    _offlineCapabilitiesConfigs.clear();
  }
}
