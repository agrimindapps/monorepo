import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/device_management/data/models/device_model.dart';
import '../../features/device_management/presentation/providers/device_management_providers.dart'
    as feature_providers;

part 'device_management_providers.g.dart';

/// Configuração de limite de dispositivos para o Plantis
/// Web não conta no limite, apenas dispositivos mobile (iOS/Android)
const plantisDeviceLimitConfig = DeviceLimitConfig(
  maxMobileDevices: 3,
  maxWebDevices: -1, // Web ilimitado
  countWebInLimit: false, // Web não conta no limite
  premiumMaxMobileDevices: 10,
  allowEmulators: true,
);

/// Immutable state for Device Management
@immutable
class DeviceManagementState {
  final List<DeviceModel> devices;
  final DeviceModel? currentDevice;
  final DeviceStatisticsModel? statistics;
  final String? errorMessage;
  final String? successMessage;
  final bool isRevoking;
  final String? revokingDeviceUuid;
  final bool isValidating;

  const DeviceManagementState({
    required this.devices,
    this.currentDevice,
    this.statistics,
    this.errorMessage,
    this.successMessage,
    this.isRevoking = false,
    this.revokingDeviceUuid,
    this.isValidating = false,
  });

  factory DeviceManagementState.initial() {
    return const DeviceManagementState(devices: []);
  }

  DeviceManagementState copyWith({
    List<DeviceModel>? devices,
    DeviceModel? currentDevice,
    DeviceStatisticsModel? statistics,
    String? errorMessage,
    String? successMessage,
    bool? isRevoking,
    String? revokingDeviceUuid,
    bool? isValidating,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearCurrentDevice = false,
    bool clearStatistics = false,
  }) {
    return DeviceManagementState(
      devices: devices ?? this.devices,
      currentDevice: clearCurrentDevice
          ? null
          : (currentDevice ?? this.currentDevice),
      statistics: clearStatistics ? null : (statistics ?? this.statistics),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      isRevoking: isRevoking ?? this.isRevoking,
      revokingDeviceUuid: revokingDeviceUuid,
      isValidating: isValidating ?? this.isValidating,
    );
  }

  List<DeviceModel> get activeDevices =>
      devices.where((d) => d.isActive).toList();
  List<DeviceModel> get inactiveDevices =>
      devices.where((d) => !d.isActive).toList();

  /// Conta apenas dispositivos mobile ativos (iOS/Android)
  int get activeMobileDeviceCount => activeDevices
      .where((d) => plantisDeviceLimitConfig.isMobilePlatform(d.platform))
      .length;

  /// Conta dispositivos web ativos
  int get activeWebDeviceCount => activeDevices
      .where((d) => plantisDeviceLimitConfig.isWebOrDesktopPlatform(d.platform))
      .length;

  int get activeDeviceCount => activeDevices.length;
  int get totalDeviceCount => devices.length;
  bool get hasDevices => devices.isNotEmpty;

  /// Verifica se pode adicionar mais dispositivos mobile
  /// Web não conta no limite
  bool get canAddMoreDevices =>
      activeMobileDeviceCount < plantisDeviceLimitConfig.maxMobileDevices;
  bool get isCurrentDeviceIdentified => currentDevice != null;

  String get deviceSummary {
    if (!hasDevices) return 'Nenhum dispositivo registrado';
    if (activeMobileDeviceCount == 1) return '1 dispositivo móvel ativo';
    return '$activeMobileDeviceCount dispositivos móveis ativos';
  }

  String get statusText {
    if (!hasDevices) return 'Nenhum dispositivo registrado';

    final mobile = activeMobileDeviceCount;
    final web = activeWebDeviceCount;

    if (web > 0) {
      return '$mobile móvel(is) + $web web';
    }
    return mobile == 1 ? '1 dispositivo ativo' : '$mobile dispositivos ativos';
  }

  Color get statusColor {
    if (!hasDevices) return Colors.grey;
    if (activeMobileDeviceCount < plantisDeviceLimitConfig.maxMobileDevices)
      return Colors.green;
    return Colors.orange;
  }

