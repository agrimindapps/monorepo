import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import 'sync_error_handler.dart';

/// Service responsible for sync recovery strategies following SOLID principles
/// 
/// Follows SRP: Single responsibility of handling recovery strategies
/// Follows DIP: Depends on abstractions (AuthRepository)
class SyncRecoveryService {
  final AuthRepository _authRepository;

  // Recovery timers
  Timer? _networkRecoveryTimer;
  Timer? _serverRecoveryTimer;
  Timer? _timeoutRecoveryTimer;

  // Recovery callbacks
  VoidCallback? _onNetworkRecovery;
  VoidCallback? _onServerRecovery;
  VoidCallback? _onTimeoutRecovery;
  VoidCallback? _onAuthRequired;

  SyncRecoveryService(this._authRepository);

  /// Sets recovery callbacks
  void setRecoveryCallbacks({
    VoidCallback? onNetworkRecovery,
    VoidCallback? onServerRecovery,
    VoidCallback? onTimeoutRecovery,
    VoidCallback? onAuthRequired,
  }) {
    _onNetworkRecovery = onNetworkRecovery;
    _onServerRecovery = onServerRecovery;
    _onTimeoutRecovery = onTimeoutRecovery;
    _onAuthRequired = onAuthRequired;
  }

  /// Applies recovery strategy based on error type
  void applyRecoveryStrategy(SyncException error) {
    switch (error.type) {
      case SyncErrorType.network:
        _scheduleNetworkRecovery();
        break;
      case SyncErrorType.authentication:
        _handleAuthenticationError();
        break;
      case SyncErrorType.timeout:
        _scheduleTimeoutRecovery();
        break;
      case SyncErrorType.server:
        _scheduleServerErrorRecovery();
        break;
      case SyncErrorType.validation:
        _handleValidationError(error);
        break;
      case SyncErrorType.conflict:
        _handleConflictError(error);
        break;
      case SyncErrorType.unknown:
        _handleUnknownError(error);
        break;
    }
  }

  /// Schedules network recovery attempt
  void _scheduleNetworkRecovery() {
    debugPrint('🌐 Agendando recuperação de rede em 30 segundos...');
    
    _networkRecoveryTimer?.cancel();
    _networkRecoveryTimer = Timer(const Duration(seconds: 30), () {
      debugPrint('🔄 Tentando recuperação de rede...');
      _onNetworkRecovery?.call();
    });
  }

  /// Schedules timeout recovery attempt
  void _scheduleTimeoutRecovery() {
    debugPrint('⏰ Agendando recuperação de timeout em 60 segundos...');
    
    _timeoutRecoveryTimer?.cancel();
    _timeoutRecoveryTimer = Timer(const Duration(seconds: 60), () {
      debugPrint('🔄 Tentando recuperação de timeout...');
      _onTimeoutRecovery?.call();
    });
  }

  /// Schedules server error recovery attempt
  void _scheduleServerErrorRecovery() {
    debugPrint('🔥 Agendando recuperação de erro do servidor em 2 minutos...');
    
    _serverRecoveryTimer?.cancel();
    _serverRecoveryTimer = Timer(const Duration(minutes: 2), () {
      debugPrint('🔄 Tentando recuperação de erro do servidor...');
      _onServerRecovery?.call();
    });
  }

  /// Handles authentication errors
  void _handleAuthenticationError() {
    debugPrint('🔐 Erro de autenticação detectado - solicitando nova autenticação');
    _onAuthRequired?.call();
  }

  /// Handles validation errors
  void _handleValidationError(SyncException error) {
    debugPrint('📋 Erro de validação: ${error.message}');
    debugPrint('📋 Detalhes: ${error.details}');
    // Validation errors typically require user intervention
    // Log for debugging but don't auto-retry
  }

  /// Handles conflict errors
  void _handleConflictError(SyncException error) {
    debugPrint('⚔️ Conflito de dados detectado: ${error.message}');
    debugPrint('⚔️ Detalhes: ${error.details}');
    // Conflict errors require manual resolution
    // This should trigger conflict resolution UI
  }

  /// Handles unknown errors
  void _handleUnknownError(SyncException error) {
    debugPrint('❓ Erro desconhecido: ${error.message}');
    debugPrint('❓ Erro original: ${error.originalError}');
    // Unknown errors are logged but no automatic recovery is attempted
  }

  /// Cancels all pending recovery timers
  void cancelAllRecoveries() {
    _networkRecoveryTimer?.cancel();
    _serverRecoveryTimer?.cancel();
    _timeoutRecoveryTimer?.cancel();
    
    _networkRecoveryTimer = null;
    _serverRecoveryTimer = null;
    _timeoutRecoveryTimer = null;
  }

  /// Disposes all resources
  void dispose() {
    cancelAllRecoveries();
  }
}