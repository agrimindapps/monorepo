// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../controllers/auth_controller.dart';
import '../../infrastructure/degraded_mode_service.dart';
import 'interfaces.dart';

/// Inicializador responsável pelo sistema de autenticação
///
/// Gerencia:
/// - Login anônimo automático em dispositivos móveis
/// - Fallback para modo offline quando auth falha
/// - Retry inteligente para operações de autenticação
class AuthenticationInitializer
    implements IFallbackService, IRecoverableService {
  final DegradedModeService _degradedModeService;

  final List<String> _initializedServices = [];
  bool _isInitialized = false;
  int _recoveryAttempts = 0;
  PlantasAuthController? _authController;

  AuthenticationInitializer({
    required DegradedModeService degradedModeService,
  }) : _degradedModeService = degradedModeService;

  @override
  String get name => 'AuthenticationInitializer';

  @override
  List<String> get dependencies => [
        'PlantasAuthController', // Ou OfflineMode
      ];

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<String> get managedServices => [
        'Authentication',
        'OfflineAuthentication',
      ];

  @override
  bool get isUsingFallback =>
      _initializedServices.contains('OfflineAuthentication');

  @override
  List<String> get fallbackLimitations {
    if (_initializedServices.contains('OfflineAuthentication')) {
      return ['Login e sincronização indisponíveis'];
    }
    return [];
  }

  @override
  bool get canRecover => _recoveryAttempts < 3; // Menos tentativas para auth

  @override
  int get recoveryAttempts => _recoveryAttempts;

  @override
  void resetRecoveryAttempts() {
    _recoveryAttempts = 0;
  }

  @override
  bool canInitialize(List<String> availableServices) {
    // Só pode inicializar se o auth controller estiver disponível
    return availableServices.contains('PlantasAuthController');
  }

  @override
  Future<InitializationResult> initialize() async {
    return await initializeWithFallback();
  }

  @override
  Future<InitializationResult> initializeWithFallback() async {
    debugPrint('🔄 [$name] Iniciando inicialização de autenticação...');

    _initializedServices.clear();
    final failures = <ServiceFailure>[];

    // Apenas dispositivos móveis fazem login automático
    if (!GetPlatform.isMobile) {
      debugPrint(
          '⚠️ [$name] Plataforma não-móvel - pulando autenticação automática');
      _isInitialized = true;
      return InitializationResult.success(services: []);
    }

    // Verificar se auth controller está disponível
    if (!_degradedModeService.isServiceAvailable(ServiceType.auth)) {
      debugPrint(
          '⚠️ [$name] AuthController indisponível - usando modo offline');
      _initializedServices.add('OfflineAuthentication');
      _isInitialized = true;

      return InitializationResult.success(
          services: List.from(_initializedServices));
    }

    // Obter referência do auth controller
    try {
      _authController = Get.find<PlantasAuthController>();
    } catch (e) {
      debugPrint('❌ [$name] Não foi possível obter AuthController: $e');
      _initializedServices.add('OfflineAuthentication');
      _isInitialized = true;

      return InitializationResult.success(
          services: List.from(_initializedServices));
    }

    // Tentar autenticação com retry
    final authResult = await _performAuthenticationWithRetry();
    if (authResult.failure != null) {
      failures.add(authResult.failure!);
    }

    _isInitialized = true;

    final success = _initializedServices.isNotEmpty;
    debugPrint(success
        ? '✅ [$name] Inicialização concluída (${_initializedServices.length} serviços)'
        : '❌ [$name] Falha na inicialização');

    return success
        ? InitializationResult.success(
            services: List.from(_initializedServices))
        : InitializationResult.failure(
            error: 'Falha na inicialização de autenticação',
            services: List.from(_initializedServices),
            failures: failures,
          );
  }

  Future<_ServiceResult> _performAuthenticationWithRetry() async {
    const maxRetries = 3;
    const baseDelay = Duration(milliseconds: 500);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔑 [$name] Tentativa de login anônimo #$attempt');

        if (!_authController!.isUserLoggedIn()) {
          await _authController!.signInAnonymously().timeout(
                const Duration(seconds: 15),
                onTimeout: () => throw TimeoutException(
                  'Login timeout',
                  const Duration(seconds: 15),
                ),
              );
          debugPrint(
              '✅ [$name] Login anônimo realizado com sucesso (tentativa $attempt)');
        } else {
          debugPrint('✅ [$name] Usuário já está logado');
        }

        _initializedServices.add('Authentication');
        return _ServiceResult.success();
      } catch (e) {
        debugPrint('⚠️ [$name] Erro no login anônimo (tentativa $attempt): $e');

        if (attempt < maxRetries) {
          final delay = Duration(
            milliseconds: baseDelay.inMilliseconds * attempt,
          );
          debugPrint(
              '🔄 [$name] Tentando novamente em ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
        } else {
          debugPrint(
              '❌ [$name] Falha no login anônimo após $maxRetries tentativas');

          // Usar modo offline como fallback
          _initializedServices.add('OfflineAuthentication');
          debugPrint(
              '⚠️ [$name] Fallback para modo offline devido a erro de autenticação');

          return _ServiceResult.withFailure(
            ServiceFailure(
              type: ServiceType.auth,
              error: 'Falha no login anônimo: $e',
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }

    // Não deveria chegar aqui, mas por segurança
    _initializedServices.add('OfflineAuthentication');
    return _ServiceResult.success();
  }

  @override
  Future<bool> recover() async {
    if (!canRecover) {
      debugPrint('⚠️ [$name] Máximo de tentativas de recovery atingido');
      return false;
    }

    // Só pode recuperar se estava em modo offline
    if (!_initializedServices.contains('OfflineAuthentication')) {
      return false;
    }

    // Verificar se auth controller está disponível agora
    if (!_degradedModeService.isServiceAvailable(ServiceType.auth)) {
      debugPrint('⚠️ [$name] AuthController ainda indisponível para recovery');
      return false;
    }

    _recoveryAttempts++;
    debugPrint('🔄 [$name] Tentativa de recovery #$_recoveryAttempts');

    try {
      // Obter referência atualizada do auth controller
      _authController = Get.find<PlantasAuthController>();

      // Tentar autenticação
      if (!_authController!.isUserLoggedIn()) {
        await _authController!.signInAnonymously().timeout(
              const Duration(seconds: 10), // Timeout menor para recovery
            );
      }

      // Atualizar lista de serviços
      _initializedServices.remove('OfflineAuthentication');
      _initializedServices.add('Authentication');

      resetRecoveryAttempts();
      debugPrint('✅ [$name] Authentication recuperado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [$name] Falha na recuperação de auth: $e');
      return false;
    }
  }

  /// Verifica se usuário está logado (quando auth está disponível)
  bool get isUserLoggedIn {
    if (_authController == null ||
        _initializedServices.contains('OfflineAuthentication')) {
      return false;
    }

    try {
      return _authController!.isUserLoggedIn();
    } catch (e) {
      debugPrint('⚠️ [$name] Erro ao verificar login: $e');
      return false;
    }
  }

  /// Obtém referência do auth controller (se disponível)
  PlantasAuthController? get authController => _authController;

  @override
  Future<void> dispose() async {
    _initializedServices.clear();
    _isInitialized = false;
    _recoveryAttempts = 0;
    _authController = null;

    debugPrint('🔄 [$name] Recursos liberados');
  }

  /// Obtém estatísticas do inicializador
  Map<String, dynamic> getStats() {
    return {
      'name': name,
      'initialized': isInitialized,
      'using_fallback': isUsingFallback,
      'recovery_attempts': recoveryAttempts,
      'managed_services': managedServices,
      'initialized_services': _initializedServices,
      'fallback_limitations': fallbackLimitations,
      'is_user_logged_in': isUserLoggedIn,
      'is_mobile_platform': GetPlatform.isMobile,
      'auth_controller_available': _authController != null,
    };
  }
}

/// Resultado interno de inicialização de serviço
class _ServiceResult {
  final bool success;
  final ServiceFailure? failure;

  _ServiceResult.success()
      : success = true,
        failure = null;
  _ServiceResult.withFailure(ServiceFailure failure)
      : success = false,
        failure = failure;
}
