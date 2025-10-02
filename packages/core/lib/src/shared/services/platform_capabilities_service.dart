import 'package:flutter/foundation.dart';

/// Service for detecting platform and providing platform-specific capabilities
///
/// This service provides a centralized way to detect the current platform
/// and make platform-specific decisions across all apps in the monorepo.
class PlatformCapabilitiesService {
  const PlatformCapabilitiesService();

  // ===== Platform Detection =====

  /// Check if running on mobile platform (Android or iOS)
  bool get isMobile => defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS;

  /// Check if running on Android platform
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Check if running on iOS platform
  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Check if running on web platform
  bool get isWeb => kIsWeb;

  /// Check if running on desktop platform
  bool get isDesktop => defaultTargetPlatform == TargetPlatform.windows ||
                       defaultTargetPlatform == TargetPlatform.macOS ||
                       defaultTargetPlatform == TargetPlatform.linux;

  /// Check if running on Windows
  bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  /// Check if running on macOS
  bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  /// Check if running on Linux
  bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  /// Check if running on Fuchsia
  bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

  /// Get current platform name as string
  String get platformName {
    if (kIsWeb) return 'web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  // ===== Platform Capabilities =====

  /// Check if platform supports native notifications
  bool get supportsNativeNotifications => isMobile || isDesktop;

  /// Check if platform supports camera access
  bool get supportsCameraAccess => isMobile;

  /// Check if platform supports biometric authentication
  bool get supportsBiometrics => isMobile;

  /// Check if platform supports file system access
  bool get supportsFileSystem => !isWeb;

  /// Check if platform supports background tasks
  bool get supportsBackgroundTasks => isMobile;

  /// Check if platform supports local storage
  bool get supportsLocalStorage => true;

  /// Check if platform requires network-only storage
  bool get requiresNetworkStorage => isWeb;

  // ===== Display & UI Capabilities =====

  /// Check if platform typically uses bottom navigation
  bool get prefersBottomNavigation => isMobile;

  /// Check if platform typically uses side navigation
  bool get prefersSideNavigation => isDesktop;

  /// Check if platform supports haptic feedback
  bool get supportsHaptics => isMobile;

  /// Check if platform supports widgets/shortcuts
  bool get supportsHomeScreenWidgets => isMobile;

  // ===== Performance Hints =====

  /// Check if platform should use lightweight animations
  bool get shouldUseLightweightAnimations => isWeb;

  /// Check if platform should preload images aggressively
  bool get shouldPreloadImages => !isWeb;

  /// Check if platform should cache data locally
  bool get shouldCacheLocally => !isWeb;

  // ===== Debug Utilities =====

  /// Get detailed platform information as Map
  Map<String, dynamic> get platformInfo => {
    'name': platformName,
    'isMobile': isMobile,
    'isWeb': isWeb,
    'isDesktop': isDesktop,
    'isAndroid': isAndroid,
    'isIOS': isIOS,
    'isWindows': isWindows,
    'isMacOS': isMacOS,
    'isLinux': isLinux,
    'isFuchsia': isFuchsia,
    'kIsWeb': kIsWeb,
    'defaultTargetPlatform': defaultTargetPlatform.toString(),
  };

  /// Print platform information (debug only)
  void printPlatformInfo() {
    if (kDebugMode) {
      debugPrint('📱 Platform Information:');
      platformInfo.forEach((key, value) {
        debugPrint('   $key: $value');
      });
    }
  }
}
