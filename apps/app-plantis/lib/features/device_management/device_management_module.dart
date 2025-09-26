import 'package:core/core.dart' show ILocalStorageRepository, FirebaseDeviceService;
import 'package:provider/provider.dart';

import '../../core/auth/auth_state_notifier.dart';
import 'data/datasources/device_local_datasource.dart';
import 'data/datasources/device_remote_datasource.dart';
import 'data/repositories/device_repository_impl.dart';
import 'domain/repositories/device_repository.dart';
import 'domain/usecases/get_device_statistics_usecase.dart' as local;
import 'domain/usecases/get_user_devices_usecase.dart' as local;
import 'domain/usecases/revoke_device_usecase.dart' as local;
import 'domain/usecases/update_device_activity_usecase.dart';
import 'domain/usecases/validate_device_usecase.dart' as local;
import 'presentation/providers/device_management_provider.dart';

/// Módulo de injeção de dependências para Device Management
/// Configura todas as dependências necessárias seguindo padrão do app-plantis
class DeviceManagementModule {
  /// Providers de data sources
  static List<Provider<Object?>> get dataSources => [
    // Local data source
    Provider<DeviceLocalDataSource>(
      create: (context) => DeviceLocalDataSourceImpl(
        storageService: context.read<ILocalStorageRepository>(),
      ),
    ),

    // Remote data source
    Provider<DeviceRemoteDataSource>(
      create: (context) => DeviceRemoteDataSourceImpl(
        firebaseDeviceService: context.read<FirebaseDeviceService>(),
      ),
    ),
  ];

  /// Repository providers
  static List<Provider<Object?>> get repositories => [
    Provider<DeviceRepository>(
      create: (context) => DeviceRepositoryImpl(
        remoteDataSource: context.read<DeviceRemoteDataSource>(),
        localDataSource: context.read<DeviceLocalDataSource>(),
      ),
    ),
  ];

  /// Use cases providers - usando implementações locais do app-plantis
  static List<Provider<Object?>> get useCases => [
    // Use cases locais do app-plantis
    Provider<local.GetUserDevicesUseCase>(
      create: (context) => local.GetUserDevicesUseCase(
        context.read<DeviceRepository>(),
        context.read<AuthStateNotifier>(),
      ),
    ),

    Provider<local.ValidateDeviceUseCase>(
      create: (context) => local.ValidateDeviceUseCase(
        context.read<DeviceRepository>(),
        context.read<AuthStateNotifier>(),
      ),
    ),

    Provider<local.RevokeDeviceUseCase>(
      create: (context) => local.RevokeDeviceUseCase(
        context.read<DeviceRepository>(),
        context.read<AuthStateNotifier>(),
      ),
    ),

    Provider<local.RevokeAllOtherDevicesUseCase>(
      create: (context) => local.RevokeAllOtherDevicesUseCase(
        context.read<DeviceRepository>(),
        context.read<AuthStateNotifier>(),
      ),
    ),

    Provider<local.GetDeviceStatisticsUseCase>(
      create: (context) => local.GetDeviceStatisticsUseCase(
        context.read<DeviceRepository>(),
        context.read<AuthStateNotifier>(),
      ),
    ),

    Provider<UpdateDeviceActivityUseCase>(
      create: (context) => UpdateDeviceActivityUseCase(
        context.read<DeviceRepository>(),
      ),
    ),
  ];

  /// Business logic providers
  static List<dynamic> get providers => [
    ChangeNotifierProvider<DeviceManagementProvider>(
      create: (context) => DeviceManagementProvider(
        getUserDevicesUseCase: context.read<local.GetUserDevicesUseCase>(),
        validateDeviceUseCase: context.read<local.ValidateDeviceUseCase>(),
        revokeDeviceUseCase: context.read<local.RevokeDeviceUseCase>(),
        revokeAllOtherDevicesUseCase: context.read<local.RevokeAllOtherDevicesUseCase>(),
        getDeviceStatisticsUseCase: context.read<local.GetDeviceStatisticsUseCase>(),
        authStateNotifier: context.read<AuthStateNotifier>(),
      ),
    ),
  ];

  /// Todos os providers do módulo organizados em ordem de dependência
  static List<dynamic> get allProviders => [
    ...dataSources,
    ...repositories,
    ...useCases,
    ...providers,
  ];
}

/// Extension para facilitar registro no app
extension DeviceManagementModuleExtension on List<dynamic> {
  /// Adiciona providers do device management à lista existente
  List<dynamic> withDeviceManagement() {
    return [
      ...this,
      ...DeviceManagementModule.allProviders,
    ];
  }
}