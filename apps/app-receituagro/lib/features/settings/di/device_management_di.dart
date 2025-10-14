import 'package:core/core.dart';

import '../data/datasources/device_local_datasource.dart';
import '../data/datasources/device_remote_datasource.dart';
// ❌ REMOVIDO: device_repository_impl.dart (registrado via @LazySingleton)

/// Dependency Injection para Device Management
/// Configura todos os serviços necessários para gerenciamento de dispositivos
///
/// ⚠️ IMPORTANTE: Separado em 2 métodos para evitar conflitos com Injectable:
/// 1. registerDataSources() - chamado ANTES do Injectable
/// 2. registerUseCasesAndServices() - chamado DEPOIS do Injectable
class DeviceManagementDI {
  static bool _dataSourcesRegistered = false;
  static bool _useCasesRegistered = false;

  /// Registra APENAS os datasources (chamado ANTES do Injectable)
  static Future<void> registerDataSources(GetIt sl) async {
    if (_dataSourcesRegistered) return;

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

    _dataSourcesRegistered = true;
  }

  /// Registra use cases e services (chamado DEPOIS do Injectable)
  /// ⚠️ IDeviceRepository já registrado via @LazySingleton - NÃO registrar aqui!
  static Future<void> registerUseCasesAndServices(GetIt sl) async {
    if (_useCasesRegistered) return;

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

    _useCasesRegistered = true;
  }

  /// Método legado (mantido para compatibilidade) - usa os novos métodos
  @Deprecated('Use registerDataSources() e registerUseCasesAndServices() separadamente')
  static Future<void> registerDependencies(GetIt sl) async {
    await registerDataSources(sl);
    await registerUseCasesAndServices(sl);
  }

  /// Remove todas as dependências registradas (para testes)
  static Future<void> unregisterDependencies(GetIt sl) async {
    if (!_dataSourcesRegistered && !_useCasesRegistered) return;
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

    _dataSourcesRegistered = false;
    _useCasesRegistered = false;
  }

  /// Verifica se as dependências estão registradas
  static bool get isRegistered => _dataSourcesRegistered && _useCasesRegistered;

  /// Força re-registro das dependências (útil para testes)
  static Future<void> resetAndRegister(GetIt sl) async {
    await unregisterDependencies(sl);
    await registerDataSources(sl);
    await registerUseCasesAndServices(sl);
  }
}
