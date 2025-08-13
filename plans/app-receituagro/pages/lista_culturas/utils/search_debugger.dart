// Flutter imports:
import 'package:flutter/foundation.dart';

/// Utilitário para debug e monitoramento de performance de busca
class SearchDebugger {
  static bool _debugMode = kDebugMode;
  static final List<SearchEvent> _events = [];

  static void enableDebug() => _debugMode = true;
  static void disableDebug() => _debugMode = false;

  static void logSearch(
      String searchTerm, int resultsCount, Duration duration) {
    if (!_debugMode) return;

    final event = SearchEvent(
      searchTerm: searchTerm,
      resultsCount: resultsCount,
      duration: duration,
      timestamp: DateTime.now(),
    );

    _events.add(event);

    // Log no console
    debugPrint(
        '🔍 Search: "$searchTerm" -> $resultsCount results in ${duration.inMilliseconds}ms');

    // Manter apenas os últimos 100 eventos
    if (_events.length > 100) {
      _events.removeAt(0);
    }
  }

  static void logDebounce(String searchTerm, Duration debounceTime) {
    if (!_debugMode) return;
    debugPrint(
        '⏱️  Debounce: "$searchTerm" delayed by ${debounceTime.inMilliseconds}ms');
  }

  static void logCancel(String searchTerm) {
    if (!_debugMode) return;
  }

  static List<SearchEvent> getEvents() => List.unmodifiable(_events);

  static void clearEvents() => _events.clear();

  static void printStats() {
    if (!_debugMode || _events.isEmpty) return;

    final avgDuration =
        _events.map((e) => e.duration.inMilliseconds).reduce((a, b) => a + b) /
            _events.length;

    final maxDuration = _events
        .map((e) => e.duration.inMilliseconds)
        .reduce((a, b) => a > b ? a : b);

    // Statistics calculated but not displayed
  }
}

class SearchEvent {
  final String searchTerm;
  final int resultsCount;
  final Duration duration;
  final DateTime timestamp;

  const SearchEvent({
    required this.searchTerm,
    required this.resultsCount,
    required this.duration,
    required this.timestamp,
  });
}
