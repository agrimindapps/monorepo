import 'package:core/core.dart' hide ValidateDeviceUseCase;
import 'package:provider/provider.dart';

import '../../core/auth/auth_state_notifier.dart';
import 'data/datasources/device_local_datasource.dart';
import 'data/datasources/device_remote_datasource.dart';
import 'data/repositories/device_repository_impl.dart';
import 'domain/repositories/device_repository.dart';
import 'domain/usecases/get_device_statistics_usecase.dart';
import 'domain/usecases/validate_device_usecase.dart';
import 'presentation/providers/device_management_provider.dart';

/// Módulo de injeção de dependências para Device Management
/// Configura todas as dependências necessárias seguindo padrão do app-plantis
class DeviceManagementModule {
  /// Providers de data sources
  static List<Provider<Object?>> get dataSources => [
    // Local data source
    Provider<DeviceLocalDataSource>(
      create: (context) => DeviceLocalDataSourceImpl(),
    ),

    // Remote data source
    Provider<DeviceRemoteDataSource>(
      create: (context) => DeviceRemoteDataSourceImpl(),
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

  /// Use cases providers - usando serviços do core
  static List<Provider<Object?>> get useCases => [
    Provider<GetUserDevicesUseCase>(
      create: (context) => GetUserDevicesUseCase(
        context.read<IDeviceRepository>(),
      ),
    ),

    Provider<ValidateDeviceUseCase>(
      create: (context) => ValidateDeviceUseCase(
        context.read<DeviceRepository>(),
        context.read<AuthStateNotifier>(),
      ),
    ),

    Provider<RevokeDeviceUseCase>(
      create: (context) => RevokeDeviceUseCase(
        context.read<IDeviceRepository>(),
      ),
    ),

    Provider<RevokeAllOtherDevicesUseCase>(
      create: (context) => RevokeAllOtherDevicesUseCase(
        context.read<IDeviceRepository>(),
      ),
    ),

    Provider<GetDeviceStatisticsUseCase>(
      create: (context) => GetDeviceStatisticsUseCase(
        context.read<DeviceRepository>(),
        context.read<AuthStateNotifier>(),
      ),
    ),
  ];

  /// Business logic providers
  static List<dynamic> get providers => [
    ChangeNotifierProvider<DeviceManagementProvider>(
      create: (context) => DeviceManagementProvider(
        getUserDevicesUseCase: context.read<GetUserDevicesUseCase>(),
        validateDeviceUseCase: context.read<ValidateDeviceUseCase>(),
        revokeDeviceUseCase: context.read<RevokeDeviceUseCase>(),
        revokeAllOtherDevicesUseCase: context.read<RevokeAllOtherDevicesUseCase>(),
        getDeviceStatisticsUseCase: context.read<GetDeviceStatisticsUseCase>(),
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