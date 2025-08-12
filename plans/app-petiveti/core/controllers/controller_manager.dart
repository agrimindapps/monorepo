// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../pages/meupet/animal_cadastro/controllers/animal_form_controller.dart';
import '../../pages/meupet/animal_page/controllers/animal_page_controller.dart';
import '../../pages/meupet/despesas_cadastro/controllers/despesa_form_controller.dart';
import '../../pages/meupet/despesas_page/controllers/despesas_page_controller.dart';
import '../../pages/meupet/lembretes_cadastro/controllers/lembrete_form_controller.dart';
import '../../pages/meupet/lembretes_page/controllers/lembretes_page_controller.dart';
import '../../pages/meupet/medicamentos_page/controllers/medicamentos_page_controller.dart';
import '../../pages/meupet/peso_cadastro/controllers/peso_cadastro_controller.dart';
import '../../pages/meupet/vacina_page/controllers/vacina_page_controller.dart';
import '../error_manager.dart';
import 'performance_monitor.dart';

/// Gerenciador centralizado de controllers com lazy loading
/// Otimiza performance inicial carregando controllers apenas quando necessário
class ControllerManager {
  static ControllerManager? _instance;
  static ControllerManager get instance => _instance ??= ControllerManager._();
  ControllerManager._();

  final Map<String, bool> _controllerStatus = {};
  final Map<String, DateTime> _initializationTimes = {};

  /// Inicializar controllers críticos (sempre carregados no app start)
  Future<void> initializeEagerControllers() async {
    final startTime = DateTime.now();
    final errorManager = ErrorManager.instance;
    final performanceMonitor = PerformanceMonitor.instance;

    debugPrint('🚀 Iniciando controllers críticos...');
    performanceMonitor.startOperation('EagerControllersInitialization');

    try {
      // AuthService e SubscriptionService (já inicializados no mobile_page.dart)
      // Apenas verificamos se estão disponíveis
      
      // AnimalPageController - crítico pois usado na tela principal
      performanceMonitor.startOperation('AnimalPageController');
      await errorManager.executeWithRetry(
        operationName: 'Inicialização AnimalPageController (crítico)',
        operation: () async {
          Get.put(AnimalPageController());
          _controllerStatus['AnimalPageController'] = true;
          debugPrint('✅ AnimalPageController inicializado');
        },
        category: ErrorCategory.initialization,
      );
      performanceMonitor.endOperation('AnimalPageController', success: true);

      final duration = DateTime.now().difference(startTime);
      debugPrint('🎯 Controllers críticos inicializados em ${duration.inMilliseconds}ms');
      performanceMonitor.endOperation('EagerControllersInitialization', success: true);
      
    } catch (e, stackTrace) {
      performanceMonitor.endOperation('EagerControllersInitialization', success: false, error: e.toString());
      
      final error = AppErrorInfo.critical(
        message: 'Falha na inicialização de controllers críticos',
        details: 'Controllers essenciais falharam: $e',
        category: ErrorCategory.initialization,
        originalError: e,
        stackTrace: stackTrace,
      );
      
      errorManager.reportError(error);
      rethrow;
    }
  }

