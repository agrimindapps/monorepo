import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../domain/extensions/vehicle_device_extension.dart';

part 'vehicle_device_notifier.g.dart';

/// State para gerenciamento de dispositivos veiculares
class VehicleDeviceState {
  const VehicleDeviceState({
    required this.devices,
    this.statistics,
    this.isLoading = false,
    this.errorMessage,
    this.isOnline = true,
  });

  final List<core.DeviceEntity> devices;
  final VehicleDeviceStatistics? statistics;
  final bool isLoading;
  final String? errorMessage;
  final bool isOnline;
  bool get hasError => errorMessage != null;
  bool get hasDevices => devices.isNotEmpty;

  /// Dispositivos ativos (com funcionalidades veiculares)
  List<core.DeviceEntity> get activeDevices =>
      devices.where((device) => device.canAccessVehicle).toList();

  /// Dispositivos inativos
  List<core.DeviceEntity> get inactiveDevices =>
      devices.where((device) => !device.isActive).toList();

  /// Dispositivos confiáveis para dados financeiros
  List<core.DeviceEntity> get trustedDevices =>
      devices.where((device) => device.canAccessFinancialData).toList();

  /// Número de dispositivos ativos
  int get activeDeviceCount => activeDevices.length;

  /// Dispositivo atual (se disponível)
  core.DeviceEntity? get currentDevice {
    if (devices.isEmpty) return null;
    final sortedDevices = List<core.DeviceEntity>.from(devices)
      ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
    return sortedDevices.first;
  }

