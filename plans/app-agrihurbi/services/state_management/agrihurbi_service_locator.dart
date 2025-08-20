// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../error_handling/error_handler_service.dart';
import 'agrihurbi_state_manager.dart';
import 'unified_data_service.dart';

/// Service Locator para gerenciar dependências do sistema de estado centralizado
/// 
/// Inicializa e gerencia todos os services relacionados ao gerenciamento de estado
/// e tratamento de erros, garantindo ordem correta de inicialização e cleanup.
class AgrihurbiServiceLocator {
  
  // ========== SINGLETON PATTERN ==========
  
  static AgrihurbiServiceLocator? _instance;
  static AgrihurbiServiceLocator get instance => _instance ??= AgrihurbiServiceLocator._();
  AgrihurbiServiceLocator._();

  // ========== ESTADO DE INICIALIZAÇÃO ==========
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ========== INICIALIZAÇÃO ==========

  /// Inicializa todos os services necessários
  Future<void> initializeServices() async {
    if (_isInitialized) {
      debugPrint('⚠️ AgrihurbiServiceLocator: Services já inicializados');
      return;
    }

    try {
      debugPrint('🚀 AgrihurbiServiceLocator: Inicializando services centralizados...');

      // 1. Inicializar ErrorHandlerService (primeiro, pois outros podem usá-lo)
      if (!Get.isRegistered<ErrorHandlerService>()) {
        Get.put<ErrorHandlerService>(ErrorHandlerService.instance, permanent: true);
        debugPrint('✅ ErrorHandlerService registrado');
      }

      // 2. Inicializar AgrihurbiStateManager (gerencia estado global)
      if (!Get.isRegistered<AgrihurbiStateManager>()) {
        Get.put<AgrihurbiStateManager>(AgrihurbiStateManager.instance, permanent: true);
        debugPrint('✅ AgrihurbiStateManager registrado');
      }

      // 3. Inicializar UnifiedDataService (depende do state manager)
      if (!Get.isRegistered<UnifiedDataService>()) {
        Get.put<UnifiedDataService>(UnifiedDataService.instance, permanent: true);
        debugPrint('✅ UnifiedDataService registrado');
      }

      _isInitialized = true;
      debugPrint('🎉 AgrihurbiServiceLocator: Todos os services inicializados com sucesso');

    } catch (e) {
      debugPrint('❌ AgrihurbiServiceLocator: Erro na inicialização: $e');
      
      // Cleanup em caso de erro
      await _cleanupPartialInitialization();
      rethrow;
    }
  }

  /// Realiza cleanup parcial em caso de erro na inicialização
  Future<void> _cleanupPartialInitialization() async {
    try {
      if (Get.isRegistered<UnifiedDataService>()) {
        Get.delete<UnifiedDataService>();
      }
      if (Get.isRegistered<AgrihurbiStateManager>()) {
        Get.delete<AgrihurbiStateManager>();
      }
      if (Get.isRegistered<ErrorHandlerService>()) {
        Get.delete<ErrorHandlerService>();
      }
      
      _isInitialized = false;
      debugPrint('🧹 AgrihurbiServiceLocator: Cleanup parcial realizado');
    } catch (e) {
      debugPrint('❌ AgrihurbiServiceLocator: Erro no cleanup: $e');
    }
  }

  // ========== ACESSO FACILITADO AOS SERVICES ==========

  /// Obtém ErrorHandlerService
  ErrorHandlerService get errorHandler {
    _ensureInitialized();
    return Get.find<ErrorHandlerService>();
  }

  /// Obtém AgrihurbiStateManager
  AgrihurbiStateManager get stateManager {
    _ensureInitialized();
    return Get.find<AgrihurbiStateManager>();
  }

  /// Obtém UnifiedDataService
  UnifiedDataService get dataService {
    _ensureInitialized();
    return Get.find<UnifiedDataService>();
  }

  // ========== MÉTODOS DE CONVENIÊNCIA ==========

