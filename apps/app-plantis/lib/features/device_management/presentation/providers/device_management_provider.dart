import 'dart:async';

import 'package:core/core.dart' hide GetUserDevicesUseCase, ValidateDeviceUseCase, RevokeDeviceUseCase, RevokeAllOtherDevicesUseCase, DeviceValidationResult, ValidateDeviceParams, GetUserDevicesParams, RevokeDeviceParams, RevokeAllOtherDevicesParams;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../data/models/device_model.dart';
import '../../domain/usecases/get_device_statistics_usecase.dart';
import '../../domain/usecases/get_user_devices_usecase.dart';
import '../../domain/usecases/revoke_device_usecase.dart';
import '../../domain/usecases/validate_device_usecase.dart';

/// Provider para gerenciar estado de dispositivos no app-plantis
/// Segue padrão Provider usado no app com estado reativo
class DeviceManagementProvider extends ChangeNotifier {
  final GetUserDevicesUseCase _getUserDevicesUseCase;
  final ValidateDeviceUseCase _validateDeviceUseCase;
  final RevokeDeviceUseCase _revokeDeviceUseCase;
  final RevokeAllOtherDevicesUseCase _revokeAllOtherDevicesUseCase;
  final GetDeviceStatisticsUseCase _getDeviceStatisticsUseCase;
  final AuthStateNotifier _authStateNotifier;

  // Estado principal
  List<DeviceModel> _devices = [];
  DeviceModel? _currentDevice;
  DeviceStatisticsModel? _statistics;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _successMessage;

  // Estados específicos de operações
  bool _isValidating = false;
  bool _isRevoking = false;
  String? _revokingDeviceUuid;

  // Stream subscriptions
  StreamSubscription<UserEntity?>? _userSubscription;

  DeviceManagementProvider({
    required GetUserDevicesUseCase getUserDevicesUseCase,
    required ValidateDeviceUseCase validateDeviceUseCase,
    required RevokeDeviceUseCase revokeDeviceUseCase,
    required RevokeAllOtherDevicesUseCase revokeAllOtherDevicesUseCase,
    required GetDeviceStatisticsUseCase getDeviceStatisticsUseCase,
    required AuthStateNotifier authStateNotifier,
  })  : _getUserDevicesUseCase = getUserDevicesUseCase,
        _validateDeviceUseCase = validateDeviceUseCase,
        _revokeDeviceUseCase = revokeDeviceUseCase,
        _revokeAllOtherDevicesUseCase = revokeAllOtherDevicesUseCase,
        _getDeviceStatisticsUseCase = getDeviceStatisticsUseCase,
        _authStateNotifier = authStateNotifier {
    _initializeProvider();
  }

  // Getters principais
  List<DeviceModel> get devices => List.unmodifiable(_devices);
  DeviceModel? get currentDevice => _currentDevice;
  DeviceStatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Getters de estados específicos
  bool get isValidating => _isValidating;
  bool get isRevoking => _isRevoking;
  String? get revokingDeviceUuid => _revokingDeviceUuid;

  // Getters derivados
  List<DeviceModel> get activeDevices => _devices.where((d) => d.isActive).toList();
  List<DeviceModel> get inactiveDevices => _devices.where((d) => !d.isActive).toList();
  int get activeDeviceCount => activeDevices.length;
  int get totalDeviceCount => _devices.length;
  bool get hasDevices => _devices.isNotEmpty;
  bool get canAddMoreDevices => activeDeviceCount < 3; // Limite padrão

  // Getters específicos do plantis
  bool get isCurrentDeviceIdentified => _currentDevice != null;
  String get deviceSummary {
    if (!hasDevices) return 'Nenhum dispositivo registrado';
    if (activeDeviceCount == 1) return '1 dispositivo ativo';
    return '$activeDeviceCount dispositivos ativos';
  }

  /// Inicializa o provider
  void _initializeProvider() {
    if (kDebugMode) {
      debugPrint('🔐 DeviceProvider: Initializing');
    }

    // Escuta mudanças de usuário
    _userSubscription = _authStateNotifier.userStream.listen(_onUserChanged);

    // Inicializa se já tem usuário
    if (_authStateNotifier.isAuthenticated) {
      _initializeDeviceManagement();
    }
  }

  /// Callback para mudanças de usuário
  void _onUserChanged(UserEntity? user) {
    if (user == null) {
      // Usuário deslogou
      _resetState();
    } else {
      // Usuário logou
      _initializeDeviceManagement();
    }
  }

  /// Inicializa gerenciamento de dispositivos
  Future<void> _initializeDeviceManagement() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearMessages();

