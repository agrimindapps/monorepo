import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import 'package:core/core.dart';

import '../core/device_integration_service.dart';
import '../presentation/providers/vehicle_device_provider.dart';

/// Módulo de injeção de dependência para Device Management
@module
abstract class DeviceManagementModule {
  // External dependencies
  @lazySingleton
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

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
  ) => DeviceIntegrationService(
        coreDeviceService,
        deviceInfoPlugin,
      );

  // Vehicle Device Provider
  @injectable
  VehicleDeviceProvider provideVehicleDeviceProvider() => VehicleDeviceProvider();
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
