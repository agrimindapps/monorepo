import 'package:core/core.dart'
    hide
        GetUserDevicesUseCase,
        RevokeDeviceUseCase,
        RevokeAllOtherDevicesUseCase,
        ValidateDeviceUseCase,
        GetUserDevicesParams,
        RevokeDeviceParams,
        RevokeAllOtherDevicesParams,
        ValidateDeviceParams,
        DeviceValidationResult;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/device_management/data/models/device_model.dart';
import '../../features/device_management/domain/usecases/get_device_statistics_usecase.dart';
import '../../features/device_management/domain/usecases/get_user_devices_usecase.dart';
import '../../features/device_management/domain/usecases/revoke_device_usecase.dart';
import '../../features/device_management/domain/usecases/validate_device_usecase.dart';

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
      currentDevice: clearCurrentDevice ? null : (currentDevice ?? this.currentDevice),
      statistics: clearStatistics ? null : (statistics ?? this.statistics),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isRevoking: isRevoking ?? this.isRevoking,
      revokingDeviceUuid: revokingDeviceUuid,
      isValidating: isValidating ?? this.isValidating,
    );
  }

  // Computed properties
  List<DeviceModel> get activeDevices => devices.where((d) => d.isActive).toList();
  List<DeviceModel> get inactiveDevices => devices.where((d) => !d.isActive).toList();
  int get activeDeviceCount => activeDevices.length;
  int get totalDeviceCount => devices.length;
  bool get hasDevices => devices.isNotEmpty;
  bool get canAddMoreDevices => activeDeviceCount < 3;
  bool get isCurrentDeviceIdentified => currentDevice != null;

  String get deviceSummary {
    if (!hasDevices) return 'Nenhum dispositivo registrado';
    if (activeDeviceCount == 1) return '1 dispositivo ativo';
    return '$activeDeviceCount dispositivos ativos';
  }

  // UI Helpers
  String get statusText {
    if (!hasDevices) return 'Nenhum dispositivo registrado';

    final active = activeDeviceCount;
    final total = totalDeviceCount;

    if (active == total) {
      return active == 1 ? '1 dispositivo ativo' : '$active dispositivos ativos';
    } else {
      return '$active de $total dispositivos ativos';
    }
  }

  Color get statusColor {
    if (!hasDevices) return Colors.grey;
    if (activeDeviceCount == totalDeviceCount) return Colors.green;
    return Colors.orange;
  }

  IconData get statusIcon {
    if (!hasDevices) return Icons.devices_other;
    if (activeDeviceCount == totalDeviceCount) return Icons.verified;
    return Icons.warning;
  }

  String get deviceLimitText => '$activeDeviceCount/3 dispositivos';

  bool get isNearDeviceLimit => activeDeviceCount >= 2;

  bool get hasReachedDeviceLimit => activeDeviceCount >= 3;

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
class DeviceManagementNotifier extends AsyncNotifier<DeviceManagementState> {
  late final GetUserDevicesUseCase _getUserDevicesUseCase;
  late final ValidateDeviceUseCase _validateDeviceUseCase;
  late final RevokeDeviceUseCase _revokeDeviceUseCase;
  late final RevokeAllOtherDevicesUseCase _revokeAllOtherDevicesUseCase;
  late final GetDeviceStatisticsUseCase _getDeviceStatisticsUseCase;

  @override
  Future<DeviceManagementState> build() async {
    // Initialize use cases
    _getUserDevicesUseCase = GetIt.instance<GetUserDevicesUseCase>();
    _validateDeviceUseCase = GetIt.instance<ValidateDeviceUseCase>();
    _revokeDeviceUseCase = GetIt.instance<RevokeDeviceUseCase>();
    _revokeAllOtherDevicesUseCase = GetIt.instance<RevokeAllOtherDevicesUseCase>();
    _getDeviceStatisticsUseCase = GetIt.instance<GetDeviceStatisticsUseCase>();

    // Initialize device management
    return _initializeDeviceManagement();
  }

  /// Initialize device management
  Future<DeviceManagementState> _initializeDeviceManagement() async {
    try {
      // Identify current device
      final currentDevice = await _identifyCurrentDevice();

      // Load devices
      final devicesResult = await _getUserDevicesUseCase.call(const GetUserDevicesParams());

      final List<DeviceModel> devices = devicesResult.fold(
        (failure) => <DeviceModel>[],
        (List<DeviceModel> devicesList) => devicesList,
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
          debugPrint('🚫 DeviceManagementNotifier: Current platform not supported');
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('📱 DeviceManagementNotifier: Current device identified: ${currentDevice.name}');
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
      final currentState = state.valueOrNull ?? DeviceManagementState.initial();

      final result = await _getUserDevicesUseCase.call(const GetUserDevicesParams());

      return result.fold(
        (Failure failure) => currentState.copyWith(
          errorMessage: 'Erro ao carregar dispositivos: ${failure.message}',
        ),
        (List<DeviceModel> devices) => currentState.copyWith(
          devices: devices,
          clearError: true,
        ),
      );
    });
  }

