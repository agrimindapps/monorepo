import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Providers unificados para gerenciamento de dispositivos
/// Consolida lógica de device management entre todos os apps do monorepo

// ========== CORE DEVICE PROVIDERS ==========

/// Provider principal para informações do dispositivo atual
final currentDeviceProvider = FutureProvider<DeviceEntity>((ref) async {
  // REVIEW (converted TODO 2025-10-06): Implementar criação de DeviceEntity a partir de DeviceInfoPlugin
  // Por enquanto, retornar entidade mock até services serem implementados
  final now = DateTime.now();
  return DeviceEntity(
    id: 'current_device_${now.millisecondsSinceEpoch}',
    uuid: 'uuid_${now.millisecondsSinceEpoch}',
    name: 'Dispositivo Atual',
    model: 'Modelo Desconhecido',
    platform: defaultTargetPlatform.name,
    systemVersion: '1.0.0',
    appVersion: '1.0.0',
    buildNumber: '1',
    isPhysicalDevice: true,
    manufacturer: 'Desconhecido',
    firstLoginAt: now,
    lastActiveAt: now,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
});

/// Provider para lista de dispositivos do usuário
final userDevicesProvider = FutureProvider<List<DeviceEntity>>((ref) async {
  final userId = ref.watch(domainCurrentUserProvider)?.id;
  if (userId == null) return [];

  // REVIEW (converted TODO 2025-10-06): Implementar busca real de dispositivos do usuário
  // Por enquanto, retornar lista mock até services serem implementados
  final currentDevice = await ref.watch(currentDeviceProvider.future);
  return [currentDevice];
});

/// Provider para estado de gerenciamento de dispositivos
final deviceManagementProvider =
    StateNotifierProvider<DeviceManagementNotifier, DeviceManagementState>((
      ref,
    ) {
      return DeviceManagementNotifier();
    });

/// Provider para sessão ativa do dispositivo atual
final currentDeviceSessionProvider = Provider<DeviceSession?>((ref) {
  final user = ref.watch(domainCurrentUserProvider);
  final device = ref.watch(currentDeviceProvider).value;

  if (user == null || device == null) return null;

  return DeviceSession(
    userId: user.id,
    deviceId: device.id,
    sessionStart: DateTime.now(), // Será persistido
    isActive: true,
    lastActivity: DateTime.now(),
    appId: ref.watch(currentAppIdProvider),
  );
});

// ========== DEVICE LIMITS PROVIDERS ==========

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

  // Ordenar por último acesso e retornar os que excedem
  final sortedDevices = List<DeviceEntity>.from(devices)
    ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));

  return sortedDevices.skip(maxDevices).toList();
});

// ========== DEVICE VALIDATION PROVIDERS ==========

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

  // REVIEW (converted TODO 2025-10-06): Implementar validação real de dispositivo
  // Por enquanto, considerar sempre válido
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

// ========== DEVICE ACTIONS PROVIDERS ==========

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

// ========== DEVICE ANALYTICS PROVIDERS ==========

/// Provider para estatísticas de uso por dispositivo
final deviceUsageStatsProvider = FutureProvider.family<
  DeviceUsageStats,
  String
>((ref, deviceId) async {
  // REVIEW (converted TODO 2025-10-06): Implementar estatísticas reais de uso
  // Por enquanto, retornar estatísticas mock
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
    return daysSinceAccess <= 30; // Ativo nos últimos 30 dias
  }).toList();
});

/// Provider para dispositivos inativos
final inactiveDevicesProvider = Provider<List<DeviceEntity>>((ref) {
  final devices = ref.watch(userDevicesProvider).value ?? [];
  final now = DateTime.now();

  return devices.where((device) {
    final daysSinceAccess = now.difference(device.lastActiveAt).inDays;
    return daysSinceAccess > 90; // Inativo por mais de 90 dias
  }).toList();
});

// ========== SECURITY PROVIDERS ==========

/// Provider para verificação de segurança do dispositivo
final deviceSecurityProvider = FutureProvider<DeviceSecurityInfo>((ref) async {
  final device = ref.watch(currentDeviceProvider).value;
  if (device == null) throw Exception('Dispositivo não disponível');

  // REVIEW (converted TODO 2025-10-06): Implementar verificação real de segurança
  // Por enquanto, retornar informações mock
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

// ========== MODELS ==========

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

// ========== NOTIFIER IMPLEMENTATION ==========

/// Notifier para gerenciamento de dispositivos
class DeviceManagementNotifier extends StateNotifier<DeviceManagementState> {
  DeviceManagementNotifier() : super(const DeviceManagementIdle());

  late final DeviceManagementService _deviceService;

  void _initialize() {
    // REVIEW (converted TODO 2025-10-06): Implementar inicialização do DeviceManagementService
    // Por enquanto, manter sem inicialização
  }

  Future<bool> registerCurrentDevice() async {
    try {
      state = const DeviceManagementLoading();

      // REVIEW (converted TODO 2025-10-06): Implementar registro real de dispositivo
      // Por enquanto, simular sucesso
      await Future.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess(
        'Dispositivo registrado com sucesso',
      );
      return true;
    } catch (e) {
      state = DeviceManagementError('Erro ao registrar dispositivo: $e');
      return false;
    }
  }

  Future<bool> revokeDevice(String deviceId) async {
    try {
      state = const DeviceManagementLoading();

      // REVIEW (converted TODO 2025-10-06): Implementar revogação real de dispositivo
      // Por enquanto, simular sucesso
      await Future.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess('Dispositivo revogado com sucesso');
      return true;
    } catch (e) {
      state = DeviceManagementError('Erro ao revogar dispositivo: $e');
      return false;
    }
  }

  Future<bool> revokeAllOtherDevices() async {
    try {
      state = const DeviceManagementLoading();

      // REVIEW (converted TODO 2025-10-06): Implementar revogação de outros dispositivos
      // Por enquanto, simular sucesso
      await Future.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess(
        'Outros dispositivos revogados com sucesso',
      );
      return true;
    } catch (e) {
      state = DeviceManagementError('Erro ao revogar outros dispositivos: $e');
      return false;
    }
  }

  Future<bool> updateDeviceInfo(Map<String, dynamic> updates) async {
    try {
      state = const DeviceManagementLoading();

      // REVIEW (converted TODO 2025-10-06): Implementar atualização real de informações do dispositivo
      // Por enquanto, simular sucesso
      await Future.delayed(const Duration(seconds: 1));

      state = const DeviceManagementSuccess(
        'Informações do dispositivo atualizadas',
      );
      return true;
    } catch (e) {
      state = DeviceManagementError('Erro ao atualizar informações: $e');
      return false;
    }
  }

  Future<void> refreshDevicesList() async {
    try {
      state = const DeviceManagementLoading();

      // Trigger refresh nos providers relacionados
      // Será implementado com ref.invalidate() quando necessário

      state = const DeviceManagementIdle();
    } catch (e) {
      state = DeviceManagementError('Erro ao atualizar lista: $e');
    }
  }

  void clearState() {
    state = const DeviceManagementIdle();
  }
}
