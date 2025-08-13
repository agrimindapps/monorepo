// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../controllers/auth_controller.dart';
import '../../infrastructure/degraded_mode_service.dart';
import '../../infrastructure/fallback_storage_service.dart';
import 'authentication_initializer.dart';
import 'controllers_initializer.dart';
import 'core_services_initializer.dart';
import 'interfaces.dart';
import 'recovery_service.dart';

/// Serviço principal de inicialização da aplicação PlantApp
///
/// Orquestra todo o processo de inicialização seguindo a ordem correta:
/// 1. Core Services (Hive, License)
/// 2. Controllers (Binding, Theme, Auth)
/// 3. Authentication (Login anônimo)
///
/// Gerencia fallbacks, recovery e estados de degradação
class PlantasAppInitializationService
    implements IPlantasAppInitializationService {
  // Dependências
  final DegradedModeService _degradedModeService;
  final FallbackStorageService _fallbackStorage;
  final ThemeManager _themeManager;

  // Inicializadores
  late final CoreServicesInitializer _coreInitializer;
  late final ControllersInitializer _controllersInitializer;
  late final AuthenticationInitializer _authInitializer;
  late final RecoveryService _recoveryService;

  // Estado
  final StreamController<InitializationStatus> _statusController =
      StreamController<InitializationStatus>.broadcast();
  InitializationStatus _currentStatus = InitializationStatus.idle;
  final List<String> _initializedServices = [];
  final List<ServiceFailure> _serviceFailures = [];

  PlantasAppInitializationService({
    DegradedModeService? degradedModeService,
    FallbackStorageService? fallbackStorage,
    ThemeManager? themeManager,
  })  : _degradedModeService = degradedModeService ?? DegradedModeService(),
        _fallbackStorage = fallbackStorage ?? FallbackStorageService(),
        _themeManager = themeManager ?? ThemeManager() {
    _initializeComponents();
  }

  void _initializeComponents() {
    // Criar inicializadores
    _coreInitializer = CoreServicesInitializer(
      degradedModeService: _degradedModeService,
      fallbackStorage: _fallbackStorage,
    );

    _controllersInitializer = ControllersInitializer(
      degradedModeService: _degradedModeService,
      themeManager: _themeManager,
    );

    _authInitializer = AuthenticationInitializer(
      degradedModeService: _degradedModeService,
    );

    _recoveryService = RecoveryService(
      degradedModeService: _degradedModeService,
    );

    // Registrar serviços recuperáveis
    _recoveryService.registerRecoverableService(
        'CoreServicesInitializer', _coreInitializer);
    _recoveryService.registerRecoverableService(
        'ControllersInitializer', _controllersInitializer);
    _recoveryService.registerRecoverableService(
        'AuthenticationInitializer', _authInitializer);

    debugPrint(
        '🏗️ [PlantasAppInitializationService] Componentes inicializados');
  }

  @override
  Stream<InitializationStatus> get statusStream => _statusController.stream;

  @override
  InitializationStatus get currentStatus => _currentStatus;

  @override
  bool get isDegraded => _degradedModeService.isDegraded;

  @override
  List<String> get initializedServices =>
      List.unmodifiable(_initializedServices);

  @override
  List<ServiceFailure> get serviceFailures =>
      List.unmodifiable(_serviceFailures);

  /// Obtém referência do auth controller (se disponível)
  PlantasAuthController? get authController =>
      _controllersInitializer.authController;

  @override
  Future<InitializationResult> initialize() async {
    debugPrint(
        '🚀 [PlantasAppInitializationService] Iniciando processo de inicialização');

    _updateStatus(InitializationStatus.initializing);
    _clearState();

    try {
      // Etapa 1: Core Services
      await _initializeCoreServices();

      // Etapa 2: Controllers
      await _initializeControllers();

      // Etapa 3: Authentication
      await _initializeAuthentication();

      // Verificar resultado final
      final success = _verifyInitializationIntegrity();

      if (success) {
        _updateStatus(InitializationStatus.success);

        // Iniciar auto-recovery se necessário
        if (_degradedModeService.isDegraded) {
          _recoveryService.startAutoRecovery();
        }

        debugPrint(
            '✅ [PlantasAppInitializationService] Inicialização concluída com sucesso');
        debugPrint('   Serviços inicializados: ${_initializedServices.length}');
        debugPrint('   Modo degradado: ${isDegraded ? "SIM" : "NÃO"}');

        return InitializationResult.success(
            services: List.from(_initializedServices));
      } else {
        _updateStatus(InitializationStatus.partial);

        // Iniciar auto-recovery para tentar melhorar o estado
        _recoveryService.startAutoRecovery();

        debugPrint(
            '⚠️ [PlantasAppInitializationService] Inicialização parcial');

        return InitializationResult.failure(
          error:
              'Inicialização incompleta - alguns serviços estão em modo fallback',
          services: List.from(_initializedServices),
          failures: List.from(_serviceFailures),
        );
      }
    } catch (e) {
      _updateStatus(InitializationStatus.error);
      debugPrint(
          '❌ [PlantasAppInitializationService] Erro crítico na inicialização: $e');

      return InitializationResult.failure(
        error: 'Erro crítico na inicialização: $e',
        services: List.from(_initializedServices),
        failures: List.from(_serviceFailures),
      );
    }
  }

  Future<void> _initializeCoreServices() async {
    debugPrint('🔧 [PlantasAppInitializationService] Etapa 1: Core Services');

    final result = await _coreInitializer.initialize();
    _processInitializationResult('CoreServices', result);
  }

  Future<void> _initializeControllers() async {
    debugPrint('🎮 [PlantasAppInitializationService] Etapa 2: Controllers');

    if (!_controllersInitializer.canInitialize(_initializedServices)) {
      const error = 'Dependências não satisfeitas para controllers';
      debugPrint('❌ [PlantasAppInitializationService] $error');
      throw Exception(error);
    }

    final result = await _controllersInitializer.initialize();
    _processInitializationResult('Controllers', result);
  }

  Future<void> _initializeAuthentication() async {
    debugPrint('🔐 [PlantasAppInitializationService] Etapa 3: Authentication');

    if (!_authInitializer.canInitialize(_initializedServices)) {
      debugPrint(
          '⚠️ [PlantasAppInitializationService] Auth não pode ser inicializado - pulando');
      return;
    }

    final result = await _authInitializer.initialize();
    _processInitializationResult('Authentication', result);
  }

  void _processInitializationResult(String stage, InitializationResult result) {
    // Adicionar serviços inicializados
    _initializedServices.addAll(result.initializedServices);

    // Adicionar falhas
    _serviceFailures.addAll(result.failures);

    if (result.success) {
      debugPrint('✅ [PlantasAppInitializationService] $stage: OK');
    } else {
      debugPrint(
          '⚠️ [PlantasAppInitializationService] $stage: ${result.error}');
    }
  }

  bool _verifyInitializationIntegrity() {
    // Categorias de serviços essenciais
    final coreServices = ['PlantasHiveService', 'FallbackStorageService'];
    final licenseServices = ['LocalLicenseService', 'BasicLicenseMode'];
    final bindingServices = ['NovaTarefasBinding', 'BasicBinding'];
    final themeServices = ['ThemeManager', 'BasicTheme'];
    final authServices = ['PlantasAuthController', 'OfflineMode'];

    // Verificar se pelo menos um de cada categoria está disponível
    final hasCore = coreServices.any((s) => _initializedServices.contains(s));
    final hasLicense =
        licenseServices.any((s) => _initializedServices.contains(s));
    final hasBinding =
        bindingServices.any((s) => _initializedServices.contains(s));
    final hasTheme = themeServices.any((s) => _initializedServices.contains(s));
    final hasAuth = authServices.any((s) => _initializedServices.contains(s));

    final allCategoriesAvailable =
        hasCore && hasLicense && hasBinding && hasTheme && hasAuth;

    debugPrint(
        '🔍 [PlantasAppInitializationService] Verificação de integridade:');
    debugPrint('   Core: ${hasCore ? "✅" : "❌"}');
    debugPrint('   License: ${hasLicense ? "✅" : "❌"}');
    debugPrint('   Binding: ${hasBinding ? "✅" : "❌"}');
    debugPrint('   Theme: ${hasTheme ? "✅" : "❌"}');
    debugPrint('   Auth: ${hasAuth ? "✅" : "❌"}');

    return allCategoriesAvailable;
  }

  @override
  Future<void> performRecovery() async {
    if (!isDegraded) {
      debugPrint(
          '📋 [PlantasAppInitializationService] Sistema não está degradado');
      return;
    }

    debugPrint(
        '🔄 [PlantasAppInitializationService] Iniciando recovery manual');
    _updateStatus(InitializationStatus.recovering);

    try {
      await _recoveryService
          .performIntelligentRecovery(_degradedModeService.failedServices);

      // Verificar se ainda há degradação
      if (!isDegraded) {
        _updateStatus(InitializationStatus.success);
        _recoveryService.stopAutoRecovery();
        debugPrint(
            '✅ [PlantasAppInitializationService] Recovery completo - sistema totalmente funcional');
      } else {
        _updateStatus(InitializationStatus.partial);
        debugPrint(
            '⚠️ [PlantasAppInitializationService] Recovery parcial - alguns serviços ainda estão degradados');
      }
    } catch (e) {
      _updateStatus(InitializationStatus.partial);
      debugPrint(
          '❌ [PlantasAppInitializationService] Erro durante recovery: $e');
    }
  }

  @override
  Future<InitializationResult> restart() async {
    debugPrint('🔄 [PlantasAppInitializationService] Reiniciando sistema');

    // Parar auto-recovery
    _recoveryService.stopAutoRecovery();

    // Reset de todos os serviços
    await _resetAllServices();

    // Reinicializar
    return await initialize();
  }

  Future<void> _resetAllServices() async {
    // Reset dos inicializadores
    await _coreInitializer.dispose();
    await _controllersInitializer.dispose();
    await _authInitializer.dispose();

    // Reset do recovery service
    await _recoveryService.dispose();

    // Reset dos serviços de fallback
    _fallbackStorage.deactivate();
    _degradedModeService.reset();

    // Reset do estado local
    _clearState();

    // Recriar componentes
    _initializeComponents();

    debugPrint('🔄 [PlantasAppInitializationService] Reset completo realizado');
  }

  void _clearState() {
    _initializedServices.clear();
    _serviceFailures.clear();
  }

  void _updateStatus(InitializationStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      debugPrint('📊 [PlantasAppInitializationService] Status: ${status.name}');
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('🔄 [PlantasAppInitializationService] Liberando recursos');

    _recoveryService.stopAutoRecovery();

    await _coreInitializer.dispose();
    await _controllersInitializer.dispose();
    await _authInitializer.dispose();
    await _recoveryService.dispose();

    await _statusController.close();

    _clearState();

    debugPrint('✅ [PlantasAppInitializationService] Recursos liberados');
  }

  /// Obtém estatísticas completas do sistema
  Map<String, dynamic> getComprehensiveStats() {
    return {
      'initialization_service': {
        'current_status': _currentStatus.name,
        'is_degraded': isDegraded,
        'initialized_services_count': _initializedServices.length,
        'service_failures_count': _serviceFailures.length,
        'initialized_services': _initializedServices,
      },
      'degraded_mode_service': _degradedModeService.getStats(),
      'fallback_storage_service': _fallbackStorage.getStats(),
      'recovery_service': _recoveryService.getStats(),
      'initializers': {
        'core_services': _coreInitializer.getStats(),
        'controllers': _controllersInitializer.getStats(),
        'authentication': _authInitializer.getStats(),
      },
    };
  }
}
