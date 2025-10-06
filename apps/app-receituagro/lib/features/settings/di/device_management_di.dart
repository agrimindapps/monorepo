import 'package:core/core.dart';

import '../data/datasources/device_local_datasource.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../data/repositories/device_repository_impl.dart';

/// Dependency Injection para Device Management
/// Configura todos os serviços necessários para gerenciamento de dispositivos
class DeviceManagementDI {
  static bool _isRegistered = false;

  /// Registra todas as dependências de device management
  static Future<void> registerDependencies(GetIt sl) async {
    if (_isRegistered) return;
    sl.registerLazySingleton<DeviceLocalDataSource>(
      () => DeviceLocalDataSourceImpl(
        localStorage: sl<ILocalStorageRepository>(),
      ),
    );
    sl.registerLazySingleton<DeviceRemoteDataSource>(
      () {
        try {
          return DeviceRemoteDataSourceImpl(
            firebaseDeviceService: sl<FirebaseDeviceService>(),
          );
        } catch (e) {
          print('⚠️  FirebaseDeviceService not available, using fallback: $e');
          return DeviceRemoteDataSourceImpl(
            firebaseDeviceService: null, // Use null-safe implementation
          );
        }
      },
    );
    sl.registerLazySingleton<IDeviceRepository>(
      () => DeviceRepositoryImpl(
        localDataSource: sl<DeviceLocalDataSource>(),
        remoteDataSource: sl<DeviceRemoteDataSource>(),
        connectivityService: sl<ConnectivityService>(),
      ),
    );
    sl.registerLazySingleton<GetUserDevicesUseCase>(
      () => GetUserDevicesUseCase(
        sl<IDeviceRepository>(),
      ),
    );
    sl.registerLazySingleton<ValidateDeviceUseCase>(
      () => ValidateDeviceUseCase(
        sl<IDeviceRepository>(),
      ),
    );
    sl.registerLazySingleton<RevokeDeviceUseCase>(
      () => RevokeDeviceUseCase(
        sl<IDeviceRepository>(),
      ),
    );
    try {
      if (sl.isRegistered<FirebaseDeviceService>() &&
          sl.isRegistered<FirebaseAuthService>() &&
          sl.isRegistered<FirebaseAnalyticsService>()) {
        sl.registerLazySingleton<DeviceManagementService>(
          () => DeviceManagementService(
            firebaseDeviceService: sl<FirebaseDeviceService>(),
            authService: sl<FirebaseAuthService>(),
            analyticsService: sl<FirebaseAnalyticsService>(),
            deviceRepository: sl<IDeviceRepository>(),
          ),
        );
      } else {
        print('⚠️  DeviceManagementService: Required Firebase services not available (Web platform)');
        print('   Missing services:');
        if (!sl.isRegistered<FirebaseDeviceService>()) {
          print('   - FirebaseDeviceService');
        }
        if (!sl.isRegistered<FirebaseAuthService>()) {
          print('   - FirebaseAuthService');
        }
        if (!sl.isRegistered<FirebaseAnalyticsService>()) {
          print('   - FirebaseAnalyticsService');
        }
      }
    } catch (e, stackTrace) {
      print('⚠️  Error checking DeviceManagementService dependencies: $e');
      print('Stack trace:');
      print(stackTrace);
    }

    _isRegistered = true;
  }

  /// Remove todas as dependências registradas (para testes)
  static Future<void> unregisterDependencies(GetIt sl) async {
    if (!_isRegistered) return;
    if (sl.isRegistered<DeviceManagementService>()) {
      await sl.unregister<DeviceManagementService>();
    }
    
    if (sl.isRegistered<RevokeDeviceUseCase>()) {
      await sl.unregister<RevokeDeviceUseCase>();
    }
    
    if (sl.isRegistered<ValidateDeviceUseCase>()) {
      await sl.unregister<ValidateDeviceUseCase>();
    }
    
    if (sl.isRegistered<GetUserDevicesUseCase>()) {
      await sl.unregister<GetUserDevicesUseCase>();
    }
    
    if (sl.isRegistered<IDeviceRepository>()) {
      await sl.unregister<IDeviceRepository>();
    }
    
    if (sl.isRegistered<DeviceRemoteDataSource>()) {
      await sl.unregister<DeviceRemoteDataSource>();
    }
    
    if (sl.isRegistered<DeviceLocalDataSource>()) {
      await sl.unregister<DeviceLocalDataSource>();
    }

    _isRegistered = false;
  }

  /// Verifica se as dependências estão registradas
  static bool get isRegistered => _isRegistered;

  /// Força re-registro das dependências (útil para testes)
  static Future<void> resetAndRegister(GetIt sl) async {
    await unregisterDependencies(sl);
    await registerDependencies(sl);
  }
}