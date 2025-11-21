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
        RevokeAllOtherDevicesParams;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../data/models/device_model.dart';
import '../../domain/usecases/get_device_statistics_usecase.dart';
import '../../domain/usecases/get_user_devices_usecase.dart';
import '../../domain/usecases/revoke_device_usecase.dart';
import '../../domain/usecases/validate_device_usecase.dart';
import 'device_management_providers.dart';

part 'device_management_provider.freezed.dart';
part 'device_management_provider.g.dart';

/// State for Device Management
@freezed
class DeviceManagementState with _$DeviceManagementState {
  const factory DeviceManagementState({
    @Default([]) List<DeviceModel> devices,
    DeviceModel? currentDevice,
    DeviceStatisticsModel? statistics,
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
    String? errorMessage,
    String? successMessage,
    @Default(false) bool isValidating,
    @Default(false) bool isRevoking,
    String? revokingDeviceUuid,
  }) = _DeviceManagementState;

  const DeviceManagementState._();

  List<DeviceModel> get activeDevices =>
      devices.where((d) => d.isActive).toList();

  List<DeviceModel> get inactiveDevices =>
      devices.where((d) => !d.isActive).toList();

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

  String get statusText {
    if (!isInitialized) return 'Carregando...';
    if (!hasDevices) return 'Nenhum dispositivo registrado';

    final active = activeDeviceCount;
    final total = totalDeviceCount;

    if (active == total) {
      return active == 1
          ? '1 dispositivo ativo'
          : '$active dispositivos ativos';
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

  String get deviceLimitText {
    return '$activeDeviceCount/3 dispositivos';
  }

  bool get isNearDeviceLimit => activeDeviceCount >= 2;
  bool get hasReachedDeviceLimit => activeDeviceCount >= 3;
}

/// Provider para gerenciar estado de dispositivos no app-plantis
@riverpod
class DeviceManagementNotifier extends _$DeviceManagementNotifier {
  late final GetUserDevicesUseCase _getUserDevicesUseCase;
  late final ValidateDeviceUseCase _validateDeviceUseCase;
  late final RevokeDeviceUseCase _revokeDeviceUseCase;
  late final RevokeAllOtherDevicesUseCase _revokeAllOtherDevicesUseCase;
  late final GetDeviceStatisticsUseCase _getDeviceStatisticsUseCase;
  
  AuthStateNotifier get _authStateNotifier => ref.read(authStateNotifierProvider);

  StreamSubscription<UserEntity?>? _userSubscription;

  @override
  DeviceManagementState build() {
    ref.onDispose(() {
      if (kDebugMode) {
        debugPrint('♻️ DeviceProvider: Disposing');
      }
      _userSubscription?.cancel();
    });

    _initializeProvider();

    return const DeviceManagementState();
  }

  /// Inicializa o provider
  Future<void> _initializeProvider() async {
    if (kDebugMode) {
      debugPrint('🔐 DeviceProvider: Initializing');
    }

    try {
      _getUserDevicesUseCase = await ref.read(getUserDevicesUseCaseProvider.future);
      _validateDeviceUseCase = await ref.read(validateDeviceUseCaseProvider.future);
      _revokeDeviceUseCase = await ref.read(revokeDeviceUseCaseProvider.future);
      _revokeAllOtherDevicesUseCase = await ref.read(revokeAllOtherDevicesUseCaseProvider.future);
      _getDeviceStatisticsUseCase = await ref.read(getDeviceStatisticsUseCaseProvider.future);

      _userSubscription = _authStateNotifier.userStream.listen(_onUserChanged);

      if (_authStateNotifier.isAuthenticated) {
        _initializeDeviceManagement();
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao carregar dependências: $e');
    }
  }

  /// Callback para mudanças de usuário
  void _onUserChanged(UserEntity? user) {
    if (user == null) {
      _resetState();
    } else {
      _initializeDeviceManagement();
    }
  }

  /// Inicializa gerenciamento de dispositivos
  Future<void> _initializeDeviceManagement() async {
    if (state.isInitialized) return;

    _setLoading(true);
    _clearMessages();

    try {
      await _identifyCurrentDevice();
      await _loadDevices(showLoading: false);

      state = state.copyWith(isInitialized: true);

      if (kDebugMode) {
        debugPrint('✅ DeviceProvider: Initialized successfully');
      }
    } catch (e) {
      _setError('Erro ao inicializar gerenciamento de dispositivos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Identifica o dispositivo atual
  Future<void> _identifyCurrentDevice() async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Identifying current device');
      }

      final currentDevice = await DeviceModel.fromCurrentDevice();
      if (currentDevice == null) {
        if (kDebugMode) {
          debugPrint(
            '🚫 DeviceProvider: Current platform not supported for device management',
          );
        }
        return;
      }

      state = state.copyWith(currentDevice: currentDevice);

      if (kDebugMode) {
        debugPrint(
          '📱 DeviceProvider: Current device identified: ${currentDevice.name}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceProvider: Error identifying current device: $e');
      }
    }
  }

  /// Carrega lista de dispositivos
  Future<void> loadDevices({bool refresh = false}) async {
    await _loadDevices(showLoading: true, refresh: refresh);
  }

  Future<void> _loadDevices({
    bool showLoading = true,
    bool refresh = false,
  }) async {
    if (showLoading) _setLoading(true);
    _clearMessages();

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Loading devices (refresh: $refresh)');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _setError('Usuário não autenticado');
        return;
      }

      const params = GetUserDevicesParams(activeOnly: false);

      final result = await _getUserDevicesUseCase(params);

      result.fold(
        (failure) {
          _setError('Erro ao carregar dispositivos: ${failure.message}');
        },
        (devices) {
          final deviceModels =
              devices.map((entity) => DeviceModel.fromEntity(entity)).toList();
          state = state.copyWith(devices: deviceModels);
          _clearError();

          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: Loaded ${devices.length} devices');
          }
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao carregar dispositivos: $e');
    } finally {
      if (showLoading) _setLoading(false);
    }
  }

  /// Valida dispositivo atual
  Future<DeviceValidationResult?> validateCurrentDevice() async {
    if (state.isValidating) return null;

    state = state.copyWith(isValidating: true);
    _clearMessages();

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Validating current device');
      }

      if (state.currentDevice == null) {
        _setError('Nenhum dispositivo atual identificado');
        return null;
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _setError('Usuário não autenticado');
        return null;
      }

      final params = ValidateDeviceParams(device: state.currentDevice);

      final result = await _validateDeviceUseCase(params);

      return result.fold(
        (failure) {
          _setError('Erro ao validar dispositivo: ${failure.message}');
          return null;
        },
        (validationResult) {
          if (validationResult.isValid) {
            _setSuccess('Dispositivo validado com sucesso');
            _loadDevices(showLoading: false);
          } else {
            _setError(
              validationResult.message ?? 'Falha na validação do dispositivo',
            );
          }

          return validationResult;
        },
      );
    } catch (e) {
      _setError('Erro inesperado na validação: $e');
      return null;
    } finally {
      state = state.copyWith(isValidating: false);
    }
  }

