import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/device_local_datasource.dart';
import '../../data/datasources/device_remote_datasource.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/usecases/get_user_devices_usecase.dart';
import '../../domain/usecases/revoke_device_usecase.dart';
import '../../domain/usecases/validate_device_usecase.dart';

part 'device_management_providers.g.dart';

// --- Data Sources ---

@riverpod
DeviceLocalDataSource deviceLocalDataSource(DeviceLocalDataSourceRef ref) {
  return DeviceLocalDataSourceImpl(
    localStorage: ref.watch(localStorageRepositoryProvider),
  );
}

@riverpod
DeviceRemoteDataSource deviceRemoteDataSource(DeviceRemoteDataSourceRef ref) {
  return DeviceRemoteDataSourceImpl(
    firebaseDeviceService: ref.watch(firebaseDeviceServiceProvider),
  );
}

// --- Repository ---

@riverpod
IDeviceRepository deviceRepository(DeviceRepositoryRef ref) {
  return DeviceRepositoryImpl(
    localDataSource: ref.watch(deviceLocalDataSourceProvider),
    remoteDataSource: ref.watch(deviceRemoteDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
}

// --- Use Cases ---

@riverpod
GetUserDevicesUseCase getUserDevicesUseCase(GetUserDevicesUseCaseRef ref) {
  return GetUserDevicesUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
ValidateDeviceUseCase validateDeviceUseCase(ValidateDeviceUseCaseRef ref) {
  return ValidateDeviceUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
RevokeDeviceUseCase revokeDeviceUseCase(RevokeDeviceUseCaseRef ref) {
  return RevokeDeviceUseCase(ref.watch(deviceRepositoryProvider));
}

// --- Service ---

@riverpod
DeviceManagementService deviceManagementService(DeviceManagementServiceRef ref) {
  return DeviceManagementService(
    firebaseDeviceService: ref.watch(firebaseDeviceServiceProvider),
    authService: ref.watch(firebaseAuthServiceProvider),
    analyticsService: ref.watch(firebaseAnalyticsServiceProvider),
    deviceRepository: ref.watch(deviceRepositoryProvider),
  );
}
