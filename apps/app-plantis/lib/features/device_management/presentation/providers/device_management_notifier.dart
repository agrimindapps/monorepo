import 'dart:async';

import 'package:core/core.dart'
    hide
        GetUserDevicesUseCase,
        ValidateDeviceUseCase,
        RevokeDeviceUseCase,
        RevokeAllOtherDevicesUseCase,
        DeviceValidationResult,
        ValidateDeviceParams,
        GetUserDevicesParams,
        RevokeDeviceParams,
        RevokeAllOtherDevicesParams,
        getIt;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/device_model.dart';
import '../../domain/usecases/get_device_statistics_usecase.dart';
import '../../domain/usecases/get_user_devices_usecase.dart';
import '../../domain/usecases/revoke_device_usecase.dart';
import '../../domain/usecases/validate_device_usecase.dart';

part 'device_management_notifier.g.dart';

/// State model para device management (imutável)
class DeviceManagementState {
  final List<DeviceModel> devices;
  final DeviceModel? currentDevice;
  final DeviceStatisticsModel? statistics;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final bool isValidating;
  final bool isRevoking;
  final String? revokingDeviceUuid;

  const DeviceManagementState({
    required this.devices,
    this.currentDevice,
    this.statistics,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.isValidating = false,
    this.isRevoking = false,
    this.revokingDeviceUuid,
  });

  factory DeviceManagementState.initial() {
    return const DeviceManagementState(
      devices: [],
      isLoading: false,
      isInitialized: false,
    );
  }

  DeviceManagementState copyWith({
    List<DeviceModel>? devices,
    DeviceModel? currentDevice,
    DeviceStatisticsModel? statistics,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    bool? isValidating,
    bool? isRevoking,
    String? revokingDeviceUuid,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearRevoking = false,
  }) {
    return DeviceManagementState(
      devices: devices ?? this.devices,
      currentDevice: currentDevice ?? this.currentDevice,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isValidating: isValidating ?? this.isValidating,
      isRevoking: isRevoking ?? this.isRevoking,
      revokingDeviceUuid: clearRevoking ? null : (revokingDeviceUuid ?? this.revokingDeviceUuid),
    );
  }
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
}

@riverpod
GetUserDevicesUseCase getUserDevicesUseCase(GetUserDevicesUseCaseRef ref) {
  return getIt<GetUserDevicesUseCase>();
}

@riverpod
ValidateDeviceUseCase validateDeviceUseCase(ValidateDeviceUseCaseRef ref) {
  return getIt<ValidateDeviceUseCase>();
}

@riverpod
RevokeDeviceUseCase revokeDeviceUseCase(RevokeDeviceUseCaseRef ref) {
  return getIt<RevokeDeviceUseCase>();
}

@riverpod
RevokeAllOtherDevicesUseCase revokeAllOtherDevicesUseCase(RevokeAllOtherDevicesUseCaseRef ref) {
  return getIt<RevokeAllOtherDevicesUseCase>();
}

@riverpod
GetDeviceStatisticsUseCase getDeviceStatisticsUseCase(GetDeviceStatisticsUseCaseRef ref) {
  return getIt<GetDeviceStatisticsUseCase>();
}

@riverpod
AuthStateNotifier authStateNotifier(AuthStateNotifierRef ref) {
  return getIt<AuthStateNotifier>();
}

@riverpod
class DeviceManagementNotifier extends _$DeviceManagementNotifier {
  late final GetUserDevicesUseCase _getUserDevicesUseCase;
  late final ValidateDeviceUseCase _validateDeviceUseCase;
  late final RevokeDeviceUseCase _revokeDeviceUseCase;
  late final RevokeAllOtherDevicesUseCase _revokeAllOtherDevicesUseCase;
  late final GetDeviceStatisticsUseCase _getDeviceStatisticsUseCase;
  late final AuthStateNotifier _authStateNotifier;

  StreamSubscription<UserEntity?>? _userSubscription;

