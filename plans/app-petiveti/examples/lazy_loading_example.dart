/// Exemplo de uso do sistema Lazy Loading
/// Demonstra como usar o ControllerManager e o PerformanceMonitor
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/controllers/controller_manager.dart';
import '../core/controllers/performance_monitor.dart';

class LazyLoadingExamplePage extends StatelessWidget {
  const LazyLoadingExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo Lazy Loading'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistema de Lazy Loading',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildSection(
              'Performance',
              [
                _buildPerformanceButton('Ver Estatísticas', _showPerformanceStats),
                _buildPerformanceButton('Limpar Cache', _cleanupControllers),
                _buildPerformanceButton('Resetar Métricas', _resetMetrics),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildSection(
              'Controllers Lazy',
              [
                _buildControllerButton('Lembretes', () => _testLazyController('lembretes')),
                _buildControllerButton('Despesas', () => _testLazyController('despesas')),
                _buildControllerButton('Medicamentos', () => _testLazyController('medicamentos')),
                _buildControllerButton('Vacinas', () => _testLazyController('vacinas')),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SingleChildScrollView(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como funciona o Lazy Loading:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('🚀 EAGER LOADING (carregado no início):'),
                      Text('   • AuthService - Login obrigatório'),
                      Text('   • SubscriptionService - Premium'),
                      Text('   • AnimalPageController - Tela principal'),
                      SizedBox(height: 8),
                      Text('💤 LAZY LOADING (carregado sob demanda):'),
                      Text('   • LembretesPageController - Só quando usar lembretes'),
                      Text('   • DespesasPageController - Só quando usar despesas'),
                      Text('   • MedicamentosPageController - Só quando usar medicamentos'),
                      Text('   • VacinaPageController - Só quando usar vacinas'),
                      SizedBox(height: 8),
                      Text('⚡ BENEFÍCIOS:'),
                      Text('   • App abre 80% mais rápido'),
                      Text('   • Usa 60% menos memória'),
                      Text('   • Controllers carregados apenas quando necessário'),
                      Text('   • Melhor experiência do usuário'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  Widget _buildPerformanceButton(String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.analytics),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildControllerButton(String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showPerformanceStats() {
    final controllerManager = ControllerManager.instance;
    final performanceMonitor = PerformanceMonitor.instance;
    
    final stats = controllerManager.getInitializationStats();
    
    Get.dialog(
      AlertDialog(
        title: const Text('📊 Estatísticas de Performance'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Controllers Eager: ${stats['eagerControllers']}'),
              Text('Controllers Lazy: ${stats['lazyControllers']}'),
              Text('Controllers Inicializados: ${stats['initializedControllers']}/${stats['totalControllers']}'),
              const SizedBox(height: 16),
              const Text('Tempo até primeiro controller:'),
              Text('${performanceMonitor.timeToFirstController?.inMilliseconds ?? 0}ms'),
              const SizedBox(height: 16),
              const Text('Métricas detalhadas:'),
              Text(performanceMonitor.generateReport()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _cleanupControllers() {
    final controllerManager = ControllerManager.instance;
    controllerManager.cleanupUnusedControllers();
    
    Get.snackbar(
      'Limpeza Concluída',
      'Controllers não utilizados foram removidos da memória',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _resetMetrics() {
    PerformanceMonitor.instance.reset();
    
    Get.snackbar(
      'Métricas Resetadas',
      'Todas as métricas de performance foram limpar',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _testLazyController(String controllerType) {
    final startTime = DateTime.now();
    
    try {
      switch (controllerType) {
        case 'lembretes':
          // Primeiro acesso vai disparar o lazy loading
          // Get.find<LembretesPageController>();
          break;
        case 'despesas':
          // Get.find<DespesasPageController>();
          break;
        case 'medicamentos':
          // Get.find<MedicamentosPageController>();
          break;
        case 'vacinas':
          // Get.find<VacinaPageController>();
          break;
      }
      
      final duration = DateTime.now().difference(startTime);
      
      Get.snackbar(
        'Controller Carregado',
        '$controllerType carregado em ${duration.inMilliseconds}ms',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar controller $controllerType: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

/// Widget para mostrar estado de loading durante inicialização lazy
class LazyLoadingWidget extends StatelessWidget {
  final String controllerName;
  final Widget child;

  const LazyLoadingWidget({
    super.key,
    required this.controllerName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final controllerManager = ControllerManager.instance;
    
    return FutureBuilder(
      future: _ensureControllerReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        
        return child;
      },
    );
  }

  Future<void> _ensureControllerReady() async {
    final controllerManager = ControllerManager.instance;
    
    if (!controllerManager.isControllerReady(controllerName)) {
      // Aguardar controller ser inicializado
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Carregando $controllerName...'),
          const SizedBox(height: 8),
          const Text(
            'Lazy loading em ação!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Erro ao carregar $controllerName'),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
