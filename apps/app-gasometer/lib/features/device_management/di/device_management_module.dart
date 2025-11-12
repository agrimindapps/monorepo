import 'package:core/core.dart';

import '../core/device_integration_service.dart';

/// Módulo de injeção de dependência para Device Management
@module
abstract class DeviceManagementModule {
  @lazySingleton
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();
  @lazySingleton
  DeviceManagementService provideDeviceManagementService(
    FirebaseDeviceService firebaseDeviceService,
    FirebaseAuthService authService,
    FirebaseAnalyticsService analyticsService,
    IDeviceRepository deviceRepository,
  ) => DeviceManagementService(
    firebaseDeviceService: firebaseDeviceService,
    authService: authService,
    analyticsService: analyticsService,
    deviceRepository: deviceRepository,
  );
  @lazySingleton
  DeviceIntegrationService provideDeviceIntegrationService(
    DeviceManagementService coreDeviceService,
    DeviceInfoPlugin deviceInfoPlugin,
  ) => DeviceIntegrationService(coreDeviceService, deviceInfoPlugin);
}