  IconData get statusIcon {
    if (!hasDevices) return Icons.devices_other;
    if (activeMobileDeviceCount < plantisDeviceLimitConfig.maxMobileDevices)
      return Icons.verified;
    return Icons.warning;
  }

  /// Mostra apenas dispositivos mobile no limite (web não conta)
  String get deviceLimitText =>
      '$activeMobileDeviceCount/${plantisDeviceLimitConfig.maxMobileDevices} dispositivos móveis';

  bool get isNearDeviceLimit =>
      activeMobileDeviceCount >=
      (plantisDeviceLimitConfig.maxMobileDevices - 1);

  bool get hasReachedDeviceLimit =>
      activeMobileDeviceCount >= plantisDeviceLimitConfig.maxMobileDevices;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceManagementState &&
        listEquals(other.devices, devices) &&
        other.currentDevice == currentDevice &&
        other.statistics == statistics &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        other.isRevoking == isRevoking &&
        other.revokingDeviceUuid == revokingDeviceUuid &&
        other.isValidating == isValidating;
  }

  @override
  int get hashCode => Object.hash(
    devices.length,
    currentDevice,
    statistics,
    errorMessage,
    successMessage,
    isRevoking,
    revokingDeviceUuid,
    isValidating,
  );
}

/// Riverpod AsyncNotifier for Device Management
/// Utiliza DeviceManagementService do core para operações
@riverpod
class DeviceManagementNotifier extends _$DeviceManagementNotifier {
  late DeviceManagementService _deviceManagementService;

  @override
  Future<DeviceManagementState> build() async {
    _deviceManagementService = ref.watch(
      feature_providers.plantisDeviceManagementServiceProvider,
    );

    ref.onDispose(() {
      if (kDebugMode) {
        debugPrint('🧹 DeviceManagementNotifier disposed');
      }
    });

    return _initializeDeviceManagement();
  }

  /// Initialize device management
  Future<DeviceManagementState> _initializeDeviceManagement() async {
    try {
      final currentDevice = await _identifyCurrentDevice();
      final devicesResult = await _deviceManagementService.getUserDevices();

      final List<DeviceModel> devices = devicesResult.fold(
        (failure) => <DeviceModel>[],
        (devicesList) =>
            devicesList.map((e) => DeviceModel.fromEntity(e)).toList(),
      );

      return DeviceManagementState(
        devices: devices,
        currentDevice: currentDevice,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagementNotifier: Error initializing: $e');
      }
      return DeviceManagementState.initial();
    }
  }

