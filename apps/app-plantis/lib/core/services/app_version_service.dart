import 'package:core/core.dart';

/// Service to get app version information
/// Centralizes version retrieval to avoid hardcoded values
class AppVersionService {
  static AppVersionService? _instance;
  static AppVersionService get instance => _instance ??= AppVersionService._();

  AppVersionService._();

  PackageInfo? _packageInfo;

  /// Initialize and cache package info
  Future<void> initialize() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
  }

  /// Get app version (e.g., "1.0.0")
  Future<String> getVersion() async {
    if (_packageInfo == null) {
      await initialize();
    }
    return _packageInfo?.version ?? '1.0.0';
  }

  /// Get app build number (e.g., "1")
  Future<String> getBuildNumber() async {
    if (_packageInfo == null) {
      await initialize();
    }
    return _packageInfo?.buildNumber ?? '1';
  }

  /// Get full version string (e.g., "1.0.0+1")
  Future<String> getFullVersion() async {
    final version = await getVersion();
    final buildNumber = await getBuildNumber();
    return '$version+$buildNumber';
  }

  /// Get app name
  Future<String> getAppName() async {
    if (_packageInfo == null) {
      await initialize();
    }
    return _packageInfo?.appName ?? 'Plantis';
  }

  /// Get package name (bundle identifier)
  Future<String> getPackageName() async {
    if (_packageInfo == null) {
      await initialize();
    }
    return _packageInfo?.packageName ?? 'br.com.agrimsolution.plantis';
  }
}