  @override
  Future<DeviceManagementState> build() async {
    _getUserDevicesUseCase = ref.read(getUserDevicesUseCaseProvider);
    _validateDeviceUseCase = ref.read(validateDeviceUseCaseProvider);
    _revokeDeviceUseCase = ref.read(revokeDeviceUseCaseProvider);
    _revokeAllOtherDevicesUseCase = ref.read(revokeAllOtherDevicesUseCaseProvider);
    _getDeviceStatisticsUseCase = ref.read(getDeviceStatisticsUseCaseProvider);
    _authStateNotifier = ref.read(authStateNotifierProvider);
    ref.onDispose(() {
      _userSubscription?.cancel();
      if (kDebugMode) {
        debugPrint('♻️ DeviceProvider: Disposing');
      }
    });

    if (kDebugMode) {
      debugPrint('🔐 DeviceProvider: Initializing');
    }
    _userSubscription = _authStateNotifier.userStream.listen(_onUserChanged);
    if (_authStateNotifier.isAuthenticated) {
      return await _initializeDeviceManagement();
    }

    return DeviceManagementState.initial();
  }

  /// Callback para mudanças de usuário
  void _onUserChanged(UserEntity? user) {
    if (user == null) {
      _resetState();
    } else {
      state = const AsyncValue.loading();
      _reinitialize();
    }
  }

  /// Reinitialize after user login
  Future<void> _reinitialize() async {
    state = await AsyncValue.guard(() => _initializeDeviceManagement());
  }

  /// Inicializa gerenciamento de dispositivos
  Future<DeviceManagementState> _initializeDeviceManagement() async {
    try {
      final currentDevice = await DeviceModel.fromCurrentDevice();
      if (currentDevice == null) {
        if (kDebugMode) {
          debugPrint('🚫 DeviceProvider: Current platform not supported for device management');
        }
        return DeviceManagementState.initial().copyWith(isInitialized: true);
      }

      if (kDebugMode) {
        debugPrint('📱 DeviceProvider: Current device identified: ${currentDevice.name}');
      }
      final devices = await _loadDevicesData();

      if (kDebugMode) {
        debugPrint('✅ DeviceProvider: Initialized successfully');
      }

      return DeviceManagementState(
        devices: devices,
        currentDevice: currentDevice,
        isInitialized: true,
        isLoading: false,
      );
    } catch (e) {
      return DeviceManagementState.initial().copyWith(
        errorMessage: 'Erro ao inicializar gerenciamento de dispositivos: $e',
        isInitialized: false,
      );
    }
  }

  /// Carrega lista de dispositivos (retorna dados sem modificar state)
  Future<List<DeviceModel>> _loadDevicesData() async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Loading devices');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      const params = GetUserDevicesParams(activeOnly: false);
      final result = await _getUserDevicesUseCase(params);

