import 'dart:async';
import 'hive_box_manager.dart';
import '../utils/diagnostico_logger.dart';

/// Serviço para monitoramento contínuo de vazamentos de Hive boxes
class HiveLeakMonitor {
  static Timer? _monitorTimer;
  static bool _isMonitoring = false;
  static const Duration _checkInterval = Duration(minutes: 2);

  /// Inicia monitoramento automático de vazamentos
  static void startMonitoring() {
    if (_isMonitoring) {
      DiagnosticoLogger.info('Monitoramento de vazamentos já está ativo');
      return;
    }

    HiveBoxManager.setMonitoringEnabled(true);
    _isMonitoring = true;

    DiagnosticoLogger.info(
      'Monitoramento automático de vazamentos de boxes iniciado',
    );

    _monitorTimer = Timer.periodic(_checkInterval, (timer) {
      _performLeakCheck();
    });
  }

  /// Para monitoramento automático
  static void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;
    DiagnosticoLogger.info('Monitoramento automático de vazamentos parado');
  }

  /// Executa verificação manual de vazamentos
  static void checkForLeaks() {
    _performLeakCheck();
  }

  /// Verificação interna de vazamentos
  static void _performLeakCheck() {
    try {
      final leakedBoxes = HiveBoxManager.detectBoxLeaks();

      if (leakedBoxes.isNotEmpty) {
        HiveBoxManager.alertBoxLeaks();

        // Tentar correção automática para vazamentos pequenos
        if (leakedBoxes.length <= 3) {
          DiagnosticoLogger.info(
            'Tentando correção automática de vazamentos...',
          );
          HiveBoxManager.forceCloseLeakedBoxes();
        } else {
          DiagnosticoLogger.critical(
            'Muitos vazamentos detectados (${leakedBoxes.length}). Intervenção manual necessária.',
          );
        }
      }
    } catch (e, stackTrace) {
      DiagnosticoLogger.error(
        'Erro durante verificação de vazamentos',
        e,
        stackTrace,
      );
    }
  }

  /// Obtém status do monitoramento
  static Map<String, dynamic> getMonitoringStatus() {
    return {
      'is_monitoring': _isMonitoring,
      'check_interval_minutes': _checkInterval.inMinutes,
      'boxes_report': HiveBoxManager.getBoxesReport(),
    };
  }

  /// Limpa estado do monitoramento (para testes)
  static void reset() {
    stopMonitoring();
    // Note: Não podemos limpar o _openBoxes diretamente pois é privado
    // Isso é intencional para manter isolamento
  }
}
