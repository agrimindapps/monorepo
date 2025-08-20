// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/bottom_bar_controller.dart';
import '../core/controllers/controller_manager.dart';
import '../core/controllers/performance_monitor.dart';
import '../core/error_manager.dart';
import '../core/interfaces/i_auth_service.dart';
import '../core/interfaces/i_subscription_service.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../widgets/bottombar_widget.dart';
import 'calc/calculadoras_page.dart';
import 'dashboard/views/dashboard_page.dart';
import 'home_vet_page.dart';
import 'medicamentos/lista_medicamento/views/lista_medicamento_page.dart';
import 'meupet/animal_cadastro/controllers/animal_form_controller.dart';
import 'meupet/animal_page/controllers/animal_page_controller.dart';
import 'meupet/despesas_cadastro/controllers/despesa_form_controller.dart';
import 'meupet/despesas_page/controllers/despesas_page_controller.dart';
import 'meupet/lembretes_cadastro/controllers/lembrete_form_controller.dart';
import 'meupet/lembretes_page/controllers/lembretes_page_controller.dart';
import 'meupet/medicamentos_page/controllers/medicamentos_page_controller.dart';
import 'meupet/peso_cadastro/controllers/peso_cadastro_controller.dart';
import 'meupet/vacina_page/controllers/vacina_page_controller.dart';
import 'options_page.dart';
import 'racas/racas_seletor/views/racas_seletor_page.dart';

class MobilePageMain extends StatefulWidget {
  const MobilePageMain({super.key});

  @override
  State<MobilePageMain> createState() => _MobilePageMainState();
}

class _MobilePageMainState extends State<MobilePageMain> {
  final PageController _pageControllerMobile = PageController();
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    
    // Inicializar monitor de performance
    PerformanceMonitor.instance.initialize();
    
    // Inicializa o BottomBarController
    final bottomBarController = Get.put(BottomBarController());
    bottomBarController.setPageController(_pageControllerMobile);
    _initializationFuture = _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    final errorManager = ErrorManager.instance;

    try {
      // Serviços críticos (falha impede funcionamento)
      await errorManager.executeWithRetry(
        operationName: 'Inicialização AuthService',
        operation: () async {
          final authService = AuthService();
          Get.put<IAuthService>(authService);
          Get.put(authService); // Manter referência direta para compatibilidade
        },
        category: ErrorCategory.initialization,
      );

      await errorManager.executeWithRetry(
        operationName: 'Inicialização SubscriptionService',
        operation: () async {
          final subscriptionService = SubscriptionService();
          Get.put<ISubscriptionService>(subscriptionService);
          Get.put(subscriptionService); // Manter referência direta para compatibilidade
        },
        category: ErrorCategory.initialization,
      );

      // Usar ControllerManager para inicialização otimizada
      await _initializeWithControllerManager();

    } catch (e, stackTrace) {
      final error = AppErrorInfo.critical(
        message: 'Falha na inicialização de serviços críticos',
        details: 'Serviços de autenticação ou assinatura falharam',
        category: ErrorCategory.initialization,
        originalError: e,
        stackTrace: stackTrace,
      );
      
      errorManager.reportError(error);
      rethrow; // Relançar para mostrar tela de erro
    }
  }

  Future<void> _initializeWithControllerManager() async {
    final controllerManager = ControllerManager.instance;
    
    debugPrint('🚀 Iniciando inicialização otimizada com ControllerManager...');
    final startTime = DateTime.now();
    
    try {
      // 1. Inicializar controllers críticos
      await controllerManager.initializeEagerControllers();
      
      // 2. Configurar lazy loading para controllers não críticos
      controllerManager.setupLazyControllers();
      
      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ Inicialização otimizada concluída em ${duration.inMilliseconds}ms');
      
      // 3. Imprimir estatísticas de performance
      if (kDebugMode) {
        controllerManager.printPerformanceStats();
        PerformanceMonitor.instance.printReport();
      }
      
    } catch (e) {
      debugPrint('❌ Erro na inicialização otimizada: $e');
      rethrow;
    }
  }

  @Deprecated('Substituído pelo ControllerManager')
  Future<void> _initializeNonCriticalControllers(ErrorManager errorManager) async {
    final controllers = [
      () async => Get.put(AnimalPageController()),
      () => AnimalFormController.initialize(),
      () => LembretesPageController.initialize(),
      () => LembreteFormController.initialize(),
      () => DespesasPageController.initialize(),
      () => DespesaFormController.initialize(),
      () => MedicamentosPageController.initializeController(),
      () => VacinaPageController.initialize(),
      () => PesoCadastroController.initialize(),
    ];

    final controllerNames = [
      'AnimalPageController',
      'AnimalFormController',
      'LembretesPageController',
      'LembreteFormController',
      'DespesasPageController',
      'DespesaFormController',
      'MedicamentosPageController',
      'VacinaPageController',
      'PesoCadastroController',
    ];

    for (int i = 0; i < controllers.length; i++) {
      await errorManager.executeWithFallback(
        operationName: 'Inicialização ${controllerNames[i]}',
        operation: controllers[i],
        fallback: () {
          debugPrint('⚠️ ${controllerNames[i]} não pôde ser inicializado - continuando sem ele');
        },
        category: ErrorCategory.initialization,
        context: {'controller': controllerNames[i]},
      );
    }
  }

  Widget _buildPageMobile(int index) {
    switch (index) {
      case 0:
        return const RacasSeletorPage();
      case 1:
        return const ListaMedicamentoPage();
      case 2:
        return const HomeVetPage();
      case 3:
        return const CalculadorasPage();
      case 4:
        return const DashboardPage();
      case 5:
        return const OptionsVetPage();
      default:
        return const RacasSeletorPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erro ao inicializar: ${snapshot.error}')),
          );
        }

        return Column(
          children: [
            Expanded(
              child: PageView.custom(
                controller: _pageControllerMobile,
                onPageChanged: (index) {
                  final bottomBarController = Get.find<BottomBarController>();
                  bottomBarController.setSelectedIndex(index);
                },
                physics: const NeverScrollableScrollPhysics(),
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return KeyedSubtree(
                      key: ValueKey(index),
                      child: _buildPageMobile(index),
                    );
                  },
                  childCount: 6,
                ),
              ),
            ),
            const VetBottomBarWidget(),
          ],
        );
      },
    );
  }
}
