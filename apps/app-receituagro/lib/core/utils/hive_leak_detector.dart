import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Registro de abertura/fechamento de uma box
class BoxLifecycleEvent {
  final String boxName;
  final DateTime timestamp;
  final BoxEventType eventType;
  final StackTrace? stackTrace;

  const BoxLifecycleEvent({
    required this.boxName,
    required this.timestamp,
    required this.eventType,
    this.stackTrace,
  });

  /// Duração desde que o evento ocorreu até agora
  Duration get ageInMinutes => DateTime.now().difference(timestamp);

  @override
  String toString() {
    return 'BoxLifecycleEvent{box: $boxName, type: $eventType, '
        'timestamp: $timestamp, age: ${ageInMinutes.inMinutes}min}';
  }
}

/// Tipo de evento de lifecycle de uma box
enum BoxEventType {
  opened,
  closed,
}

/// Relatório de memory leaks detectados
class LeakReport {
  /// Boxes abertas há mais tempo que o threshold
  final List<BoxLifecycleEvent> suspectedLeaks;

  /// Total de boxes atualmente abertas
  final int totalOpenBoxes;

  /// Tempo máximo que uma box está aberta (em minutos)
  final int maxOpenTimeMinutes;

  /// Indica se foram detectados memory leaks
  bool get hasLeaks => suspectedLeaks.isNotEmpty;

  const LeakReport({
    required this.suspectedLeaks,
    required this.totalOpenBoxes,
    required this.maxOpenTimeMinutes,
  });

  /// Cria um relatório vazio (sem leaks)
  factory LeakReport.empty() {
    return const LeakReport(
      suspectedLeaks: [],
      totalOpenBoxes: 0,
      maxOpenTimeMinutes: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasLeaks': hasLeaks,
      'suspectedLeaks': suspectedLeaks.length,
      'totalOpenBoxes': totalOpenBoxes,
      'maxOpenTimeMinutes': maxOpenTimeMinutes,
      'leakedBoxes': suspectedLeaks.map((e) => e.boxName).toList(),
    };
  }

  @override
  String toString() {
    return 'LeakReport{hasLeaks: $hasLeaks, suspected: ${suspectedLeaks.length}, '
        'totalOpen: $totalOpenBoxes, maxOpenTime: ${maxOpenTimeMinutes}min}';
  }
}

/// Detector de memory leaks em Hive boxes
///
/// Monitora abertura/fechamento de boxes e detecta possíveis vazamentos
/// de memória quando boxes permanecem abertas por muito tempo.
///
/// Uso:
/// ```dart
/// // Registrar abertura
/// HiveLeakDetector.instance.registerBoxOpened('my_box');
///
/// // Registrar fechamento
/// HiveLeakDetector.instance.registerBoxClosed('my_box');
///
/// // Verificar leaks
/// final report = HiveLeakDetector.instance.checkForLeaks();
/// if (report.hasLeaks) {
///   print('LEAK DETECTED: ${report.suspectedLeaks}');
/// }
/// ```
class HiveLeakDetector {
  static HiveLeakDetector? _instance;

  /// Singleton instance
  static HiveLeakDetector get instance => _instance ??= HiveLeakDetector._();

  HiveLeakDetector._();

  /// Mapa de boxes atualmente abertas (boxName -> evento de abertura)
  final Map<String, BoxLifecycleEvent> _openBoxes = {};

  /// Histórico completo de eventos (limitado aos últimos N eventos)
  final List<BoxLifecycleEvent> _eventHistory = [];

  /// Limite de eventos no histórico
  static const int _maxHistorySize = 100;

  /// Threshold padrão para detectar leaks (em minutos)
  static const int _defaultLeakThresholdMinutes = 5;

  /// Registra abertura de uma box
  ///
  /// [boxName] - Nome da box aberta
  /// [captureStackTrace] - Se true, captura stack trace (debug only)
  void registerBoxOpened(String boxName, {bool captureStackTrace = false}) {
    final event = BoxLifecycleEvent(
      boxName: boxName,
      timestamp: DateTime.now(),
      eventType: BoxEventType.opened,
      stackTrace: captureStackTrace && kDebugMode ? StackTrace.current : null,
    );

    _openBoxes[boxName] = event;
    _addToHistory(event);

    if (kDebugMode) {
      developer.log(
        'Box OPENED: $boxName (total open: ${_openBoxes.length})',
        name: 'HiveLeakDetector.registerBoxOpened',
      );
    }
  }

  /// Registra fechamento de uma box
  ///
  /// [boxName] - Nome da box fechada
  void registerBoxClosed(String boxName) {
    final openEvent = _openBoxes.remove(boxName);

    final closeEvent = BoxLifecycleEvent(
      boxName: boxName,
      timestamp: DateTime.now(),
      eventType: BoxEventType.closed,
    );

    _addToHistory(closeEvent);

    if (kDebugMode) {
      if (openEvent != null) {
        final openDuration = closeEvent.timestamp.difference(openEvent.timestamp);
        developer.log(
          'Box CLOSED: $boxName (was open for ${openDuration.inSeconds}s, '
          'total open: ${_openBoxes.length})',
          name: 'HiveLeakDetector.registerBoxClosed',
        );
      } else {
        developer.log(
          'Box CLOSED: $boxName (was not tracked as open, '
          'total open: ${_openBoxes.length})',
          name: 'HiveLeakDetector.registerBoxClosed',
          level: 800, // Warning - box wasn't registered as open
        );
      }
    }
  }