      return result.fold(
        (failure) {
          throw Exception('Erro ao carregar dispositivos: ${failure.message}');
        },
        (devices) {
          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: Loaded ${devices.length} devices');
          }
          return devices.map((entity) => DeviceModel.fromEntity(entity)).toList();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceProvider: Error loading devices: $e');
      }
      rethrow;
    }
  }

  /// Carrega lista de dispositivos (public method)
  Future<void> loadDevices({bool refresh = false}) async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    state = AsyncValue.data(currentState.copyWith(
      isLoading: true,
      clearError: true,
    ));

    try {
      final devices = await _loadDevicesData();

      state = AsyncValue.data(currentState.copyWith(
        devices: devices,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        errorMessage: 'Erro inesperado ao carregar dispositivos: $e',
        isLoading: false,
      ));
    }
  }

  /// Valida dispositivo atual
  Future<DeviceValidationResult?> validateCurrentDevice() async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    if (currentState.isValidating) return null;

    state = AsyncValue.data(currentState.copyWith(
      isValidating: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Validating current device');
      }

      if (currentState.currentDevice == null) {
        state = AsyncValue.data(currentState.copyWith(
          errorMessage: 'Nenhum dispositivo atual identificado',
          isValidating: false,
        ));
        return null;
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        state = AsyncValue.data(currentState.copyWith(
          errorMessage: 'Usuário não autenticado',
          isValidating: false,
        ));
        return null;
      }

      final params = ValidateDeviceParams(device: currentState.currentDevice);
      final result = await _validateDeviceUseCase(params);

      return result.fold(
        (failure) {
          state = AsyncValue.data(currentState.copyWith(
            errorMessage: 'Erro ao validar dispositivo: ${failure.message}',
            isValidating: false,
          ));
          return null;
        },
        (validationResult) {
          if (validationResult.isValid) {
            state = AsyncValue.data(currentState.copyWith(
              successMessage: 'Dispositivo validado com sucesso',
              isValidating: false,
            ));
            loadDevices();
          } else {
            state = AsyncValue.data(currentState.copyWith(
              errorMessage: validationResult.message ?? 'Falha na validação do dispositivo',
              isValidating: false,
            ));
          }

          return validationResult;
        },
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        errorMessage: 'Erro inesperado na validação: $e',
        isValidating: false,
      ));
      return null;
    }
  }

  /// Revoga um dispositivo específico
  Future<bool> revokeDevice(String deviceUuid, {String? reason}) async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    if (currentState.isRevoking) return false;
    if (currentState.currentDevice?.uuid == deviceUuid) {
      state = AsyncValue.data(currentState.copyWith(
        errorMessage: 'Não é possível revogar o dispositivo atual',
      ));
      return false;
    }

    state = AsyncValue.data(currentState.copyWith(
      isRevoking: true,
      revokingDeviceUuid: deviceUuid,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Revoking device $deviceUuid');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        state = AsyncValue.data(currentState.copyWith(
          errorMessage: 'Usuário não autenticado',
          isRevoking: false,
          clearRevoking: true,
        ));
        return false;
      }

      final params = RevokeDeviceParams(deviceUuid: deviceUuid);
      final result = await _revokeDeviceUseCase(params);

      return result.fold(
        (failure) {
          state = AsyncValue.data(currentState.copyWith(
            errorMessage: 'Erro ao revogar dispositivo: ${failure.message}',
            isRevoking: false,
            clearRevoking: true,
          ));
          return false;
        },
        (_) {
          final updatedDevices = currentState.devices.where((d) => d.uuid != deviceUuid).toList();

          state = AsyncValue.data(currentState.copyWith(
            devices: updatedDevices,
            successMessage: 'Dispositivo revogado com sucesso',
            isRevoking: false,
            clearRevoking: true,
          ));
          loadDevices();

          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: Device revoked successfully');
          }

          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        errorMessage: 'Erro inesperado ao revogar dispositivo: $e',
        isRevoking: false,
        clearRevoking: true,
      ));
      return false;
    }
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<bool> revokeAllOtherDevices({String? reason}) async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    if (currentState.isRevoking) return false;

    state = AsyncValue.data(currentState.copyWith(
      isRevoking: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Revoking all other devices');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        state = AsyncValue.data(currentState.copyWith(
          errorMessage: 'Usuário não autenticado',
          isRevoking: false,
        ));
        return false;
      }

      if (currentState.currentDevice?.uuid == null) {
        state = AsyncValue.data(currentState.copyWith(
          errorMessage: 'Dispositivo atual não identificado',
          isRevoking: false,
        ));
        return false;
      }

      final params = RevokeAllOtherDevicesParams(
        currentDeviceUuid: currentState.currentDevice!.uuid,
      );

      final result = await _revokeAllOtherDevicesUseCase(params);

      return result.fold(
        (failure) {
          state = AsyncValue.data(currentState.copyWith(
            errorMessage: 'Erro ao revogar outros dispositivos: ${failure.message}',
            isRevoking: false,
          ));
          return false;
        },
        (_) {
          state = AsyncValue.data(currentState.copyWith(
            successMessage: 'Outros dispositivos revogados com sucesso',
            isRevoking: false,
          ));
          loadDevices();

          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: All other devices revoked');
          }

          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        errorMessage: 'Erro inesperado ao revogar outros dispositivos: $e',
        isRevoking: false,
      ));
      return false;
    }
  }

  /// Refresh completo dos dados
  Future<void> refresh() async {
    await loadDevices(refresh: true);
  }

  /// Obtém dispositivo por UUID
  DeviceModel? getDeviceByUuid(String uuid) {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();
    try {
      return currentState.devices.firstWhere((device) => device.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se dispositivo está sendo revogado
  bool isDeviceBeingRevoked(String uuid) {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();
    return currentState.isRevoking && currentState.revokingDeviceUuid == uuid;
  }

  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    state = AsyncValue.data(
      (state.valueOrNull ?? DeviceManagementState.initial()).copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  /// Carrega estatísticas de dispositivos
  Future<void> loadStatistics({bool refresh = false}) async {
    final currentState = state.valueOrNull ?? DeviceManagementState.initial();

    if (currentState.isLoading) return;

    try {
      state = AsyncValue.data(currentState.copyWith(
        isLoading: true,
        clearError: true,
      ));

      if (kDebugMode) {
        debugPrint('🔄 DeviceProvider: Loading statistics (refresh: $refresh)');
      }

      final result = await _getDeviceStatisticsUseCase(
        GetDeviceStatisticsParams(
          includeExtendedInfo: true,
          refreshCache: refresh,
        ),
      );

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceProvider: Failed to load statistics - ${failure.message}');
          }
          state = AsyncValue.data(currentState.copyWith(
            errorMessage: 'Erro ao carregar estatísticas: ${failure.message}',
            isLoading: false,
          ));
        },
        (statistics) {
          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: Statistics loaded successfully');
          }
          state = AsyncValue.data(currentState.copyWith(
            statistics: statistics,
            isLoading: false,
          ));
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceProvider: Unexpected error loading statistics - $e');
      }
      state = AsyncValue.data(currentState.copyWith(
        errorMessage: 'Erro inesperado ao carregar estatísticas',
        isLoading: false,
      ));
    }
  }

  /// Resets estado do provider
  void _resetState() {
    if (kDebugMode) {
      debugPrint('🔄 DeviceProvider: Resetting state');
    }

    state = AsyncValue.data(DeviceManagementState.initial());
  }
}

