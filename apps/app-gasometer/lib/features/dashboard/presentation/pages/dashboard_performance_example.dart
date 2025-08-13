import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// Exemplo de integração do PerformanceService em uma página do Dashboard
/// 
/// Este exemplo mostra como usar o PerformanceService para:
/// - Rastrear operações específicas
/// - Monitorar métricas em tempo real
/// - Registrar eventos customizados
class DashboardPerformanceExample extends StatefulWidget {
  const DashboardPerformanceExample({super.key});

  @override
  State<DashboardPerformanceExample> createState() => _DashboardPerformanceExampleState();
}

class _DashboardPerformanceExampleState extends State<DashboardPerformanceExample> {
  final _performanceService = PerformanceService();
  
  double _currentFps = 0.0;
  double _memoryUsage = 0.0;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _initializePerformanceMonitoring();
    _loadDashboardData();
  }

  void _initializePerformanceMonitoring() {
    // Monitorar FPS em tempo real
    _performanceService.getFpsStream().listen((fps) {
      if (mounted) {
        setState(() {
          _currentFps = fps;
        });
      }
    });

    // Monitorar memória em tempo real
    _performanceService.getMemoryStream().listen((memory) {
      if (mounted) {
        setState(() {
          _memoryUsage = memory.usagePercentage;
        });
      }
    });

    // Configurar callbacks para alertas
    _performanceService.setPerformanceAlertCallback((alertType, data) {
      _handlePerformanceAlert(alertType, data);
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoadingData = true;
    });

    // Iniciar trace customizado para rastrear tempo de carregamento
    await _performanceService.startTrace('dashboard_data_load', attributes: {
      'screen': 'dashboard',
      'data_type': 'initial_load',
    });

    try {
      // Simular carregamento de dados (substitua pela lógica real)
      await Future.delayed(const Duration(seconds: 2));
      
      // Exemplo de métricas customizadas
      await _performanceService.recordCustomMetric(
        name: 'dashboard_items_loaded',
        value: 10,
        type: MetricType.counter,
        tags: {'screen': 'dashboard'},
      );

    } finally {
      // Parar trace e registrar métricas
      await _performanceService.stopTrace('dashboard_data_load', metrics: {
        'items_count': 10,
        'cache_hit': 1,
      });

      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _performHeavyOperation() async {
    // Medir tempo de operação pesada
    final duration = await _performanceService.measureOperationTime(
      'heavy_computation',
      () async {
        // Simular operação pesada
        await Future.delayed(const Duration(seconds: 1));
        
        // Calcular algo complexo
        for (int i = 0; i < 1000000; i++) {
          // Operação fictícia
        }
      },
      attributes: {'type': 'computation'},
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Operação completada em ${duration.inMilliseconds}ms'),
        ),
      );
    }
  }

  void _handlePerformanceAlert(String alertType, Map<String, dynamic> data) {
    // Tratar alertas de performance
    String message = '';
    
    switch (alertType) {
      case 'low_fps':
        message = 'FPS baixo detectado: ${data['current_fps']?.toStringAsFixed(1)}';
        break;
      case 'high_memory_usage':
        message = 'Uso alto de memória: ${data['current_usage']?.toStringAsFixed(1)}%';
        break;
      case 'high_cpu_usage':
        message = 'Uso alto de CPU: ${data['current_usage']?.toStringAsFixed(1)}%';
        break;
    }

    if (message.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _exportPerformanceReport() async {
    try {
      final report = await _performanceService.getPerformanceReport();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Relatório de Performance'),
            content: SingleChildScrollView(
              child: Text(
                report.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao exportar relatório: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard com Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _exportPerformanceReport,
            tooltip: 'Relatório de Performance',
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicadores de performance em tempo real
          Container(
            color: _currentFps < 30 ? Colors.red.shade100 : Colors.green.shade100,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricCard(
                  'FPS',
                  _currentFps.toStringAsFixed(1),
                  Icons.speed,
                  _currentFps >= 50 ? Colors.green : Colors.orange,
                ),
                _buildMetricCard(
                  'Memória',
                  '${_memoryUsage.toStringAsFixed(1)}%',
                  Icons.memory,
                  _memoryUsage <= 70 ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
          
          // Conteúdo principal
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: ListTile(
                          title: const Text('Executar Operação Pesada'),
                          subtitle: const Text('Teste de performance com trace'),
                          trailing: ElevatedButton(
                            onPressed: _performHeavyOperation,
                            child: const Text('Executar'),
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text('Recarregar Dashboard'),
                          subtitle: const Text('Rastreia tempo de carregamento'),
                          trailing: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadDashboardData,
                          ),
                        ),
                      ),
                      // Adicione mais conteúdo do dashboard aqui
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Não precisamos parar o service pois ele é singleton
    super.dispose();
  }
}