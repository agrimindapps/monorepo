import 'package:core/core.dart' hide Column;

import '../../domain/entities/device_settings_entity.dart';
import '../../domain/entities/notification_settings_entity.dart';
import '../../domain/entities/premium_settings_entity.dart';
import '../../domain/entities/theme_settings_entity.dart';
import 'device_notifier.dart';
import 'notification_notifier.dart';
import 'premium_notifier.dart';
import 'theme_notifier.dart';

/// Combined model representing all user settings
/// Aggregates theme, notification, device, and premium settings into a single model
///
/// Benefits:
/// - Single source of truth for all settings
/// - Easy to persist all settings together
/// - Convenient for UI components that need multiple setting types
/// - Type-safe way to access all settings
class UserSettingsModel {
  /// Theme-related settings
  final ThemeSettingsEntity themeSettings;

  /// Notification-related settings
  final NotificationSettingsEntity notificationSettings;

  /// Device-related settings
  final DeviceSettingsEntity deviceSettings;

  /// Premium-related settings
  final PremiumSettingsEntity premiumSettings;

  /// Whether any loading operation is in progress
  final bool isLoading;

  /// Error message if any operation failed
  final String? error;

  const UserSettingsModel({
    required this.themeSettings,
    required this.notificationSettings,
    required this.deviceSettings,
    required this.premiumSettings,
    required this.isLoading,
    this.error,
  });

  /// Factory constructor for initial/default state
  factory UserSettingsModel.initial(String deviceId) {
    return UserSettingsModel(
      themeSettings: ThemeSettingsEntity.defaults(),
      notificationSettings: NotificationSettingsEntity.defaults(),
      deviceSettings: DeviceSettingsEntity.defaults(deviceId),
      premiumSettings: PremiumSettingsEntity.defaults(),
      isLoading: false,
      error: null,
    );
  }

