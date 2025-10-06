import 'package:flutter/foundation.dart';

/// Interface for device information and platform detection
abstract class IDeviceService {
  /// Check if app is running in development/debug mode
  Future<bool> isDevelopmentVersion();
  
  /// Check if running on web platform
  bool get isWeb;
  
  /// Check if running on mobile platform
  bool get isMobile;
  
  /// Get device/platform information
  Future<DeviceInfo> getDeviceInfo();
  
  /// Check if external URL can be launched
  Future<bool> canLaunchUrl(String url);
  
  /// Launch external URL
  Future<bool> launchUrl(String url, {LaunchMode mode = LaunchMode.external});
}

/// Device information model
class DeviceInfo {
  final String platform;
  final String version;
  final bool isPhysicalDevice;
  final bool isDevelopment;
  
  const DeviceInfo({
    required this.platform,
    required this.version,
    required this.isPhysicalDevice,
    required this.isDevelopment,
  });
}

/// URL launch modes
enum LaunchMode {
  external,
  inApp,
}

/// Mock implementation for development
class MockDeviceService implements IDeviceService {
  @override
  Future<bool> isDevelopmentVersion() async {
    return kDebugMode;
  }
  
  @override
  bool get isWeb => kIsWeb;
  
  @override
  bool get isMobile => !kIsWeb;
  
  @override
  Future<DeviceInfo> getDeviceInfo() async {
    return const DeviceInfo(
      platform: kIsWeb ? 'Web' : 'Mobile',
      version: '1.0.0',
      isPhysicalDevice: !kIsWeb,
      isDevelopment: kDebugMode,
    );
  }
  
  @override
  Future<bool> canLaunchUrl(String url) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return true;
  }
  
  @override
  Future<bool> launchUrl(String url, {LaunchMode mode = LaunchMode.external}) async {
    debugPrint('Launching URL: $url (mode: $mode)');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return true;
  }
}