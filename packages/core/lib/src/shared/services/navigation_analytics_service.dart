import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../infrastructure/services/firebase_analytics_service.dart';
import '../interfaces/i_navigation_extension.dart';

/// Service for tracking navigation analytics and user journey patterns
class NavigationAnalyticsService implements INavigationAnalytics {
  final FirebaseAnalyticsService _firebaseAnalytics;
  final List<NavigationEvent> _sessionEvents = [];
  final Map<String, int> _pageViewCounts = {};
  final Map<String, Duration> _pageTimings = {};
  final Map<String, DateTime> _pageStartTimes = {};

  static const int _maxSessionEvents = 100;

  NavigationAnalyticsService(this._firebaseAnalytics);

  @override
  Future<void> trackPageView(
    String pageType,
    Map<String, dynamic>? parameters,
  ) async {
    try {
      _pageViewCounts[pageType] = (_pageViewCounts[pageType] ?? 0) + 1;
      _pageStartTimes[pageType] = DateTime.now();
      final event = NavigationEvent(
        type: NavigationEventType.pageView,
        pageType: pageType,
        timestamp: DateTime.now(),
        parameters: parameters,
      );

      _addSessionEvent(event);
      final result = await _firebaseAnalytics.logEvent(
        'navigation_page_view',
        parameters: {
          'page_type': pageType,
          'session_page_count': _pageViewCounts[pageType],
          ...?parameters,
        },
      );
      result.fold(
        (error) => debugPrint('Analytics error: ${error.message}'),
        (_) {},
      );

      debugPrint('Tracked page view: $pageType');
    } catch (error) {
      debugPrint('Failed to track page view: $error');
    }
  }

  @override
  Future<void> trackNavigationPath(List<String> path) async {
    try {
      final event = NavigationEvent(
        type: NavigationEventType.navigationPath,
        pageType: path.join(' -> '),
        timestamp: DateTime.now(),
        parameters: {
          'path': path,
          'path_length': path.length,
          'path_string': path.join(' -> '),
        },
      );

      _addSessionEvent(event);

      final result = await _firebaseAnalytics.logEvent(
        'navigation_path',
        parameters: {
          'path': path,
          'path_length': path.length,
          'path_string': path.join(' -> '),
        },
      );
      result.fold(
        (error) => debugPrint('Analytics error: ${error.message}'),
        (_) {},
      );

      debugPrint('Tracked navigation path: ${path.join(' -> ')}');
    } catch (error) {
      debugPrint('Failed to track navigation path: $error');
    }
  }

  @override
  Future<void> trackNavigationPerformance(
    String action,
    Duration duration,
  ) async {
    try {
      final event = NavigationEvent(
        type: NavigationEventType.performance,
        pageType: action,
        timestamp: DateTime.now(),
        parameters: {
          'action': action,
          'duration_ms': duration.inMilliseconds,
          'duration_seconds': duration.inSeconds,
        },
      );

      _addSessionEvent(event);

      final result = await _firebaseAnalytics.logEvent(
        'navigation_performance',
        parameters: {
          'action': action,
          'duration_ms': duration.inMilliseconds,
          'is_slow': duration.inMilliseconds > 1000,
        },
      );
      result.fold(
        (error) => debugPrint('Analytics error: ${error.message}'),
        (_) {},
      );

      debugPrint(
        'Tracked navigation performance: $action (${duration.inMilliseconds}ms)',
      );
    } catch (error) {
      debugPrint('Failed to track navigation performance: $error');
    }
  }

  @override
  Future<void> trackNavigationError(
    String pageType,
    String error,
    Map<String, dynamic>? context,
  ) async {
    try {
      final event = NavigationEvent(
        type: NavigationEventType.error,
        pageType: pageType,
        timestamp: DateTime.now(),
        parameters: {'error': error, 'page_type': pageType, ...?context},
      );

      _addSessionEvent(event);

      final result = await _firebaseAnalytics.logEvent(
        'navigation_error',
        parameters: {'page_type': pageType, 'error': error, ...?context},
      );
      result.fold(
        (error) => debugPrint('Analytics error: ${error.message}'),
        (_) {},
      );

      debugPrint('Tracked navigation error: $pageType - $error');
    } catch (error) {
      debugPrint('Failed to track navigation error: $error');
    }
  }

