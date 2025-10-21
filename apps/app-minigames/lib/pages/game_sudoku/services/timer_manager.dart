// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Serviço avançado de gerenciamento de timers para o jogo Sudoku
///
/// Esta implementação demonstra uma versão mais robusta e segura para
/// gerenciar timers, prevenir memory leaks e melhorar a confiabilidade.
///
/// Características:
/// - Múltiplos timers com identificadores únicos
/// - Cancelamento automático em caso de erros
/// - Logging detalhado para debug
/// - Prevenção de race conditions
/// - Cleanup automático de recursos
class SudokuTimerManager {
  final Map<String, Timer> _activeTimers = {};
  final Map<String, int> _timerIds = {};
  bool _isDisposed = false;
  int _nextTimerId = 0;

  /// Verifica se o manager foi disposed
  bool get isDisposed => _isDisposed;

  /// Retorna quantos timers estão ativos
  int get activeTimersCount => _activeTimers.length;

  /// Cria um timer periódico com identificador único
  Timer createPeriodicTimer({
    required String name,
    required Duration interval,
    required void Function(Timer) callback,
  }) {
    _ensureNotDisposed();

    // Cancela timer existente com mesmo nome
    cancelTimer(name);

    // Cria wrapper seguro para o callback
    final timerId = _nextTimerId++;
    _timerIds[name] = timerId;

    safeCallback(Timer timer) {
      // Verifica se o timer ainda é válido
      if (_isDisposed || _timerIds[name] != timerId) {
        timer.cancel();
        return;
      }

      try {
        callback(timer);
      } catch (e) {
        debugPrint('Erro no callback do timer $name: $e');
        // Em caso de erro, cancela o timer para evitar repetição
        cancelTimer(name);
      }
    }

    final timer = Timer.periodic(interval, safeCallback);
    _activeTimers[name] = timer;

    debugPrint('Timer $name criado (ID: $timerId)');
    return timer;
  }

  /// Cria um timer único (não periódico)
  Timer createTimer({
    required String name,
    required Duration delay,
    required VoidCallback callback,
  }) {
    _ensureNotDisposed();

    // Cancela timer existente com mesmo nome
    cancelTimer(name);

    final timerId = _nextTimerId++;
    _timerIds[name] = timerId;

    safeCallback() {
      // Verifica se o timer ainda é válido
      if (_isDisposed || _timerIds[name] != timerId) {
        return;
      }

      // Remove o timer dos ativos (já foi executado)
      _activeTimers.remove(name);
      _timerIds.remove(name);

      try {
        callback();
      } catch (e) {
        debugPrint('Erro no callback do timer $name: $e');
      }
    }

    final timer = Timer(delay, safeCallback);
    _activeTimers[name] = timer;

    debugPrint('Timer único $name criado (ID: $timerId)');
    return timer;
  }

  /// Cancela um timer específico
  bool cancelTimer(String name) {
    final timer = _activeTimers.remove(name);
    _timerIds.remove(name);

    if (timer != null) {
      timer.cancel();
      debugPrint('Timer $name cancelado');
      return true;
    }
    return false;
  }

  /// Verifica se um timer está ativo
  bool isTimerActive(String name) {
    return _activeTimers.containsKey(name) && _activeTimers[name]!.isActive;
  }

  /// Cancela todos os timers
  void cancelAllTimers() {
    debugPrint('Cancelando ${_activeTimers.length} timers ativos');

    for (final entry in _activeTimers.entries) {
      try {
        entry.value.cancel();
        debugPrint('Timer ${entry.key} cancelado');
      } catch (e) {
        debugPrint('Erro ao cancelar timer ${entry.key}: $e');
      }
    }

    _activeTimers.clear();
    _timerIds.clear();
  }

  /// Pausa todos os timers (implementação futura)
  void pauseAllTimers() {
    // Por enquanto apenas cancela, mas poderia ser implementado
    // um sistema de pausa/resume mais sofisticado
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
  }

  /// Disposa o manager e todos os recursos
  void dispose() {
    if (_isDisposed) return;

    debugPrint('Disposing SudokuTimerManager');
    cancelAllTimers();
    _isDisposed = true;
  }

  /// Verifica se o manager não foi disposed
  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError(
          'SudokuTimerManager foi disposed e não pode criar novos timers');
    }
  }

  /// Informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'isDisposed': _isDisposed,
      'activeTimersCount': _activeTimers.length,
      'activeTimers': _activeTimers.keys.toList(),
      'nextTimerId': _nextTimerId,
    };
  }

  @override
  String toString() {
    return 'SudokuTimerManager(active: ${_activeTimers.length}, disposed: $_isDisposed)';
  }
}
