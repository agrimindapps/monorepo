import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/services_providers.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../settings/data/datasources/device_local_datasource.dart';
import '../../../settings/data/datasources/device_remote_datasource.dart';
import '../../../settings/data/repositories/device_repository_impl.dart';
import '../../domain/usecases/get_device_statistics_usecase.dart';
import '../../domain/usecases/get_user_devices_usecase.dart';
import '../../domain/usecases/revoke_device_usecase.dart';
import '../../domain/usecases/validate_device_usecase.dart';

part 'device_management_providers.g.dart';

@riverpod
ConnectivityService connectivityService(ConnectivityServiceRef ref) {
  return ConnectivityService.instance;
}

@riverpod
Future<DeviceLocalDataSource> deviceLocalDataSource(DeviceLocalDataSourceRef ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return DeviceLocalDataSource(prefs);
}

@riverpod
DeviceRemoteDataSource deviceRemoteDataSource(DeviceRemoteDataSourceRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return DeviceRemoteDataSource(firestore: firestore);
}

@riverpod
Future<IDeviceRepository> deviceRepository(DeviceRepositoryRef ref) async {
  final localDataSource = await ref.watch(deviceLocalDataSourceProvider.future);
  final remoteDataSource = ref.watch(deviceRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return DeviceRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    connectivityService: connectivityService,
  );
}

@riverpod
Future<GetUserDevicesUseCase> getUserDevicesUseCase(GetUserDevicesUseCaseRef ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  return GetUserDevicesUseCase(repository);
}

@riverpod
Future<ValidateDeviceUseCase> validateDeviceUseCase(ValidateDeviceUseCaseRef ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  return ValidateDeviceUseCase(repository);
}

@riverpod
Future<RevokeDeviceUseCase> revokeDeviceUseCase(RevokeDeviceUseCaseRef ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  return RevokeDeviceUseCase(repository);
}

@riverpod
Future<RevokeAllOtherDevicesUseCase> revokeAllOtherDevicesUseCase(RevokeAllOtherDevicesUseCaseRef ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  return RevokeAllOtherDevicesUseCase(repository);
}

@riverpod
Future<GetDeviceStatisticsUseCase> getDeviceStatisticsUseCase(GetDeviceStatisticsUseCaseRef ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  return GetDeviceStatisticsUseCase(repository);
}
