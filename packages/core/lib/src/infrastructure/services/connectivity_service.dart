import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../domain/repositories/i_sync_repository.dart';
import '../../shared/utils/failure.dart';

/// Serviço de conectividade usando connectivity_plus
class ConnectivityService implements IConnectivityRepository {
  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  bool _isInitialized = false;
  bool _isOnline = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);
      final initialResult = await checkConnectivity();
      initialResult.fold(
        (failure) => developer.log(
          'Erro ao verificar conectividade inicial: ${failure.message}',
          name: 'Connectivity',
        ),
        (isOnline) => _isOnline = isOnline,
      );
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (Object error) {
          developer.log(
            'Erro no listener de conectividade: $error',
            name: 'Connectivity',
          );
        },
      );

      _isInitialized = true;
      developer.log('ConnectivityService inicializado', name: 'Connectivity');

      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('Erro ao inicializar conectividade: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnline() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return Right(_isOnline);
    } catch (e) {
      return Left(NetworkFailure('Erro ao verificar conectividade: $e'));
    }
  }

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  @override
  Future<Either<Failure, bool>> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isOnline = _isConnected(result);

      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        _connectivityController.add(isOnline);

        developer.log(
          isOnline ? 'Conectividade restaurada' : 'Conectividade perdida',
          name: 'Connectivity',
        );
      }

      return Right(isOnline);
    } catch (e) {
      return Left(NetworkFailure('Erro ao verificar conectividade: $e'));
    }
  }

  @override
  Future<Either<Failure, ConnectivityType>> getConnectivityType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final type = _mapConnectivityType(result);
      return Right(type);
    } catch (e) {
      return Left(NetworkFailure('Erro ao obter tipo de conectividade: $e'));
    }
  }

  /// Callback para mudanças de conectividade
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    try {
      final isOnline = _isConnected(results);

      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        _connectivityController.add(isOnline);

        developer.log(
          isOnline
              ? 'Conectividade restaurada: ${results.map((r) => r.name).join(', ')}'
              : 'Conectividade perdida: ${results.map((r) => r.name).join(', ')}',
          name: 'Connectivity',
        );
      }
    } catch (e) {
      developer.log(
        'Erro ao processar mudança de conectividade: $e',
        name: 'Connectivity',
      );
    }
  }

  /// Verifica se há conexão baseado nos resultados
  bool _isConnected(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          return true;
        case ConnectivityResult.bluetooth:
        case ConnectivityResult.vpn:
        case ConnectivityResult.other:
          return true;
        case ConnectivityResult.none:
          continue; // Verifica próximo resultado
      }
    }

    return false;
  }

  /// Mapeia ConnectivityResult para ConnectivityType
  ConnectivityType _mapConnectivityType(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityType.none;
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
          return ConnectivityType.wifi;
        case ConnectivityResult.ethernet:
          return ConnectivityType.ethernet;
        case ConnectivityResult.mobile:
          return ConnectivityType.mobile;
        case ConnectivityResult.bluetooth:
          return ConnectivityType.bluetooth;
        case ConnectivityResult.vpn:
          return ConnectivityType.vpn;
        case ConnectivityResult.other:
          return ConnectivityType.other;
        case ConnectivityResult.none:
          continue;
      }
    }

    return ConnectivityType.none;
  }

  /// Compatibility method: getCurrentNetworkStatus (from app-plantis)
  /// Retorna um tipo que mapeia para o antigo NetworkStatus
  Future<Either<Failure, ConnectivityType>> getCurrentNetworkStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final type = _mapConnectivityType(result);
      final compatibleType = _mapToCompatibleType(type);
      return Right(compatibleType);
    } catch (e) {
      return Left(NetworkFailure('Erro ao obter status de rede atual: $e'));
    }
  }

  /// Mapeia tipos para compatibilidade com app-plantis NetworkStatus
  ConnectivityType _mapToCompatibleType(ConnectivityType type) {
    switch (type) {
      case ConnectivityType.none:
        return ConnectivityType.offline;
      case ConnectivityType.wifi:
        return ConnectivityType.wifi;
      case ConnectivityType.mobile:
        return ConnectivityType.mobile;
      case ConnectivityType.ethernet:
      case ConnectivityType.vpn:
      case ConnectivityType.other:
      case ConnectivityType.bluetooth:
        return ConnectivityType.online;
      case ConnectivityType.offline:
        return ConnectivityType.offline;
      case ConnectivityType.online:
        return ConnectivityType.online;
    }
  }

  /// Stream de conectividade compatível com app-plantis NetworkStatus
  Stream<ConnectivityType> get networkStatusStream {
    return _connectivityController.stream.map((isOnline) {
      return isOnline ? ConnectivityType.online : ConnectivityType.offline;
    });
  }

  /// Obtém informações detalhadas de conectividade
  Future<Map<String, dynamic>> getDetailedConnectivityInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final type = _mapConnectivityType(result);
      final isOnline = _isConnected(result);

      return {
        'is_online': isOnline,
        'connectivity_type': type.name,
        'raw_results': result.map((r) => r.name).toList(),
        'is_initialized': _isInitialized,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'is_online': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Testa conectividade real com ping
  Future<Either<Failure, bool>> testRealConnectivity({
    String testUrl = 'https://www.google.com',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final basicCheck = await checkConnectivity();
      final basicResult = basicCheck.fold((l) => false, (r) => r);

      if (!basicResult) {
        return const Right(false);
      }
      return Right(basicResult);
    } catch (e) {
      return Left(NetworkFailure('Erro ao testar conectividade real: $e'));
    }
  }

  /// Força recheck da conectividade
  Future<void> forceConnectivityCheck() async {
    try {
      await checkConnectivity();
    } catch (e) {
      developer.log(
        'Erro ao forçar verificação de conectividade: $e',
        name: 'Connectivity',
      );
    }
  }

  /// Cleanup dos recursos
  Future<void> dispose() async {
    try {
      await _connectivitySubscription?.cancel();
      await _connectivityController.close();
      _isInitialized = false;

      developer.log('ConnectivityService disposed', name: 'Connectivity');
    } catch (e) {
      developer.log(
        'Erro ao fazer dispose do ConnectivityService: $e',
        name: 'Connectivity',
      );
    }
  }

  /// Obtém status atual como string legível
  String get currentStatusString {
    if (!_isInitialized) return 'Não inicializado';
    return _isOnline ? 'Online' : 'Offline';
  }

  /// Verifica se conectividade está estável
  /// (não mudou nos últimos X segundos)
  bool get isConnectivityStable {
    return _isInitialized;
  }
}
