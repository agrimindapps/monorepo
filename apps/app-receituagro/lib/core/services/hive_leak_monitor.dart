import 'dart:async';
// REMOVED (P0.1): Old HiveBoxManager implementation deleted - monitoring features not available in new implementation
// import '../utils/hive_box_manager.dart';
import '../utils/diagnostico_logger.dart';

/// Serviço para monitoramento contínuo de vazamentos de Hive boxes
/// ⚠️ TEMPORARILY DISABLED: Monitoring features depend on old HiveBoxManager implementation
/// TODO: Reimplement monitoring using IHiveManager from Core
class HiveLeakMonitor {
  static Timer? _monitorTimer;
  static bool _isMonitoring = false;
  static const Duration _checkInterval = Duration(minutes: 2);

  /// Inicia monitoramento automático de vazamentos
  static void startMonitoring() {
    // DISABLED (P0.1): Monitoring features temporarily disabled
    DiagnosticoLogger.info(
      'Box leak monitoring temporarily disabled (P0 fixes)',
    );
    return;

    // if (_isMonitoring) {
    //   DiagnosticoLogger.info('Monitoramento de vazamentos já está ativo');
    //   return;
    // }
    //
    // HiveBoxManager.setMonitoringEnabled(true);
    // _isMonitoring = true;
    //
    // DiagnosticoLogger.info(
    //   'Monitoramento automático de vazamentos de boxes iniciado',
    // );
    //
    // _monitorTimer = Timer.periodic(_checkInterval, (timer) {
    //   _performLeakCheck();
    // });
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
    // DISABLED (P0.1): Monitoring features temporarily disabled
    return;

    // try {
    //   final leakedBoxes = HiveBoxManager.detectBoxLeaks();
    //
    //   if (leakedBoxes.isNotEmpty) {
    //     HiveBoxManager.alertBoxLeaks();
    //
    //     // Tentar correção automática para vazamentos pequenos
    //     if (leakedBoxes.length <= 3) {
    //       DiagnosticoLogger.info(
    //         'Tentando correção automática de vazamentos...',
    //       );
    //       HiveBoxManager.forceCloseLeakedBoxes();
    //     } else {
    //       DiagnosticoLogger.critical(
    //         'Muitos vazamentos detectados (${leakedBoxes.length}). Intervenção manual necessária.',
    //       );
    //     }
    //   }
    // } catch (e, stackTrace) {
    //   DiagnosticoLogger.error(
    //     'Erro durante verificação de vazamentos',
    //     e,
    //     stackTrace,
    //   );
    // }
  }

  /// Obtém status do monitoramento
  static Map<String, dynamic> getMonitoringStatus() {
    // DISABLED (P0.1): Monitoring features temporarily disabled
    return {
      'is_monitoring': false,
      'check_interval_minutes': _checkInterval.inMinutes,
      'status': 'disabled',
      'reason': 'P0 fixes - monitoring features temporarily unavailable',
    };
  }

  /// Limpa estado do monitoramento (para testes)
  static void reset() {
    stopMonitoring();
    // Note: Não podemos limpar o _openBoxes diretamente pois é privado
    // Isso é intencional para manter isolamento
  }
}
