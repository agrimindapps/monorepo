import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../core/device_integration_service.dart';
import '../data/datasources/device_local_datasource.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../data/repositories/device_repository_impl.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/usecases/get_user_devices.dart';
import '../domain/usecases/revoke_device.dart';
import '../domain/usecases/validate_device_limit.dart';
import '../presentation/providers/device_management_provider.dart';

/// Módulo de injeção de dependência para Device Management
@module
abstract class DeviceManagementModule {
  // External dependencies
  @lazySingleton
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();
  
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  // Data Sources
  @lazySingleton
  DeviceLocalDataSource provideDeviceLocalDataSource() => DeviceLocalDataSource();

  @lazySingleton
  DeviceRemoteDataSource provideDeviceRemoteDataSource(
    DeviceInfoPlugin deviceInfoPlugin,
  ) => DeviceRemoteDataSource(deviceInfoPlugin: deviceInfoPlugin);

  // Repository
  @lazySingleton
  DeviceRepository provideDeviceRepository(
    DeviceRemoteDataSource remoteDataSource,
    DeviceLocalDataSource localDataSource,
    Connectivity connectivity,
  ) => DeviceRepositoryImpl(
        remoteDataSource,
        localDataSource,
        connectivity,
      );

  // Use Cases
  @lazySingleton
  GetUserDevicesUseCase provideGetUserDevicesUseCase(
    DeviceRepository repository,
  ) => GetUserDevicesUseCase(repository);

  @lazySingleton
  RevokeDeviceUseCase provideRevokeDeviceUseCase(
    DeviceRepository repository,
  ) => RevokeDeviceUseCase(repository);

  @lazySingleton
  ValidateDeviceLimitUseCase provideValidateDeviceLimitUseCase(
    DeviceRepository repository,
  ) => ValidateDeviceLimitUseCase(repository);

  // Core Services
  @lazySingleton
  DeviceIntegrationService provideDeviceIntegrationService(
    ValidateDeviceLimitUseCase validateDeviceLimitUseCase,
    DeviceRemoteDataSource deviceRemoteDataSource,
    DeviceInfoPlugin deviceInfoPlugin,
  ) => DeviceIntegrationService(
        validateDeviceLimitUseCase,
        deviceRemoteDataSource,
        deviceInfoPlugin,
      );

  // Providers
  @injectable
  DeviceManagementProvider provideDeviceManagementProvider(
    GetUserDevicesUseCase getUserDevicesUseCase,
    RevokeDeviceUseCase revokeDeviceUseCase,
    ValidateDeviceLimitUseCase validateDeviceLimitUseCase,
  ) => DeviceManagementProvider(
        getUserDevicesUseCase: getUserDevicesUseCase,
        revokeDeviceUseCase: revokeDeviceUseCase,
        validateDeviceLimitUseCase: validateDeviceLimitUseCase,
      );
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
