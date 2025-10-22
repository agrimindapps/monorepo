import 'package:hive/hive.dart';
import '../utils/diagnostico_logger.dart';

/// Informações de monitoramento de uma box aberta
class _BoxTrackingInfo {
  final String boxName;
  final DateTime openedAt;
  final StackTrace stackTrace;

  _BoxTrackingInfo(this.boxName, this.openedAt, this.stackTrace);

  Duration get openDuration => DateTime.now().difference(openedAt);
}

/// Helper centralizado para gerenciar abertura e fechamento de Hive boxes de forma segura.
/// Garante que boxes sejam sempre fechadas após uso, evitando vazamentos de recursos.
class HiveBoxManager {
  // Private constructor para classe utilitária (apenas métodos estáticos)
  HiveBoxManager._();

  /// Controle de debug/monitoramento
  static bool _monitoringEnabled = false;
  static final Map<String, _BoxTrackingInfo> _openBoxes = {};

  /// Habilita/desabilita monitoramento de boxes abertas
  static void setMonitoringEnabled(bool enabled) {
    _monitoringEnabled = enabled;
    if (enabled) {
      DiagnosticoLogger.info('Monitoramento de boxes Hive habilitado');
    } else {
      DiagnosticoLogger.info('Monitoramento de boxes Hive desabilitado');
    }
  }

  /// Registra abertura de uma box para monitoramento
  static void _trackBoxOpened(String boxName) {
    if (!_monitoringEnabled) return;

    final info = _BoxTrackingInfo(boxName, DateTime.now(), StackTrace.current);
    _openBoxes[boxName] = info;

    DiagnosticoLogger.info(
      'Box aberta: $boxName (total abertas: ${_openBoxes.length})',
    );
  }

  /// Registra fechamento de uma box para monitoramento
  static void _trackBoxClosed(String boxName) {
    if (!_monitoringEnabled) return;

    final info = _openBoxes.remove(boxName);
    if (info != null) {
      final duration = info.openDuration;
      DiagnosticoLogger.info(
        'Box fechada: $boxName (duração: ${duration.inMilliseconds}ms, restantes: ${_openBoxes.length})',
      );
    }
  }

  /// Detecta vazamentos de boxes abertas
  static List<String> detectBoxLeaks() {
    if (!_monitoringEnabled) return [];

    final leakedBoxes = <String>[];
    final now = DateTime.now();

    for (final entry in _openBoxes.entries) {
      final duration = now.difference(entry.value.openedAt);
      // Considera vazamento se box estiver aberta por mais de 5 minutos
      if (duration.inMinutes > 5) {
        leakedBoxes.add(entry.key);
        DiagnosticoLogger.warning(
          'Vazamento detectado: Box ${entry.key} aberta por ${duration.inMinutes} minutos',
        );
      }
    }

    return leakedBoxes;
  }

  /// Relatório completo do estado das boxes
  static Map<String, dynamic> getBoxesReport() {
    final report = <String, dynamic>{
      'monitoring_enabled': _monitoringEnabled,
      'total_open_boxes': _openBoxes.length,
      'open_boxes': <Map<String, dynamic>>[],
      'leaked_boxes': detectBoxLeaks(),
    };

    for (final entry in _openBoxes.entries) {
      report['open_boxes']!.add({
        'name': entry.key,
        'opened_at': entry.value.openedAt.toIso8601String(),
        'duration_ms': entry.value.openDuration.inMilliseconds,
        'stack_trace': entry.value.stackTrace.toString(),
      });
    }

    return report;
  }

  /// Executa operação com uma box garantindo fechamento automático.
  /// Uso: await withBox('boxName', (box) async => box.values.toList());
  static Future<T> withBox<T, B>(
    String boxName,
    Future<T> Function(Box<B> box) operation,
  ) async {
    Box<B>? box;
    try {
      box = await Hive.openBox<B>(boxName);
      _trackBoxOpened(boxName);
      return await operation(box);
    } finally {
      if (box != null) {
        await box.close();
        _trackBoxClosed(boxName);
      }
    }
  }

  /// Executa operação com múltiplas boxes garantindo fechamento automático.
  /// Uso: await withMultipleBoxes({'box1': Type1, 'box2': Type2}, (boxes) async => ...);
  static Future<T> withMultipleBoxes<T>(
    Map<String, Type> boxConfigs,
    Future<T> Function(Map<String, Box<dynamic>> boxes) operation,
  ) async {
    final openedBoxes = <String, Box<dynamic>>{};
    final boxesOpenedByUs = <String>[];

    try {
      // Abrir todas as boxes (ou usar já abertas)
      for (final entry in boxConfigs.entries) {
        final boxName = entry.key;

        // Se box já está aberta, usar instância existente
        if (Hive.isBoxOpen(boxName)) {
          openedBoxes[boxName] = Hive.box<dynamic>(boxName);
        } else {
          // Se não está aberta, abrir e rastrear para fechar depois
          openedBoxes[boxName] = await Hive.openBox(boxName);
          boxesOpenedByUs.add(boxName);
          _trackBoxOpened(boxName);
        }
      }

      return await operation(openedBoxes);
    } finally {
      // Fechar SOMENTE as boxes que ESTE método abriu
      for (final boxName in boxesOpenedByUs.reversed) {
        final box = openedBoxes[boxName];
        if (box != null && box.isOpen) {
          await box.close();
          _trackBoxClosed(boxName);
        }
      }
    }
  }

  /// Executa operação com box existente (se já aberta) ou abre/fecha automaticamente.
  /// Uso: await withBoxSafe('boxName', (box) async => box.values.toList());
  static Future<T> withBoxSafe<T, B>(
    String boxName,
    Future<T> Function(Box<B> box) operation,
  ) async {
    // Tentar usar box já aberta primeiro
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<B>(boxName);
      return await operation(box);
    }

    // Se não estiver aberta, abrir e fechar automaticamente
    return await withBox<T, B>(boxName, operation);
  }

  /// Verifica se uma box está aberta sem abri-la.
  static bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }

  /// Fecha uma box específica se estiver aberta.
  static Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<dynamic>(boxName);
      await box.close();
    }
  }

  /// Fecha múltiplas boxes se estiverem abertas.
  static Future<void> closeBoxes(List<String> boxNames) async {
    for (final boxName in boxNames) {
      await closeBox(boxName);
    }
  }

  /// Força fechamento de boxes vazadas detectadas
  static Future<void> forceCloseLeakedBoxes() async {
    final leakedBoxes = detectBoxLeaks();
    if (leakedBoxes.isNotEmpty) {
      DiagnosticoLogger.warning(
        'Forçando fechamento de ${leakedBoxes.length} boxes vazadas: ${leakedBoxes.join(', ')}',
      );

      for (final boxName in leakedBoxes) {
        try {
          await closeBox(boxName);
          _trackBoxClosed(boxName);
        } catch (e) {
          DiagnosticoLogger.error(
            'Erro ao forçar fechamento da box $boxName',
            e,
          );
        }
      }
    }
  }

  /// Alerta sobre vazamentos de boxes (para uso em debug)
  static void alertBoxLeaks() {
    final leakedBoxes = detectBoxLeaks();
    if (leakedBoxes.isNotEmpty) {
      DiagnosticoLogger.critical(
        'ALERTA: ${leakedBoxes.length} boxes Hive vazadas detectadas: ${leakedBoxes.join(', ')}',
      );
    }
  }
}
