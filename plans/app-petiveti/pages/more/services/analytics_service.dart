// Flutter imports:
import 'package:flutter/foundation.dart';

enum AnalyticsLevel {
  none('none', 'Nenhum'),
  basic('basic', 'Básico'),
  detailed('detailed', 'Detalhado'),
  full('full', 'Completo');

  const AnalyticsLevel(this.id, this.displayName);
  final String id;
  final String displayName;
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String sessionId;

  const AnalyticsEvent({
    required this.name,
    required this.properties,
    required this.timestamp,
    required this.sessionId,
  });

  AnalyticsEvent copyWith({
    String? name,
    Map<String, dynamic>? properties,
    DateTime? timestamp,
    String? sessionId,
  }) {
    return AnalyticsEvent(
      name: name ?? this.name,
      properties: properties ?? this.properties,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'properties': properties,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
    };
  }

  static AnalyticsEvent fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'] ?? '',
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      sessionId: json['sessionId'] ?? '',
    );
  }

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, timestamp: $timestamp)';
  }
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  AnalyticsLevel _level = AnalyticsLevel.basic;
  String _sessionId = '';
  DateTime _sessionStart = DateTime.now();
  final List<AnalyticsEvent> _eventQueue = [];
  bool _isEnabled = true;

  // Getters
  AnalyticsLevel get level => _level;
  String get sessionId => _sessionId;
  DateTime get sessionStart => _sessionStart;
  bool get isEnabled => _isEnabled;
  int get queuedEventCount => _eventQueue.length;

  void initialize({
    AnalyticsLevel level = AnalyticsLevel.basic,
    bool enabled = true,
  }) {
    _level = level;
    _isEnabled = enabled;
    _sessionId = _generateSessionId();
    _sessionStart = DateTime.now();
    
    if (_isEnabled) {
      debugPrint('AnalyticsService initialized: level=${level.id}, sessionId=$_sessionId');
    }
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    if (!_isEnabled || _level == AnalyticsLevel.none) return;

    final enrichedProperties = <String, dynamic>{
      ...?properties,
      'sessionId': _sessionId,
      'sessionDuration': DateTime.now().difference(_sessionStart).inSeconds,
      'platform': defaultTargetPlatform.name,
    };

    final event = AnalyticsEvent(
      name: eventName,
      properties: enrichedProperties,
      timestamp: DateTime.now(),
      sessionId: _sessionId,
    );

    _eventQueue.add(event);
    
    if (kDebugMode) {
      debugPrint('Analytics: $eventName ${properties?.isNotEmpty == true ? properties : ''}');
    }

    // In a real implementation, you would send events to your analytics provider
    _processEventQueue();
  }

  void trackPageView(String pageName, [Map<String, dynamic>? properties]) {
    trackEvent('page_view', {
      'page_name': pageName,
      ...?properties,
    });
  }

  void trackUserAction(String action, [Map<String, dynamic>? properties]) {
    trackEvent('user_action', {
      'action': action,
      ...?properties,
    });
  }

  void trackError(String error, [Map<String, dynamic>? properties]) {
    trackEvent('error', {
      'error_message': error,
      ...?properties,
    });
  }

  void trackTiming(String name, Duration duration, [Map<String, dynamic>? properties]) {
    trackEvent('timing', {
      'timing_name': name,
      'duration_ms': duration.inMilliseconds,
      'duration_seconds': duration.inSeconds,
      ...?properties,
    });
  }

  void trackFeatureUsage(String feature, [Map<String, dynamic>? properties]) {
    trackEvent('feature_usage', {
      'feature_name': feature,
      ...?properties,
    });
  }

  void trackConversion(String goal, [Map<String, dynamic>? properties]) {
    trackEvent('conversion', {
      'goal': goal,
      ...?properties,
    });
  }

  void setUserProperty(String key, dynamic value) {
    if (!_isEnabled || _level == AnalyticsLevel.none) return;
    
    trackEvent('user_property', {
      'property_key': key,
      'property_value': value,
    });
  }

  void setUserProperties(Map<String, dynamic> properties) {
    if (!_isEnabled || _level == AnalyticsLevel.none) return;
    
    for (final entry in properties.entries) {
      setUserProperty(entry.key, entry.value);
    }
  }

  void startSession() {
    _sessionId = _generateSessionId();
    _sessionStart = DateTime.now();
    
    trackEvent('session_start', {
      'previous_session_duration': DateTime.now().difference(_sessionStart).inSeconds,
    });
  }

  void endSession() {
    trackEvent('session_end', {
      'session_duration': DateTime.now().difference(_sessionStart).inSeconds,
      'events_in_session': _eventQueue.where((e) => e.sessionId == _sessionId).length,
    });
  }

  void _processEventQueue() {
    if (_eventQueue.isEmpty) return;
    
    switch (_level) {
      case AnalyticsLevel.none:
        _eventQueue.clear();
        break;
      case AnalyticsLevel.basic:
        _processBatchEvents();
        break;
      case AnalyticsLevel.detailed:
      case AnalyticsLevel.full:
        _processImmediateEvents();
        break;
    }
  }

  void _processBatchEvents() {
    // In a real implementation, batch events and send periodically
    if (_eventQueue.length >= 10) {
      _sendEvents(_eventQueue.toList());
      _eventQueue.clear();
    }
  }

  void _processImmediateEvents() {
    // In a real implementation, send events immediately
    if (_eventQueue.isNotEmpty) {
      _sendEvents(_eventQueue.toList());
      _eventQueue.clear();
    }
  }

  void _sendEvents(List<AnalyticsEvent> events) {
    // In a real implementation, send to analytics provider
    if (kDebugMode) {
      debugPrint('Analytics: Sending ${events.length} events');
      for (final event in events) {
        debugPrint('  - ${event.name}: ${event.properties}');
      }
    }
  }

  void flushEvents() {
    if (_eventQueue.isNotEmpty) {
      _sendEvents(_eventQueue.toList());
      _eventQueue.clear();
    }
  }

  Map<String, dynamic> getSessionInfo() {
    return {
      'sessionId': _sessionId,
      'sessionStart': _sessionStart.toIso8601String(),
      'sessionDuration': DateTime.now().difference(_sessionStart).inSeconds,
      'level': _level.id,
      'isEnabled': _isEnabled,
      'queuedEvents': _eventQueue.length,
    };
  }

  Map<String, dynamic> getAnalyticsStatistics() {
    final eventsByName = <String, int>{};
    for (final event in _eventQueue) {
      eventsByName[event.name] = (eventsByName[event.name] ?? 0) + 1;
    }

    return {
      'totalEvents': _eventQueue.length,
      'sessionDuration': DateTime.now().difference(_sessionStart).inSeconds,
      'eventsByName': eventsByName,
      'level': _level.id,
      'isEnabled': _isEnabled,
      'sessionId': _sessionId,
    };
  }

  void setLevel(AnalyticsLevel level) {
    _level = level;
    trackEvent('analytics_level_changed', {'new_level': level.id});
  }

  void enable() {
    _isEnabled = true;
    trackEvent('analytics_enabled');
  }

  void disable() {
    trackEvent('analytics_disabled');
    _isEnabled = false;
    _eventQueue.clear();
  }

  void reset() {
    _eventQueue.clear();
    _sessionId = _generateSessionId();
    _sessionStart = DateTime.now();
    trackEvent('analytics_reset');
  }

  List<AnalyticsEvent> getRecentEvents({int limit = 50}) {
    return _eventQueue.reversed.take(limit).toList();
  }

  List<AnalyticsEvent> getEventsByName(String eventName) {
    return _eventQueue.where((event) => event.name == eventName).toList();
  }

  bool hasEvent(String eventName) {
    return _eventQueue.any((event) => event.name == eventName);
  }

  int getEventCount(String eventName) {
    return _eventQueue.where((event) => event.name == eventName).length;
  }

  static List<AnalyticsLevel> getAvailableLevels() {
    return AnalyticsLevel.values;
  }

  static String getLevelDisplayName(AnalyticsLevel level) {
    return level.displayName;
  }
}
