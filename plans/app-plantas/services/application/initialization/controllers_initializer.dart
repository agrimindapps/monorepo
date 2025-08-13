// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../controllers/auth_controller.dart';
import '../../../pages/nova_tarefas_page/bindings/nova_tarefas_binding.dart';
import '../../infrastructure/degraded_mode_service.dart';
import 'interfaces.dart';

/// Inicializador responsável pelos controllers GetX da aplicação
///
/// Gerencia inicialização de:
/// - NovaTarefasBinding (com fallback para binding básico)
/// - ThemeManager (com fallback para tema básico)
/// - PlantasAuthController (com fallback para modo offline)
class ControllersInitializer implements IFallbackService, IRecoverableService {
  final DegradedModeService _degradedModeService;
  final ThemeManager _themeManager;

  final List<String> _initializedServices = [];
  bool _isInitialized = false;
  int _recoveryAttempts = 0;
  PlantasAuthController? _authController;

  ControllersInitializer({
    required DegradedModeService degradedModeService,
    required ThemeManager themeManager,
  })  : _degradedModeService = degradedModeService,
        _themeManager = themeManager;

  @override
  String get name => 'ControllersInitializer';

  @override
  List<String> get dependencies => [
        'PlantasHiveService', // Ou FallbackStorageService
        'LocalLicenseService', // Ou BasicLicenseMode
      ];

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<String> get managedServices => [
        'NovaTarefasBinding',
        'BasicBinding',
        'ThemeManager',
        'BasicTheme',
        'PlantasAuthController',
        'OfflineMode',
      ];

  @override
  bool get isUsingFallback =>
      _initializedServices.contains('BasicBinding') ||
      _initializedServices.contains('BasicTheme') ||
      _initializedServices.contains('OfflineMode');

  @override
  List<String> get fallbackLimitations {
    final limitations = <String>[];

    if (_initializedServices.contains('BasicBinding')) {
      limitations.add('Funcionalidades avançadas de tarefas indisponíveis');
    }

    if (_initializedServices.contains('BasicTheme')) {
      limitations.add('Personalização de tema limitada');
    }

    if (_initializedServices.contains('OfflineMode')) {
      limitations.add('Autenticação e sincronização indisponíveis');
    }

    return limitations;
  }

  @override
  bool get canRecover => _recoveryAttempts < 5;

  @override
  int get recoveryAttempts => _recoveryAttempts;

  @override
  void resetRecoveryAttempts() {
    _recoveryAttempts = 0;
  }

  /// Getter para acessar o auth controller
  PlantasAuthController? get authController => _authController;

  @override
  bool canInitialize(List<String> availableServices) {
    // Verifica se pelo menos um serviço de storage está disponível
    final hasStorage = availableServices.contains('PlantasHiveService') ||
        availableServices.contains('FallbackStorageService');

    // Verifica se pelo menos um serviço de license está disponível
    final hasLicense = availableServices.contains('LocalLicenseService') ||
        availableServices.contains('BasicLicenseMode');

    return hasStorage && hasLicense;
  }

  @override
  Future<InitializationResult> initialize() async {
    return await initializeWithFallback();
  }

  @override
  Future<InitializationResult> initializeWithFallback() async {
    debugPrint('🔄 [$name] Iniciando inicialização dos controllers...');

    _initializedServices.clear();
    final failures = <ServiceFailure>[];

    // Inicializar binding (com fallback)
    final bindingResult = await _initializeBindingWithFallback();
    if (bindingResult.failure != null) {
      failures.add(bindingResult.failure!);
    }

    // Inicializar theme manager (com fallback)
    final themeResult = await _initializeThemeManagerWithFallback();
    if (themeResult.failure != null) {
      failures.add(themeResult.failure!);
    }

    // Inicializar auth controller (com fallback)
    final authResult = await _initializeAuthControllerWithFallback();
    if (authResult.failure != null) {
      failures.add(authResult.failure!);
    }

    _isInitialized = true;

    final success = _initializedServices.isNotEmpty;
    debugPrint(success
        ? '✅ [$name] Inicialização concluída (${_initializedServices.length} controllers)'
        : '❌ [$name] Falha na inicialização');

    return success
        ? InitializationResult.success(
            services: List.from(_initializedServices))
        : InitializationResult.failure(
            error: 'Falha na inicialização dos controllers',
            services: List.from(_initializedServices),
            failures: failures,
          );
  }