  /// Revoke a specific device
  Future<bool> revokeDevice(String deviceUuid, {String? reason}) async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    state = AsyncValue.data(currentState.copyWith(
      isRevoking: true,
      revokingDeviceUuid: deviceUuid,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await _revokeDeviceUseCase.call(
      RevokeDeviceParams(deviceUuid: deviceUuid, reason: reason),
    );

    final success = result.fold(
      (Failure failure) {
        final updatedState = (state.valueOrNull ?? currentState).copyWith(
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
      // Reload devices after successful revocation
      await loadDevices();

      final updatedState = (state.valueOrNull ?? currentState).copyWith(
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
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    state = AsyncValue.data(currentState.copyWith(
      isRevoking: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await _revokeAllOtherDevicesUseCase.call(
      RevokeAllOtherDevicesParams(reason: reason),
    );

    final resultData = result.fold(
      (Failure failure) => (success: false, message: failure.message, count: 0),
      (RevokeAllResult revokeResult) => (
        success: true,
        message: revokeResult.message,
        count: revokeResult.revokedCount
      ),
    );

    if (resultData.success) {
      // Reload devices after successful revocation
      await loadDevices();

      final updatedState = (state.valueOrNull ?? currentState).copyWith(
        isRevoking: false,
        successMessage: '${resultData.count} dispositivos revogados com sucesso',
        clearError: true,
      );
      state = AsyncValue.data(updatedState);
    } else {
      final updatedState = (state.valueOrNull ?? currentState).copyWith(
        isRevoking: false,
        errorMessage: resultData.message,
      );
      state = AsyncValue.data(updatedState);
    }

    return resultData.success;
  }

  /// Validate current device
  Future<DeviceValidationResult?> validateCurrentDevice() async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    // Check if already validating
    if (currentState.isValidating) return null;

    state = AsyncValue.data(currentState.copyWith(
      isValidating: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceManagementNotifier: Validating current device');
      }

      final currentDevice = currentState.currentDevice;
      if (currentDevice == null) {
        final updatedState = (state.valueOrNull ?? currentState).copyWith(
          isValidating: false,
          errorMessage: 'Nenhum dispositivo atual identificado',
        );
        state = AsyncValue.data(updatedState);
        return null;
      }

      final result = await _validateDeviceUseCase.call(
        ValidateDeviceParams(device: currentDevice),
      );

      return result.fold(
        (Failure failure) {
          final updatedState = (state.valueOrNull ?? currentState).copyWith(
            isValidating: false,
            errorMessage: 'Erro ao validar dispositivo: ${failure.message}',
          );
          state = AsyncValue.data(updatedState);
          return null;
        },
        (DeviceValidationResult validationResult) async {
          if (validationResult.isValid) {
            // Reload devices after successful validation
            await loadDevices();

            final updatedState = (state.valueOrNull ?? currentState).copyWith(
              isValidating: false,
              successMessage: 'Dispositivo validado com sucesso',
              clearError: true,
            );
            state = AsyncValue.data(updatedState);
          } else {
            final updatedState = (state.valueOrNull ?? currentState).copyWith(
              isValidating: false,
              errorMessage: validationResult.message ?? 'Falha na validação do dispositivo',
            );
            state = AsyncValue.data(updatedState);
          }

          return validationResult;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceManagementNotifier: Error validating device: $e');
      }
      final updatedState = (state.valueOrNull ?? currentState).copyWith(
        isValidating: false,
        errorMessage: 'Erro inesperado na validação',
      );
      state = AsyncValue.data(updatedState);
      return null;
    }
  }

  /// Refresh - alias for loadDevices
  Future<void> refresh() async {
    await loadDevices(refresh: true);
  }

  /// Load device statistics
  Future<void> loadStatistics({bool refresh = false}) async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    try {
      final result = await _getDeviceStatisticsUseCase.call(const GetDeviceStatisticsParams());

      final statistics = result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Error loading statistics: ${failure.message}');
          }
          return null;
        },
        (stats) => stats,
      );

      state = AsyncValue.data(currentState.copyWith(
        statistics: statistics,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Exception loading statistics: $e');
      }
    }
  }

  /// Clear error message
  void clearError() {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }

  /// Clear success message
  void clearSuccess() {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();
    state = AsyncValue.data(currentState.copyWith(clearSuccess: true));
  }

  /// Reset state (on logout)
  void resetState() {
    state = AsyncValue.data(DeviceManagementState.initial());
  }
}

// Provider instances
final deviceManagementProvider =
    AsyncNotifierProvider<DeviceManagementNotifier, DeviceManagementState>(() {
  return DeviceManagementNotifier();
});
