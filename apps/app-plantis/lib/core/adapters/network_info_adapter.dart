import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../interfaces/network_info.dart';

/// Adapter que implementa a interface NetworkInfo existente usando ConnectivityService
/// do core package, mantendo 100% backward compatibility enquanto disponibiliza
/// recursos avançados progressivamente.
///
/// DESIGN PATTERN: Adapter Pattern
///
/// BACKWARD COMPATIBILITY:
/// - ✅ Mantém Future\<bool\> get isConnected (interface original)
/// - ✅ Zero breaking changes para repositories existentes
/// - ✅ Fallback silencioso em caso de erro
///
/// ENHANCED FEATURES (Opt-in):
/// - 🚀 Stream\<bool\> get connectivityStream (real-time monitoring)
/// - 🚀 Future\<ConnectivityType?\> get connectionType (WiFi/Mobile/Ethernet)
/// - 🚀 Future\<Map\<String, dynamic\>?\> get detailedStatus (debugging)
/// - 🚀 Future\<bool\> get isStable (connection stability check)
class NetworkInfoAdapter implements NetworkInfo {
  final ConnectivityService _connectivityService;
  late final StreamController<bool> _fallbackController;
  bool _isInitialized = false;
  bool _lastKnownConnectionState = false;

  NetworkInfoAdapter(this._connectivityService) {
    _fallbackController = StreamController<bool>.broadcast();
    _initializeAsync();
  }

  /// Initialization em background para não bloquear a criação do adapter
  Future<void> _initializeAsync() async {
    try {
      await _connectivityService.initialize();
      _isInitialized = true;

      // Sincroniza estado inicial
      final initialState = await _connectivityService.isOnline();
      initialState.fold(
        (failure) {
          developer.log('NetworkInfoAdapter: Failed to get initial state: ${failure.message}', name: 'NetworkAdapter');
          _lastKnownConnectionState = false;
        },
        (isOnline) {
          _lastKnownConnectionState = isOnline;
          _fallbackController.add(isOnline);
        },
      );

      developer.log('NetworkInfoAdapter initialized successfully', name: 'NetworkAdapter');
    } catch (e) {
      developer.log('NetworkInfoAdapter: Initialization error: $e', name: 'NetworkAdapter');
      // Graceful degradation - continua funcionando com fallback
      _isInitialized = false;
    }
  }

  /// [INTERFACE ORIGINAL - PRESERVADA]
  /// Implementa a interface NetworkInfo existente com 100% backward compatibility.
  /// Mantém a mesma assinatura e comportamento esperado pelos repositories.
  @override
  Future<bool> get isConnected async {
    try {
      if (_isInitialized) {
        final result = await _connectivityService.isOnline();
        return result.fold(
          (failure) {
            developer.log('NetworkInfoAdapter: ConnectivityService failed, using fallback: ${failure.message}', name: 'NetworkAdapter');
            return _fallbackConnectionCheck();
          },
          (isOnline) {
            _lastKnownConnectionState = isOnline;
            return isOnline;
          },
        );
      } else {
        // Fallback silencioso durante inicialização
        return _fallbackConnectionCheck();
      }
    } catch (e) {
      developer.log('NetworkInfoAdapter: Unexpected error in isConnected: $e', name: 'NetworkAdapter');
      return _fallbackConnectionCheck();
    }
  }

  /// [ENHANCED FEATURE - OPT-IN]
  /// Stream de conectividade em tempo real para repositories que desejam
  /// monitoramento contínuo de mudanças de conectividade.
  ///
  /// Uso: `if (networkInfo is NetworkInfoAdapter) networkInfo.connectivityStream.listen(...)`
  Stream<bool> get connectivityStream {
    if (_isInitialized) {
      try {
        return _connectivityService.connectivityStream;
      } catch (e) {
        developer.log('NetworkInfoAdapter: Error accessing connectivityStream: $e', name: 'NetworkAdapter');
        return _fallbackController.stream;
      }
    } else {
      return _fallbackController.stream;
    }
  }

  /// [ENHANCED FEATURE - OPT-IN]
  /// Obtém o tipo específico de conexão (WiFi, Mobile, Ethernet) para
  /// otimizações baseadas no tipo de rede.
  ///
  /// Returns:
  /// - ConnectivityType.wifi para conexões WiFi
  /// - ConnectivityType.mobile para dados móveis
  /// - ConnectivityType.ethernet para conexões cabeadas
  /// - ConnectivityType.none quando offline
  /// - null em caso de erro
  Future<ConnectivityType?> get connectionType async {
    try {
      if (_isInitialized) {
        final result = await _connectivityService.getConnectivityType();
        return result.fold(
          (failure) {
            developer.log('NetworkInfoAdapter: Failed to get connection type: ${failure.message}', name: 'NetworkAdapter');
            return null;
          },
          (type) => type,
        );
      }
      return null;
    } catch (e) {
      developer.log('NetworkInfoAdapter: Error getting connection type: $e', name: 'NetworkAdapter');
      return null;
    }
  }

