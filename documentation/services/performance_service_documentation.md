# Documentação do `PerformanceService`

O `PerformanceService` é uma implementação robusta para monitoramento de performance em aplicações Flutter, integrando-se com Firebase Performance e Firebase Analytics para coleta e análise de métricas. Ele oferece funcionalidades para rastrear FPS, uso de memória, uso de CPU, métricas de inicialização do aplicativo, traces customizados e métricas personalizadas.

## 1. Propósito

O principal objetivo do `PerformanceService` é fornecer uma ferramenta centralizada para:
- Monitorar o desempenho da aplicação em tempo real.
- Identificar gargalos e problemas de performance (ex: baixo FPS, alto uso de memória/CPU).
- Coletar dados de performance para análise e otimização.
- Integrar-se com serviços de monitoramento externos como Firebase Performance e Analytics.
- Disparar alertas quando os thresholds de performance são excedidos.

## 2. Inicialização

O `PerformanceService` utiliza o padrão Singleton, garantindo que haja apenas uma instância do serviço em toda a aplicação.

```dart
import 'package:core/src/infrastructure/services/performance_service.dart';

final performanceService = PerformanceService();
```

## 3. Configuração

O serviço pode ser configurado através das classes `PerformanceConfig` e `PerformanceThresholds`.

### `PerformanceConfig`

Define as configurações gerais para o monitoramento.

```dart
class PerformanceConfig {
  final bool enableFpsMonitoring;
  final bool enableMemoryMonitoring;
  final bool enableCpuMonitoring;
  final bool enableFirebaseIntegration;
  final Duration monitoringInterval; // Intervalo para coleta de memória/CPU
  final Duration fpsMonitoringInterval; // Intervalo para cálculo de FPS
}
```

### `PerformanceThresholds`

Define os limites para as métricas de performance, que podem disparar alertas.

```dart
class PerformanceThresholds {
  final double minFps;
  final double maxMemoryUsagePercent;
  final double maxCpuUsage;
}
```

Exemplo de uso:

```dart
await performanceService.setPerformanceThresholds(
  const PerformanceThresholds(
    minFps: 45.0,
    maxMemoryUsagePercent: 80.0,
    maxCpuUsage: 70.0,
  ),
);
```

## 4. Funcionalidades Principais

### 4.1. Controle de Monitoramento

- **`startPerformanceTracking({PerformanceConfig? config})`**: Inicia o monitoramento de performance. Pode receber uma configuração opcional.
- **`stopPerformanceTracking()`**: Para todos os monitoramentos e fecha os streams.
- **`pausePerformanceTracking()`**: Pausa o monitoramento (timers são cancelados).
- **`resumePerformanceTracking()`**: Retoma o monitoramento.
- **`getMonitoringState()`**: Retorna o estado atual do monitoramento (`running`, `paused`, `stopped`).

Exemplo:

```dart
// Iniciar monitoramento com configurações padrão
await performanceService.startPerformanceTracking();

// Iniciar monitoramento com configurações personalizadas
await performanceService.startPerformanceTracking(
  config: const PerformanceConfig(
    enableFpsMonitoring: true,
    enableMemoryMonitoring: true,
    enableCpuMonitoring: false,
    enableFirebaseIntegration: true,
    monitoringInterval: Duration(seconds: 5),
    fpsMonitoringInterval: Duration(seconds: 1),
  ),
);

// Parar monitoramento
await performanceService.stopPerformanceTracking();
```

### 4.2. Rastreamento de FPS

- **`getFpsStream()`**: Retorna um `Stream<double>` para receber atualizações de FPS em tempo real.
- **`getCurrentFps()`**: Retorna o FPS atual.
- **`getFpsMetrics({Duration? period})`**: Retorna métricas detalhadas de FPS (médio, min, max, quedas de frame, jank frames).
- **`isFpsHealthy()`**: Verifica se o FPS está dentro dos limites saudáveis.

Exemplo:

```dart
performanceService.getFpsStream().listen((fps) {
  print('FPS Atual: $fps');
});

final currentFps = await performanceService.getCurrentFps();
print('FPS agora: $currentFps');

final fpsMetrics = await performanceService.getFpsMetrics();
print('Métricas de FPS: ${fpsMetrics.averageFps} (média)');
```

