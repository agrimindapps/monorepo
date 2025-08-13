// EXEMPLO DE USO DO PERFORMANCE SERVICE
// Este arquivo é apenas para demonstração - remova após implementar nos apps

import 'package:flutter/material.dart';
import 'core.dart';

class PerformanceMonitorExample extends StatefulWidget {
  const PerformanceMonitorExample({super.key});

  @override
  State<PerformanceMonitorExample> createState() => _PerformanceMonitorExampleState();
}

class _PerformanceMonitorExampleState extends State<PerformanceMonitorExample> {
  final PerformanceService _performanceService = PerformanceService();
  PerformanceMetrics? _currentMetrics;
  double _currentFps = 0.0;
  MemoryUsage? _currentMemory;

  @override
  void initState() {
    super.initState();
    _initializePerformanceMonitoring();
  }

  Future<void> _initializePerformanceMonitoring() async {
    // 1. Configurar thresholds personalizados
    await _performanceService.setPerformanceThresholds(
      const PerformanceThresholds(
        maxMemoryUsagePercent: 70.0,
        minFps: 45.0,
        maxCpuUsage: 60.0,
        maxStartupTime: Duration(seconds: 3),
      ),
    );

    // 2. Configurar callback para alertas
    await _performanceService.setPerformanceAlertCallback(
      (alertType, data) {
        debugPrint('🚨 Performance Alert: $alertType - $data');
        
        // Aqui você pode mostrar notificações ou tomar ações
        if (alertType == 'low_fps') {
          _showPerformanceAlert('FPS baixo detectado: ${data['current_fps']}');
        } else if (alertType == 'high_memory_usage') {
          _showPerformanceAlert('Uso de memória alto: ${data['current_usage']}%');
        }
      },
    );

    // 3. Iniciar monitoramento
    await _performanceService.startPerformanceTracking(
      config: const PerformanceConfig(
        enableFpsMonitoring: true,
        enableMemoryMonitoring: true,
        enableCpuMonitoring: true,
        monitoringInterval: Duration(seconds: 2),
        fpsMonitoringInterval: Duration(milliseconds: 500),
        enableFirebaseIntegration: true,
      ),
    );

    // 4. Escutar streams de dados
    _setupPerformanceStreams();

    // 5. Marcar marcos importantes
    await _performanceService.markAppStarted();
    await _performanceService.markFirstFrame();
    await _performanceService.markAppInteractive();
  }

  void _setupPerformanceStreams() {
    // Stream de FPS
    _performanceService.getFpsStream().listen((fps) {
      setState(() {
        _currentFps = fps;
      });
    });

    // Stream de Memória
    _performanceService.getMemoryStream().listen((memory) {
      setState(() {
        _currentMemory = memory;
      });
    });

    // Stream de Alertas
    _performanceService.getPerformanceAlertsStream().listen((alert) {
      debugPrint('📊 Performance Alert: ${alert['type']}');
    });
  }

