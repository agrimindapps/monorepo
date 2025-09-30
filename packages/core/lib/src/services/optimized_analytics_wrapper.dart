import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/repositories/i_analytics_repository.dart';

/// Wrapper otimizado para analytics que:
/// - Agrupa eventos similares
/// - Debounce de eventos repetitivos
/// - Batch logging para melhor performance
/// - Reduz custos de analytics
class OptimizedAnalyticsWrapper {
  final IAnalyticsRepository _analytics;

  /// Debounce timer para cada tipo de evento
  final Map<String, Timer> _debounceTimers = {};

  /// Buffer de eventos para batch processing
  final List<_AnalyticsEvent> _eventBuffer = [];

  /// Timer para flush periódico do buffer
  Timer? _flushTimer;

  /// Configurações
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _flushInterval = Duration(seconds: 10);
  static const int _maxBufferSize = 20;

  /// Eventos críticos que não devem ser agrupados
  static const Set<String> _criticalEvents = {
    'purchase_completed',
    'subscription_started',
    'subscription_cancelled',
    'payment_failed',
  };

  OptimizedAnalyticsWrapper(this._analytics) {
    _startPeriodicFlush();
  }

  /// Loga evento com otimização automática
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
    bool forceCritical = false,
  }) async {
    // Eventos críticos são enviados imediatamente
    if (forceCritical || _isCriticalEvent(eventName)) {
      await _analytics.logEvent(eventName, parameters: parameters);
      return;
    }

    // Debounce para eventos repetitivos
    if (_shouldDebounce(eventName)) {
      _debounceEvent(eventName, parameters);
      return;
    }

    // Adicionar ao buffer para batch processing
    _addToBuffer(eventName, parameters);
  }

  /// Verifica se é evento crítico
  bool _isCriticalEvent(String eventName) {
    return _criticalEvents.any((critical) => eventName.contains(critical));
  }

  /// Verifica se deve fazer debounce
  bool _shouldDebounce(String eventName) {
    // Eventos de sincronização e navegação devem ter debounce
    return eventName.contains('sync') ||
        eventName.contains('page_view') ||
        eventName.contains('scroll') ||
        eventName.contains('tap');
  }

  /// Aplica debounce em evento
  void _debounceEvent(String eventName, Map<String, dynamic>? parameters) {
    // Cancela timer anterior se existir
    _debounceTimers[eventName]?.cancel();

    // Cria novo timer
    _debounceTimers[eventName] = Timer(_debounceDuration, () {
      _addToBuffer(eventName, parameters);
      _debounceTimers.remove(eventName);
    });
  }

  /// Adiciona evento ao buffer
  void _addToBuffer(String eventName, Map<String, dynamic>? parameters) {
    _eventBuffer.add(_AnalyticsEvent(
      name: eventName,
      parameters: parameters,
      timestamp: DateTime.now(),
    ));

    // Flush automático se buffer estiver cheio
    if (_eventBuffer.length >= _maxBufferSize) {
      _flushBuffer();
    }
  }

  /// Inicia flush periódico
  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(_flushInterval, (_) {
      if (_eventBuffer.isNotEmpty) {
        _flushBuffer();
      }
    });
  }

  /// Envia todos eventos do buffer
  Future<void> _flushBuffer() async {
    if (_eventBuffer.isEmpty) return;

    final eventsToSend = List<_AnalyticsEvent>.from(_eventBuffer);
    _eventBuffer.clear();

    // Agrupa eventos similares
    final groupedEvents = _groupSimilarEvents(eventsToSend);

    // Envia eventos agrupados
    for (final event in groupedEvents) {
      try {
        await _analytics.logEvent(
          event.name,
          parameters: event.parameters,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OptimizedAnalytics] Error logging event: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[OptimizedAnalytics] Flushed ${groupedEvents.length} events (from ${eventsToSend.length} original)');
    }
  }

  /// Agrupa eventos similares para reduzir volume
  List<_AnalyticsEvent> _groupSimilarEvents(List<_AnalyticsEvent> events) {
    final Map<String, List<_AnalyticsEvent>> eventsByName = {};

    // Agrupa por nome
    for (final event in events) {
      eventsByName.putIfAbsent(event.name, () => []).add(event);
    }

    final groupedEvents = <_AnalyticsEvent>[];

    // Para cada grupo de eventos
    for (final entry in eventsByName.entries) {
      final eventName = entry.key;
      final eventList = entry.value;

      if (eventList.length == 1) {
        // Evento único, adiciona normalmente
        groupedEvents.add(eventList.first);
      } else {
        // Múltiplos eventos do mesmo tipo, agrupa
        groupedEvents.add(_AnalyticsEvent(
          name: eventName,
          parameters: {
            ...?eventList.last.parameters,
            'event_count': eventList.length,
            'first_timestamp': eventList.first.timestamp.toIso8601String(),
            'last_timestamp': eventList.last.timestamp.toIso8601String(),
            'is_aggregated': true,
          },
          timestamp: eventList.last.timestamp,
        ));
      }
    }

    return groupedEvents;
  }

  /// Força flush imediato de todos eventos pendentes
  Future<void> flush() async {
    // Cancela todos debounce timers e adiciona ao buffer
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    await _flushBuffer();
  }

  /// Limpa recursos
  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;

    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    _eventBuffer.clear();
  }
}

/// Classe interna para representar um evento
class _AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;

  const _AnalyticsEvent({
    required this.name,
    this.parameters,
    required this.timestamp,
  });
}