  VehicleDeviceState copyWith({
    List<core.DeviceEntity>? devices,
    VehicleDeviceStatistics? statistics,
    bool? isLoading,
    String? errorMessage,
    bool? isOnline,
    bool clearError = false,
  }) {
    return VehicleDeviceState(
      devices: devices ?? this.devices,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Empty state
  static const empty = VehicleDeviceState(devices: []);
}

/// Informações sobre limite de dispositivos
class DeviceLimitInfo {
  const DeviceLimitInfo({
    required this.currentCount,
    required this.limit,
    required this.canAddMore,
    required this.planName,
    required this.requiresUpgrade,
  });

  final int currentCount;
  final int limit;
  final bool canAddMore;
  final String planName;
  final bool requiresUpgrade;

  /// Porcentagem do limite utilizada
  double get usagePercentage => limit > 0 ? (currentCount / limit) : 0.0;

  /// Dispositivos restantes que podem ser adicionados
  int get remainingDevices => limit - currentCount;

  /// Status textual do limite
  String get statusText {
    if (requiresUpgrade) {
      return 'Limite atingido ($currentCount/$limit)';
    }
    return 'Dispositivos: $currentCount/$limit';
  }
}

/// Provider de dependências: DeviceManagementService (mock por enquanto)
@riverpod
core.DeviceManagementService? deviceManagementService(Ref ref) {
  return null;
}

/// Provider de conectividade (stream)
/// Uses ConnectivityService from dependency_providers.dart (Riverpod provider)
@riverpod
Stream<bool> connectivityStream(Ref ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
}

/// Provider de status online
/// Uses ConnectivityService from dependency_providers.dart (Riverpod provider)
@riverpod
Future<bool> isOnlineStatus(Ref ref) async {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final result = await connectivityService.isOnline();

  return result.fold((core.Failure failure) {
    debugPrint('Connectivity check failed: ${failure.message}');
    return false;
  }, (bool isOnline) => isOnline);
}

/// Notifier principal para gerenciamento de dispositivos veiculares
@riverpod
class VehicleDeviceNotifier extends _$VehicleDeviceNotifier {
  static const int _deviceLimit = 3; // Free tier

  @override
  VehicleDeviceState build() {
    ref.listen<AsyncValue<bool>>(isOnlineStatusProvider, (previous, next) {
      next.whenData((isOnline) {
        final wasOnline = state.isOnline;

        if (!wasOnline && isOnline) {
          debugPrint('🔌 Back online - refreshing devices');
          loadUserDevices();
        }

        state = state.copyWith(isOnline: isOnline);
      });
    });
    return VehicleDeviceState.empty;
  }

  /// Carrega dispositivos do usuário (MOCK IMPLEMENTATION)
  /// TODO: Substituir por implementação real quando DeviceManagementService estiver disponível
  Future<void> loadUserDevices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Mock devices for development - replace with real device management service
      final mockDevices = [
        core.DeviceEntity(
          id: 'device_1',
          uuid: 'mock_uuid_1',
          name: 'iPhone Principal',
          model: 'iPhone 14 Pro',
          platform: 'iOS',
          systemVersion: '16.4',
          appVersion: '2.1.0',
          buildNumber: '45',
          isPhysicalDevice: true,
          manufacturer: 'Apple',
          firstLoginAt: DateTime.now().subtract(const Duration(days: 30)),
          lastActiveAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        core.DeviceEntity(
          id: 'device_2',
          uuid: 'mock_uuid_2',
          name: 'Samsung Tablet',
          model: 'Galaxy Tab S8',
          platform: 'Android',
          systemVersion: '13.0',
          appVersion: '2.1.0',
          buildNumber: '45',
          isPhysicalDevice: true,
          manufacturer: 'Samsung',
          firstLoginAt: DateTime.now().subtract(const Duration(days: 15)),
          lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      final statistics = VehicleDeviceStatistics.fromDevices(mockDevices);

      state = state.copyWith(
        devices: mockDevices,
        statistics: statistics,
        isLoading: false,
      );

      debugPrint(
        '🔄 Loaded ${mockDevices.length} mock devices (development mode)',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  /// Valida se o dispositivo pode ser registrado
  Future<bool> validateDeviceRegistration(core.DeviceEntity device) async {
    try {
      if (!canAddMoreDevices) {
        state = state.copyWith(
          errorMessage:
              'Limite de dispositivos atingido. Faça upgrade para adicionar mais.',
        );
        return false;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final isValid = device.isPhysicalDevice && device.isActive;
      if (!isValid) {
        state = state.copyWith(
          errorMessage: 'Dispositivo não passou na validação de segurança.',
        );
      }

      return isValid;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro na validação: $e');
      return false;
    }
  }

  /// Revoga um dispositivo específico
  Future<bool> revokeDevice(String deviceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final deviceExists = state.devices.any((device) => device.id == deviceId);
      if (!deviceExists) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Dispositivo não encontrado',
        );
        return false;
      }

      final updatedDevices =
          state.devices.where((device) => device.id != deviceId).toList();
      final statistics = VehicleDeviceStatistics.fromDevices(updatedDevices);

      state = state.copyWith(
        devices: updatedDevices,
        statistics: statistics,
        isLoading: false,
      );

      debugPrint('🔄 Device $deviceId revoked');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
      return false;
    }
  }

  /// Revoga múltiplos dispositivos
  Future<int> revokeMultipleDevices(List<String> deviceIds) async {
    state = state.copyWith(isLoading: true, clearError: true);

    var revokedCount = 0;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final updatedDevices = <core.DeviceEntity>[];
      for (final device in state.devices) {
        if (deviceIds.contains(device.id)) {
          revokedCount++;
        } else {
          updatedDevices.add(device);
        }
      }

      final statistics = VehicleDeviceStatistics.fromDevices(updatedDevices);

      state = state.copyWith(
        devices: updatedDevices,
        statistics: statistics,
        isLoading: false,
      );

      debugPrint('🔄 Revoked $revokedCount/${deviceIds.length} devices');

      if (revokedCount < deviceIds.length) {
        state = state.copyWith(
          errorMessage: 'Alguns dispositivos não puderam ser revogados',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao revogar dispositivos: $e',
      );
    }

    return revokedCount;
  }

  /// Obtém estatísticas detalhadas dos dispositivos
  Future<void> refreshStatistics() async {
    final statistics = VehicleDeviceStatistics.fromDevices(state.devices);
    state = state.copyWith(statistics: statistics);
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<bool> revokeAllOtherDevices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (state.devices.isNotEmpty) {
        final current = state.currentDevice;
        if (current != null) {
          final statistics = VehicleDeviceStatistics.fromDevices([current]);

          state = state.copyWith(
            devices: [current],
            statistics: statistics,
            isLoading: false,
          );

          return true;
        }
      }

      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao revogar outros dispositivos: $e',
      );
      return false;
    }
  }

  /// Atualiza lista de dispositivos
  Future<void> refresh() async {
    await loadUserDevices();
  }

  /// Obtém dispositivo por UUID
  core.DeviceEntity? getDeviceByUuid(String uuid) {
    try {
      return state.devices.firstWhere((device) => device.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se o dispositivo é o atual
  bool isCurrentDevice(String uuid) {
    final current = state.currentDevice;
    return current?.uuid == uuid;
  }

  /// Indica se pode adicionar mais dispositivos (baseado em limites premium)
  bool get canAddMoreDevices => state.activeDeviceCount < _deviceLimit;

  /// Obtém dispositivos ordenados por prioridade de sync
  List<core.DeviceEntity> getDevicesBySyncPriority() {
    final sortedDevices = List<core.DeviceEntity>.from(state.devices)
      ..sort((a, b) => b.syncPriority.compareTo(a.syncPriority));
    return sortedDevices;
  }

  /// Obtém dispositivos elegíveis para sync de dados offline
  List<core.DeviceEntity> getOfflineSyncDevices() {
    return state.devices.where((device) => device.canSyncOfflineData).toList();
  }

  /// Verifica se há conflitos de dados entre dispositivos
  Future<bool> checkForDataConflicts() async {
    return false;
  }

  /// Obtém informações de limite de dispositivos baseado na assinatura
  Future<DeviceLimitInfo> getDeviceLimitInfo() async {
    final currentCount = state.activeDeviceCount;

    return DeviceLimitInfo(
      currentCount: currentCount,
      limit: _deviceLimit,
      canAddMore: currentCount < _deviceLimit,
      planName: 'Plano Gratuito',
      requiresUpgrade: currentCount >= _deviceLimit,
    );
  }
}

/// Provider conveniente para acessar o state
@riverpod
VehicleDeviceState vehicleDeviceState(Ref ref) {
  return ref.watch(vehicleDeviceProvider);
}

/// Provider para dispositivos ativos
@riverpod
List<core.DeviceEntity> activeDevices(Ref ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.activeDevices;
}

/// Provider para dispositivos confiáveis
@riverpod
List<core.DeviceEntity> trustedDevices(Ref ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.trustedDevices;
}

/// Provider para dispositivo atual
@riverpod
core.DeviceEntity? currentDevice(Ref ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.currentDevice;
}

/// Provider para estatísticas
@riverpod
VehicleDeviceStatistics? deviceStatistics(Ref ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.statistics;
}

/// Provider para verificar se pode adicionar mais dispositivos
@riverpod
bool canAddMoreDevices(Ref ref) {
  final notifier = ref.watch(vehicleDeviceProvider.notifier);
  return notifier.canAddMoreDevices;
}
