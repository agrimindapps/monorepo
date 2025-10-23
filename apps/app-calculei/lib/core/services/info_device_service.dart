import 'package:flutter/foundation.dart';

/// Service to detect device information and environment
class InfoDeviceService {
  static final InfoDeviceService _instance = InfoDeviceService._internal();

  factory InfoDeviceService() {
    return _instance;
  }

  InfoDeviceService._internal();

  /// Check if running in production mode
  /// Returns ValueNotifier for reactive updates
  ValueNotifier<bool> get isProduction {
    // Use kReleaseMode from Flutter foundation
    return ValueNotifier<bool>(kReleaseMode);
  }
}
