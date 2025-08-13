// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../infrastructure/degraded_mode_service.dart';
import '../../infrastructure/fallback_storage_service.dart';
import '../../infrastructure/plantas_hive_service.dart';
import '../local_license_service.dart';
import 'interfaces.dart';

/// Inicializador responsável pelos serviços básicos da aplicação
///
/// Gerencia inicialização de:
/// - PlantasHiveService (com fallback para FallbackStorageService)
/// - LocalLicenseService (com fallback para modo básico)
class CoreServicesInitializer implements IFallbackService, IRecoverableService {
  final DegradedModeService _degradedModeService;
  final FallbackStorageService _fallbackStorage;

  final List<String> _initializedServices = [];
  bool _isInitialized = false;
  int _recoveryAttempts = 0;

  CoreServicesInitializer({
    required DegradedModeService degradedModeService,
    required FallbackStorageService fallbackStorage,
  })  : _degradedModeService = degradedModeService,
        _fallbackStorage = fallbackStorage;

  @override
  String get name => 'CoreServicesInitializer';

  @override
  List<String> get dependencies => []; // Não tem dependências

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<String> get managedServices => [
        'PlantasHiveService',
        'FallbackStorageService',
        'LocalLicenseService',
        'BasicLicenseMode',
      ];

  @override
  bool get isUsingFallback =>
      _initializedServices.contains('FallbackStorageService') ||
      _initializedServices.contains('BasicLicenseMode');

  @override
  List<String> get fallbackLimitations {
    final limitations = <String>[];

    if (_initializedServices.contains('FallbackStorageService')) {
      limitations.add('Dados salvos apenas em memória (não persistem)');
    }

    if (_initializedServices.contains('BasicLicenseMode')) {
      limitations.add('Verificação de licença desabilitada');
    }

    return limitations;
  }

  @override
  bool get canRecover => _recoveryAttempts < 5; // Máximo 5 tentativas

  @override
  int get recoveryAttempts => _recoveryAttempts;

  @override
  void resetRecoveryAttempts() {
    _recoveryAttempts = 0;
  }

  @override
  bool canInitialize(List<String> availableServices) {
    // Core services não dependem de outros serviços
    return true;
  }

  @override
  Future<InitializationResult> initialize() async {
    return await initializeWithFallback();
  }

  @override
  Future<InitializationResult> initializeWithFallback() async {
    debugPrint('🔄 [$name] Iniciando inicialização dos serviços básicos...');

    _initializedServices.clear();
    final failures = <ServiceFailure>[];

    // Inicializar storage (Hive com fallback)
    final storageResult = await _initializeStorageWithFallback();
    if (storageResult.failure != null) {
      failures.add(storageResult.failure!);
    }

    // Inicializar license service (com fallback)
    final licenseResult = await _initializeLicenseServiceWithFallback();
    if (licenseResult.failure != null) {
      failures.add(licenseResult.failure!);
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
            error: 'Falha na inicialização dos serviços básicos',
            services: List.from(_initializedServices),
            failures: failures,
          );
  }

  Future<_ServiceResult> _initializeStorageWithFallback() async {
    try {
      // Tentar inicializar Hive
      await PlantasHiveService.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException(
          'PlantasHiveService timeout',
          const Duration(seconds: 10),
        ),
      );

      _initializedServices.add('PlantasHiveService');
      debugPrint('✅ [$name] PlantasHiveService inicializado');

      return _ServiceResult.success();
    } catch (e) {
      debugPrint('❌ [$name] Falha no PlantasHiveService: $e');

      // Ativar fallback storage
      _fallbackStorage.activate();
      _degradedModeService.registerServiceFailure(
          ServiceType.storage, e.toString());
      _initializedServices.add('FallbackStorageService');

      debugPrint('⚠️ [$name] Usando FallbackStorageService como alternativa');

      return _ServiceResult.withFailure(
        ServiceFailure(
          type: ServiceType.storage,
          error: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<_ServiceResult> _initializeLicenseServiceWithFallback() async {
    try {
      // Tentar inicializar LocalLicenseService
      if (!Get.isRegistered<LocalLicenseService>()) {
        Get.put(LocalLicenseService());
        _initializedServices.add('LocalLicenseService');
        debugPrint('✅ [$name] LocalLicenseService registrado');
      }

      return _ServiceResult.success();
    } catch (e) {
      debugPrint('❌ [$name] Falha no LocalLicenseService: $e');

      // Registrar falha e usar modo básico
      _degradedModeService.registerServiceFailure(
          ServiceType.license, e.toString());
      _initializedServices.add('BasicLicenseMode');

      debugPrint('⚠️ [$name] Usando modo de licença básica');

      return _ServiceResult.withFailure(
        ServiceFailure(
          type: ServiceType.license,
          error: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
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

    // Tentar recuperar storage
    if (_initializedServices.contains('FallbackStorageService')) {
      if (await _recoverStorageService()) {
        anyRecovered = true;
      }
    }

    // Tentar recuperar license service
    if (_initializedServices.contains('BasicLicenseMode')) {
      if (await _recoverLicenseService()) {
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

  Future<bool> _recoverStorageService() async {
    try {
      // Tentar reinicializar Hive
      await PlantasHiveService.initialize().timeout(
        const Duration(seconds: 5),
      );

      // Se chegou aqui, Hive foi inicializado com sucesso
      _fallbackStorage.deactivate();
      _degradedModeService.clearServiceFailure(ServiceType.storage);

      // Atualizar lista de serviços
      _initializedServices.remove('FallbackStorageService');
      _initializedServices.add('PlantasHiveService');

      debugPrint('✅ [$name] PlantasHiveService recuperado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [$name] Falha na recuperação do storage: $e');
      return false;
    }
  }

  Future<bool> _recoverLicenseService() async {
    try {
      // Tentar recriar o LocalLicenseService
      if (Get.isRegistered<LocalLicenseService>()) {
        Get.delete<LocalLicenseService>();
      }

      Get.put(LocalLicenseService());

      _degradedModeService.clearServiceFailure(ServiceType.license);

      // Atualizar lista de serviços
      _initializedServices.remove('BasicLicenseMode');
      _initializedServices.add('LocalLicenseService');

      debugPrint('✅ [$name] LocalLicenseService recuperado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [$name] Falha na recuperação do license: $e');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _initializedServices.clear();
    _isInitialized = false;
    _recoveryAttempts = 0;
    _fallbackStorage.deactivate();

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
