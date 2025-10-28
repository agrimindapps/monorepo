import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app-site/const/environment_const.dart';

class InfoDeviceService {
  static final InfoDeviceService _instance = InfoDeviceService._internal();

  factory InfoDeviceService() {
    return _instance;
  }

  InfoDeviceService._internal();

  final ValueNotifier<bool> isProduction = ValueNotifier<bool>(false);

  Future<void> setProduction() async {
    int patchVersion = await InfoDeviceService.getPatchVersion();
    isProduction.value = patchVersion > 0;

    Environment().initialize();
  }

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<int> getPatchVersion() async {
    int versao = 0;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versao = int.parse(packageInfo.version.split('.')[2]);

    return versao;
  }
}