  @override
  Future<void> trackNavigationPattern(
    String pattern,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final event = NavigationEvent(
        type: NavigationEventType.pattern,
        pageType: pattern,
        timestamp: DateTime.now(),
        parameters: {'pattern': pattern, ...metadata},
      );

      _addSessionEvent(event);

      final result = await _firebaseAnalytics.logEvent(
        'navigation_pattern',
        parameters: {'pattern': pattern, ...metadata},
      );
      result.fold(
        (error) => debugPrint('Analytics error: ${error.message}'),
        (_) {},
      );

      debugPrint('Tracked navigation pattern: $pattern');
    } catch (error) {
      debugPrint('Failed to track navigation pattern: $error');
    }
  }

  @override
  Future<Map<String, dynamic>> getAnalyticsSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final filteredEvents =
          _sessionEvents.where((event) {
            return event.timestamp.isAfter(startDate) &&
                event.timestamp.isBefore(endDate);
          }).toList();
      final summary = <String, dynamic>{
        'date_range': {
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
        'total_events': filteredEvents.length,
        'page_views':
            filteredEvents
                .where((e) => e.type == NavigationEventType.pageView)
                .length,
        'navigation_paths':
            filteredEvents
                .where((e) => e.type == NavigationEventType.navigationPath)
                .length,
        'errors':
            filteredEvents
                .where((e) => e.type == NavigationEventType.error)
                .length,
        'performance_events':
            filteredEvents
                .where((e) => e.type == NavigationEventType.performance)
                .length,
        'most_viewed_pages': _getMostViewedPages(),
        'average_session_length': _calculateAverageSessionLength(
          filteredEvents,
        ),
        'error_rate': _calculateErrorRate(filteredEvents),
      };

      return summary;
    } catch (error) {
      debugPrint('Failed to generate analytics summary: $error');
      return {};
    }
  }

  /// Track page exit and calculate time spent
  Future<void> trackPageExit(String pageType) async {
    try {
      final startTime = _pageStartTimes[pageType];
      if (startTime != null) {
        final timeSpent = DateTime.now().difference(startTime);
        _pageTimings[pageType] = timeSpent;

        final result = await _firebaseAnalytics.logEvent(
          'navigation_page_exit',
          parameters: {
            'page_type': pageType,
            'time_spent_ms': timeSpent.inMilliseconds,
            'time_spent_seconds': timeSpent.inSeconds,
          },
        );
        result.fold(
          (error) => debugPrint('Analytics error: ${error.message}'),
          (_) {},
        );

        _pageStartTimes.remove(pageType);
        debugPrint('Tracked page exit: $pageType (${timeSpent.inSeconds}s)');
      }
    } catch (error) {
      debugPrint('Failed to track page exit: $error');
    }
  }

  /// Track back navigation
  Future<void> trackBackNavigation(String fromPage, String toPage) async {
    try {
      final result = await _firebaseAnalytics.logEvent(
        'navigation_back',
        parameters: {'from_page': fromPage, 'to_page': toPage},
      );
      result.fold(
        (error) => debugPrint('Analytics error: ${error.message}'),
        (_) {},
      );

      debugPrint('Tracked back navigation: $fromPage -> $toPage');
    } catch (error) {
      debugPrint('Failed to track back navigation: $error');
    }
  }

  /// Track navigation funnel step
  Future<void> trackFunnelStep(
    String funnelName,
    String stepName,
    int stepIndex,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      final result = await _firebaseAnalytics.logEvent(
        'navigation_funnel_step',
        parameters: {
          'funnel_name': funnelName,
          'step_name': stepName,
          'step_index': stepIndex,
          ...?metadata,
        },
      );
      result.fold(
        (error) => debugPrint('Analytics error: ${error.message}'),
        (_) {},
      );

      debugPrint('Tracked funnel step: $funnelName - $stepName ($stepIndex)');
    } catch (error) {
      debugPrint('Failed to track funnel step: $error');
    }
  }

  /// Get current session statistics
  Map<String, dynamic> getSessionStats() {
    return {
      'total_events': _sessionEvents.length,
      'unique_pages': _pageViewCounts.keys.length,
      'total_page_views': _pageViewCounts.values.fold(0, (a, b) => a + b),
      'session_duration': _calculateSessionDuration(),
      'most_viewed_page': _getMostViewedPage(),
      'error_count':
          _sessionEvents
              .where((e) => e.type == NavigationEventType.error)
              .length,
    };
  }

  /// Clear session analytics data
  void clearSessionData() {
    _sessionEvents.clear();
    _pageViewCounts.clear();
    _pageTimings.clear();
    _pageStartTimes.clear();
    debugPrint('Navigation analytics session data cleared');
  }

  /// Add event to session with size management
  void _addSessionEvent(NavigationEvent event) {
    _sessionEvents.add(event);
    if (_sessionEvents.length > _maxSessionEvents) {
      _sessionEvents.removeAt(0);
    }
  }

  /// Get most viewed pages in current session
  Map<String, int> _getMostViewedPages() {
    final sorted =
        _pageViewCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(10));
  }

  /// Get most viewed page
  String? _getMostViewedPage() {
    if (_pageViewCounts.isEmpty) return null;

    return _pageViewCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Calculate average session length
  Duration _calculateAverageSessionLength(List<NavigationEvent> events) {
    if (events.isEmpty) return Duration.zero;

    final pageViewEvents =
        events.where((e) => e.type == NavigationEventType.pageView).toList();

    if (pageViewEvents.length < 2) return Duration.zero;

    final firstEvent = pageViewEvents.first;
    final lastEvent = pageViewEvents.last;

    return lastEvent.timestamp.difference(firstEvent.timestamp);
  }

  /// Calculate error rate
  double _calculateErrorRate(List<NavigationEvent> events) {
    if (events.isEmpty) return 0.0;

    final errorCount =
        events.where((e) => e.type == NavigationEventType.error).length;

    return errorCount / events.length;
  }

  /// Calculate current session duration
  Duration _calculateSessionDuration() {
    if (_sessionEvents.isEmpty) return Duration.zero;

    final firstEvent = _sessionEvents.first;
    final lastEvent = _sessionEvents.last;

    return lastEvent.timestamp.difference(firstEvent.timestamp);
  }
}

/// Navigation event types for analytics
enum NavigationEventType {
  pageView,
  navigationPath,
  performance,
  error,
  pattern,
  funnel,
  back,
}

/// Navigation event model
class NavigationEvent {
  final NavigationEventType type;
  final String pageType;
  final DateTime timestamp;
  final Map<String, dynamic>? parameters;

  const NavigationEvent({
    required this.type,
    required this.pageType,
    required this.timestamp,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'pageType': pageType,
      'timestamp': timestamp.toIso8601String(),
      'parameters': parameters,
    };
  }
}