  /// Creates a copy with any specified fields replaced
  UserSettingsModel copyWith({
    ThemeSettingsEntity? themeSettings,
    NotificationSettingsEntity? notificationSettings,
    DeviceSettingsEntity? deviceSettings,
    PremiumSettingsEntity? premiumSettings,
    bool? isLoading,
    String? error,
  }) {
    return UserSettingsModel(
      themeSettings: themeSettings ?? this.themeSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      deviceSettings: deviceSettings ?? this.deviceSettings,
      premiumSettings: premiumSettings ?? this.premiumSettings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Clears error message
  UserSettingsModel clearError() {
    return copyWith(error: null);
  }

  // ============================================================================
  // CONVENIENCE GETTERS - Theme
  // ============================================================================

  /// Get current dark mode status
  bool get isDarkTheme => themeSettings.isDarkTheme;

  /// Get current language
  String get language => themeSettings.language;

  /// Get human-readable language name
  String get languageDisplayName => themeSettings.languageDisplayName;

  /// Check if using RTL language
  bool get isRtlLanguage => themeSettings.isRtlLanguage;

  // ============================================================================
  // CONVENIENCE GETTERS - Notifications
  // ============================================================================

  /// Check if notifications are enabled
  bool get notificationsEnabled => notificationSettings.notificationsEnabled;

  /// Check if notification sound is enabled
  bool get soundEnabled => notificationSettings.soundEnabled;

  /// Check if promotional notifications are enabled
  bool get promotionalNotificationsEnabled =>
      notificationSettings.promotionalNotificationsEnabled;

  /// Check if sound will actually play
  bool get willPlaySound => notificationSettings.willPlaySound;

  /// Get notification level
  NotificationLevel get notificationLevel =>
      notificationSettings.notificationLevel;

  // ============================================================================
  // CONVENIENCE GETTERS - Device Management
  // ============================================================================

  /// Get current device ID
  String get currentDeviceId => deviceSettings.currentDeviceId;

  /// Get list of all connected devices
  List<String> get connectedDevices => deviceSettings.connectedDevices;

  /// Get number of connected devices
  int get deviceCount => deviceSettings.deviceCount;

  /// Check if sync is enabled
  bool get syncEnabled => deviceSettings.syncEnabled;

  /// Check if sync is needed (>24h or never)
  bool get needsSync => deviceSettings.needsSync;

  /// Get time since last sync
  Duration? get timeSinceLastSync => deviceSettings.timeSinceLastSync;

  // ============================================================================
  // CONVENIENCE GETTERS - Premium Features
  // ============================================================================

  /// Check if user has premium features
  bool get hasPremiumFeatures => premiumSettings.hasPremiumFeatures;

  /// Check if development mode is enabled
  bool get isDevelopmentMode => premiumSettings.isDevelopmentMode;

  /// Check if analytics is enabled
  bool get analyticsEnabled => premiumSettings.analyticsEnabled;

  /// Get feature tier (free/premium/debug)
  FeatureTier get featureTier => premiumSettings.featureTier;

  /// Get list of available features
  List<String> get availableFeatures => premiumSettings.availableFeatures;

  // ============================================================================
  // COMPOSITE VALIDATION & QUERIES
  // ============================================================================

  /// Check if all settings are valid
  bool get isValid {
    return themeSettings.isValid &&
        notificationSettings.isValid &&
        deviceSettings.isValid &&
        premiumSettings.isValid;
  }

  /// Check if any setting has changed
  /// Useful for detecting unsaved changes
  bool hasAnyChanges(UserSettingsModel other) {
    return themeSettings != other.themeSettings ||
        notificationSettings != other.notificationSettings ||
        deviceSettings != other.deviceSettings ||
        premiumSettings != other.premiumSettings;
  }

  /// Get a summary of all settings for debugging/logging
  String get debugSummary {
    return '''
UserSettingsModel Summary:
  Theme: isDark=$isDarkTheme, lang=$language
  Notifications: enabled=$notificationsEnabled, sound=$soundEnabled, promo=$promotionalNotificationsEnabled
  Device: id=$currentDeviceId, deviceCount=$deviceCount, syncEnabled=$syncEnabled
  Premium: hasPremium=$hasPremiumFeatures, devMode=$isDevelopmentMode, analytics=$analyticsEnabled
  State: isLoading=$isLoading, hasError=${error != null}
''';
  }

  /// Check if user has access to a feature
  bool hasFeatureAccess(String featureKey) {
    return premiumSettings.hasFeatureAccess(featureKey);
  }

  @override
  String toString() => 'UserSettingsModel($debugSummary)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettingsModel &&
        other.themeSettings == themeSettings &&
        other.notificationSettings == notificationSettings &&
        other.deviceSettings == deviceSettings &&
        other.premiumSettings == premiumSettings &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return themeSettings.hashCode ^
        notificationSettings.hashCode ^
        deviceSettings.hashCode ^
        premiumSettings.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }
}

/// Composite settings provider that watches all 4 individual notifiers
///
/// This provider automatically updates whenever any of the 4 settings notifiers changes
/// It combines all settings into a single UserSettingsModel for easy consumption
///
/// Benefits:
/// - Single watch point for all settings
/// - Automatic aggregation of all state
/// - Rebuilds only when necessary (granular)
/// - Type-safe access to combined settings
///
/// Usage:
/// ```dart
/// // Watch all settings combined
/// final settings = ref.watch(compositeSettingsProvider);
///
/// // Now you have access to all settings
/// if (settings.isDarkTheme) {
///   // Use dark theme
/// }
///
/// if (settings.hasPremiumFeatures) {
///   // Show premium features
/// }
/// ```
final compositeSettingsProvider = Provider.autoDispose<UserSettingsModel>((
  ref,
) {
  // Watch all 4 individual notifiers
  final themeState = ref.watch(themeSettingsProvider);
  final notificationState = ref.watch(notificationSettingsProvider);
  final deviceState = ref.watch(deviceProvider(initialDeviceId: null));
  final premiumState = ref.watch(premiumProvider);

  // Determine if any is loading
  final isLoading =
      themeState.isLoading ||
      notificationState.isLoading ||
      deviceState.isLoading ||
      premiumState.isLoading;

  // Collect errors (prioritize by importance)
  final error =
      premiumState.error ??
      deviceState.error ??
      notificationState.error ??
      themeState.error;

  // Combine into single model
  return UserSettingsModel(
    themeSettings: themeState.settings,
    notificationSettings: notificationState.settings,
    deviceSettings: deviceState.settings,
    premiumSettings: premiumState.settings,
    isLoading: isLoading,
    error: error,
  );
});