  void _showPerformanceAlert(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Exemplo de medição de operação
  Future<void> _measureExpensiveOperation() async {
    await _performanceService.measureOperationTime(
      'expensive_operation',
      () async {
        // Simular operação custosa
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Exemplo: processamento de imagens, chamadas de API, etc.
        final list = List.generate(100000, (i) => i * i);
        list.reduce((a, b) => a + b);
      },
      attributes: {
        'operation_type': 'cpu_intensive',
        'data_size': '100k_items',
      },
    );
  }

  // Exemplo de trace customizado
  Future<void> _performCustomTrace() async {
    await _performanceService.startTrace(
      'custom_user_action',
      attributes: {
        'action_type': 'button_click',
        'screen': 'performance_example',
      },
    );

    // Simular ação do usuário
    await Future.delayed(const Duration(milliseconds: 800));

    await _performanceService.stopTrace(
      'custom_user_action',
      metrics: {
        'items_processed': 42.0,
        'cache_hits': 15.0,
      },
    );
  }

  Future<void> _updateCurrentMetrics() async {
    final metrics = await _performanceService.getCurrentMetrics();
    setState(() {
      _currentMetrics = metrics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitor'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de FPS
            _buildPerformanceCard(
              title: 'FPS Monitor',
              icon: Icons.speed,
              child: Column(
                children: [
                  Text(
                    '${_currentFps.toStringAsFixed(1)} FPS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _currentFps >= 45 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  LinearProgressIndicator(
                    value: (_currentFps / 60).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      _currentFps >= 45 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Card de Memória
            _buildPerformanceCard(
              title: 'Memory Usage',
              icon: Icons.memory,
              child: _currentMemory != null
                  ? Column(
                      children: [
                        Text(
                          '${_currentMemory!.usagePercentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: _currentMemory!.usagePercentage <= 70 
                                ? Colors.green 
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${_currentMemory!.usedMemoryMB.toStringAsFixed(0)} MB usado'),
                        LinearProgressIndicator(
                          value: _currentMemory!.usagePercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            _currentMemory!.usagePercentage <= 70 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
            
            const SizedBox(height: 16),
            
            // Métricas Atuais
            _buildPerformanceCard(
              title: 'Current Metrics',
              icon: Icons.analytics,
              child: _currentMetrics != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FPS: ${_currentMetrics!.fps.toStringAsFixed(1)}'),
                        Text('CPU: ${_currentMetrics!.cpuUsage.toStringAsFixed(1)}%'),
                        Text('Timestamp: ${_currentMetrics!.timestamp.toString().substring(11, 19)}'),
                        if (_currentMetrics!.frameDrops != null)
                          Text('Frame Drops: ${_currentMetrics!.frameDrops}'),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _updateCurrentMetrics,
                      child: const Text('Load Current Metrics'),
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Botões de Ação
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _measureExpensiveOperation,
                  icon: const Icon(Icons.timer),
                  label: const Text('Measure Operation'),
                ),
                ElevatedButton.icon(
                  onPressed: _performCustomTrace,
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Custom Trace'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _performanceService.incrementCounter(
                      'button_clicks',
                      tags: {'screen': 'performance_example'},
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Increment Counter'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _performanceService.recordGauge(
                      'user_engagement_score',
                      85.5,
                      tags: {'session_type': 'active'},
                    );
                  },
                  icon: const Icon(Icons.gauge),
                  label: const Text('Record Gauge'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Informações adicionais
            FutureBuilder<Map<String, dynamic>>(
              future: _performanceService.getPerformanceReport(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final report = snapshot.data!;
                  return _buildPerformanceCard(
                    title: 'Performance Report',
                    icon: Icons.assessment,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Health Status:'),
                        Text('• FPS: ${report['health_status']['fps_healthy'] ? '✅' : '❌'}'),
                        Text('• Memory: ${report['health_status']['memory_healthy'] ? '✅' : '❌'}'),
                        Text('• CPU: ${report['health_status']['cpu_healthy'] ? '✅' : '❌'}'),
                        const SizedBox(height: 8),
                        Text('Active Traces: ${report['active_traces']}'),
                        Text('Completed Traces: ${report['completed_traces']}'),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Opcional: parar monitoramento quando não precisar mais
    _performanceService.stopPerformanceTracking();
    super.dispose();
  }
}

// EXEMPLO DE USO EM UM APP REAL:

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const MyHomePage(),
      // Inicializar performance monitoring no início do app
      builder: (context, child) {
        // Configurar performance monitoring globalmente
        _setupGlobalPerformanceMonitoring();
        return child!;
      },
    );
  }
  
  void _setupGlobalPerformanceMonitoring() {
    final performance = PerformanceService();
    
    // Configuração mínima para produção
    performance.startPerformanceTracking(
      config: const PerformanceConfig(
        enableFpsMonitoring: false,        // Desabilitar FPS em produção
        enableMemoryMonitoring: true,      // Monitorar memória
        enableCpuMonitoring: false,        // CPU pode ser custoso
        enableFirebaseIntegration: true,   // Enviar para Firebase
        monitoringInterval: Duration(minutes: 1), // Intervalo maior em produção
      ),
    );
    
    // Configurar thresholds conservadores
    performance.setPerformanceThresholds(
      const PerformanceThresholds(
        maxMemoryUsagePercent: 80.0,
        minFps: 30.0,
        maxCpuUsage: 80.0,
      ),
    );
    
    // Configurar alertas silenciosos (apenas logs)
    performance.setPerformanceAlertCallback((type, data) {
      debugPrint('Performance Alert in production: $type - $data');
      // Enviar para seu sistema de monitoramento (Crashlytics, etc.)
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PerformanceService _performance = PerformanceService();

  @override
  void initState() {
    super.initState();
    // Marcar que a tela principal carregou
    _performance.markAppInteractive();
  }

  Future<void> _onExpensiveButtonPressed() async {
    // Medir performance de operações importantes
    await _performance.measureOperationTime(
      'expensive_calculation',
      () async {
        // Sua operação custosa aqui
        await _doExpensiveCalculation();
      },
    );
  }

  Future<void> _doExpensiveCalculation() async {
    // Exemplo de operação custosa
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _onExpensiveButtonPressed,
              child: const Text('Expensive Operation'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PerformanceMonitorExample(),
                  ),
                );
              },
              child: const Text('View Performance Monitor'),
            ),
          ],
        ),
      ),
    );
  }
}