  /// Verifica se há boxes abertas há mais tempo que o threshold
  ///
  /// [thresholdMinutes] - Tempo máximo permitido (padrão: 5 minutos)
  ///
  /// Retorna [LeakReport] com boxes suspeitas de leak
  LeakReport checkForLeaks({int thresholdMinutes = _defaultLeakThresholdMinutes}) {
    final now = DateTime.now();
    final suspectedLeaks = <BoxLifecycleEvent>[];
    int maxOpenTime = 0;

    for (final event in _openBoxes.values) {
      final openDuration = now.difference(event.timestamp);
      final openMinutes = openDuration.inMinutes;

      if (openMinutes > maxOpenTime) {
        maxOpenTime = openMinutes;
      }

      if (openMinutes >= thresholdMinutes) {
        suspectedLeaks.add(event);
      }
    }

    final report = LeakReport(
      suspectedLeaks: suspectedLeaks,
      totalOpenBoxes: _openBoxes.length,
      maxOpenTimeMinutes: maxOpenTime,
    );

    if (report.hasLeaks && kDebugMode) {
      developer.log(
        'LEAK DETECTION: ${report.suspectedLeaks.length} boxes open for >${thresholdMinutes}min',
        name: 'HiveLeakDetector.checkForLeaks',
        level: 900, // Error level
      );

      for (final leak in suspectedLeaks) {
        developer.log(
          'LEAKED BOX: ${leak.boxName} (open for ${leak.ageInMinutes.inMinutes}min)',
          name: 'HiveLeakDetector.checkForLeaks',
          level: 900,
        );

        // Log stack trace se disponível
        if (leak.stackTrace != null) {
          developer.log(
            'Stack trace when box was opened:',
            name: 'HiveLeakDetector.checkForLeaks',
            stackTrace: leak.stackTrace,
            level: 900,
          );
        }
      }
    }

    return report;
  }

  /// Retorna lista de boxes atualmente abertas
  List<String> getOpenBoxes() {
    return _openBoxes.keys.toList();
  }

  /// Retorna total de boxes abertas
  int getOpenBoxCount() {
    return _openBoxes.length;
  }

  /// Retorna informações detalhadas de uma box aberta
  BoxLifecycleEvent? getBoxInfo(String boxName) {
    return _openBoxes[boxName];
  }

  /// Retorna histórico de eventos (últimos N eventos)
  List<BoxLifecycleEvent> getEventHistory({int? limit}) {
    final history = List<BoxLifecycleEvent>.from(_eventHistory.reversed);
    if (limit != null && limit < history.length) {
      return history.sublist(0, limit);
    }
    return history;
  }

  /// Limpa todo o tracking (útil para testes)
  @visibleForTesting
  void reset() {
    _openBoxes.clear();
    _eventHistory.clear();
    developer.log(
      'Leak detector reset',
      name: 'HiveLeakDetector.reset',
    );
  }

  /// Imprime relatório de status atual
  void printStatus() {
    if (!kDebugMode) return;

    final report = checkForLeaks();

    print('\n========== HiveLeakDetector Status ==========');
    print('Open boxes: ${report.totalOpenBoxes}');
    print('Max open time: ${report.maxOpenTimeMinutes} minutes');
    print('Suspected leaks: ${report.suspectedLeaks.length}');

    if (_openBoxes.isNotEmpty) {
      print('\nCurrently open boxes:');
      for (final entry in _openBoxes.entries) {
        final age = entry.value.ageInMinutes.inMinutes;
        print('  - ${entry.key}: open for ${age}min');
      }
    }

    if (report.hasLeaks) {
      print('\n⚠️  SUSPECTED MEMORY LEAKS:');
      for (final leak in report.suspectedLeaks) {
        print('  - ${leak.boxName}: ${leak.ageInMinutes.inMinutes}min');
      }
    }

    print('============================================\n');
  }

  /// Adiciona evento ao histórico (mantém limite de tamanho)
  void _addToHistory(BoxLifecycleEvent event) {
    _eventHistory.add(event);

    // Mantém histórico limitado
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0); // Remove o mais antigo
    }
  }

  /// Retorna estatísticas gerais de uso
  Map<String, dynamic> getStatistics() {
    final totalOpens = _eventHistory
        .where((e) => e.eventType == BoxEventType.opened)
        .length;
    final totalCloses = _eventHistory
        .where((e) => e.eventType == BoxEventType.closed)
        .length;

    return {
      'currentlyOpen': _openBoxes.length,
      'totalOpensInHistory': totalOpens,
      'totalClosesInHistory': totalCloses,
      'historySize': _eventHistory.length,
      'openBoxNames': _openBoxes.keys.toList(),
    };
  }
}
