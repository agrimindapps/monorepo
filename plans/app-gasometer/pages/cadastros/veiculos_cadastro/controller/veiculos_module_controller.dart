// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../bindings/veiculos_module_binding.dart';
import '../mixins/controller_lifecycle_mixin.dart';

/// Controller de gerenciamento do módulo de veículos
///
/// Responsável por:
/// - Orquestrar inicialização de dependências
/// - Monitorar estado do módulo
/// - Fornecer diagnóstico e health check
/// - Coordenar cleanup do módulo
class VeiculosModuleController extends GetxController
    with ControllerLifecycleMixin {
  // Estado do módulo
  final RxBool isInitialized = false.obs;
  final RxBool hasErrors = false.obs;
  final RxString lastError = ''.obs;
  final RxMap<String, bool> dependencyStatus = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _setupModuleMonitoring();
    _initializeModule();
  }

  /// Configura monitoramento do módulo
  void _setupModuleMonitoring() {
    // Worker para monitorar mudanças no status de dependências
    registerEverWorker(
      dependencyStatus,
      (status) {
        final allDependenciesReady = status.values.every((isReady) => isReady);
        isInitialized.value = allDependenciesReady;

        if (allDependenciesReady && hasErrors.value) {
          // Reset erro se todas as dependências estão prontas
          hasErrors.value = false;
          lastError.value = '';
        }
      },
    );

    // Periodic health check
    registerSubscription(
      Stream.periodic(const Duration(seconds: 30))
          .listen((_) => _performHealthCheck()),
    );
  }

  /// Inicializa o módulo completo
  Future<void> _initializeModule() async {
    try {
      hasErrors.value = false;
      lastError.value = '';

      // Garante que o binding está configurado
      if (!VeiculosModuleBinding.isFullyInitialized()) {
        VeiculosModuleBinding().dependencies();
      }

      // Verifica status das dependências
      await _checkDependencyStatus();

      isInitialized.value = VeiculosModuleBinding.isFullyInitialized();
    } catch (e) {
      _handleModuleError('Falha na inicialização do módulo', e);
    }
  }

  /// Verifica status de todas as dependências
  Future<void> _checkDependencyStatus() async {
    final status = VeiculosModuleBinding.getDependencyStatus();
    dependencyStatus.assignAll(status);

    // Log dependências não encontradas
    status.forEach((dependency, isRegistered) {
      if (!isRegistered) {
        debugPrint('Warning: Dependency $dependency not registered');
      }
    });
  }

  /// Realiza health check periódico
  void _performHealthCheck() {
    if (!isClosed) {
      _checkDependencyStatus();
    }
  }

  /// Re-inicializa o módulo em caso de problemas
  Future<void> reinitializeModule() async {
    try {
      hasErrors.value = false;
      lastError.value = '';
      isInitialized.value = false;

      // Força re-inicialização do binding
      VeiculosModuleBinding.reinitialize();

      await _checkDependencyStatus();

      isInitialized.value = VeiculosModuleBinding.isFullyInitialized();
    } catch (e) {
      _handleModuleError('Falha na re-inicialização do módulo', e);
    }
  }

  /// Obtém informações de diagnóstico do módulo
  Map<String, dynamic> getModuleDiagnostic() {
    return {
      'isInitialized': isInitialized.value,
      'hasErrors': hasErrors.value,
      'lastError': lastError.value,
      'dependencyStatus': Map<String, bool>.from(dependencyStatus),
      'moduleBinding': {
        'isFullyInitialized': VeiculosModuleBinding.isFullyInitialized(),
        'dependencyCount': dependencyStatus.length,
      },
      'controller': getDiagnosticInfo(),
    };
  }

  /// Verifica se o módulo está saudável
  bool get isHealthy {
    return isInitialized.value &&
        !hasErrors.value &&
        dependencyStatus.values.every((status) => status);
  }

  /// Força atualização do status das dependências
  void refreshDependencyStatus() {
    _checkDependencyStatus();
  }

  /// Handle de erros do módulo
  void _handleModuleError(String message, dynamic error) {
    hasErrors.value = true;
    lastError.value = '$message: $error';
    isInitialized.value = false;

    // Log para debugging
    debugPrint('VeiculosModuleController Error: $message - $error');
  }

  /// Limpa completamente o módulo
  Future<void> disposeModule() async {
    try {
      VeiculosModuleBinding.dispose();
      isInitialized.value = false;
      hasErrors.value = false;
      lastError.value = '';
      dependencyStatus.clear();
    } catch (e) {
      debugPrint('Warning: Error disposing module: $e');
    }
  }

  @override
  void onClose() {
    // Não faz dispose do módulo no onClose pois pode ser usado por outros controllers
    super.onClose();
  }
}