  /// Identify current device
  Future<DeviceModel?> _identifyCurrentDevice() async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceManagementNotifier: Identifying current device');
      }

      final currentDevice = await DeviceModel.fromCurrentDevice();

      if (currentDevice == null) {
        if (kDebugMode) {
          debugPrint(
            '🚫 DeviceManagementNotifier: Current platform not supported',
          );
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint(
          '📱 DeviceManagementNotifier: Current device identified: ${currentDevice.name}',
        );
      }

      return currentDevice;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagementNotifier: Error identifying device: $e');
      }
      return null;
    }
  }

  /// Load devices list
  Future<void> loadDevices({bool refresh = false}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentState = state.value ?? DeviceManagementState.initial();

      final result = await _deviceManagementService.getUserDevices();

      return result.fold(
        (Failure failure) => currentState.copyWith(
          errorMessage: 'Erro ao carregar dispositivos: ${failure.message}',
        ),
        (devicesList) => currentState.copyWith(
          devices: devicesList.map((e) => DeviceModel.fromEntity(e)).toList(),
          clearError: true,
        ),
      );
    });
  }

  /// Revoke a specific device
  Future<bool> revokeDevice(String deviceUuid, {String? reason}) async {
    final currentState = state.value ?? DeviceManagementState.initial();

    state = AsyncValue.data(
      currentState.copyWith(
        isRevoking: true,
        revokingDeviceUuid: deviceUuid,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _deviceManagementService.revokeDevice(deviceUuid);

    final success = result.fold(
      (Failure failure) {
        final updatedState = (state.value ?? currentState).copyWith(
          isRevoking: false,
          revokingDeviceUuid: null,
          errorMessage: failure.message,
        );
        state = AsyncValue.data(updatedState);
        return false;
      },
      (void _) {
        return true;
      },
    );

    if (success) {
      await loadDevices();

      final updatedState = (state.value ?? currentState).copyWith(
        isRevoking: false,
        revokingDeviceUuid: null,
        successMessage: 'Dispositivo revogado com sucesso',
        clearError: true,
      );
      state = AsyncValue.data(updatedState);
    }

    return success;
  }

  /// Revoke all other devices
  Future<bool> revokeAllOtherDevices({String? reason}) async {
    final currentState = state.value ?? DeviceManagementState.initial();
    final currentDeviceUuid = currentState.currentDevice?.uuid;

    if (currentDeviceUuid == null) {
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Dispositivo atual não identificado',
        ),
      );
      return false;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isRevoking: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _deviceManagementService.revokeAllOtherDevices(
      currentDeviceUuid,
    );

    final success = result.fold((Failure failure) {
      final updatedState = (state.value ?? currentState).copyWith(
        isRevoking: false,
        errorMessage: failure.message,
      );
      state = AsyncValue.data(updatedState);
      return false;
    }, (void _) => true);

    if (success) {
      await loadDevices();

      final updatedState = (state.value ?? currentState).copyWith(
        isRevoking: false,
        successMessage: 'Outros dispositivos revogados com sucesso',
        clearError: true,
      );
      state = AsyncValue.data(updatedState);
    }

    return success;
  }

  /// Validate current device
  Future<bool> validateCurrentDevice() async {
    final currentState = state.value ?? DeviceManagementState.initial();
    if (currentState.isValidating) return false;

    state = AsyncValue.data(
      currentState.copyWith(
        isValidating: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceManagementNotifier: Validating current device');
      }

      final currentDevice = currentState.currentDevice;
      if (currentDevice == null) {
        final updatedState = (state.value ?? currentState).copyWith(
          isValidating: false,
          errorMessage: 'Nenhum dispositivo atual identificado',
        );
        state = AsyncValue.data(updatedState);
        return false;
      }

      final result = await _deviceManagementService.validateDevice(
        currentDevice.toEntity(),
      );

      return result.fold(
        (Failure failure) {
          final updatedState = (state.value ?? currentState).copyWith(
            isValidating: false,
            errorMessage: 'Erro ao validar dispositivo: ${failure.message}',
          );
          state = AsyncValue.data(updatedState);
          return false;
        },
        (DeviceEntity validatedDevice) {
          loadDevices();

          final updatedState = (state.value ?? currentState).copyWith(
            isValidating: false,
            successMessage: 'Dispositivo validado com sucesso',
            clearError: true,
          );
          state = AsyncValue.data(updatedState);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagementNotifier: Error validating device: $e');
      }
      final updatedState = (state.value ?? currentState).copyWith(
        isValidating: false,
        errorMessage: 'Erro inesperado na validação',
      );
      state = AsyncValue.data(updatedState);
      return false;
    }
  }

  /// Refresh - alias for loadDevices
  Future<void> refresh() async {
    await loadDevices(refresh: true);
  }

  /// Load device statistics
  Future<void> loadStatistics({bool refresh = false}) async {
    final currentState = state.value ?? DeviceManagementState.initial();

    try {
      final result = await _deviceManagementService.getDeviceStatistics();

      final statistics = result.fold((failure) {
        if (kDebugMode) {
          debugPrint('❌ Error loading statistics: ${failure.message}');
        }
        return null;
      }, (stats) => DeviceStatisticsModel.fromEntity(stats));

      state = AsyncValue.data(currentState.copyWith(statistics: statistics));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Exception loading statistics: $e');
      }
    }
  }

  /// Clear error message
  void clearError() {
    final currentState = state.value ?? DeviceManagementState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }

  /// Clear success message
  void clearSuccess() {
    final currentState = state.value ?? DeviceManagementState.initial();
    state = AsyncValue.data(currentState.copyWith(clearSuccess: true));
  }

  /// Reset state (on logout)
  void resetState() {
    state = AsyncValue.data(DeviceManagementState.initial());
  }
}

/// Alias for backwards compatibility with legacy code
/// Use deviceManagementProvider instead in new code
const deviceManagementNotifierProvider = deviceManagementProvider;
