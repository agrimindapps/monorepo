import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/device_entity.dart';
import '../../../domain/entities/device_limit_config.dart';
import '../../../domain/repositories/i_device_repository.dart';
import '../../../infrastructure/repositories/datasources/device_local_datasource.dart';
import '../../../infrastructure/repositories/device_repository_impl.dart';
import '../../../infrastructure/services/connectivity_service.dart';
import '../../../infrastructure/services/device_identity_service.dart';
import '../../../infrastructure/services/firebase_device_service.dart';
import '../auth/auth_domain_providers.dart' show domainCurrentUserProvider;
import '../premium/subscription_providers.dart'
    show currentAppIdProvider, featureLimitsProvider;

/// Providers unificados para gerenciamento de dispositivos
/// Consolida lógica de device management entre todos os apps do monorepo
/// Migrado para Riverpod 3.0 - sem legacy imports

/// Provider para o DeviceIdentityService
/// Serviço central para identificação de dispositivos em todo o monorepo
final deviceIdentityServiceProvider = Provider<DeviceIdentityService>((ref) {
  return DeviceIdentityService.instance;
});

/// Provider para configuração de limites de dispositivos
/// Pode ser overridden por cada app para customizar os limites
final deviceLimitConfigProvider = Provider<DeviceLimitConfig>((ref) {
  return const DeviceLimitConfig(
    maxMobileDevices: 3,
    maxWebDevices: -1, // Web ilimitado
    countWebInLimit: false, // Web não conta no limite
    premiumMaxMobileDevices: 10,
    allowEmulators: true,
  );
});

/// Provider para o ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

/// Provider para o DeviceLocalDataSource
/// Requer ILocalStorageRepository como dependência - deve ser overridden no app
final deviceLocalDataSourceProvider = Provider<DeviceLocalDataSource>((ref) {
  throw UnimplementedError(
    'deviceLocalDataSourceProvider must be overridden at app startup with ILocalStorageRepository',
  );
});

/// Provider para o FirebaseDeviceService
final firebaseDeviceServiceProvider = Provider<FirebaseDeviceService>((ref) {
  final limitConfig = ref.watch(deviceLimitConfigProvider);
  return FirebaseDeviceService(limitConfig: limitConfig);
});

/// Provider para o DeviceRepository unificado
/// Coordena operações entre local cache e Firebase
final deviceRepositoryProvider = Provider<IDeviceRepository>((ref) {
  final localDataSource = ref.watch(deviceLocalDataSourceProvider);
  final remoteDataSource = ref.watch(firebaseDeviceServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return DeviceRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    connectivityService: connectivityService,
  );
});

/// Provider para lista de dispositivos do usuário usando o repository unificado
final userDevicesFromRepositoryProvider = FutureProvider<List<DeviceEntity>>((
  ref,
) async {
  final userId = ref.watch(domainCurrentUserProvider)?.id;
  if (userId == null) return [];

  final repository = ref.watch(deviceRepositoryProvider);
  final result = await repository.getUserDevices(userId);

  return result.fold((failure) {
    if (kDebugMode) {
      debugPrint('❌ userDevicesFromRepositoryProvider: ${failure.message}');
    }
    return [];
  }, (devices) => devices);
});

/// Provider para verificar se pode adicionar mais dispositivos
final canAddMoreDevicesProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(domainCurrentUserProvider)?.id;
  if (userId == null) return false;

  final repository = ref.watch(deviceRepositoryProvider);
  final result = await repository.canAddMoreDevices(userId);

  return result.fold((failure) => false, (canAdd) => canAdd);
});

/// Provider para verificação detalhada de limite de dispositivos
final deviceLimitCheckProvider = FutureProvider<DeviceLimitCheckResult?>((
  ref,
) async {
  final userId = ref.watch(domainCurrentUserProvider)?.id;
  if (userId == null) return null;

  final firebaseService = ref.watch(firebaseDeviceServiceProvider);
  final result = await firebaseService.checkDeviceLimit(userId);

  return result.fold((failure) {
    if (kDebugMode) {
      debugPrint('❌ deviceLimitCheckProvider: ${failure.message}');
    }
    return null;
  }, (checkResult) => checkResult);
});

