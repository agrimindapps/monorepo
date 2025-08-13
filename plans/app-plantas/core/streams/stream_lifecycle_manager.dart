// Dart imports:
import 'dart:async';

import 'package:logging/logging.dart';

import '../../repository/espaco_repository.dart';
import '../../repository/planta_config_repository.dart';
// Project imports:
// Removed unused import
import '../../repository/planta_repository.dart';
import '../../repository/tarefa_repository.dart';
import '../../services/domain/plants/planta_care_query_service.dart';
import '../../services/domain/tasks/simple_task_service.dart';

/// Gerenciador global de lifecycle para streams e recursos
/// Facilita o cleanup de toda a aplicação quando necessário
class StreamLifecycleManager {
  static StreamLifecycleManager? _instance;
  static StreamLifecycleManager get instance =>
      _instance ??= StreamLifecycleManager._();

  StreamLifecycleManager._();

  bool _isDisposed = false;

  /// Verificar se foi disposed
  bool get isDisposed => _isDisposed;

  /// Dispose de todos os repositories e services
  Future<void> disposeAll() async {
    if (_isDisposed) return;

    _isDisposed = true;

    Logger('StreamLifecycleManager').info('Iniciando cleanup global de streams e recursos...');

    try {
      // Dispose dos services primeiro
      await PlantaCareQueryService.instance.dispose();
      await SimpleTaskService.instance.dispose();

      // Dispose dos repositories
      await PlantaRepository.instance.dispose();
      await EspacoRepository.instance.dispose();
      await TarefaRepository.instance.dispose();
      await PlantaConfigRepository.instance.dispose();

      Logger('StreamLifecycleManager').info('Cleanup global concluído com sucesso');
    } catch (e) {
      Logger('StreamLifecycleManager').warning('Erro durante cleanup global', e);
      rethrow;
    }
  }

  /// Dispose parcial de um conjunto específico de recursos
  Future<void> disposeRepositories() async {
    if (_isDisposed) return;

    try {
      await PlantaRepository.instance.dispose();
      await EspacoRepository.instance.dispose();
      await TarefaRepository.instance.dispose();
      await PlantaConfigRepository.instance.dispose();
    } catch (e) {
      Logger('StreamLifecycleManager').warning('Erro durante cleanup de repositories', e);
      rethrow;
    }
  }

  /// Dispose parcial dos services
  Future<void> disposeServices() async {
    if (_isDisposed) return;

    try {
      await PlantaCareQueryService.instance.dispose();
      await SimpleTaskService.instance.dispose();
    } catch (e) {
      Logger('StreamLifecycleManager').warning('Erro durante cleanup de services', e);
      rethrow;
    }
  }

  /// Obter estatísticas de debug de todos os recursos
  Map<String, dynamic> getGlobalDebugInfo() {
    if (_isDisposed) {
      return {
        'status': 'disposed',
        'message': 'StreamLifecycleManager foi disposed'
      };
    }

    return {
      'streamLifecycleManager': {
        'isDisposed': _isDisposed,
      },
      'repositories': {
        'planta': PlantaRepository.instance.streamDebugInfo,
        'espaco': EspacoRepository.instance.streamDebugInfo,
        'tarefa': TarefaRepository.instance.streamDebugInfo,
      },
      'services': {
        'plantaCareQuery': PlantaCareQueryService.instance.debugInfo,
      },
      'summary': {
        'totalActiveStreams': _getTotalActiveStreams(),
        'hasMemoryLeaks': _hasMemoryLeaks(),
      }
    };
  }

  /// Calcular total de streams ativas
  int _getTotalActiveStreams() {
    try {
      final plantaStreams = PlantaRepository
              .instance.streamDebugInfo['activeSubscriptions'] as int? ??
          0;
      final espacoStreams = EspacoRepository
              .instance.streamDebugInfo['activeSubscriptions'] as int? ??
          0;
      final tarefaStreams = TarefaRepository
              .instance.streamDebugInfo['activeSubscriptions'] as int? ??
          0;
      final careQueryStreams = PlantaCareQueryService
              .instance.debugInfo['activeSubscriptions'] as int? ??
          0;

      return plantaStreams + espacoStreams + tarefaStreams + careQueryStreams;
    } catch (e) {
      return -1; // Indica erro na coleta
    }
  }

  /// Verificar se há possíveis vazamentos
  bool _hasMemoryLeaks() {
    try {
      final totalStreams = _getTotalActiveStreams();
      // Considerar memory leak se houver mais de 50 streams ativas
      // (threshold ajustável baseado no uso real da aplicação)
      return totalStreams > 50;
    } catch (e) {
      return false; // Em caso de erro, assumir que não há leaks
    }
  }

  /// Executar diagnóstico completo de memória
  Future<Map<String, dynamic>> performMemoryDiagnostic() async {
    final startTime = DateTime.now();

    final diagnosticInfo = {
      'timestamp': startTime.toIso8601String(),
      'diagnosticVersion': '1.0.0',
      'globalInfo': getGlobalDebugInfo(),
      'memoryAnalysis': {
        'totalActiveStreams': _getTotalActiveStreams(),
        'hasMemoryLeaks': _hasMemoryLeaks(),
        'recommendedAction': _getRecommendedAction(),
      }
    };

    final endTime = DateTime.now();
    diagnosticInfo['executionTimeMs'] =
        endTime.difference(startTime).inMilliseconds;

    return diagnosticInfo;
  }

  /// Obter ação recomendada baseada no diagnóstico
  String _getRecommendedAction() {
    final totalStreams = _getTotalActiveStreams();

    if (totalStreams == -1) {
      return 'ERRO: Não foi possível coletar informações dos streams';
    } else if (totalStreams == 0) {
      return 'OK: Nenhum stream ativo detectado';
    } else if (totalStreams <= 10) {
      return 'OK: Número normal de streams ativas ($totalStreams)';
    } else if (totalStreams <= 30) {
      return 'ATENÇÃO: Muitos streams ativas ($totalStreams) - monitorar de perto';
    } else if (totalStreams <= 50) {
      return 'ALERTA: Alto número de streams ativas ($totalStreams) - considerar cleanup';
    } else {
      return 'CRÍTICO: Possível memory leak detectado ($totalStreams streams) - executar dispose imediato';
    }
  }

  /// Resetar o estado (para testes)
  void reset() {
    _isDisposed = false;
  }
}