  Future<_ServiceResult> _initializeBindingWithFallback() async {
    try {
      NovaTarefasBinding().dependencies();
      _initializedServices.add('NovaTarefasBinding');
      debugPrint('✅ [$name] NovaTarefasBinding inicializado');

      return _ServiceResult.success();
    } catch (e) {
      debugPrint('❌ [$name] Falha no NovaTarefasBinding: $e');

      _degradedModeService.registerServiceFailure(
          ServiceType.binding, e.toString());
      _initializedServices.add('BasicBinding');
      debugPrint('⚠️ [$name] Usando binding básico como alternativa');

      return _ServiceResult.withFailure(
        ServiceFailure(
          type: ServiceType.binding,
          error: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<_ServiceResult> _initializeThemeManagerWithFallback() async {
    try {
      if (!Get.isRegistered<ThemeManager>()) {
        Get.put(_themeManager);
        _initializedServices.add('ThemeManager');
        debugPrint('✅ [$name] ThemeManager registrado');
      }

      return _ServiceResult.success();
    } catch (e) {
      debugPrint('❌ [$name] Falha no ThemeManager: $e');

      _degradedModeService.registerServiceFailure(
          ServiceType.theme, e.toString());
      _initializedServices.add('BasicTheme');
      debugPrint('⚠️ [$name] Usando tema básico como alternativa');

      return _ServiceResult.withFailure(
        ServiceFailure(
          type: ServiceType.theme,
          error: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<_ServiceResult> _initializeAuthControllerWithFallback() async {
    try {
      if (!Get.isRegistered<PlantasAuthController>()) {
        _authController = Get.put(PlantasAuthController());

        // Aguardar inicialização completa do controller
        await Future.delayed(const Duration(milliseconds: 100));

        // Verificar se controller está pronto
        if (!_isControllerReady(_authController!)) {
          throw Exception('PlantasAuthController não está pronto');
        }

        _initializedServices.add('PlantasAuthController');
        debugPrint('✅ [$name] PlantasAuthController registrado e verificado');
      } else {
        _authController = Get.find<PlantasAuthController>();
        if (!_isControllerReady(_authController!)) {
          throw Exception('PlantasAuthController existente não está pronto');
        }
        _initializedServices.add('PlantasAuthController');
      }

      return _ServiceResult.success();
    } catch (e) {
      debugPrint('❌ [$name] Falha no PlantasAuthController: $e');

      _degradedModeService.registerServiceFailure(
          ServiceType.auth, e.toString());
      _initializedServices.add('OfflineMode');
      debugPrint('⚠️ [$name] Usando modo offline como alternativa');

      return _ServiceResult.withFailure(
        ServiceFailure(
          type: ServiceType.auth,
          error: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  bool _isControllerReady(PlantasAuthController controller) {
    try {
      // Verificar se o controller tem os services necessários inicializados
      controller.isUserLoggedIn(); // Teste básico de funcionamento
      return true;
    } catch (e) {
      debugPrint('⚠️ [$name] Controller não está pronto: $e');
      return false;
    }
  }

  @override
  Future<bool> recover() async {
    if (!canRecover) {
      debugPrint('⚠️ [$name] Máximo de tentativas de recovery atingido');
      return false;
    }

    _recoveryAttempts++;
    debugPrint('🔄 [$name] Tentativa de recovery #$_recoveryAttempts');

    bool anyRecovered = false;

    // Tentar recuperar binding
    if (_initializedServices.contains('BasicBinding')) {
      if (await _recoverBindingService()) {
        anyRecovered = true;
      }
    }

    // Tentar recuperar theme manager
    if (_initializedServices.contains('BasicTheme')) {
      if (await _recoverThemeService()) {
        anyRecovered = true;
      }
    }

    // Tentar recuperar auth controller
    if (_initializedServices.contains('OfflineMode')) {
      if (await _recoverAuthService()) {
        anyRecovered = true;
      }
    }

    if (anyRecovered) {
      debugPrint('✅ [$name] Recovery parcial ou completo realizado');
      resetRecoveryAttempts();
    } else {
      debugPrint('❌ [$name] Recovery falhou');
    }

    return anyRecovered;
  }

  Future<bool> _recoverBindingService() async {
    try {
      // Tentar reinicializar binding
      NovaTarefasBinding().dependencies();

      _degradedModeService.clearServiceFailure(ServiceType.binding);

      // Atualizar lista de serviços
      _initializedServices.remove('BasicBinding');
      _initializedServices.add('NovaTarefasBinding');

      debugPrint('✅ [$name] NovaTarefasBinding recuperado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [$name] Falha na recuperação do binding: $e');
      return false;
    }
  }

  Future<bool> _recoverThemeService() async {
    try {
      // Tentar recriar o ThemeManager
      if (Get.isRegistered<ThemeManager>()) {
        Get.delete<ThemeManager>();
      }

      Get.put(_themeManager);

      _degradedModeService.clearServiceFailure(ServiceType.theme);

      // Atualizar lista de serviços
      _initializedServices.remove('BasicTheme');
      _initializedServices.add('ThemeManager');

      debugPrint('✅ [$name] ThemeManager recuperado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [$name] Falha na recuperação do theme: $e');
      return false;
    }
  }

  Future<bool> _recoverAuthService() async {
    try {
      // Tentar recriar o AuthController
      if (Get.isRegistered<PlantasAuthController>()) {
        Get.delete<PlantasAuthController>();
      }

      _authController = Get.put(PlantasAuthController());

      // Aguardar inicialização
      await Future.delayed(const Duration(milliseconds: 200));

      // Verificar se está funcionando
      if (_isControllerReady(_authController!)) {
        _degradedModeService.clearServiceFailure(ServiceType.auth);

        // Atualizar lista de serviços
        _initializedServices.remove('OfflineMode');
        _initializedServices.add('PlantasAuthController');

        debugPrint('✅ [$name] PlantasAuthController recuperado com sucesso');
        return true;
      } else {
        throw Exception('Controller não está funcionando após recovery');
      }
    } catch (e) {
      debugPrint('❌ [$name] Falha na recuperação do auth: $e');
      return false;
    }
  }

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