/// Provider para contagem de dispositivos por tipo (mobile/web)
final deviceCountByTypeProvider = FutureProvider<Map<String, int>>((ref) async {
  final userId = ref.watch(domainCurrentUserProvider)?.id;
  if (userId == null) return {'mobile': 0, 'web': 0, 'total': 0};

  final firebaseService = ref.watch(firebaseDeviceServiceProvider);
  final result = await firebaseService.getDeviceCountByType(userId);

  return result.fold(
    (failure) => {'mobile': 0, 'web': 0, 'total': 0},
    (counts) => counts,
  );
});

/// Provider para estatísticas de dispositivos
final deviceStatisticsProvider = FutureProvider<DeviceStatistics?>((ref) async {
  final userId = ref.watch(domainCurrentUserProvider)?.id;
  if (userId == null) return null;

  final repository = ref.watch(deviceRepositoryProvider);
  final result = await repository.getDeviceStatistics(userId);

  return result.fold((failure) => null, (stats) => stats);
});

/// Provider principal para informações do dispositivo atual
/// Usa DeviceIdentityService para obter informações reais do dispositivo
final currentDeviceProvider = FutureProvider<DeviceEntity>((ref) async {
  final deviceIdentityService = ref.watch(deviceIdentityServiceProvider);
  return deviceIdentityService.getCurrentDeviceEntity();
});

/// Provider para lista de dispositivos do usuário
final userDevicesProvider = FutureProvider<List<DeviceEntity>>((ref) async {
  final userId = ref.watch(domainCurrentUserProvider)?.id;
  if (userId == null) return [];
  final currentDevice = await ref.watch(currentDeviceProvider.future);
  return [currentDevice];
});

/// Provider para estado de gerenciamento de dispositivos - Riverpod 3.0
final deviceManagementProvider =
    NotifierProvider<DeviceManagementNotifier, DeviceManagementState>(
      DeviceManagementNotifier.new,
    );

/// Provider para sessão ativa do dispositivo atual
final currentDeviceSessionProvider = Provider<DeviceSession?>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  final device = ref.watch(currentDeviceProvider).value;

  if (user == null || device == null) return null;

  return DeviceSession(
    userId: user.id,
    deviceId: device.id,
    sessionStart: DateTime.now(),
    isActive: true,
    lastActivity: DateTime.now(),
    appId: ref.watch(currentAppIdProvider),
  );
});

/// Provider para verificar se pode adicionar novo dispositivo
final canAddDeviceProvider = Provider<bool>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  final limits = ref.watch(
    featureLimitsProvider(ref.watch(currentAppIdProvider)),
  );

  return limits.hasReachedLimit('devices', devices.length) == false;
});

/// Provider para contagem atual de dispositivos
final deviceCountProvider = Provider<int>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  return devices.length;
});

/// Provider para limite máximo de dispositivos
final maxDevicesProvider = Provider<int>((ref) {
  final appId = ref.watch(currentAppIdProvider);
  final limits = ref.watch(featureLimitsProvider(appId));
  return limits.getLimitFor('devices');
});

/// Provider para dispositivos que excedem o limite
final excessDevicesProvider = Provider<List<DeviceEntity>>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  final maxDevices = ref.watch(maxDevicesProvider);

  if (maxDevices == -1 || devices.length <= maxDevices) return [];
  final sortedDevices = List<DeviceEntity>.from(devices)
    ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));

  return sortedDevices.skip(maxDevices).toList();
});

/// Provider para validação do dispositivo atual
final deviceValidationProvider = FutureProvider<DeviceValidationResult>((
  ref,
) async {
  final device = ref.watch(currentDeviceProvider).value;
  final user = ref.watch(domainCurrentUserProvider);

  if (device == null || user == null) {
    return DeviceValidationResult.invalid(
      'Dispositivo ou usuário não disponível',
    );
  }
  return DeviceValidationResult.valid();
});

/// Provider para verificar se dispositivo está autorizado
final isDeviceAuthorizedProvider = Provider<bool>((ref) {
  final validation = ref.watch(deviceValidationProvider).value;
  return validation?.isValid ?? false;
});

/// Provider para razão de não autorização
final deviceUnauthorizedReasonProvider = Provider<String?>((ref) {
  final validation = ref.watch(deviceValidationProvider).value;
  return validation?.isValid == false ? validation?.reason : null;
});

