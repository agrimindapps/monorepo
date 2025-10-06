import 'package:core/core.dart';

import '../core/device_integration_service.dart';

/// Módulo de injeção de dependência para Device Management
@module
abstract class DeviceManagementModule {
  // External dependencies
  @lazySingleton
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();

  // TODO: Fix Connectivity registration - use ConnectivityPlus from core
  // @lazySingleton
  // Connectivity get connectivity => Connectivity();

  // Core Services (using core package)
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

  // Vehicle-specific integration service
  @lazySingleton
  DeviceIntegrationService provideDeviceIntegrationService(
    DeviceManagementService coreDeviceService,
    DeviceInfoPlugin deviceInfoPlugin,
  ) => DeviceIntegrationService(coreDeviceService, deviceInfoPlugin);

  // TODO: Fix VehicleDeviceProvider - migrated to Riverpod
  // @injectable
  // VehicleDeviceProvider provideVehicleDeviceProvider(
  //   DeviceManagementService coreDeviceService,
  //   ConnectivityService connectivityService,
  // ) => VehicleDeviceProvider(
  //       coreDeviceService: coreDeviceService,
  //       connectivityService: connectivityService,
  //     );
}

/// Função para inicializar as caixas Hive necessárias
Future<void> initializeDeviceManagementHiveBoxes() async {
  try {
    // Inicializar as caixas Hive para device management
    await Hive.openBox<Map<dynamic, dynamic>>('user_devices');
    await Hive.openBox<Map<dynamic, dynamic>>('device_statistics');
  } catch (e) {
    print('Erro ao inicializar boxes do Device Management: $e');
  }
}