  /// Executa operação com tratamento de erro centralizado
  Future<T?> executeOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    String? customErrorMessage,
    int maxRetries = 1,
  }) async {
    _ensureInitialized();
    
    if (maxRetries > 1) {
      return await errorHandler.executeWithRetry(
        operation,
        maxRetries: maxRetries,
        operationName: operationName,
      );
    } else {
      return await errorHandler.handleAsyncOperation(
        operation,
        operationName: operationName,
        customErrorMessage: customErrorMessage,
      );
    }
  }

  /// Atualiza dados com tratamento de erro
  Future<void> refreshData({
    bool bovinos = false,
    bool equinos = false,
    bool pluviometros = false,
    bool measurements = false,
    bool all = false,
  }) async {
    _ensureInitialized();

    if (all) {
      await executeOperation(
        () => dataService.syncAllData(),
        operationName: 'refreshAllData',
        customErrorMessage: 'Erro ao atualizar todos os dados',
      );
      return;
    }

    final operations = <Future>[];
    
    if (bovinos) {
      operations.add(executeOperation(
        () => dataService.refreshBovinos(),
        operationName: 'refreshBovinos',
      ) ?? Future.value());
    }
    
    if (equinos) {
      operations.add(executeOperation(
        () => dataService.refreshEquinos(),
        operationName: 'refreshEquinos',
      ) ?? Future.value());
    }
    
    if (pluviometros) {
      operations.add(executeOperation(
        () => dataService.refreshPluviometros(),
        operationName: 'refreshPluviometros',
      ) ?? Future.value());
    }
    
    if (measurements) {
      operations.add(executeOperation(
        () => dataService.refreshCurrentMeasurements(),
        operationName: 'refreshMeasurements',
      ) ?? Future.value());
    }

    await Future.wait(operations);
  }

  /// Valida operação antes de executar
  Future<bool> validateOperation({
    bool requiresNetwork = true,
    bool requiresAuth = false,
    String? operationName,
  }) async {
    _ensureInitialized();
    
    return await errorHandler.validateOperation(
      requiresNetwork: requiresNetwork,
      requiresAuth: requiresAuth,
      operationName: operationName,
    );
  }

  // ========== CLEANUP ==========

  /// Limpa todos os services (útil para logout ou reset completo)
  Future<void> cleanup() async {
    try {
      debugPrint('🧹 AgrihurbiServiceLocator: Iniciando cleanup dos services...');

      // Limpar dados primeiro
      if (Get.isRegistered<UnifiedDataService>()) {
        dataService.clearAllData();
      }

      // Limpar estado
      if (Get.isRegistered<AgrihurbiStateManager>()) {
        stateManager.clearAllState();
      }

      debugPrint('✅ AgrihurbiServiceLocator: Cleanup concluído');
    } catch (e) {
      debugPrint('❌ AgrihurbiServiceLocator: Erro no cleanup: $e');
    }
  }

  /// Remove todos os services (apenas para testes ou reset completo)
  Future<void> dispose() async {
    try {
      debugPrint('🗑️ AgrihurbiServiceLocator: Removendo todos os services...');

      await cleanup();

      // Remover services do GetX
      if (Get.isRegistered<UnifiedDataService>()) {
        Get.delete<UnifiedDataService>();
      }
      if (Get.isRegistered<AgrihurbiStateManager>()) {
        Get.delete<AgrihurbiStateManager>();
      }
      if (Get.isRegistered<ErrorHandlerService>()) {
        Get.delete<ErrorHandlerService>();
      }

      _isInitialized = false;
      debugPrint('✅ AgrihurbiServiceLocator: Todos os services removidos');
    } catch (e) {
      debugPrint('❌ AgrihurbiServiceLocator: Erro ao remover services: $e');
    }
  }

  // ========== VALIDAÇÕES ==========

  /// Garante que services estão inicializados
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('AgrihurbiServiceLocator não foi inicializado. Chame initializeServices() primeiro.');
    }
  }

  // ========== INFORMAÇÕES DE DEBUG ==========

  /// Obtém informações de debug sobre o estado atual
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _isInitialized,
      'errorHandlerRegistered': Get.isRegistered<ErrorHandlerService>(),
      'stateManagerRegistered': Get.isRegistered<AgrihurbiStateManager>(),
      'dataServiceRegistered': Get.isRegistered<UnifiedDataService>(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Imprime informações de debug
  void printDebugInfo() {
    final info = getDebugInfo();
    debugPrint('🔍 AgrihurbiServiceLocator Debug Info:');
    info.forEach((key, value) {
      debugPrint('   $key: $value');
    });
  }
}

// ========== EXTENSION PARA ACESSO FACILITADO ==========

/// Extension para acessar services de forma mais simples
extension AgrihurbiServiceExtension on GetInterface {
  
  /// Acesso rápido ao service locator
  AgrihurbiServiceLocator get agrihurbi => AgrihurbiServiceLocator.instance;
  
  /// Acesso rápido ao error handler
  ErrorHandlerService get errorHandler => AgrihurbiServiceLocator.instance.errorHandler;
  
  /// Acesso rápido ao state manager
  AgrihurbiStateManager get stateManager => AgrihurbiServiceLocator.instance.stateManager;
  
  /// Acesso rápido ao data service
  UnifiedDataService get dataService => AgrihurbiServiceLocator.instance.dataService;
}