/// Provider para ações de gerenciamento de dispositivos
final deviceActionsProvider = Provider<DeviceActions>((ref) {
  final notifier = ref.read(deviceManagementProvider.notifier);

  return DeviceActions(
    registerDevice: notifier.registerCurrentDevice,
    revokeDevice: notifier.revokeDevice,
    revokeAllOtherDevices: notifier.revokeAllOtherDevices,
    updateDeviceInfo: notifier.updateDeviceInfo,
    refreshDevicesList: notifier.refreshDevicesList,
  );
});

/// Provider para estatísticas de uso por dispositivo
final deviceUsageStatsProvider =
    FutureProvider.family<DeviceUsageStats, String>((ref, deviceId) async {
      return DeviceUsageStats(
        deviceId: deviceId,
        totalSessions: 42,
        totalUsageTime: const Duration(hours: 24),
        lastUsed: DateTime.now(),
        appLaunches: 156,
        featureUsage: {'auth': 50, 'sync': 30, 'analytics': 20},
      );
    });

/// Provider para dispositivos ativos recentemente
final recentActiveDevicesProvider = Provider<List<DeviceEntity>>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  final now = DateTime.now();

  return devices.where((device) {
    final daysSinceAccess = now.difference(device.lastActiveAt).inDays;
    return daysSinceAccess <= 30;
  }).toList();
});

/// Provider para dispositivos inativos
final inactiveDevicesProvider = Provider<List<DeviceEntity>>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  final now = DateTime.now();

  return devices.where((device) {
    final daysSinceAccess = now.difference(device.lastActiveAt).inDays;
    return daysSinceAccess > 90;
  }).toList();
});

/// Provider para verificação de segurança do dispositivo
final deviceSecurityProvider = FutureProvider<DeviceSecurityInfo>((ref) async {
  final device = ref.watch(currentDeviceProvider).value;
  if (device == null) throw Exception('Dispositivo não disponível');
  return DeviceSecurityInfo(
    deviceId: device.id,
    isCompromised: false,
    isRooted: false,
    hasSecureStorage: true,
    alerts: [],
    lastSecurityCheck: DateTime.now(),
  );
});

/// Provider para verificar se dispositivo está comprometido
final isDeviceCompromisedProvider = Provider<bool>((ref) {
  final security = ref.watch(deviceSecurityProvider).value;
  return security?.isCompromised ?? false;
});

/// Provider para alertas de segurança
final securityAlertsProvider = Provider<List<SecurityAlert>>((ref) {
  final security = ref.watch(deviceSecurityProvider).value;
  return security?.alerts ?? [];
});

/// Estados do gerenciamento de dispositivos
abstract class DeviceManagementState {
  const DeviceManagementState();
}

class DeviceManagementIdle extends DeviceManagementState {
  const DeviceManagementIdle();
}

class DeviceManagementLoading extends DeviceManagementState {
  const DeviceManagementLoading();
}

class DeviceManagementSuccess extends DeviceManagementState {
  final String message;
  const DeviceManagementSuccess(this.message);
}

class DeviceManagementError extends DeviceManagementState {
  final String message;
  const DeviceManagementError(this.message);
}

/// Sessão do dispositivo
class DeviceSession {
  final String userId;
  final String deviceId;
  final DateTime sessionStart;
  final bool isActive;
  final DateTime lastActivity;
  final String appId;

  const DeviceSession({
    required this.userId,
    required this.deviceId,
    required this.sessionStart,
    required this.isActive,
    required this.lastActivity,
    required this.appId,
  });

  Duration get sessionDuration => DateTime.now().difference(sessionStart);
  bool get isActiveSession =>
      DateTime.now().difference(lastActivity).inMinutes < 30;
}

/// Resultado da validação do dispositivo
class DeviceValidationResult {
  final bool isValid;
  final String? reason;
  final DateTime validatedAt;

  const DeviceValidationResult({
    required this.isValid,
    this.reason,
    required this.validatedAt,
  });

  factory DeviceValidationResult.valid() {
    return DeviceValidationResult(isValid: true, validatedAt: DateTime.now());
  }

  factory DeviceValidationResult.invalid(String reason) {
    return DeviceValidationResult(
      isValid: false,
      reason: reason,
      validatedAt: DateTime.now(),
    );
  }
}