  /// Revoga um dispositivo específico
  Future<bool> revokeDevice(String deviceUuid, {String? reason}) async {
    if (state.isRevoking) return false;
    if (state.currentDevice?.uuid == deviceUuid) {
      _setError('Não é possível revogar o dispositivo atual');
      return false;
    }

    state = state.copyWith(isRevoking: true, revokingDeviceUuid: deviceUuid);
    _clearMessages();

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Revoking device $deviceUuid');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      final params = RevokeDeviceParams(deviceUuid: deviceUuid);

      final result = await _revokeDeviceUseCase(params);

      return result.fold(
        (failure) {
          _setError('Erro ao revogar dispositivo: ${failure.message}');
          return false;
        },
        (_) {
          _setSuccess('Dispositivo revogado com sucesso');
          final updatedDevices =
              state.devices.where((d) => d.uuid != deviceUuid).toList();
          state = state.copyWith(devices: updatedDevices);
          _loadDevices(showLoading: false);

          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: Device revoked successfully');
          }

          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao revogar dispositivo: $e');
      return false;
    } finally {
      state = state.copyWith(isRevoking: false, revokingDeviceUuid: null);
    }
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<bool> revokeAllOtherDevices({String? reason}) async {
    if (state.isRevoking) return false;

    state = state.copyWith(isRevoking: true);
    _clearMessages();

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Revoking all other devices');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      if (state.currentDevice?.uuid == null) {
        _setError('Dispositivo atual não identificado');
        return false;
      }

      final params = RevokeAllOtherDevicesParams(
        currentDeviceUuid: state.currentDevice!.uuid,
      );

      final result = await _revokeAllOtherDevicesUseCase(params);

      return result.fold(
        (failure) {
          _setError('Erro ao revogar outros dispositivos: ${failure.message}');
          return false;
        },
        (_) {
          _setSuccess('Outros dispositivos revogados com sucesso');
          _loadDevices(showLoading: false);

          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: All other devices revoked');
          }

          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao revogar outros dispositivos: $e');
      return false;
    } finally {
      state = state.copyWith(isRevoking: false);
    }
  }

  /// Refresh completo dos dados
  Future<void> refresh() async {
    await _loadDevices(showLoading: true, refresh: true);
  }

  /// Obtém dispositivo por UUID
  DeviceModel? getDeviceByUuid(String uuid) {
    try {
      return state.devices.firstWhere((device) => device.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se dispositivo está sendo revogado
  bool isDeviceBeingRevoked(String uuid) {
    return state.isRevoking && state.revokingDeviceUuid == uuid;
  }

  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    _clearMessages();
  }

  /// Carrega estatísticas de dispositivos
  Future<void> loadStatistics({bool refresh = false}) async {
    if (state.isLoading) return;

    try {
      _setLoading(true);
      _clearMessages();

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
            debugPrint(
              '❌ DeviceProvider: Failed to load statistics - ${failure.message}',
            );
          }
          _setError('Erro ao carregar estatísticas: ${failure.message}');
        },
        (statistics) {
          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: Statistics loaded successfully');
          }
          state = state.copyWith(statistics: statistics);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ DeviceProvider: Unexpected error loading statistics - $e',
        );
      }
      _setError('Erro inesperado ao carregar estatísticas');
    } finally {
      _setLoading(false);
    }
  }

  /// Resets estado do provider
  void _resetState() {
    if (kDebugMode) {
      debugPrint('🔄 DeviceProvider: Resetting state');
    }

    state = const DeviceManagementState();
  }

  void _setLoading(bool loading) {
    if (state.isLoading != loading) {
      state = state.copyWith(isLoading: loading);
    }
  }

  void _setError(String error) {
    state = state.copyWith(errorMessage: error, successMessage: null);
  }

  void _setSuccess(String success) {
    state = state.copyWith(successMessage: success, errorMessage: null);
  }

  void _clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  void _clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
