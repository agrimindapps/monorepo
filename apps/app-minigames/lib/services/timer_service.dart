// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Tipos de timer suportados pelo TimerService
enum TimerType {
  gameTimer, // Timer principal do jogo
  matchTimer, // Timer para processamento de matches
  debounceTimer, // Timer para debounce de ações
  animationTimer, // Timer para animações
}

/// Service robusto para gerenciamento de timers
///
/// Este service previne vazamentos de memória garantindo que todos os
/// timers sejam adequadamente cancelados e gerenciados durante o ciclo
/// de vida dos widgets.
class TimerService {
  final Map<TimerType, Timer> _activeTimers = {};
  final Map<TimerType, int> _timerIds = {};
  bool _isDisposed = false;
  int _nextTimerId = 0;

  /// Verifica se o service foi disposed
  bool get isDisposed => _isDisposed;

  /// Retorna a quantidade de timers ativos
  int get activeTimersCount => _activeTimers.length;

  /// Cria um timer periódico para o tipo especificado
  ///
  /// Cancela automaticamente qualquer timer existente do mesmo tipo
  /// antes de criar o novo.
  Timer createPeriodicTimer({
    required TimerType type,
    required Duration interval,
    required void Function(Timer) callback,
  }) {
    if (_isDisposed) {
      throw StateError(
          'TimerService foi disposed e não pode criar novos timers');
    }

    // Cancela timer existente do mesmo tipo
    cancelTimer(type);

    // Cria wrapper seguro para o callback
    final timerId = _nextTimerId++;
    _timerIds[type] = timerId;

    safeCallback(Timer timer) {
      // Verifica se o timer ainda é válido e o service não foi disposed
      if (_isDisposed || _timerIds[type] != timerId) {
        timer.cancel();
        return;
      }

      try {
        callback(timer);
      } catch (e) {
        // Log do erro sem quebrar o timer
        if (kDebugMode) {
          debugPrint('Erro no callback do timer $type: $e');
        }
        // Em caso de erro, cancela o timer para evitar repetição do erro
        cancelTimer(type);
      }
    }

    // Cria e registra o timer
    final timer = Timer.periodic(interval, safeCallback);
    _activeTimers[type] = timer;

    return timer;
  }

  /// Cria um timer único (não periódico) para o tipo especificado
  Timer createTimer({
    required TimerType type,
    required Duration delay,
    required VoidCallback callback,
  }) {
    if (_isDisposed) {
      throw StateError(
          'TimerService foi disposed e não pode criar novos timers');
    }

    // Cancela timer existente do mesmo tipo
    cancelTimer(type);

    // Cria wrapper seguro para o callback
    final timerId = _nextTimerId++;
    _timerIds[type] = timerId;

    safeCallback() {
      // Verifica se o timer ainda é válido e o service não foi disposed
      if (_isDisposed || _timerIds[type] != timerId) {
        return;
      }

      // Remove o timer dos ativos (já foi executado)
      _activeTimers.remove(type);
      _timerIds.remove(type);

      try {
        callback();
      } catch (e) {
        // Log do erro
        if (kDebugMode) {
          debugPrint('Erro no callback do timer $type: $e');
        }
      }
    }

    // Cria e registra o timer
    final timer = Timer(delay, safeCallback);
    _activeTimers[type] = timer;

    return timer;
  }

  /// Cancela um timer específico
  bool cancelTimer(TimerType type) {
    final timer = _activeTimers.remove(type);
    _timerIds.remove(type);

    if (timer != null) {
      timer.cancel();

      // Log para debug de race conditions
      if (kDebugMode) {
        debugPrint('Timer $type cancelado');
      }

      return true;
    }
    return false;
  }

  /// Cancela múltiplos timers atomicamente para prevenir race conditions
  void cancelTimers(List<TimerType> types) {
    for (final type in types) {
      cancelTimer(type);
    }
  }

  /// Cancela todos os timers relacionados ao jogo (gameTimer e matchTimer)
  /// para prevenir condições de corrida durante fim de jogo
  void cancelGameRelatedTimers() {
    cancelTimers([TimerType.gameTimer, TimerType.matchTimer]);
  }

  /// Verifica se um timer específico está ativo
  bool isTimerActive(TimerType type) {
    return _activeTimers.containsKey(type) && _activeTimers[type]!.isActive;
  }

  /// Pausa todos os timers (cancela mas mantém configuração para restart)
  void pauseAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    // Não remove dos mapas para permitir restart
  }

  /// Cancela todos os timers ativos
  void cancelAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _timerIds.clear();
  }

  /// Dispose do service - cancela todos os timers e marca como disposed
  void dispose() {
    if (_isDisposed) return;

    cancelAllTimers();
    _isDisposed = true;

    if (kDebugMode) {
      debugPrint('TimerService disposed');
    }
  }

  /// Informações de debug sobre timers ativos
  Map<String, dynamic> getDebugInfo() {
    return {
      'isDisposed': _isDisposed,
      'activeTimersCount': _activeTimers.length,
      'activeTimers': _activeTimers.keys.map((k) => k.toString()).toList(),
      'nextTimerId': _nextTimerId,
    };
  }

  @override
  String toString() {
    return 'TimerService(active: ${_activeTimers.length}, disposed: $_isDisposed)';
  }
}
