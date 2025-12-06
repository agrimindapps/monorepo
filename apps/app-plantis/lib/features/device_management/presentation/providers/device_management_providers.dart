/// Device Management Providers for app-plantis
/// 
/// Este arquivo configura os providers de device management específicos do plantis,
/// utilizando a implementação base do core package.
/// 
/// A lógica de negócio está toda no core. Aqui apenas:
/// - Configuramos os overrides necessários para o plantis
/// - Re-exportamos os providers do core para uso no app
library;

import 'package:core/core.dart' hide Column, connectivityServiceProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';

part 'device_management_providers.g.dart';

/// Provider para configuração de limites específica do plantis
/// Override do deviceLimitConfigProvider do core
@riverpod
DeviceLimitConfig plantisDeviceLimitConfig(Ref ref) {
  return const DeviceLimitConfig(
    maxMobileDevices: 3,
    maxWebDevices: -1, // Web ilimitado
    countWebInLimit: false, // Web não conta no limite
    premiumMaxMobileDevices: 10,
    allowEmulators: true,
  );
}

/// Provider para o DeviceManagementService configurado para o plantis
@riverpod
DeviceManagementService plantisDeviceManagementService(Ref ref) {
  final limitConfig = ref.watch(plantisDeviceLimitConfigProvider);
  final firebaseDeviceService = FirebaseDeviceService(
    limitConfig: limitConfig,
  );
  final authService = ref.watch(firebaseAuthServiceProvider);
  final analyticsService = ref.watch(firebaseAnalyticsServiceProvider);
  
  // Usa FirebaseDeviceService como repository (implementa IDeviceRepository)
  return DeviceManagementService(
    firebaseDeviceService: firebaseDeviceService,
    authService: authService,
    analyticsService: analyticsService,
    deviceRepository: firebaseDeviceService,
  );
}

/// Provider para lista de dispositivos do usuário
@riverpod
Future<List<DeviceEntity>> plantisUserDevices(Ref ref) async {
  final service = ref.watch(plantisDeviceManagementServiceProvider);
  final result = await service.getUserDevices();
  
  return result.fold(
    (failure) => [],
    (devices) => devices,
  );
}

/// Provider para verificar se pode adicionar mais dispositivos
@riverpod
Future<bool> plantisCanAddMoreDevices(Ref ref) async {
  final service = ref.watch(plantisDeviceManagementServiceProvider);
  final result = await service.canAddMoreDevices();
  
  return result.fold(
    (failure) => false,
    (canAdd) => canAdd,
  );
}

/// Provider para estatísticas de dispositivos
@riverpod
Future<DeviceStatistics?> plantisDeviceStatistics(Ref ref) async {
  final service = ref.watch(plantisDeviceManagementServiceProvider);
  final result = await service.getDeviceStatistics();
  
  return result.fold(
    (failure) => null,
    (stats) => stats,
  );
}
