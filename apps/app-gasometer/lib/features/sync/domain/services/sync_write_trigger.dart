import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

/// Dispara sincronizações assim que o usuário realiza operações de escrita.
///
/// Evita excesso de requisições aplicando debounce curto e usa prioridade alta
/// para que o BackgroundSyncManager processe rapidamente as mudanças locais.

class SyncWriteTrigger {
  SyncWriteTrigger();

  static const String _serviceId = 'gasometer';
  static const Duration _defaultDebounce = Duration(seconds: 2);

  Timer? _debounceTimer;
  DateTime? _lastTriggerAt;

  /// Agenda um sync em background aplicando debounce para consolidar múltiplas
  /// operações consecutivas (ex: vários inserts em sequência).
  void scheduleSync({Duration debounce = _defaultDebounce}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      _debounceTimer = null;
      unawaited(_triggerInternal(force: false));
    });
  }

  /// Dispara o sync imediatamente (sem debounce), útil após operações críticas
  /// como deleções ou importações em lote.
  Future<void> triggerImmediate({bool force = true}) async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await _triggerInternal(force: force);
  }

  Future<void> _triggerInternal({required bool force}) async {
    try {
      await BackgroundSyncManager.instance.triggerSync(
        _serviceId,
        priority: SyncPriority.high,
        force: force,
      );
      _lastTriggerAt = DateTime.now();
      developer.log(
        '🔁 Sync trigger dispatched (force=$force)',
        name: 'SyncWriteTrigger',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to trigger sync: $e',
        name: 'SyncWriteTrigger',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  DateTime? get lastTriggerAt => _lastTriggerAt;
}
