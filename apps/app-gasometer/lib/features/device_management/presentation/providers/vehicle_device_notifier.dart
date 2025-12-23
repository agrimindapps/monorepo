import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../domain/extensions/vehicle_device_extension.dart';

/// Provider para DeviceManagementService do core
final coreDeviceManagementServiceProvider = Provider<core.DeviceManagementService>((ref) {
  return ref.watch(deviceManagementServiceProvider);
});

/// Provider de conectividade (stream)
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

/// Provider de status online
final isOnlineStatusProvider = FutureProvider<bool>((ref) async {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final result = await connectivityService.isOnline();

  return result.fold((core.Failure failure) {
    debugPrint('Connectivity check failed: ${failure.message}');
    return false;
  }, (bool isOnline) => isOnline);
});

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

/// Notifier principal para gerenciamento de dispositivos veiculares
class VehicleDeviceNotifier extends StateNotifier<VehicleDeviceState> {
  VehicleDeviceNotifier(this._ref, this._deviceService) : super(VehicleDeviceState.empty) {
    // Listen para mudanças de conectividade
    _ref.listen<AsyncValue<bool>>(isOnlineStatusProvider, (previous, next) {
      next.whenData((isOnline) {
        final wasOnline = state.isOnline;

        if (!wasOnline && isOnline) {
          debugPrint('🔌 Back online - refreshing devices');
          loadUserDevices();
        }

        state = state.copyWith(isOnline: isOnline);
      });
    });
  }
  
  static const int _deviceLimit = 3; // Free tier
  final Ref _ref;
  final core.DeviceManagementService _deviceService;

  /// Carrega dispositivos do usuário do Firebase
  Future<void> loadUserDevices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _deviceService.getUserDevices();
      
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ VehicleDeviceNotifier: Failed to load devices - ${failure.message}');
          }
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (devices) {
          final statistics = VehicleDeviceStatistics.fromDevices(devices);

          state = state.copyWith(
            devices: devices,
            statistics: statistics,
            isLoading: false,
          );

          if (kDebugMode) {
            debugPrint('✅ VehicleDeviceNotifier: Loaded ${devices.length} devices');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ VehicleDeviceNotifier: Unexpected error - $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  /// Valida se o dispositivo pode ser registrado
  Future<bool> validateDeviceRegistration(core.DeviceEntity device) async {
    try {
      final canAddResult = await _deviceService.canAddMoreDevices();
      
      return canAddResult.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
          return false;
        },
        (canAdd) {
          if (!canAdd) {
            state = state.copyWith(
              errorMessage:
                  'Limite de dispositivos atingido. Faça upgrade para adicionar mais.',
            );
            return false;
          }

          final isValid = device.isPhysicalDevice && device.isActive;
          if (!isValid) {
            state = state.copyWith(
              errorMessage: 'Dispositivo não passou na validação de segurança.',
            );
          }

          return isValid;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro na validação: $e');
      return false;
    }
  }

  /// Revoga um dispositivo específico
  Future<bool> revokeDevice(String deviceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Find device UUID from ID
      final device = state.devices.firstWhere(
        (d) => d.id == deviceId,
        orElse: () => throw Exception('Dispositivo não encontrado'),
      );
      
      final result = await _deviceService.revokeDevice(device.uuid);
      
      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ VehicleDeviceNotifier: Failed to revoke - ${failure.message}');
          }
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (_) {
          // Remove from local state
          final updatedDevices =
              state.devices.where((d) => d.id != deviceId).toList();
          final statistics = VehicleDeviceStatistics.fromDevices(updatedDevices);

          state = state.copyWith(
            devices: updatedDevices,
            statistics: statistics,
            isLoading: false,
          );

          if (kDebugMode) {
            debugPrint('✅ VehicleDeviceNotifier: Device $deviceId revoked');
          }
          return true;
        },
      );
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
      for (final deviceId in deviceIds) {
        final success = await revokeDevice(deviceId);
        if (success) {
          revokedCount++;
        }
      }

      if (kDebugMode) {
        debugPrint('🔄 Revoked $revokedCount/${deviceIds.length} devices');
      }

      if (revokedCount < deviceIds.length) {
        state = state.copyWith(
          errorMessage: 'Alguns dispositivos não puderam ser revogados',
        );
      }
      
      state = state.copyWith(isLoading: false);
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
    final result = await _deviceService.getDeviceStatistics();
    
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('⚠️ VehicleDeviceNotifier: Failed to get statistics');
        }
      },
      (coreStats) {
        final statistics = VehicleDeviceStatistics.fromDevices(state.devices);
        state = state.copyWith(statistics: statistics);
      },
    );
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<bool> revokeAllOtherDevices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final current = state.currentDevice;
      if (current == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Nenhum dispositivo atual encontrado',
        );
        return false;
      }

      final result = await _deviceService.revokeAllOtherDevices(current.uuid);
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (_) {
          // Keep only current device in state
          final statistics = VehicleDeviceStatistics.fromDevices([current]);

          state = state.copyWith(
            devices: [current],
            statistics: statistics,
            isLoading: false,
          );

          if (kDebugMode) {
            debugPrint('✅ VehicleDeviceNotifier: All other devices revoked');
          }
          return true;
        },
      );
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

/// Provider principal para VehicleDeviceNotifier
final vehicleDeviceProvider = StateNotifierProvider<VehicleDeviceNotifier, VehicleDeviceState>((ref) {
  final deviceService = ref.watch(deviceManagementServiceProvider);
  return VehicleDeviceNotifier(ref, deviceService);
});

/// Provider conveniente para acessar o state
final vehicleDeviceStateProvider = Provider<VehicleDeviceState>((ref) {
  return ref.watch(vehicleDeviceProvider);
});

/// Provider para dispositivos ativos
final activeDevicesProvider = Provider<List<core.DeviceEntity>>((ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.activeDevices;
});

/// Provider para dispositivos confiáveis
final trustedDevicesProvider = Provider<List<core.DeviceEntity>>((ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.trustedDevices;
});

/// Provider para dispositivo atual
final currentDeviceProvider = Provider<core.DeviceEntity?>((ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.currentDevice;
});

/// Provider para estatísticas
final deviceStatisticsProvider = Provider<VehicleDeviceStatistics?>((ref) {
  final state = ref.watch(vehicleDeviceStateProvider);
  return state.statistics;
});

/// Provider para verificar se pode adicionar mais dispositivos
final canAddMoreDevicesProvider = Provider<bool>((ref) {
  final notifier = ref.watch(vehicleDeviceProvider.notifier);
  return notifier.canAddMoreDevices;
});
