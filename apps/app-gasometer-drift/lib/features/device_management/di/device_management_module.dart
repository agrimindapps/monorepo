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

/// Função para inicializar as caixas Hive necessárias
Future<void> initializeDeviceManagementHiveBoxes() async {
  try {
    await Hive.openBox<Map<dynamic, dynamic>>('user_devices');
    await Hive.openBox<Map<dynamic, dynamic>>('device_statistics');
  } catch (e) {
    print('Erro ao inicializar boxes do Device Management: $e');
  }
}
