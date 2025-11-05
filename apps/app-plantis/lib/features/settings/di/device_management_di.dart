import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../data/datasources/device_local_datasource.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../data/repositories/device_repository_impl.dart';

/// Configuração de Dependency Injection para Device Management
///
/// Registra todos os componentes necessários para gerenciamento de dispositivos
// ignore: avoid_classes_with_only_static_members
class DeviceManagementDI {
  /// Fase 1: Registros manuais (antes do Injectable)
  ///
  /// Registra datasources e repositório que não podem usar @injectable
  static Future<void> registerPhase1(GetIt getIt) async {
    // Data Sources
    final deviceLocalDataSource = DeviceLocalDataSource();
    // Initialize Hive box only on non-web platforms
    if (!kIsWeb) {
      await deviceLocalDataSource.init(); // Inicializa o Hive box
    }
    getIt.registerLazySingleton<DeviceLocalDataSource>(
      () => deviceLocalDataSource,
    );

    getIt.registerLazySingleton<DeviceRemoteDataSource>(
      () => DeviceRemoteDataSource(),
    );

    // Repository Implementation
    getIt.registerLazySingleton<IDeviceRepository>(
      () => DeviceRepositoryImpl(
        localDataSource: getIt<DeviceLocalDataSource>(),
        remoteDataSource: getIt<DeviceRemoteDataSource>(),
        connectivityService: getIt<ConnectivityService>(),
      ),
    );

    // Use Cases (do core package)
    getIt.registerLazySingleton<GetUserDevicesUseCase>(
      () => GetUserDevicesUseCase(getIt<IDeviceRepository>()),
    );

    getIt.registerLazySingleton<RevokeDeviceUseCase>(
      () => RevokeDeviceUseCase(getIt<IDeviceRepository>()),
    );

  }

  /// Método de conveniência para registrar tudo
  static Future<void> registerAll(GetIt getIt) async {
    await registerPhase1(getIt);
  }
}