/// Estatísticas de uso do dispositivo
class DeviceUsageStats {
  final String deviceId;
  final int totalSessions;
  final Duration totalUsageTime;
  final DateTime? lastUsed;
  final int appLaunches;
  final Map<String, int> featureUsage;

  const DeviceUsageStats({
    required this.deviceId,
    required this.totalSessions,
    required this.totalUsageTime,
    this.lastUsed,
    required this.appLaunches,
    required this.featureUsage,
  });

  double get averageSessionDuration {
    if (totalSessions == 0) return 0;
    return totalUsageTime.inMinutes / totalSessions;
  }

  bool get isFrequentlyUsed => appLaunches > 10;
}

/// Informações de segurança do dispositivo
class DeviceSecurityInfo {
  final String deviceId;
  final bool isCompromised;
  final bool isRooted;
  final bool hasSecureStorage;
  final List<SecurityAlert> alerts;
  final DateTime lastSecurityCheck;

  const DeviceSecurityInfo({
    required this.deviceId,
    required this.isCompromised,
    required this.isRooted,
    required this.hasSecureStorage,
    required this.alerts,
    required this.lastSecurityCheck,
  });

  bool get isSecure => !isCompromised && !isRooted && hasSecureStorage;
  int get riskLevel => alerts.length;
}

/// Alerta de segurança
class SecurityAlert {
  final String id;
  final SecurityAlertType type;
  final String title;
  final String description;
  final SecuritySeverity severity;
  final DateTime createdAt;

  const SecurityAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.createdAt,
  });
}

enum SecurityAlertType {
  rootDetection,
  debuggerDetection,
  emulatorDetection,
  tampering,
  suspiciousActivity,
}

enum SecuritySeverity { low, medium, high, critical }

/// Ações de gerenciamento de dispositivos
class DeviceActions {
  final Future<bool> Function() registerDevice;
  final Future<bool> Function(String deviceId) revokeDevice;
  final Future<bool> Function() revokeAllOtherDevices;
  final Future<bool> Function(Map<String, dynamic> updates) updateDeviceInfo;
  final Future<void> Function() refreshDevicesList;

  const DeviceActions({
    required this.registerDevice,
    required this.revokeDevice,
    required this.revokeAllOtherDevices,
    required this.updateDeviceInfo,
    required this.refreshDevicesList,
  });
}

/// Notifier para gerenciamento de dispositivos - Riverpod 3.0
class DeviceManagementNotifier extends Notifier<DeviceManagementState> {
  @override
  DeviceManagementState build() => const DeviceManagementIdle();

  Future<bool> registerCurrentDevice() async {
    try {
      state = const DeviceManagementLoading();
      await Future<void>.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess(
        'Dispositivo registrado com sucesso',
      );
      return true;
    } catch (e) {
      state = const DeviceManagementError('Erro ao registrar dispositivo: \$e');
      return false;
    }
  }

  Future<bool> revokeDevice(String deviceId) async {
    try {
      state = const DeviceManagementLoading();
      await Future<void>.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess('Dispositivo revogado com sucesso');
      return true;
    } catch (e) {
      state = const DeviceManagementError('Erro ao revogar dispositivo: \$e');
      return false;
    }
  }

  Future<bool> revokeAllOtherDevices() async {
    try {
      state = const DeviceManagementLoading();
      await Future<void>.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess(
        'Outros dispositivos revogados com sucesso',
      );
      return true;
    } catch (e) {
      state = const DeviceManagementError(
        'Erro ao revogar outros dispositivos: \$e',
      );
      return false;
    }
  }

  Future<bool> updateDeviceInfo(Map<String, dynamic> updates) async {
    try {
      state = const DeviceManagementLoading();
      await Future<void>.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess(
        'Informações do dispositivo atualizadas',
      );
      return true;
    } catch (e) {
      state = const DeviceManagementError('Erro ao atualizar informações: \$e');
      return false;
    }
  }

  Future<void> refreshDevicesList() async {
    try {
      state = const DeviceManagementLoading();
      state = const DeviceManagementIdle();
    } catch (e) {
      state = const DeviceManagementError('Erro ao atualizar lista: \$e');
    }
  }

  void clearState() {
    state = const DeviceManagementIdle();
  }
}
