import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

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

    // === DATA SOURCES ===
    
    // Local Data Source
    sl.registerLazySingleton<DeviceLocalDataSource>(
      () => DeviceLocalDataSourceImpl(
        localStorage: sl<ILocalStorageRepository>(),
      ),
    );

    // Remote Data Source (Web-safe registration)
    sl.registerLazySingleton<DeviceRemoteDataSource>(
      () {
        try {
          return DeviceRemoteDataSourceImpl(
            firebaseDeviceService: sl<FirebaseDeviceService>(),
          );
        } catch (e) {
          // Fallback for Web or if service is not available
          print('⚠️  FirebaseDeviceService not available, using fallback: $e');
          return DeviceRemoteDataSourceImpl(
            firebaseDeviceService: null, // Use null-safe implementation
          );
        }
      },
    );

    // === REPOSITORY ===
    
    // Device Repository Implementation
    sl.registerLazySingleton<IDeviceRepository>(
      () => DeviceRepositoryImpl(
        localDataSource: sl<DeviceLocalDataSource>(),
        remoteDataSource: sl<DeviceRemoteDataSource>(),
        connectivityService: sl<ConnectivityService>(),
      ),
    );

    // === USE CASES ===
    
    // Get User Devices Use Case
    sl.registerLazySingleton<GetUserDevicesUseCase>(
      () => GetUserDevicesUseCase(
        sl<IDeviceRepository>(),
      ),
    );

    // Validate Device Use Case
    sl.registerLazySingleton<ValidateDeviceUseCase>(
      () => ValidateDeviceUseCase(
        sl<IDeviceRepository>(),
      ),
    );

    // Revoke Device Use Case
    sl.registerLazySingleton<RevokeDeviceUseCase>(
      () => RevokeDeviceUseCase(
        sl<IDeviceRepository>(),
      ),
    );

    // === HIGH-LEVEL SERVICES ===
    
    // Device Management Service (Web-safe registration)  
    sl.registerLazySingleton<DeviceManagementService>(
      () {
        try {
          return DeviceManagementService(
            firebaseDeviceService: sl<FirebaseDeviceService>(),
            authService: sl<FirebaseAuthService>(),
            analyticsService: sl<FirebaseAnalyticsService>(),
            deviceRepository: sl<IDeviceRepository>(),
          );
        } catch (e) {
          // For Web compatibility, register a stub FirebaseDeviceService first
          print('⚠️  FirebaseDeviceService not available, DeviceManagementService skipped: $e');
          // Return a simplified service that won't be used
          rethrow; // Let this fail gracefully - service won't be available
        }
      },
    );

    _isRegistered = true;
  }

  /// Remove todas as dependências registradas (para testes)
  static Future<void> unregisterDependencies(GetIt sl) async {
    if (!_isRegistered) return;

    // Remove na ordem inversa do registro
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