/// Extensions para helpers de texto e formatação
extension DeviceManagementStateExtensions on DeviceManagementState {
  /// Texto de status dos dispositivos
  String get statusText {
    if (!isInitialized) return 'Carregando...';
    if (!hasDevices) return 'Nenhum dispositivo registrado';

    final active = activeDeviceCount;
    final total = totalDeviceCount;

    if (active == total) {
      return active == 1 ? '1 dispositivo ativo' : '$active dispositivos ativos';
    } else {
      return '$active de $total dispositivos ativos';
    }
  }

  /// Cor do status para UI
  Color get statusColor {
    if (!hasDevices) return Colors.grey;
    if (activeDeviceCount == totalDeviceCount) return Colors.green;
    return Colors.orange;
  }

  /// Ícone do status
  IconData get statusIcon {
    if (!hasDevices) return Icons.devices_other;
    if (activeDeviceCount == totalDeviceCount) return Icons.verified;
    return Icons.warning;
  }

  /// Texto de limite de dispositivos
  String get deviceLimitText {
    return '$activeDeviceCount/3 dispositivos';
  }

  /// Se está próximo do limite
  bool get isNearDeviceLimit => activeDeviceCount >= 2;

  /// Se atingiu o limite
  bool get hasReachedDeviceLimit => activeDeviceCount >= 3;
}