    try {
      // Identifica dispositivo atual
      await _identifyCurrentDevice();

      // Carrega dispositivos
      await _loadDevices(showLoading: false);

      _isInitialized = true;

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

      _currentDevice = await DeviceModel.fromCurrentDevice();

      if (kDebugMode) {
        debugPrint('📱 DeviceProvider: Current device identified: ${_currentDevice!.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceProvider: Error identifying current device: $e');
      }
      // Não é crítico, continua sem identificar
    }
  }

  /// Carrega lista de dispositivos
  Future<void> loadDevices({bool refresh = false}) async {
    await _loadDevices(showLoading: true, refresh: refresh);
  }

  Future<void> _loadDevices({bool showLoading = true, bool refresh = false}) async {
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

      const params = GetUserDevicesParams(
        activeOnly: false,
      );

      final result = await _getUserDevicesUseCase(params);

      result.fold(
        (failure) {
          _setError('Erro ao carregar dispositivos: ${failure.message}');
        },
        (devices) {
          // Converte DeviceEntity para DeviceModel
          _devices = devices.map((entity) => DeviceModel.fromEntity(entity)).toList();
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
    if (_isValidating) return null;

    _isValidating = true;
    _clearMessages();
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Validating current device');
      }

      if (_currentDevice == null) {
        _setError('Nenhum dispositivo atual identificado');
        return null;
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _setError('Usuário não autenticado');
        return null;
      }

      final params = ValidateDeviceParams(
        device: _currentDevice,
      );

      final result = await _validateDeviceUseCase(params);

      return result.fold(
        (failure) {
          _setError('Erro ao validar dispositivo: ${failure.message}');
          return null;
        },
        (validationResult) {
          if (validationResult.isValid) {
            _setSuccess('Dispositivo validado com sucesso');

            // Recarrega lista de dispositivos
            _loadDevices(showLoading: false);
          } else {
            _setError(validationResult.message ?? 'Falha na validação do dispositivo');
          }

          return validationResult;
        },
      );
    } catch (e) {
      _setError('Erro inesperado na validação: $e');
      return null;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Revoga um dispositivo específico
  Future<bool> revokeDevice(String deviceUuid, {String? reason}) async {
    if (_isRevoking) return false;

    // Impede revogar o dispositivo atual por padrão
    if (_currentDevice?.uuid == deviceUuid) {
      _setError('Não é possível revogar o dispositivo atual');
      return false;
    }

    _isRevoking = true;
    _revokingDeviceUuid = deviceUuid;
    _clearMessages();
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Revoking device $deviceUuid');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      final params = RevokeDeviceParams(
        deviceUuid: deviceUuid,
      );

      final result = await _revokeDeviceUseCase(params);

      return result.fold(
        (failure) {
          _setError('Erro ao revogar dispositivo: ${failure.message}');
          return false;
        },
        (_) {
          _setSuccess('Dispositivo revogado com sucesso');

          // Remove da lista local
          _devices.removeWhere((d) => d.uuid == deviceUuid);

          // Recarrega dados para sincronizar
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
      _isRevoking = false;
      _revokingDeviceUuid = null;
      notifyListeners();
    }
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<bool> revokeAllOtherDevices({String? reason}) async {
    if (_isRevoking) return false;

    _isRevoking = true;
    _clearMessages();
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceProvider: Revoking all other devices');
      }

      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      if (_currentDevice?.uuid == null) {
        _setError('Dispositivo atual não identificado');
        return false;
      }

      final params = RevokeAllOtherDevicesParams(
        currentDeviceUuid: _currentDevice!.uuid,
      );

      final result = await _revokeAllOtherDevicesUseCase(params);

      return result.fold(
        (failure) {
          _setError('Erro ao revogar outros dispositivos: ${failure.message}');
          return false;
        },
        (_) {
          _setSuccess('Outros dispositivos revogados com sucesso');

          // Recarrega dados para sincronizar
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
      _isRevoking = false;
      notifyListeners();
    }
  }

  /// Refresh completo dos dados
  Future<void> refresh() async {
    await _loadDevices(showLoading: true, refresh: true);
  }

  /// Obtém dispositivo por UUID
  DeviceModel? getDeviceByUuid(String uuid) {
    try {
      return _devices.firstWhere((device) => device.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se dispositivo está sendo revogado
  bool isDeviceBeingRevoked(String uuid) {
    return _isRevoking && _revokingDeviceUuid == uuid;
  }


  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    _clearMessages();
  }

  /// Carrega estatísticas de dispositivos
  Future<void> loadStatistics({bool refresh = false}) async {
    if (_isLoading) return;

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
            debugPrint('❌ DeviceProvider: Failed to load statistics - ${failure.message}');
          }
          _setError('Erro ao carregar estatísticas: ${failure.message}');
        },
        (statistics) {
          if (kDebugMode) {
            debugPrint('✅ DeviceProvider: Statistics loaded successfully');
          }
          _statistics = statistics;
          notifyListeners();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceProvider: Unexpected error loading statistics - $e');
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

    _devices = [];
    _currentDevice = null;
    _statistics = null;
    _isLoading = false;
    _isInitialized = false;
    _isValidating = false;
    _isRevoking = false;
    _revokingDeviceUuid = null;
    _clearMessages();
    notifyListeners();
  }

  // Métodos privados de gerenciamento de estado

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String success) {
    _successMessage = success;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _clearMessages() {
    bool shouldNotify = _errorMessage != null || _successMessage != null;
    _errorMessage = null;
    _successMessage = null;
    if (shouldNotify) notifyListeners();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('♻️ DeviceProvider: Disposing');
    }

    _userSubscription?.cancel();
    super.dispose();
  }
}

/// Extensions para helpers de texto e formatação
extension DeviceManagementProviderExtensions on DeviceManagementProvider {
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