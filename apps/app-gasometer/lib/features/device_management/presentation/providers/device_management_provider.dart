import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/device_info.dart';
import '../../domain/entities/device_session.dart';
import '../../domain/usecases/get_user_devices.dart';
import '../../domain/usecases/revoke_device.dart';
import '../../domain/usecases/validate_device_limit.dart';

/// Provider para gerenciamento de dispositivos usando Provider pattern
class DeviceManagementProvider extends ChangeNotifier {
  final GetUserDevicesUseCase _getUserDevicesUseCase;
  final RevokeDeviceUseCase _revokeDeviceUseCase;
  final ValidateDeviceLimitUseCase _validateDeviceLimitUseCase;

  DeviceManagementProvider({
    required GetUserDevicesUseCase getUserDevicesUseCase,
    required RevokeDeviceUseCase revokeDeviceUseCase,
    required ValidateDeviceLimitUseCase validateDeviceLimitUseCase,
  }) : _getUserDevicesUseCase = getUserDevicesUseCase,
       _revokeDeviceUseCase = revokeDeviceUseCase,
       _validateDeviceLimitUseCase = validateDeviceLimitUseCase;

  // Estado
  List<DeviceInfo> _devices = [];
  DeviceStatistics? _statistics;
  bool _isLoading = false;
  bool _isLoadingStatistics = false;
  String? _errorMessage;
  String? _currentUserId;
  DeviceInfo? _currentDevice;

  // Getters
  List<DeviceInfo> get devices => List.unmodifiable(_devices);
  DeviceStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isLoadingStatistics => _isLoadingStatistics;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  DeviceInfo? get currentDevice => _currentDevice;
  
  /// Dispositivos ativos
  List<DeviceInfo> get activeDevices => 
      _devices.where((device) => device.isActive).toList();
  
  /// Dispositivos inativos
  List<DeviceInfo> get inactiveDevices => 
      _devices.where((device) => !device.isActive).toList();
  
  /// Número de dispositivos ativos
  int get activeDeviceCount => activeDevices.length;
  
  /// Pode adicionar mais dispositivos
  bool get canAddMoreDevices => activeDeviceCount < 3;
  
  /// Tem dispositivos para mostrar
  bool get hasDevices => _devices.isNotEmpty;
  
  /// Estado de erro
  bool get hasError => _errorMessage != null;

  /// Define o usuário atual
  void setCurrentUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _clearState();
      notifyListeners();
    }
  }

  /// Define o dispositivo atual
  void setCurrentDevice(DeviceInfo device) {
    _currentDevice = device;
    notifyListeners();
  }

  /// Carrega dispositivos do usuário
  Future<void> loadUserDevices({bool forceRefresh = false}) async {
    if (_currentUserId == null) {
      _setError('ID do usuário não definido');
      return;
    }

    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _getUserDevicesUseCase(_currentUserId!);
      
      result.fold(
        (failure) => _setError(failure.message),
        (devices) {
          _devices = devices;
          if (kDebugMode) {
            debugPrint('✅ DeviceManagementProvider: Loaded ${devices.length} devices');
          }
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao carregar dispositivos: $e');
      if (kDebugMode) {
        debugPrint('❌ DeviceManagementProvider: Unexpected error - $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Valida limite de dispositivo
  Future<bool> validateDeviceLimit(DeviceInfo device) async {
    if (_currentUserId == null) {
      _setError('ID do usuário não definido');
      return false;
    }

    try {
      final result = await _validateDeviceLimitUseCase(
        userId: _currentUserId!,
        device: device,
      );
      
      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (canAdd) => canAdd,
      );
    } catch (e) {
      _setError('Erro inesperado na validação: $e');
      return false;
    }
  }

  /// Registra e valida um novo dispositivo
  Future<bool> registerDevice(DeviceInfo device) async {
    if (_currentUserId == null) {
      _setError('ID do usuário não definido');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _validateDeviceLimitUseCase.validateAndRegisterDevice(
        userId: _currentUserId!,
        device: device,
      );
      
      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (registeredDevice) {
          // Atualizar lista local
          final existingIndex = _devices.indexWhere(
            (d) => d.uuid == registeredDevice.uuid,
          );
          
          if (existingIndex >= 0) {
            _devices[existingIndex] = registeredDevice;
          } else {
            _devices.add(registeredDevice);
          }
          
          _setCurrentDevice(registeredDevice);
          
          if (kDebugMode) {
            debugPrint('✅ DeviceManagementProvider: Device registered successfully');
          }
          
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado no registro: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Revoga um dispositivo específico
  Future<bool> revokeDevice(String deviceUuid) async {
    if (_currentUserId == null) {
      _setError('ID do usuário não definido');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _revokeDeviceUseCase(
        userId: _currentUserId!,
        deviceUuid: deviceUuid,
      );
      
      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (_) {
          // Remover ou marcar como inativo na lista local
          _devices.removeWhere((device) => device.uuid == deviceUuid);
          
          if (kDebugMode) {
            debugPrint('✅ DeviceManagementProvider: Device revoked successfully');
          }
          
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado na revogação: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Revoga todos os outros dispositivos
  Future<bool> revokeAllOtherDevices() async {
    if (_currentUserId == null || _currentDevice == null) {
      _setError('Usuário ou dispositivo atual não definidos');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _revokeDeviceUseCase.revokeAllOthers(
        userId: _currentUserId!,
        currentDeviceUuid: _currentDevice!.uuid,
      );
      
      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (_) {
          // Manter apenas o dispositivo atual
          _devices.removeWhere(
            (device) => device.uuid != _currentDevice!.uuid,
          );
          
          if (kDebugMode) {
            debugPrint('✅ DeviceManagementProvider: All other devices revoked');
          }
          
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado na revogação em massa: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh completo dos dados
  Future<void> refresh() async {
    await loadUserDevices(forceRefresh: true);
  }

  /// Limpa o erro atual
  void clearError() {
    _clearError();
  }

  /// Obtém dispositivo por UUID
  DeviceInfo? getDeviceByUuid(String uuid) {
    try {
      return _devices.firstWhere((device) => device.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se é o dispositivo atual
  bool isCurrentDevice(String uuid) {
    return _currentDevice?.uuid == uuid;
  }

  /// Obtém status de um dispositivo
  String getDeviceStatus(DeviceInfo device) {
    if (!device.isActive) return 'Inativo';
    if (isCurrentDevice(device.uuid)) return 'Atual';
    return device.activityStatus;
  }

  // Métodos privados para gerenciamento de estado

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setCurrentDevice(DeviceInfo device) {
    if (_currentDevice?.uuid != device.uuid) {
      _currentDevice = device;
      notifyListeners();
    }
  }

  void _clearState() {
    _devices.clear();
    _statistics = null;
    _errorMessage = null;
    _currentDevice = null;
    _isLoading = false;
    _isLoadingStatistics = false;
  }

  @override
  void dispose() {
    _clearState();
    super.dispose();
  }
}
