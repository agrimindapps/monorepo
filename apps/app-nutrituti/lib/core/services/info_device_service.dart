import 'package:flutter/foundation.dart';

class InfoDeviceService {
  static final InfoDeviceService _instance = InfoDeviceService._internal();

  factory InfoDeviceService() => _instance;

  InfoDeviceService._internal();

  ValueNotifier<bool> isProduction = ValueNotifier<bool>(true);

  void initialize() {
    // Use GlobalEnvironment from core package
    isProduction.value = kReleaseMode;
  }
}