  /// Configurar controllers para lazy loading (carregados sob demanda)
  void setupLazyControllers() {
    debugPrint('💤 Configurando lazy loading para controllers não críticos...');

    // Configurar lazy loading para cada controller
    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: AnimalFormController');
      _markControllerAsInitialized('AnimalFormController');
      // Usar initialize method se disponível
      AnimalFormController.initialize();
      return Get.find<AnimalFormController>();
    }, tag: 'AnimalFormController');

    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: LembretesPageController');
      _markControllerAsInitialized('LembretesPageController');
      LembretesPageController.initialize();
      return Get.find<LembretesPageController>();
    }, tag: 'LembretesPageController');

    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: LembreteFormController');
      _markControllerAsInitialized('LembreteFormController');
      LembreteFormController.initialize();
      return Get.find<LembreteFormController>();
    }, tag: 'LembreteFormController');

    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: DespesasPageController');
      _markControllerAsInitialized('DespesasPageController');
      DespesasPageController.initialize();
      return Get.find<DespesasPageController>();
    }, tag: 'DespesasPageController');

    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: DespesaFormController');
      _markControllerAsInitialized('DespesaFormController');
      DespesaFormController.initialize();
      return Get.find<DespesaFormController>();
    }, tag: 'DespesaFormController');

    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: MedicamentosPageController');
      _markControllerAsInitialized('MedicamentosPageController');
      MedicamentosPageController.initializeController();
      return Get.find<MedicamentosPageController>();
    }, tag: 'MedicamentosPageController');

    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: VacinaPageController');
      _markControllerAsInitialized('VacinaPageController');
      VacinaPageController.initialize();
      return Get.find<VacinaPageController>();
    }, tag: 'VacinaPageController');

    Get.lazyPut(() {
      debugPrint('🔄 Lazy loading: PesoCadastroController');
      _markControllerAsInitialized('PesoCadastroController');
      PesoCadastroController.initialize();
      return Get.find<PesoCadastroController>();
    }, tag: 'PesoCadastroController');

    debugPrint('✅ Lazy loading configurado para ${_getLazyControllerNames().length} controllers');
  }

  /// Verificar se um controller está pronto para uso
  bool isControllerReady(String controllerName) {
    return _controllerStatus[controllerName] ?? false;
  }

  /// Obter controller com lazy loading automático
  T getController<T>() {
    final controllerName = T.toString();
    
    if (!isControllerReady(controllerName)) {
      debugPrint('⚠️ Controller $controllerName não está pronto, será carregado agora');
    }
    
    return Get.find<T>();
  }

  /// Forçar inicialização de um controller específico
  Future<T> initializeController<T>(String controllerName) async {
    if (isControllerReady(controllerName)) {
      debugPrint('✅ Controller $controllerName já está inicializado');
      return Get.find<T>();
    }

    debugPrint('🔄 Forçando inicialização de $controllerName');
    final controller = Get.find<T>(); // Vai disparar o lazy loading
    _markControllerAsInitialized(controllerName);
    
    return controller;
  }

  /// Marcar controller como inicializado
  void _markControllerAsInitialized(String controllerName) {
    _controllerStatus[controllerName] = true;
    _initializationTimes[controllerName] = DateTime.now();
  }

  /// Obter estatísticas de inicialização
  Map<String, dynamic> getInitializationStats() {
    final totalControllers = _getEagerControllerNames().length + _getLazyControllerNames().length;
    final initializedControllers = _controllerStatus.values.where((status) => status).length;
    
    return {
      'totalControllers': totalControllers,
      'initializedControllers': initializedControllers,
      'lazyControllers': _getLazyControllerNames().length,
      'eagerControllers': _getEagerControllerNames().length,
      'initializationTimes': Map.from(_initializationTimes),
      'controllerStatus': Map.from(_controllerStatus),
    };
  }

  /// Imprimir estatísticas de performance
  void printPerformanceStats() {
    final stats = getInitializationStats();
    debugPrint('📊 === ESTATÍSTICAS DE PERFORMANCE ===');
    debugPrint('🔥 Controllers Eager (críticos): ${stats['eagerControllers']}');
    debugPrint('💤 Controllers Lazy (sob demanda): ${stats['lazyControllers']}');
    debugPrint('✅ Controllers inicializados: ${stats['initializedControllers']}/${stats['totalControllers']}');
    
    final initTimes = stats['initializationTimes'] as Map<String, DateTime>;
    if (initTimes.isNotEmpty) {
      debugPrint('⏱️ Tempos de inicialização:');
      initTimes.forEach((name, time) {
        debugPrint('   • $name: ${time.toString()}');
      });
    }
  }

  /// Limpar controllers não utilizados (garbage collection)
  void cleanupUnusedControllers() {
    final lazyControllers = _getLazyControllerNames();
    int removedCount = 0;
    
    for (final controllerName in lazyControllers) {
      if (_controllerStatus[controllerName] == true) {
        try {
          // Verifica se o controller ainda está sendo usado
          // Se não estiver, remove da memória
          if (!Get.isRegistered(
            tag: controllerName
          )) {
            _controllerStatus[controllerName] = false;
            _initializationTimes.remove(controllerName);
            removedCount++;
            debugPrint('🗑️ Controller $controllerName removido da memória');
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao limpar controller $controllerName: $e');
        }
      }
    }
    
    if (removedCount > 0) {
      debugPrint('✅ Cleanup concluído: $removedCount controllers removidos');
    }
  }

  /// Obter nomes dos controllers eager
  List<String> _getEagerControllerNames() {
    return [
      'AuthService',
      'SubscriptionService', 
      'AnimalPageController',
    ];
  }

  /// Obter nomes dos controllers lazy
  List<String> _getLazyControllerNames() {
    return [
      'AnimalFormController',
      'LembretesPageController',
      'LembreteFormController',
      'DespesasPageController',
      'DespesaFormController',
      'MedicamentosPageController',
      'VacinaPageController',
      'PesoCadastroController',
    ];
  }

  /// Resetar estado do manager (útil para testes)
  @visibleForTesting
  void reset() {
    _controllerStatus.clear();
    _initializationTimes.clear();
    debugPrint('🔄 ControllerManager resetado');
  }
}
