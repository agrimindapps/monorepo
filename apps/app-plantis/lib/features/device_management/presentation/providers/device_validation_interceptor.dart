import 'dart:async';

import 'package:core/core.dart'
    hide ValidateDeviceUseCase, DeviceValidationResult;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../domain/usecases/validate_device_usecase.dart';

/// Interceptor para validação automática de dispositivos
/// Monitora mudanças de autenticação e valida dispositivos automaticamente
class DeviceValidationInterceptor {
  final ValidateDeviceUseCase _validateDeviceUseCase;
  final AuthStateNotifier _authStateNotifier;

  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<bool>? _authSubscription;

  bool _isValidating = false;
  bool _hasValidatedThisSession = false;

  DeviceValidationInterceptor({
    required ValidateDeviceUseCase validateDeviceUseCase,
    required AuthStateNotifier authStateNotifier,
  }) : _validateDeviceUseCase = validateDeviceUseCase,
       _authStateNotifier = authStateNotifier {
    _startListening();
  }

  /// Inicia monitoramento de mudanças de autenticação
  void _startListening() {
    if (kDebugMode) {
      debugPrint('🔐 DeviceInterceptor: Starting authentication monitoring');
    }
    _userSubscription = _authStateNotifier.userStream.listen(_onUserChanged);
    _authSubscription = _authStateNotifier.authStream.listen(_onAuthChanged);
  }

  /// Callback para mudanças de usuário
  void _onUserChanged(UserEntity? user) {
    if (kDebugMode) {
      debugPrint('🔐 DeviceInterceptor: User changed - ${user?.id}');
    }

    if (user == null) {
      _hasValidatedThisSession = false;
      if (kDebugMode) {
        debugPrint('🔐 DeviceInterceptor: User logged out, resetting session');
      }
    }
  }

  /// Callback para mudanças de estado de autenticação
  void _onAuthChanged(bool isAuthenticated) {
    if (kDebugMode) {
      debugPrint('🔐 DeviceInterceptor: Auth state changed - $isAuthenticated');
    }

    if (isAuthenticated && !_hasValidatedThisSession) {
      _validateDeviceOnLogin();
    }
  }

  /// Valida dispositivo automaticamente após login
  Future<void> _validateDeviceOnLogin() async {
    if (_isValidating) {
      if (kDebugMode) {
        debugPrint('🔐 DeviceInterceptor: Already validating, skipping');
      }
      return;
    }

    _isValidating = true;

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceInterceptor: Auto-validating device after login');
      }

      final result = await _validateDeviceUseCase();

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ DeviceInterceptor: Auto-validation failed - ${failure.message}',
            );
          }
          if (failure.code == 'DEVICE_LIMIT_EXCEEDED') {
            _notifyDeviceLimitExceeded();
          }
        },
        (DeviceValidationResult validationResult) {
          if (validationResult.isValid) {
            if (kDebugMode) {
              debugPrint(
                '✅ DeviceInterceptor: Device auto-validated successfully',
              );
            }
            _hasValidatedThisSession = true;
          } else {
            if (kDebugMode) {
              debugPrint(
                '⚠️ DeviceInterceptor: Device validation failed - ${validationResult.message}',
              );
            }
            switch (validationResult.status) {
              case DeviceValidationStatus.exceeded:
                _notifyDeviceLimitExceeded();
                break;
              case DeviceValidationStatus.invalid:
                _notifyDeviceInvalid();
                break;
              default:
                break;
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ DeviceInterceptor: Unexpected error during auto-validation - $e',
        );
      }
    } finally {
      _isValidating = false;
    }
  }

  /// Notifica que o limite de dispositivos foi excedido
  void _notifyDeviceLimitExceeded() {
    if (kDebugMode) {
      debugPrint(
        '⚠️ DeviceInterceptor: Device limit exceeded - user action required',
      );
    }
  }

  /// Notifica que o dispositivo é inválido
  void _notifyDeviceInvalid() {
    if (kDebugMode) {
      debugPrint('⚠️ DeviceInterceptor: Device invalid - security concern');
    }
  }

  /// Força validação manual
  Future<DeviceValidationResult?> forceValidation() async {
    if (_isValidating) {
      if (kDebugMode) {
        debugPrint('🔐 DeviceInterceptor: Validation already in progress');
      }
      return null;
    }

    if (!_authStateNotifier.isAuthenticated) {
      if (kDebugMode) {
        debugPrint(
          '🔐 DeviceInterceptor: Cannot validate - user not authenticated',
        );
      }
      return null;
    }

    _isValidating = true;

    try {
      if (kDebugMode) {
        debugPrint('🔐 DeviceInterceptor: Force validating device');
      }

      final result = await _validateDeviceUseCase();

      return result.fold(
        (Failure failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ DeviceInterceptor: Force validation failed - ${failure.message}',
            );
          }
          return null;
        },
        (DeviceValidationResult validationResult) {
          if (validationResult.isValid) {
            _hasValidatedThisSession = true;
            if (kDebugMode) {
              debugPrint('✅ DeviceInterceptor: Force validation successful');
            }
          }
          return validationResult;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ DeviceInterceptor: Unexpected error during force validation - $e',
        );
      }
      return null;
    } finally {
      _isValidating = false;
    }
  }

  /// Getters para estado atual
  bool get isValidating => _isValidating;
  bool get hasValidatedThisSession => _hasValidatedThisSession;

  /// Para de escutar mudanças e limpa recursos
  void dispose() {
    if (kDebugMode) {
      debugPrint('♻️ DeviceInterceptor: Disposing');
    }

    _userSubscription?.cancel();
    _authSubscription?.cancel();

    _userSubscription = null;
    _authSubscription = null;
  }
}
