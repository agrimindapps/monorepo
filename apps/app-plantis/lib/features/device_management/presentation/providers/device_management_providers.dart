import 'package:core/core.dart'
    hide
        Column,
        RevokeDeviceUseCase,
        RevokeAllOtherDevicesUseCase,
        GetUserDevicesUseCase,
        ValidateDeviceUseCase;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_di_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../settings/data/datasources/device_local_datasource.dart';
import '../../../settings/data/datasources/device_remote_datasource.dart';
import '../../../settings/data/repositories/device_repository_impl.dart';
import '../../domain/usecases/get_device_statistics_usecase.dart';
import '../../domain/usecases/get_user_devices_usecase.dart';
import '../../domain/usecases/revoke_device_usecase.dart';
import '../../domain/usecases/validate_device_usecase.dart';

part 'device_management_providers.g.dart';

@riverpod
Future<DeviceLocalDataSource> deviceLocalDataSource(
    Ref ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DeviceLocalDataSource(prefs);
}

@riverpod
DeviceRemoteDataSource deviceRemoteDataSource(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return DeviceRemoteDataSource(firestore: firestore);
}

@riverpod
Future<IDeviceRepository> deviceRepository(Ref ref) async {
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
Future<GetUserDevicesUseCase> getUserDevicesUseCase(
    Ref ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  final authStateNotifier = ref.watch(authStateNotifierProvider);
  return GetUserDevicesUseCase(repository, authStateNotifier);
}

@riverpod
Future<ValidateDeviceUseCase> validateDeviceUseCase(
    Ref ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  final authStateNotifier = ref.watch(authStateNotifierProvider);
  return ValidateDeviceUseCase(repository, authStateNotifier);
}

@riverpod
Future<RevokeDeviceUseCase> revokeDeviceUseCase(
    Ref ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  final authStateNotifier = ref.watch(authStateNotifierProvider);
  return RevokeDeviceUseCase(repository, authStateNotifier);
}

@riverpod
Future<RevokeAllOtherDevicesUseCase> revokeAllOtherDevicesUseCase(
    Ref ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  final authStateNotifier = ref.watch(authStateNotifierProvider);
  return RevokeAllOtherDevicesUseCase(repository, authStateNotifier);
}

@riverpod
Future<GetDeviceStatisticsUseCase> getDeviceStatisticsUseCase(
    Ref ref) async {
  final repository = await ref.watch(deviceRepositoryProvider.future);
  final authStateNotifier = ref.watch(authStateNotifierProvider);
  return GetDeviceStatisticsUseCase(repository, authStateNotifier);
}