### 4.3. Rastreamento de Memória

- **`getMemoryStream()`**: Retorna um `Stream<MemoryUsage>` para receber atualizações de uso de memória em tempo real.
- **`getMemoryUsage()`**: Retorna o uso de memória atual.
- **`isMemoryHealthy()`**: Verifica se o uso de memória está dentro dos limites saudáveis.
- **`forceGarbageCollection()`**: Tenta forçar a coleta de lixo (apenas em modo debug e com efeito limitado no Flutter).

Exemplo:

```dart
performanceService.getMemoryStream().listen((memory) {
  print('Uso de Memória: ${memory.usedMemoryMB.toStringAsFixed(2)} MB');
});

final memory = await performanceService.getMemoryUsage();
print('Memória Usada: ${memory.usagePercentage.toStringAsFixed(2)}%');
```

### 4.4. Rastreamento de CPU

- **`getCpuStream()`**: Retorna um `Stream<double>` para receber atualizações de uso de CPU em tempo real.
- **`getCpuUsage()`**: Retorna o uso de CPU atual.
- **`isCpuHealthy()`**: Verifica se o uso de CPU está dentro dos limites saudáveis.

Exemplo:

```dart
performanceService.getCpuStream().listen((cpu) {
  print('Uso de CPU: ${cpu.toStringAsFixed(2)}%');
});

final cpu = await performanceService.getCpuUsage();
print('CPU Usada: $cpu%');
```

### 4.5. Métricas de Inicialização

- **`markAppStarted()`**: Marca o início da aplicação.
- **`markFirstFrame()`**: Marca o momento em que o primeiro frame é renderizado.
- **`markAppInteractive()`**: Marca o momento em que a aplicação se torna interativa.
- **`getStartupMetrics()`**: Retorna métricas de tempo de inicialização (cold start, time to first frame, time to interactive).

Exemplo:

```dart
// No início do main()
await performanceService.markAppStarted();

// No primeiro frame (ex: WidgetsBinding.instance.addPostFrameCallback)
await performanceService.markFirstFrame();

// Quando a UI estiver pronta para interação
await performanceService.markAppInteractive();

final startupMetrics = await performanceService.getStartupMetrics();
print('Tempo para primeiro frame: ${startupMetrics.firstFrameTime.inMilliseconds}ms');
```

### 4.6. Traces Customizados

Permite medir o tempo de execução de operações específicas.

- **`startTrace(String traceName, {Map<String, String>? attributes})`**: Inicia um trace com um nome e atributos opcionais.
- **`stopTrace(String traceName, {Map<String, double>? metrics})`**: Para um trace e registra métricas opcionais. Retorna um `TraceResult`.
- **`measureOperationTime<T>(String operationName, Future<T> Function() operation, {Map<String, String>? attributes})`**: Uma função utilitária para medir o tempo de uma operação assíncrona.
- **`getActiveTraces()`**: Retorna uma lista dos nomes dos traces ativos.

Exemplo:

```dart
// Medir uma operação
await performanceService.measureOperationTime(
  'load_user_data',
  () async {
    // Simula uma operação demorada
    await Future.delayed(const Duration(seconds: 2));
  },
  attributes: {'user_id': '123', 'data_source': 'api'},
);

// Ou manualmente
await performanceService.startTrace('process_image', attributes: {'image_id': 'abc'});
// ... código para processar imagem ...
await performanceService.stopTrace('process_image', metrics: {'image_size_kb': 1024.0});
```

### 4.7. Métricas Customizadas

Permite registrar métricas personalizadas que podem ser enviadas para o Firebase Analytics.

- **`recordCustomMetric({required String name, required double value, required MetricType type, String? unit, Map<String, String>? tags})`**: Registra uma métrica genérica.
- **`incrementCounter(String name, {Map<String, String>? tags})`**: Incrementa um contador.
- **`recordGauge(String name, double value, {Map<String, String>? tags})`**: Registra um valor de gauge.
- **`recordTiming(String name, Duration duration, {Map<String, String>? tags})`**: Registra um tempo de duração.

Exemplo:

```dart
await performanceService.incrementCounter('button_click_count', tags: {'button_name': 'submit'});
await performanceService.recordGauge('current_users_online', 150.0);
await performanceService.recordTiming('api_call_duration', const Duration(milliseconds: 500), tags: {'endpoint': '/users'});
```

### 4.8. Métricas Consolidadas

O serviço coleta métricas de performance consolidadas em intervalos regulares.

- **`getCurrentMetrics()`**: Retorna as métricas atuais de FPS, memória e CPU.
- **`getPerformanceHistory({DateTime? since, int? limit, Duration? period})`**: Retorna um histórico de métricas de performance.

Exemplo:

```dart
final currentMetrics = await performanceService.getCurrentMetrics();
print('Métricas Atuais: FPS=${currentMetrics.fps}, Memória=${currentMetrics.memoryUsage.usagePercentage}%');

final history = await performanceService.getPerformanceHistory(period: const Duration(minutes: 5));
print('Histórico de performance nos últimos 5 minutos: ${history.length} entradas');
```

### 4.9. Alertas

O serviço pode emitir alertas quando os thresholds de performance são violados.

- **`getPerformanceAlertsStream()`**: Retorna um `Stream<Map<String, dynamic>>` para receber alertas.
- **`setPerformanceAlertCallback(void Function(String alertType, Map<String, dynamic> data) callback)`**: Define um callback para ser executado quando um alerta é emitido.
- **`checkPerformanceIssues()`**: Retorna uma lista de strings descrevendo os problemas de performance atuais.

Exemplo:

```dart
performanceService.getPerformanceAlertsStream().listen((alert) {
  print('ALERTA: ${alert['type']} - Dados: ${alert['data']}');
});

performanceService.setPerformanceAlertCallback((alertType, data) {
  print('Callback de Alerta: $alertType - $data');
});

final issues = await performanceService.checkPerformanceIssues();
if (issues.isNotEmpty) {
  print('Problemas de Performance Encontrados:');
  for (var issue in issues) {
    print('- $issue');
  }
}
```

### 4.10. Relatórios e Exportação de Dados

- **`getPerformanceReport({DateTime? startTime, DateTime? endTime})`**: Gera um relatório consolidado de performance.
- **`exportPerformanceData({required String format, DateTime? startTime, DateTime? endTime})`**: Exporta os dados de performance em um formato específico (atualmente apenas 'json' é suportado).

Exemplo:

```dart
final report = await performanceService.getPerformanceReport();
print('Relatório de Performance: $report');

final jsonData = await performanceService.exportPerformanceData(format: 'json');
print('Dados Exportados (JSON): $jsonData');
```

### 4.11. Integração com Firebase

O serviço se integra com Firebase Performance para traces e Firebase Analytics para métricas customizadas.

- **`enableFirebaseSync({Duration? interval})`**: Habilita a integração com Firebase.
- **`disableFirebaseSync()`**: Desabilita a integração com Firebase.
- **`syncWithFirebase()`**: (Método de interface, a sincronização ocorre em tempo real via traces).

### 4.12. Limpeza de Dados Antigos

- **`clearOldPerformanceData({Duration? olderThan})`**: Limpa dados de performance antigos do histórico.

Exemplo:

```dart
// Limpar dados com mais de 30 dias
await performanceService.clearOldPerformanceData(olderThan: const Duration(days: 30));
```

### 4.13. Informações de Performance do Dispositivo

- **`getDevicePerformanceInfo()`**: Retorna informações detalhadas sobre o dispositivo.

Exemplo:

```dart
final deviceInfo = await performanceService.getDevicePerformanceInfo();
print('Informações do Dispositivo: $deviceInfo');
```

### 4.14. Suporte a Funcionalidades

- **`getFeatureSupport()`**: Retorna um mapa indicando quais funcionalidades de monitoramento são suportadas na plataforma atual.

Exemplo:

```dart
final featureSupport = await performanceService.getFeatureSupport();
print('Suporte a Funcionalidades: $featureSupport');
```

### 4.15. Resetar Métricas

- **`resetAllMetrics()`**: Limpa todos os dados de métricas coletados (FPS, memória, histórico, traces).

Exemplo:

```dart
await performanceService.resetAllMetrics();
print('Todas as métricas foram resetadas.');
```