  /// [ENHANCED FEATURE - OPT-IN]
  /// Informações detalhadas de conectividade para debugging e monitoramento.
  ///
  /// Returns Map com:
  /// - is_online: bool
  /// - connectivity_type: String
  /// - raw_results: List\<String\>
  /// - is_initialized: bool
  /// - timestamp: String
  Future<Map<String, dynamic>?> get detailedStatus async {
    try {
      if (_isInitialized) {
        return await _connectivityService.getDetailedConnectivityInfo();
      } else {
        return {
          'is_online': _lastKnownConnectionState,
          'connectivity_type': 'unknown',
          'is_initialized': false,
          'adapter_status': 'initializing',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      developer.log('NetworkInfoAdapter: Error getting detailed status: $e', name: 'NetworkAdapter');
      return {
        'error': e.toString(),
        'is_online': _lastKnownConnectionState,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// [ENHANCED FEATURE - OPT-IN]
  /// Verifica se a conectividade está estável (sem oscilações recentes).
  /// Útil para decidir quando fazer sync ou operações que requerem conexão estável.
  Future<bool> get isStable async {
    try {
      if (_isInitialized) {
        return _connectivityService.isConnectivityStable;
      }
      // Durante inicialização, considera estável se temos conexão conhecida
      return _lastKnownConnectionState;
    } catch (e) {
      developer.log('NetworkInfoAdapter: Error checking stability: $e', name: 'NetworkAdapter');
      return _lastKnownConnectionState;
    }
  }

  /// [ENHANCED FEATURE - OPT-IN]
  /// Força uma nova verificação de conectividade, útil após mudanças de rede
  /// ou quando precisamos de uma verificação atualizada.
  Future<void> forceConnectivityCheck() async {
    try {
      if (_isInitialized) {
        await _connectivityService.forceConnectivityCheck();
      }
    } catch (e) {
      developer.log('NetworkInfoAdapter: Error forcing connectivity check: $e', name: 'NetworkAdapter');
    }
  }

  /// [ENHANCED FEATURE - OPT-IN]
  /// Testa conectividade real fazendo uma requisição HTTP, não apenas
  /// verificando o status da interface de rede.
  Future<bool> testRealConnectivity({
    String testUrl = 'https://www.google.com',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      if (_isInitialized) {
        final result = await _connectivityService.testRealConnectivity(
          testUrl: testUrl,
          timeout: timeout,
        );
        return result.fold(
          (failure) {
            developer.log('NetworkInfoAdapter: Real connectivity test failed: ${failure.message}', name: 'NetworkAdapter');
            return false;
          },
          (isConnected) => isConnected,
        );
      }
      return _lastKnownConnectionState;
    } catch (e) {
      developer.log('NetworkInfoAdapter: Error testing real connectivity: $e', name: 'NetworkAdapter');
      return false;
    }
  }

  /// Fallback básico usando connectivity_plus diretamente quando ConnectivityService falha
  Future<bool> _fallbackConnectionCheck() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      final isConnected = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);

      _lastKnownConnectionState = isConnected;
      _fallbackController.add(isConnected);

      return isConnected;
    } catch (e) {
      developer.log('NetworkInfoAdapter: Fallback connection check failed: $e', name: 'NetworkAdapter');
      // Último recurso: retorna o último estado conhecido
      return _lastKnownConnectionState;
    }
  }

  /// Status atual como string legível para debugging
  String get currentStatusString {
    if (!_isInitialized) return 'Inicializando...';
    return _lastKnownConnectionState ? 'Online' : 'Offline';
  }

  /// Cleanup de recursos
  Future<void> dispose() async {
    try {
      await _fallbackController.close();
      if (_isInitialized) {
        await _connectivityService.dispose();
      }
    } catch (e) {
      developer.log('NetworkInfoAdapter: Error during dispose: $e', name: 'NetworkAdapter');
    }
  }

  /// Type check helper para repositories que querem usar features avançadas
  static bool isEnhanced(NetworkInfo networkInfo) {
    return networkInfo is NetworkInfoAdapter;
  }

  /// Cast helper para repositories que querem usar features avançadas
  static NetworkInfoAdapter? asEnhanced(NetworkInfo networkInfo) {
    return networkInfo is NetworkInfoAdapter ? networkInfo : null;
  }
}

/// Extension methods para facilitar o uso das features avançadas pelos repositories
extension NetworkInfoEnhanced on NetworkInfo {
  /// Verifica se é o adapter avançado
  bool get isEnhanced => this is NetworkInfoAdapter;

  /// Cast seguro para o adapter avançado
  NetworkInfoAdapter? get asEnhanced => this is NetworkInfoAdapter ? this as NetworkInfoAdapter : null;

  /// Stream de conectividade (se disponível)
  Stream<bool>? get connectivityStreamIfAvailable => asEnhanced?.connectivityStream;

  /// Tipo de conexão (se disponível)
  Future<ConnectivityType?> get connectionTypeIfAvailable async => await asEnhanced?.connectionType;

  /// Status detalhado (se disponível)
  Future<Map<String, dynamic>?> get detailedStatusIfAvailable async => await asEnhanced?.detailedStatus;
}