import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Service especializado para gerenciamento de conectividade do módulo de combustível
/// Aplica SRP (Single Responsibility Principle) - responsável apenas por conectividade
@lazySingleton
class FuelConnectivityService {
  FuelConnectivityService(this._connectivityService);

  final ConnectivityService _connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;

  /// Stream de mudanças de conectividade
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Estado atual de conectividade
  bool get isOnline => _isOnline;

  /// Verifica conectividade inicial e configura listener
  Future<bool> initialize() async {
    final result = await _connectivityService.isOnline();

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '🔌 Erro ao verificar conectividade inicial: ${failure.message}',
          );
        }
        _isOnline = true; // Assume online em caso de erro
      },
      (online) {
        _isOnline = online;
        if (kDebugMode) {
          debugPrint(
            '🔌 Conectividade inicial: ${online ? 'online' : 'offline'}',
          );
        }
      },
    );

    // Configura listener de mudanças
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _handleConnectivityChange,
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('🔌 Erro no stream de conectividade: $error');
        }
      },
    );

    return _isOnline;
  }

  /// Trata mudanças de conectividade
  void _handleConnectivityChange(bool online) {
    final wasOnline = _isOnline;
    _isOnline = online;

    if (kDebugMode) {
      debugPrint(
        '🔌 Conectividade mudou: ${wasOnline ? 'online' : 'offline'} → ${online ? 'online' : 'offline'}',
      );
    }

    // Notifica listeners
    _connectivityController.add(online);
  }

  /// Verifica conectividade manualmente (força refresh)
  Future<bool> checkConnectivity() async {
    final result = await _connectivityService.isOnline();

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('🔌 Erro ao verificar conectividade: ${failure.message}');
        }
        return _isOnline; // Mantém estado atual em caso de erro
      },
      (online) {
        if (_isOnline != online) {
          _handleConnectivityChange(online);
        }
        return online;
      },
    );
  }

  /// Retorna mudança de estado (de offline para online)
  bool hasGoneOnline(bool wasOnline) {
    return !wasOnline && _isOnline;
  }

  /// Retorna mudança de estado (de online para offline)
  bool hasGoneOffline(bool wasOnline) {
    return wasOnline && !_isOnline;
  }

  /// Aguarda até que conectividade seja restaurada
  Future<void> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_isOnline) return;

    try {
      await connectivityStream
          .firstWhere((online) => online)
          .timeout(timeout);

      if (kDebugMode) {
        debugPrint('🔌 Conexão restaurada!');
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('🔌 Timeout aguardando conexão');
      }
      rethrow;
    }
  }

  /// Executa ação quando conectividade for restaurada
  Future<T> executeWhenOnline<T>(
    Future<T> Function() action, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_isOnline) {
      await waitForConnection(timeout: timeout);
    }

    return await action();
  }

  /// Cancela assinaturas e limpa recursos
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();

    if (kDebugMode) {
      debugPrint('🔌 FuelConnectivityService disposed');
    }
  }

  /// Adiciona listener customizado de mudanças de conectividade
  StreamSubscription<bool> addConnectivityListener(
    void Function(bool isOnline) onConnectivityChanged, {
    void Function(Object error)? onError,
  }) {
    return connectivityStream.listen(
      onConnectivityChanged,
      onError: onError,
    );
  }

  /// Verifica se está offline
  bool get isOffline => !_isOnline;

  /// Obtém status de conectividade como Either
  Future<Either<Failure, bool>> getConnectivityStatus() async {
    return await _connectivityService.isOnline();
  }
}
